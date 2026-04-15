"""
Tank Battle — FastAPI WebSocket server.

This is the uvicorn entrypoint. It imports game logic from game_server.py
and runs the authoritative multiplayer game loop.

Run locally: uvicorn server.app:app --host 0.0.0.0 --port 8000
"""

import asyncio
import json
import logging
import random
import time
import uuid

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import JSONResponse

# ===== Logging Setup =====

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger("tankgame")
log.setLevel(logging.INFO)

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
player_names: dict[str, str] = {}  # pid -> display name for logging
q: asyncio.Queue = asyncio.Queue()
loop_started = False
tick_count = 0
server_start_time = time.time()

log.info("=== TANK BATTLE SERVER STARTING ===")
log.info(f"Map seed={seed} gridSize={state.grid_size}")
log.info(f"Tick rate={TICK_RATE}s ({1/TICK_RATE:.0f} ticks/sec)")


# ===== Helpers =====

def _player_tag(pid: str) -> str:
    """Short player identifier for logs: 'PlayerName(abcd1234)'."""
    name = player_names.get(pid, "???")
    return f"{name}({pid[:8]})"


async def broadcast(msg: str, exclude: str | None = None):
    bad = []
    for pid, ws in conns.items():
        if pid == exclude:
            continue
        try:
            await ws.send_text(msg)
        except Exception as e:
            log.warning(f"SEND_FAIL player={_player_tag(pid)} error={e}")
            bad.append(pid)
    for pid in bad:
        log.info(f"DISCONNECT_STALE player={_player_tag(pid)} reason=send_failure")
        player_names.pop(pid, None)
        conns.pop(pid, None)
        state.remove_player(pid)


async def game_loop():
    """Server-authoritative game loop at 20 ticks/sec."""
    global tick_count
    log.info("GAME_LOOP_START")

    while True:
        t0 = time.monotonic()
        tick_count += 1

        # Process queued inputs
        inputs_processed = 0
        while not q.empty():
            try:
                pid, m = q.get_nowait()
            except asyncio.QueueEmpty:
                break
            inputs_processed += 1
            if m.type == ClientMessageType.MOVE and m.direction is not None:
                try:
                    d = Direction(m.direction)
                    moved = state.move_player(pid, d)
                    if moved:
                        t = state.players[pid].tank
                        log.debug(f"MOVE player={_player_tag(pid)} dir={d.name} pos=({t.row},{t.col})")
                except (ValueError, KeyError):
                    log.warning(f"MOVE_INVALID player={_player_tag(pid)} dir={m.direction}")
            elif m.type == ClientMessageType.SHOOT:
                proj = state.shoot(pid)
                if proj:
                    log.info(f"SHOOT player={_player_tag(pid)} proj_pos=({proj.row},{proj.col}) dir={proj.direction.name}")
                else:
                    log.debug(f"SHOOT_BLOCKED player={_player_tag(pid)}")

        # Update projectiles
        if state.projectiles:
            hits = state.update_projectiles()
            for h in hits:
                log.info(f"HIT victim={_player_tag(h.victim_id)} shooter={_player_tag(h.shooter_id)} "
                         f"shooter_score={state.players.get(h.shooter_id, PlayerData(Tank(0,0,Direction.UP))).score}")
                await broadcast(hit_msg(h.victim_id, h.shooter_id))
                state.schedule_respawn(h.victim_id)

        # Check respawns
        for pid, row, col, d in state.check_respawns():
            log.info(f"RESPAWN player={_player_tag(pid)} pos=({row},{col}) dir={d.name}")
            await broadcast(respawn_msg(pid, row, col, d.value))

        # Broadcast state to all players
        if conns:
            await broadcast(state_update_msg(state.to_world_state()))

        # Periodic status log (every 10 seconds = ~200 ticks)
        if tick_count % 200 == 0:
            uptime = time.time() - server_start_time
            proj_count = len(state.projectiles)
            alive = sum(1 for pd in state.players.values() if pd.tank.is_alive)
            log.info(f"STATUS tick={tick_count} uptime={uptime:.0f}s players={len(conns)} "
                     f"alive={alive} projectiles={proj_count} "
                     f"scores={{{', '.join(f'{_player_tag(pid)}:{pd.score}' for pid, pd in state.players.items())}}}")

        dt = time.monotonic() - t0
        await asyncio.sleep(max(0, TICK_RATE - dt))


