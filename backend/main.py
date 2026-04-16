import asyncio
import os
import time
import uuid
from contextlib import asynccontextmanager
from typing import Dict

import docker
import docker.errors
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

# ── Config ────────────────────────────────────────────────────────────────────

CHALLENGE_IMAGE = os.getenv("CHALLENGE_IMAGE", "krali4-challenge")
HOST_IP = os.getenv("HOST_IP", "localhost")
SESSION_TTL = int(os.getenv("SESSION_TTL", "7200"))  # seconds
CHALLENGE_NETWORK = "krali4-challenge-net"

# ── State ─────────────────────────────────────────────────────────────────────

sessions: Dict[str, dict] = {}
docker_client = docker.from_env()

# ── Rate limiting ─────────────────────────────────────────────────────────────

limiter = Limiter(key_func=get_remote_address)


# ── Lifespan ──────────────────────────────────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI):
    _ensure_challenge_network()
    _cleanup_orphans()
    task = asyncio.create_task(_cleanup_loop())
    yield
    task.cancel()


def _cleanup_orphans():
    """Remove challenge containers left over from a previous backend run."""
    try:
        orphans = docker_client.containers.list(filters={"label": "app=krali4"})
        for c in orphans:
            print(f"[startup] removing orphan container {c.name}")
            c.remove(force=True)
    except Exception as exc:
        print(f"[startup] orphan cleanup error: {exc}")


def _ensure_challenge_network():
    try:
        docker_client.networks.get(CHALLENGE_NETWORK)
    except docker.errors.NotFound:
        # Standard bridge so host port-publishing works.
        # Egress blocking is handled by K8s NetworkPolicy in production.
        docker_client.networks.create(
            CHALLENGE_NETWORK,
            driver="bridge",
            labels={"app": "krali4"},
        )


# ── App ───────────────────────────────────────────────────────────────────────

app = FastAPI(lifespan=lifespan)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET", "POST", "DELETE"],
    allow_headers=["*"],
)


# ── Helpers ───────────────────────────────────────────────────────────────────

def _active_session_for_ip(ip: str) -> dict | None:
    now = time.time()
    for s in sessions.values():
        if s["ip"] == ip and s["expires_at"] > now:
            return s
    return None


async def _destroy(session_id: str):
    s = sessions.pop(session_id, None)
    if not s:
        return
    try:
        c = docker_client.containers.get(s["container_id"])
        c.remove(force=True)
    except docker.errors.NotFound:
        pass
    except Exception as exc:
        print(f"[cleanup] error removing container for {session_id}: {exc}")


async def _cleanup_loop():
    while True:
        await asyncio.sleep(60)
        now = time.time()
        expired = [sid for sid, s in list(sessions.items()) if s["expires_at"] <= now]
        for sid in expired:
            print(f"[cleanup] expiring session {sid}")
            await _destroy(sid)


def _session_response(session_id: str, s: dict) -> dict:
    return {
        "session_id": session_id,
        "ssh_host": HOST_IP,
        "ssh_port": s["port"],
        "ssh_user": "level0",
        "ssh_password": "level0",
        "ssh_command": f"ssh level0@{HOST_IP} -p {s['port']}",
        "expires_at": s["expires_at"],
        "time_remaining": max(0, int(s["expires_at"] - time.time())),
    }


# ── Routes ────────────────────────────────────────────────────────────────────

RATE_LIMIT = os.getenv("RATE_LIMIT", "3/hour")

@app.post("/api/sessions")
@limiter.limit(RATE_LIMIT)
async def create_session(request: Request):
    client_ip = get_remote_address(request)

    existing = _active_session_for_ip(client_ip)
    if existing:
        raise HTTPException(
            status_code=409,
            detail="You already have an active session. Stop it before starting a new one.",
        )

    session_id = str(uuid.uuid4())

    try:
        container = docker_client.containers.run(
            CHALLENGE_IMAGE,
            detach=True,
            ports={"22/tcp": None},  # Docker assigns a random host port
            network=CHALLENGE_NETWORK,
            # Resource limits
            mem_limit="128m",
            memswap_limit="128m",  # disables swap
            cpu_quota=50000,       # 0.5 CPU (out of 100000)
            pids_limit=100,
            # Hardening
            security_opt=["no-new-privileges:true"],
            cap_drop=["ALL"],
            cap_add=["SETUID", "SETGID", "CHOWN", "DAC_OVERRIDE", "NET_BIND_SERVICE", "SYS_CHROOT", "AUDIT_WRITE"],
            # Ephemeral storage limit (requires overlay2 with xfs quota or similar)
            # storage_opt={"size": "100M"},
            name=f"krali4-{session_id[:8]}",
            labels={"session_id": session_id, "app": "krali4"},
        )
    except docker.errors.ImageNotFound:
        raise HTTPException(
            status_code=500,
            detail=f"Challenge image '{CHALLENGE_IMAGE}' not found. Run: docker build -t {CHALLENGE_IMAGE} ./challenge",
        )
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))

    container.reload()
    port_bindings = container.ports.get("22/tcp")
    if not port_bindings:
        container.remove(force=True)
        raise HTTPException(status_code=500, detail="Container started but port was not bound.")

    port = int(port_bindings[0]["HostPort"])
    expires_at = time.time() + SESSION_TTL

    sessions[session_id] = {
        "container_id": container.id,
        "port": port,
        "ip": client_ip,
        "created_at": time.time(),
        "expires_at": expires_at,
    }

    return _session_response(session_id, sessions[session_id])


@app.get("/api/sessions/{session_id}")
async def get_session(session_id: str):
    s = sessions.get(session_id)
    if not s:
        raise HTTPException(status_code=404, detail="Session not found or expired.")
    if s["expires_at"] <= time.time():
        await _destroy(session_id)
        raise HTTPException(status_code=404, detail="Session expired.")
    return _session_response(session_id, s)


@app.delete("/api/sessions/{session_id}")
async def delete_session(session_id: str, request: Request):
    s = sessions.get(session_id)
    if not s:
        raise HTTPException(status_code=404, detail="Session not found.")
    # Only the originating IP can delete the session
    if s["ip"] != get_remote_address(request):
        raise HTTPException(status_code=403, detail="Not your session.")
    await _destroy(session_id)
    return {"status": "deleted"}


@app.get("/api/health")
async def health():
    return {"status": "ok", "sessions": len(sessions)}
