import { elements, state } from "./state.js";

export function cacheElements() {
  elements.output = document.getElementById("terminalOutput");
  elements.form = document.getElementById("commandForm");
  elements.input = document.getElementById("commandInput");
  elements.promptLabel = document.getElementById("promptLabel");
  elements.promptPreview = document.getElementById("promptPreview");
  elements.shortcutRack = document.getElementById("shortcutRack");
  elements.statusText = document.getElementById("statusText");
  elements.shell = document.getElementById("terminalShell");
  elements.connectionBadge = document.getElementById("connectionBadge");
  elements.connectionMeta = document.getElementById("connectionMeta");
  elements.connectionUptime = document.getElementById("connectionUptime");
}

export function setConnectionState(connected, target = "", since = "") {
  state.connected = Boolean(connected);
  state.connectionTarget = target || "";
  state.connectionSince = since || "";

  if (elements.connectionBadge) {
    elements.connectionBadge.textContent = state.connected ? "CONNECTED" : "DISCONNECTED";
    elements.connectionBadge.dataset.connected = state.connected ? "true" : "false";
  }

  if (elements.connectionMeta) {
    elements.connectionMeta.textContent = state.connected
      ? `${state.connectionTarget || "simulated-host"}`
      : "unknown";
  }
}

export function setConnectionUptime(text) {
  if (elements.connectionUptime) {
    elements.connectionUptime.textContent = text;
  }
}

export function setPrompt(prompt) {
  state.prompt = prompt;
  if (elements.promptLabel) elements.promptLabel.textContent = prompt;
  if (elements.promptPreview) elements.promptPreview.textContent = prompt;
}

export function setStatus(text) {
  if (elements.statusText) {
    elements.statusText.textContent = text;
  }
}

export function scrollOutputToBottom() {
  if (elements.output) {
    elements.output.scrollTop = elements.output.scrollHeight;
  }
}

export function appendEntry(type, text, prompt = state.prompt) {
  if (!elements.output) {
    return null;
  }

  const entry = document.createElement("div");
  entry.className = `entry ${type}`;

  if (type === "command") {
    const promptEl = document.createElement("span");
    promptEl.className = "prompt";
    promptEl.textContent = prompt;

    const commandEl = document.createElement("span");
    commandEl.className = "command-text";
    commandEl.textContent = text;

    entry.append(promptEl, commandEl);
  } else {
    entry.textContent = text;
  }

  elements.output.appendChild(entry);
  scrollOutputToBottom();
  return entry;
}

export function clearOutput() {
  if (elements.output) {
    elements.output.textContent = "";
  }
}

export function renderShortcuts(onClickCommand) {
  if (!elements.shortcutRack) {
    return;
  }

  elements.shortcutRack.textContent = "";
  state.suggestions.forEach((command) => {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "shortcut";
    button.textContent = command;
    button.addEventListener("click", () => onClickCommand(command));
    elements.shortcutRack.appendChild(button);
  });
}

export function renderBoot(lines) {
  lines.forEach((line) => appendEntry("system", line));
}

export function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export function chunkText(text, chunkSize = 28) {
  const chunks = [];
  const lines = text.split("\n");
  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i];
    if (!line.length) {
      chunks.push("\n");
      continue;
    }

    for (let j = 0; j < line.length; j += chunkSize) {
      chunks.push(line.slice(j, j + chunkSize));
    }

    if (i < lines.length - 1) {
      chunks[chunks.length - 1] += "\n";
    }
  }
  return chunks;
}

export function resolveChunks(result) {
  if (Array.isArray(result.stream_chunks) && result.stream_chunks.length > 1) {
    return result.stream_chunks;
  }

  const output = String(result.output ?? "");
  if (!output) {
    return [];
  }

  if (output.length <= 40) {
    return [output];
  }

  return chunkText(output, output.length > 320 ? 24 : 32);
}

export function computeStepMs(chunks, latencyMs) {
  const totalChars = chunks.reduce((sum, part) => sum + part.length, 0);
  if (totalChars <= 60) return 12;
  if (totalChars <= 180) return 16;
  if (totalChars <= 360) return 20;

  const adjusted = Math.round((latencyMs || 90) / 8);
  return Math.max(10, Math.min(32, adjusted));
}

export async function appendStreamedOutput(chunks, stepMs = 24) {
  const entry = appendEntry("output", "");
  if (!entry) {
    return;
  }

  setStatus("Rendering output...");

  for (const chunk of chunks) {
    entry.textContent += chunk;
    scrollOutputToBottom();
    await sleep(stepMs);
  }
}

export function autocompleteInput() {
  const current = elements.input?.value.trimStart() ?? "";
  if (!current) {
    return;
  }

  const candidates = state.commands.filter((command) => command.startsWith(current));
  if (candidates.length === 1 && elements.input) {
    elements.input.value = candidates[0].replace(" <name>", " ").replace(" <file>", " ");
  }
}