# ===== FastAPI App =====

app = FastAPI()


@app.get("/health")
async def health():
    uptime = time.time() - server_start_time
    log.info(f"HEALTH_CHECK players={len(conns)} uptime={uptime:.0f}s tick={tick_count}")
    return JSONResponse({
        "status": "ok",
        "players": len(conns),
        "mapSeed": state.map.seed,
        "gridSize": state.grid_size,
        "uptime": round(uptime),
        "tick": tick_count,
        "playerList": [
            {"id": pid[:8], "name": player_names.get(pid, "?"), "score": pd.score, "alive": pd.tank.is_alive}
            for pid, pd in state.players.items()
        ],
    })


@app.websocket("/ws")
async def ws_endpoint(ws: WebSocket):
    global loop_started

    await ws.accept()
    pid = str(uuid.uuid4())
    joined = False

    client_host = ws.client.host if ws.client else "unknown"
    log.info(f"WS_CONNECT pid={pid[:8]} client={client_host}")

    try:
        raw = await asyncio.wait_for(ws.receive_text(), timeout=10.0)
        msg = ClientMessage.parse(raw)

        if msg.type != ClientMessageType.JOIN:
            log.warning(f"WS_REJECT pid={pid[:8]} reason=first_msg_not_join got={msg.type}")
            await ws.send_text(error_msg("First message must be 'join'"))
            return

        name = msg.display_name or f"Tank-{pid[:4]}"
        tank = state.add_player(pid, name)

        if tank is None:
            log.error(f"JOIN_FAIL pid={pid[:8]} name={name} reason=add_player_returned_none")
            await ws.send_text(error_msg("Failed to join"))
            return

        joined = True
        conns[pid] = ws
        player_names[pid] = name

        # Start game loop on first player connection
        if not loop_started:
            loop_started = True
            asyncio.create_task(game_loop())
            log.info("GAME_LOOP_STARTED triggered by first player join")

        log.info(f"JOIN player={_player_tag(pid)} pos=({tank.row},{tank.col}) dir={tank.direction.name} "
                 f"total_players={len(conns)} client={client_host}")

        await ws.send_text(welcome_msg(pid, state.to_world_state()))
        log.info(f"WELCOME_SENT player={_player_tag(pid)} world_players={len(state.players)} "
                 f"map_seed={state.map.seed}")

        await broadcast(player_joined_msg(pid, name), exclude=pid)

        # Receive loop
        msg_count = 0
        while True:
            raw = await ws.receive_text()
            msg_count += 1
            parsed = ClientMessage.parse(raw)
            await q.put((pid, parsed))

            # Log every 100th message to avoid spam, but always log shoots
            if parsed.type == ClientMessageType.SHOOT:
                log.debug(f"INPUT player={_player_tag(pid)} type=SHOOT msg#={msg_count}")
            elif msg_count % 100 == 0:
                log.info(f"INPUT_SUMMARY player={_player_tag(pid)} msgs_received={msg_count}")

    except WebSocketDisconnect:
        log.info(f"WS_DISCONNECT player={_player_tag(pid)} reason=client_closed msgs={msg_count if joined else 0}")
    except asyncio.TimeoutError:
        log.warning(f"WS_TIMEOUT pid={pid[:8]} reason=no_join_within_10s")
    except asyncio.CancelledError:
        log.info(f"WS_CANCELLED player={_player_tag(pid)}")
    except Exception as e:
        log.error(f"WS_ERROR player={_player_tag(pid)} error={e}", exc_info=True)
    finally:
        if joined:
            conns.pop(pid, None)
            player_names.pop(pid, None)
            remaining_tank = state.remove_player(pid)
            log.info(f"LEAVE player={_player_tag(pid)} total_players={len(conns)} "
                     f"last_pos=({remaining_tank.row},{remaining_tank.col} dir={remaining_tank.direction.name})"
                     if remaining_tank else
                     f"LEAVE player={_player_tag(pid)} total_players={len(conns)} no_tank_data")
            await broadcast(player_left_msg(pid))
