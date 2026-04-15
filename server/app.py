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
        generate_fun_name, release_name,
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
        generate_fun_name, release_name,
    )

# ===== Shared State =====

TICK_RATE = 0.05  # 50ms = 20 ticks/sec
MAP_ROTATION_INTERVAL = 3600  # rotate map every hour (seconds)

seed = random.randint(0, 0xFFFFFFFF)
state = GameState(seed=seed, grid_size=8)
conns: dict[str, WebSocket] = {}
player_names: dict[str, str] = {}  # pid -> display name for logging
q: asyncio.Queue = asyncio.Queue()
loop_started = False
tick_count = 0
server_start_time = time.time()
last_map_rotation = time.time()
last_leaderboard_sync = 0.0

# Session leaderboard: tracks stats for the current container lifetime
# Keyed by display name (not pid, since pids change on reconnect)
session_stats: dict[str, dict] = {}  # name -> {kills, deaths, shots, sessions}

# modal.Dict for persistent leaderboard (only used inside Modal containers)
_modal_dict = None

def _get_modal_dict():
    """Lazily initialize modal.Dict — only works inside Modal containers."""
    global _modal_dict
    if _modal_dict is not None:
        return _modal_dict
    try:
        import modal as _modal
        _modal_dict = _modal.Dict.from_name("tankgame-leaderboard", create_if_missing=True)
        log.info("MODAL_DICT_CONNECTED name=tankgame-leaderboard")
        return _modal_dict
    except Exception as e:
        log.debug(f"MODAL_DICT_UNAVAILABLE error={e} (normal when running locally)")
        return None

log.info("=== TANK BATTLE SERVER STARTING ===")
log.info(f"Map seed={seed} gridSize={state.grid_size}")
log.info(f"Tick rate={TICK_RATE}s ({1/TICK_RATE:.0f} ticks/sec)")
log.info(f"Map rotation interval={MAP_ROTATION_INTERVAL}s")


# ===== Leaderboard Persistence =====

def _sync_to_modal_dict():
    """Push session stats to modal.Dict for persistence across container restarts."""
    d = _get_modal_dict()
    if d is None or not session_stats:
        return
    try:
        synced = 0
        for name, stats in session_stats.items():
            existing = d.get(name)
            if existing is None:
                d[name] = {**stats, "last_seen": time.time()}
                synced += 1
            else:
                # Accumulate — don't overwrite, add to historical totals
                d[name] = {
                    "kills": existing.get("kills", 0) + stats.get("kills", 0),
                    "deaths": existing.get("deaths", 0) + stats.get("deaths", 0),
                    "shots": existing.get("shots", 0) + stats.get("shots", 0),
                    "sessions": existing.get("sessions", 0) + stats.get("sessions", 0),
                    "last_seen": time.time(),
                }
                synced += 1
        if synced > 0:
            log.info(f"LEADERBOARD_SYNCED entries={synced} to=modal.Dict")
    except Exception as e:
        log.error(f"LEADERBOARD_SYNC_FAIL error={e}")


def _record_kill(shooter_name: str, victim_name: str):
    """Record a kill in session stats."""
    if shooter_name not in session_stats:
        session_stats[shooter_name] = {"kills": 0, "deaths": 0, "shots": 0, "sessions": 1}
    if victim_name not in session_stats:
        session_stats[victim_name] = {"kills": 0, "deaths": 0, "shots": 0, "sessions": 1}
    session_stats[shooter_name]["kills"] += 1
    session_stats[victim_name]["deaths"] += 1


def _record_shot(shooter_name: str):
    """Record a shot fired."""
    if shooter_name not in session_stats:
        session_stats[shooter_name] = {"kills": 0, "deaths": 0, "shots": 0, "sessions": 1}
    session_stats[shooter_name]["shots"] += 1


