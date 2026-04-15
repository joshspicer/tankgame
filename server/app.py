"""
Tank Battle — FastAPI WebSocket server.

This is the uvicorn entrypoint. It imports game logic from game_server.py
and runs the authoritative multiplayer game loop.

Run locally: uvicorn server.app:app --host 0.0.0.0 --port 8000
"""

import asyncio
import json
import random
import time
import uuid

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import JSONResponse

# Import game logic — works both locally (from server.game_server)
# and in Modal container (from game_server, since /root is in sys.path)
try:
    from server.game_server import (
        Direction, GameState, Map, SeededRNG,
        Tank, Projectile, HitInfo, PlayerData,
        ClientMessage, ClientMessageType,
        ServerMessageType, server_msg,
        welcome_msg, state_update_msg,
        player_joined_msg, player_left_msg,
        hit_msg, respawn_msg, error_msg,
    )
except ImportError:
    import sys
    sys.path.insert(0, "/root")
    from game_server import (
        Direction, GameState, Map, SeededRNG,
        Tank, Projectile, HitInfo, PlayerData,
        ClientMessage, ClientMessageType,
        ServerMessageType, server_msg,
        welcome_msg, state_update_msg,
        player_joined_msg, player_left_msg,
        hit_msg, respawn_msg, error_msg,
    )

# ===== Shared State =====

TICK_RATE = 0.05  # 50ms = 20 ticks/sec

seed = random.randint(0, 0xFFFFFFFF)
state = GameState(seed=seed, grid_size=8)
conns: dict[str, WebSocket] = {}
q: asyncio.Queue = asyncio.Queue()
loop_started = False

print(f"[Server] Initialized with map seed {seed}")


# ===== Helpers =====

async def broadcast(msg: str, exclude: str | None = None):
    bad = []
    for pid, ws in conns.items():
        if pid == exclude:
            continue
        try:
            await ws.send_text(msg)
        except Exception:
            bad.append(pid)
    for pid in bad:
        conns.pop(pid, None)
        state.remove_player(pid)


async def game_loop():
    """Server-authoritative game loop at 20 ticks/sec."""
    while True:
        t0 = time.monotonic()

        # Process queued inputs
        while not q.empty():
            try:
                pid, m = q.get_nowait()
            except asyncio.QueueEmpty:
                break
            if m.type == ClientMessageType.MOVE and m.direction is not None:
                try:
                    state.move_player(pid, Direction(m.direction))
                except (ValueError, KeyError):
                    pass
            elif m.type == ClientMessageType.SHOOT:
                state.shoot(pid)

        # Update projectiles
        if state.projectiles:
            hits = state.update_projectiles()
            for h in hits:
                await broadcast(hit_msg(h.victim_id, h.shooter_id))
                state.schedule_respawn(h.victim_id)

        # Check respawns
        for pid, row, col, d in state.check_respawns():
            await broadcast(respawn_msg(pid, row, col, d.value))

        # Broadcast state to all players
        if conns:
            await broadcast(state_update_msg(state.to_world_state()))

        dt = time.monotonic() - t0
        await asyncio.sleep(max(0, TICK_RATE - dt))


# ===== FastAPI App =====

app = FastAPI()


@app.get("/health")
async def health():
    return JSONResponse({
        "status": "ok",
        "players": len(conns),
        "mapSeed": state.map.seed,
        "gridSize": state.grid_size,
    })


@app.websocket("/ws")
async def ws_endpoint(ws: WebSocket):
    global loop_started

    await ws.accept()
    pid = str(uuid.uuid4())
    joined = False

    try:
        raw = await asyncio.wait_for(ws.receive_text(), timeout=10.0)
        msg = ClientMessage.parse(raw)
        if msg.type != ClientMessageType.JOIN:
            await ws.send_text(error_msg("First message must be 'join'"))
            return

        name = msg.display_name or f"Tank-{pid[:4]}"
        tank = state.add_player(pid, name)
        if tank is None:
            await ws.send_text(error_msg("Failed to join"))
            return

        joined = True
        conns[pid] = ws

        # Start game loop on first player connection
        if not loop_started:
            loop_started = True
            asyncio.create_task(game_loop())
            print("[Server] Game loop started")

        print(f"[Server] {name} ({pid[:8]}) joined. Total: {len(conns)}")
        await ws.send_text(welcome_msg(pid, state.to_world_state()))
        await broadcast(player_joined_msg(pid, name), exclude=pid)

        # Receive loop
        while True:
            raw = await ws.receive_text()
            await q.put((pid, ClientMessage.parse(raw)))

    except WebSocketDisconnect:
        pass
    except asyncio.TimeoutError:
        pass
    except asyncio.CancelledError:
        pass
    except Exception as e:
        print(f"[Server] Error for {pid[:8]}: {e}")
    finally:
        if joined:
            conns.pop(pid, None)
            state.remove_player(pid)
            print(f"[Server] {pid[:8]} left. Total: {len(conns)}")
            await broadcast(player_left_msg(pid))
