const API = "";  // same origin; change to backend URL if serving separately
const SESSION_KEY = "krali4_session_id";

let countdownTimer = null;

function el(id) { return document.getElementById(id); }

function formatTime(seconds) {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = seconds % 60;
    return `${h}h ${String(m).padStart(2, "0")}m ${String(s).padStart(2, "0")}s`;
}

function showSSHInfo(data) {
    el("ch-start-btn").style.display = "none";
    el("ch-info").style.display = "block";
    el("ch-cmd").textContent = data.ssh_command;
    el("ch-password").textContent = data.ssh_password;
    startCountdown(data.time_remaining);
}

function hideSSHInfo() {
    el("ch-start-btn").style.display = "inline-block";
    el("ch-info").style.display = "none";
    el("ch-countdown").textContent = "";
    if (countdownTimer) { clearInterval(countdownTimer); countdownTimer = null; }
}

function startCountdown(seconds) {
    let remaining = seconds;
    el("ch-countdown").textContent = formatTime(remaining);
    if (countdownTimer) clearInterval(countdownTimer);
    countdownTimer = setInterval(() => {
        remaining--;
        if (remaining <= 0) {
            clearInterval(countdownTimer);
            hideSSHInfo();
            localStorage.removeItem(SESSION_KEY);
            setStatus("Session expired.");
        } else {
            el("ch-countdown").textContent = formatTime(remaining);
        }
    }, 1000);
}

function setStatus(msg, isError = false) {
    const s = el("ch-status");
    s.textContent = msg;
    s.style.color = isError ? "#dd4444" : "#555";
}

async function startSession() {
    setStatus("Starting session...");
    el("ch-start-btn").disabled = true;
    try {
        const res = await fetch(`${API}/api/sessions`, { method: "POST" });
        const data = await res.json();
        if (!res.ok) { throw new Error(data.detail ?? `HTTP ${res.status}`); }
        localStorage.setItem(SESSION_KEY, data.session_id);
        showSSHInfo(data);
        setStatus("");
    } catch (e) {
        setStatus(e.message, true);
    } finally {
        el("ch-start-btn").disabled = false;
    }
}

async function stopSession() {
    const id = localStorage.getItem(SESSION_KEY);
    if (!id) { hideSSHInfo(); return; }
    setStatus("Stopping session...");
    el("ch-stop-btn").disabled = true;
    try {
        await fetch(`${API}/api/sessions/${id}`, { method: "DELETE" });
    } catch (_) {}
    localStorage.removeItem(SESSION_KEY);
    hideSSHInfo();
    setStatus("");
    el("ch-stop-btn").disabled = false;
}

async function restoreSession() {
    const id = localStorage.getItem(SESSION_KEY);
    if (!id) return;
    try {
        const res = await fetch(`${API}/api/sessions/${id}`);
        if (!res.ok) { localStorage.removeItem(SESSION_KEY); return; }
        const data = await res.json();
        showSSHInfo(data);
    } catch (_) {
        localStorage.removeItem(SESSION_KEY);
    }
}

document.addEventListener("DOMContentLoaded", () => {
    el("ch-start-btn").addEventListener("click", startSession);
    el("ch-stop-btn").addEventListener("click", stopSession);
    restoreSession();
});