def _record_session_start(name: str):
    """Record a player starting a session."""
    if name not in session_stats:
        session_stats[name] = {"kills": 0, "deaths": 0, "shots": 0, "sessions": 1}
    else:
        session_stats[name]["sessions"] += 1


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
    global tick_count, last_leaderboard_sync, last_map_rotation
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
                    _record_shot(player_names.get(pid, pid[:8]))
                else:
                    log.debug(f"SHOOT_BLOCKED player={_player_tag(pid)}")

        # Update projectiles
        if state.projectiles:
            hits = state.update_projectiles()
            for h in hits:
                shooter_name = player_names.get(h.shooter_id, h.shooter_id[:8])
                victim_name = player_names.get(h.victim_id, h.victim_id[:8])
                log.info(f"HIT victim={_player_tag(h.victim_id)} shooter={_player_tag(h.shooter_id)} "
                         f"shooter_score={state.players.get(h.shooter_id, PlayerData(Tank(0,0,Direction.UP))).score}")
                _record_kill(shooter_name, victim_name)
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

        # Sync leaderboard to modal.Dict every 60 seconds (only while game loop is running)
        now = time.time()
        if now - last_leaderboard_sync >= 60 and session_stats:
            last_leaderboard_sync = now
            _sync_to_modal_dict()

        # Map rotation (every MAP_ROTATION_INTERVAL seconds)
        if now - last_map_rotation >= MAP_ROTATION_INTERVAL and conns:
            last_map_rotation = now
            new_seed = random.randint(0, 0xFFFFFFFF)
            state.resize_grid(state.grid_size, new_seed)
            log.info(f"MAP_ROTATED new_seed={new_seed} players_respawned={len(state.players)}")
            await broadcast(state_update_msg(state.to_world_state()))

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


@app.get("/leaderboard")
async def get_leaderboard():
    """Return session leaderboard + persistent data from modal.Dict."""
    # Start with session stats
    combined = {name: {**stats} for name, stats in session_stats.items()}

    # Merge in persistent stats from modal.Dict
    d = _get_modal_dict()
    if d is not None:
        try:
            for key in d.keys():
                persistent = d[key]
                if key in combined:
                    # Session stats are current — show them, but note historical totals
                    combined[key]["all_time_kills"] = persistent.get("kills", 0)
                else:
                    combined[key] = persistent
        except Exception as e:
            log.warning(f"LEADERBOARD_READ_FAIL error={e}")

    # Sort by kills desc
    sorted_lb = sorted(combined.items(), key=lambda x: x[1].get("kills", 0), reverse=True)
    return JSONResponse({
        "leaderboard": [
            {"name": name, **stats}
            for name, stats in sorted_lb[:50]  # top 50
        ],
        "total_players": len(combined),
        "server_uptime": round(time.time() - server_start_time),
    })


@app.get("/stats/{player_name}")
async def get_player_stats(player_name: str):
    """Return stats for a specific player."""
    stats = session_stats.get(player_name)
    # Also check modal.Dict for historical stats
    if stats is None:
        d = _get_modal_dict()
        if d is not None:
            try:
                stats = d.get(player_name)
            except Exception:
                pass
    if stats is None:
        return JSONResponse({"error": "Player not found"}, status_code=404)
    kd = stats["kills"] / max(stats["deaths"], 1)
    accuracy = stats["kills"] / max(stats["shots"], 1) * 100
    return JSONResponse({
        "name": player_name,
        **stats,
        "kd_ratio": round(kd, 2),
        "accuracy_pct": round(accuracy, 1),
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

        name = generate_fun_name()
        tank = state.add_player(pid, name)

        if tank is None:
            log.error(f"JOIN_FAIL pid={pid[:8]} name={name} reason=add_player_returned_none")
            await ws.send_text(error_msg("Failed to join"))
            return

        joined = True
        conns[pid] = ws
        player_names[pid] = name
        _record_session_start(name)

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
            released_name = player_names.pop(pid, None)
            if released_name:
                release_name(released_name)
            remaining_tank = state.remove_player(pid)
            log.info(f"LEAVE player={_player_tag(pid)} total_players={len(conns)} "
                     f"last_pos=({remaining_tank.row},{remaining_tank.col} dir={remaining_tank.direction.name})"
                     if remaining_tank else
                     f"LEAVE player={_player_tag(pid)} total_players={len(conns)} no_tank_data")
            await broadcast(player_left_msg(pid))
