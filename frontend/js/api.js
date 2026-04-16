import { API, SESSION_STORAGE_KEY, state } from "./state.js";

export function ensureSessionId() {
  let id = localStorage.getItem(SESSION_STORAGE_KEY);
  if (!id) {
    if (typeof crypto !== "undefined" && crypto.randomUUID) {
      id = crypto.randomUUID();
    } else {
      id = `s-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
    }
    localStorage.setItem(SESSION_STORAGE_KEY, id);
  }
  state.sessionId = id;
}

function requestHeaders(includeJson = false) {
  const headers = {
    "X-Session-Id": state.sessionId,
  };
  if (includeJson) {
    headers["Content-Type"] = "application/json";
  }
  return headers;
}

export async function fetchSessionMetadata() {
  const response = await fetch(`${API}/api/session`, { headers: requestHeaders() });
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }
  return response.json();
}

export async function postCommand(command) {
  const response = await fetch(`${API}/api/execute`, {
    method: "POST",
    headers: requestHeaders(true),
    body: JSON.stringify({ command }),
  });

  if (!response.ok) {
    const payload = await response.json().catch(() => ({}));
    throw new Error(payload.detail ?? `HTTP ${response.status}`);
  }

  return response.json();
}

export async function postReset() {
  const response = await fetch(`${API}/api/reset`, {
    method: "POST",
    headers: requestHeaders(),
  });
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }
  return response.json();
}

export function persistSessionId(sessionId) {
  state.sessionId = sessionId;
  localStorage.setItem(SESSION_STORAGE_KEY, sessionId);
}
