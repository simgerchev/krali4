import { ensureSessionId, fetchSessionMetadata, persistSessionId, postCommand, postReset } from "./api.js";
import { elements, fallbackSession, state } from "./state.js";
import {
  appendEntry,
  appendStreamedOutput,
  autocompleteInput,
  cacheElements,
  clearOutput,
  computeStepMs,
  renderBoot,
  renderShortcuts,
  resolveChunks,
  setPrompt,
  setConnectionState,
  setConnectionUptime,
  setStatus,
  sleep,
} from "./ui.js";

let uptimeTimerId = null;

function stopUptimeTimer() {
  if (uptimeTimerId !== null) {
    clearInterval(uptimeTimerId);
    uptimeTimerId = null;
  }
}

function formatDuration(totalSeconds) {
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;

  if (hours > 0) {
    return `${String(hours).padStart(2, "0")}:${String(minutes).padStart(2, "0")}:${String(seconds).padStart(2, "0")}`;
  }

  return `${String(minutes).padStart(2, "0")}:${String(seconds).padStart(2, "0")}`;
}

function refreshUptime() {
  if (!state.connected) {
    setConnectionUptime("Uptime: --");
    return;
  }

  const startedAtMs = Date.parse(state.connectionSince || "");
  if (Number.isNaN(startedAtMs)) {
    setConnectionUptime("Uptime: --");
    return;
  }

  const elapsedSeconds = Math.max(0, Math.floor((Date.now() - startedAtMs) / 1000));
  setConnectionUptime(`Uptime: ${formatDuration(elapsedSeconds)}`);
}

function syncConnectionUi(connected, target, since) {
  setConnectionState(connected, target, since);
  stopUptimeTimer();
  refreshUptime();

  if (state.connected) {
    uptimeTimerId = setInterval(refreshUptime, 1000);
  }
}

function setInputMode(mode) {
  if (mode === "password") {
    state.inputMode = "password";
  } else if (mode === "track") {
    state.inputMode = "track";
  } else {
    state.inputMode = "text";
  }
  if (elements.input) {
    elements.input.type = state.inputMode === "password" ? "password" : "text";
    if (state.inputMode === "password") {
      elements.input.placeholder = "enter password";
    } else if (state.inputMode === "track") {
      elements.input.placeholder = "1, 2, or 3";
    } else {
      elements.input.placeholder = "Try: cat README, ls -la, find / -name '*token*'";
    }
  }
}

async function loadSession() {
  try {
    const session = await fetchSessionMetadata();
    if (session.session_id) {
      persistSessionId(session.session_id);
    }

    state.suggestions = session.suggestions ?? fallbackSession.suggestions;
    state.commands = session.commands ?? fallbackSession.commands;
    setPrompt(session.prompt ?? fallbackSession.prompt);
    setInputMode(session.input_mode ?? fallbackSession.input_mode);
    syncConnectionUi(
      session.connected ?? fallbackSession.connected,
      session.connection_target ?? fallbackSession.connection_target,
      session.connection_since ?? fallbackSession.connection_since,
    );
    renderShortcuts(runCommand);
    renderBoot(session.boot_lines ?? fallbackSession.boot_lines);
    setStatus("Ready");
  } catch (error) {
    setPrompt(fallbackSession.prompt);
    setInputMode(fallbackSession.input_mode);
    syncConnectionUi(
      fallbackSession.connected,
      fallbackSession.connection_target,
      fallbackSession.connection_since,
    );
    renderShortcuts(runCommand);
    renderBoot(fallbackSession.boot_lines);
    appendEntry("error", `Could not load live session metadata: ${error.message}`);
    setStatus("Offline mode");
  }
}

async function runCommand(command) {
  const trimmed = command.trim();
  if (!trimmed) {
    return;
  }

  const silentMode = state.inputMode === "password" || state.inputMode === "track";
  if (!silentMode) {
    appendEntry("command", trimmed);
    state.history.push(trimmed);
    state.historyIndex = state.history.length;
  }

  if (elements.input) {
    elements.input.value = "";
    elements.input.focus();
  }

  setStatus(silentMode ? "Authenticating..." : "Executing...");

  try {
    const result = await postCommand(trimmed);

    if (result.prompt) {
      setPrompt(result.prompt);
    }
    setInputMode(result.input_mode ?? "text");

    syncConnectionUi(
      result.connected ?? state.connected,
      result.connection_target ?? state.connectionTarget,
      result.connection_since ?? state.connectionSince,
    );

    const latencyMs = Number(result.latency_ms ?? 0);
    if (latencyMs > 0) {
      await sleep(latencyMs);
    }

    if (result.clear) {
      clearOutput();
      setStatus("Cleared");
      return;
    }

    const chunks = resolveChunks(result);
    if (chunks.length > 1) {
      await appendStreamedOutput(chunks, computeStepMs(chunks, latencyMs));
    } else if (chunks.length === 1) {
      appendEntry("output", chunks[0]);
    }

    setStatus("Done");
  } catch (error) {
    appendEntry("error", `Request failed: ${error.message}`);
    setStatus("Failed");
  }
}

function handleHistoryNavigation(event) {
  if (!elements.input) {
    return;
  }

  if (state.inputMode === "password" || state.inputMode === "track") {
    if (["ArrowUp", "ArrowDown", "Tab"].includes(event.key)) {
      event.preventDefault();
    }
    return;
  }

  if (event.key === "ArrowUp") {
    event.preventDefault();
    if (state.historyIndex > 0) {
      state.historyIndex -= 1;
      elements.input.value = state.history[state.historyIndex] ?? "";
    }
  } else if (event.key === "ArrowDown") {
    event.preventDefault();
    if (state.historyIndex < state.history.length - 1) {
      state.historyIndex += 1;
      elements.input.value = state.history[state.historyIndex] ?? "";
    } else {
      state.historyIndex = state.history.length;
      elements.input.value = "";
    }
  } else if (event.key === "Tab") {
    event.preventDefault();
    autocompleteInput();
  }
}

async function resetChallenge() {
  setStatus("Generating new challenge...");
  try {
    const session = await postReset();
    clearOutput();
    setPrompt(session.prompt ?? fallbackSession.prompt);
    setInputMode(session.input_mode ?? "text");
    syncConnectionUi(false, "", "");
    renderShortcuts(runCommand);
    renderBoot(session.boot_lines ?? fallbackSession.boot_lines);
    state.history = [];
    state.historyIndex = 0;
    setStatus("Ready");
  } catch (error) {
    appendEntry("error", `Reset failed: ${error.message}`);
    setStatus("Failed");
  }
  elements.input?.focus();
}

function bindEvents() {
  elements.form?.addEventListener("submit", (event) => {
    event.preventDefault();
    runCommand(elements.input?.value ?? "");
  });

  elements.input?.addEventListener("keydown", handleHistoryNavigation);
  elements.output?.addEventListener("click", () => elements.input?.focus());

}

export async function initTerminalApp() {
  cacheElements();
  ensureSessionId();
  bindEvents();
  await loadSession();
  elements.input?.focus();
}
