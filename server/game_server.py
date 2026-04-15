import asyncio
import json
import random
import time
import uuid
from contextlib import asynccontextmanager
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Optional

import modal

# ===== Game State =====


# ---------------------------------------------------------------------------
# Direction
# ---------------------------------------------------------------------------

class Direction(IntEnum):
    UP = 0
    RIGHT = 1
    DOWN = 2
    LEFT = 3

    @property
    def offset(self) -> tuple[int, int]:
        return {
            Direction.UP: (-1, 0),
            Direction.RIGHT: (0, 1),
            Direction.DOWN: (1, 0),
            Direction.LEFT: (0, -1),
        }[self]


# ---------------------------------------------------------------------------
# Seeded RNG — exact replica of Swift's SeededRNG (LCG)
# ---------------------------------------------------------------------------

class SeededRNG:
    """Deterministic RNG matching the Swift implementation exactly."""

    def __init__(self, seed: int):
        self.state = seed & 0xFFFFFFFF

    def next(self) -> int:
        # state = state &* 1664525 &+ 1013904223  (UInt32 wrapping)
        self.state = (self.state * 1664525 + 1013904223) & 0xFFFFFFFF
        return self.state

    def next_double(self) -> float:
        return self.next() / 0xFFFFFFFF


# ---------------------------------------------------------------------------
# Map
# ---------------------------------------------------------------------------

@dataclass
class Map:
    grid: list[list[bool]]
    size: int
    seed: int

    @staticmethod
    def generate(seed: int, size: int = 8) -> 'Map':
        rng = SeededRNG(seed)
        grid = [[False] * size for _ in range(size)]

        # Protected spawn corners (2x2 areas in each corner)
        protected: set[str] = set()
        for corner_r, corner_c in [(0, 0), (size - 1, size - 1), (0, size - 1), (size - 1, 0)]:
            for dr in range(2):
                for dc in range(2):
                    r = min(max(corner_r + dr - (1 if corner_r == size - 1 else 0), 0), size - 1)
                    c = min(max(corner_c + dc - (1 if corner_c == size - 1 else 0), 0), size - 1)
                    protected.add(f"{r},{c}")

        # Border cells always clear
        border: set[str] = set()
        for i in range(size):
            border.add(f"0,{i}")
            border.add(f"{size - 1},{i}")
            border.add(f"{i},0")
            border.add(f"{i},{size - 1}")

        # Random wall density (15-30%)
        density = 0.15 + (rng.next_double() * 0.15)

        # Place walls only in interior cells
        for row in range(size):
            for col in range(size):
                key = f"{row},{col}"
                if key not in protected and key not in border and rng.next_double() < density:
                    grid[row][col] = True

        return Map(grid=grid, size=size, seed=seed)

    @staticmethod
    def random(size: int = 8) -> 'Map':
        import random as _random
        seed = _random.randint(0, 0xFFFFFFFF)
        return Map.generate(seed, size)


# ---------------------------------------------------------------------------
# Tank
# ---------------------------------------------------------------------------

@dataclass
class Tank:
    row: int
    col: int
    direction: Direction
    is_alive: bool = True

    def move(self, d: Direction, grid: list[list[bool]]) -> bool:
        dr, dc = d.offset
        new_row = self.row + dr
        new_col = self.col + dc

        # Check bounds
        if not (0 <= new_row < len(grid) and 0 <= new_col < len(grid[0])):
            self.direction = d
            return False

        # Check wall
        if grid[new_row][new_col]:
            self.direction = d
            return False

        self.row = new_row
        self.col = new_col
        self.direction = d
        return True

    def shoot(self, owner_id: str) -> 'Projectile':
        dr, dc = self.direction.offset
        return Projectile(
            row=self.row + dr,
            col=self.col + dc,
            direction=self.direction,
            owner_id=owner_id,
        )

    def to_dict(self) -> dict:
        return {
            "row": self.row,
            "col": self.col,
            "direction": self.direction.value,
            "isAlive": self.is_alive,
        }


# ---------------------------------------------------------------------------
# Projectile
# ---------------------------------------------------------------------------

@dataclass
class Projectile:
    row: int
    col: int
    direction: Direction
    owner_id: str

    def advance(self):
        dr, dc = self.direction.offset
        self.row += dr
        self.col += dc

    def is_out_of_bounds(self, grid_size: int) -> bool:
        return self.row < 0 or self.row >= grid_size or self.col < 0 or self.col >= grid_size

    def hits_wall(self, grid: list[list[bool]]) -> bool:
        if self.is_out_of_bounds(len(grid)):
            return False
        return grid[self.row][self.col]

    def hits_tank(self, tank: Tank) -> bool:
        return tank.is_alive and tank.row == self.row and tank.col == self.col

    def to_dict(self) -> dict:
        return {
            "row": self.row,
            "col": self.col,
            "direction": self.direction.value,
            "ownerId": self.owner_id,
        }


# ---------------------------------------------------------------------------
# HitInfo
# ---------------------------------------------------------------------------

@dataclass
class HitInfo:
    victim_id: str
    shooter_id: str


# ---------------------------------------------------------------------------
# PlayerData
# ---------------------------------------------------------------------------

@dataclass
class PlayerData:
    tank: Tank
    score: int = 0
    display_name: str = ""
    respawn_at: Optional[float] = None  # timestamp when player should respawn


# ---------------------------------------------------------------------------
# GameState — central authoritative state
# ---------------------------------------------------------------------------

class GameState:
    def __init__(self, seed: int, grid_size: int = 8):
        self.grid_size = grid_size
        self.map = Map.generate(seed, grid_size)
        self.players: dict[str, PlayerData] = {}
        self.projectiles: list[Projectile] = []

    # -- helpers --

    @staticmethod
    def _peer_hash(peer_id: str) -> int:
        h = 5381
        for ch in peer_id.encode("utf-8"):
            h = ((h << 5) + h + ch) & 0xFFFFFFFFFFFFFFFF
        return h

    # -- player management --

    def add_player(self, player_id: str, display_name: str = "") -> Optional['Tank']:
        if player_id in self.players:
            return None
        spawn = self.find_spawn_position(player_id)
        tank = Tank(row=spawn[0], col=spawn[1], direction=spawn[2])
        self.players[player_id] = PlayerData(tank=tank, score=0, display_name=display_name)
        return tank

    def remove_player(self, player_id: str) -> Optional['Tank']:
        data = self.players.pop(player_id, None)
        if data is None:
            return None
        # Also remove their projectiles
        self.projectiles = [p for p in self.projectiles if p.owner_id != player_id]
        return data.tank

    def find_spawn_position(self, peer_id: Optional[str] = None) -> tuple:
        gs = self.map.size
        perimeter: list[tuple[int, int, Direction]] = []
        for i in range(gs):
            perimeter.append((0, i, Direction.DOWN))
            perimeter.append((gs - 1, i, Direction.UP))
            if 0 < i < gs - 1:
                perimeter.append((i, 0, Direction.RIGHT))
                perimeter.append((i, gs - 1, Direction.LEFT))

        # Filter out walls
        perimeter = [(r, c, d) for r, c, d in perimeter if not self.map.grid[r][c]]

        if not perimeter:
            return (0, 0, Direction.DOWN)

        alive = [pd for pd in self.players.values() if pd.tank.is_alive]

        if not alive:
            if peer_id and perimeter:
                h = self._peer_hash(peer_id)
                return perimeter[h % len(perimeter)]
            return perimeter[0]

        # Score each position by min distance to alive tanks
        scored: list[tuple[tuple[int, int, Direction], int]] = []
        for pos in perimeter:
            min_dist = 999999
            for pd in self.players.values():
                if not pd.tank.is_alive:
                    continue
                dist = abs(pd.tank.row - pos[0]) + abs(pd.tank.col - pos[1])
                min_dist = min(min_dist, dist)
            scored.append((pos, min_dist))

        scored.sort(key=lambda x: x[1], reverse=True)
        best_score = scored[0][1]
        candidates = [s for s in scored if s[1] >= best_score - 2]

        if peer_id and candidates:
            h = self._peer_hash(peer_id)
            h = (h + int(time.time() * 1000) % 997) & 0xFFFFFFFFFFFFFFFF
            return candidates[h % len(candidates)][0]

        return candidates[0][0] if candidates else perimeter[0]

    def respawn_player(self, player_id: str) -> Optional[tuple]:
        data = self.players.get(player_id)
        if data is None:
            return None

        spawn = self.find_spawn_position(player_id)
        data.tank = Tank(row=spawn[0], col=spawn[1], direction=spawn[2])
        data.tank.is_alive = True
        data.respawn_at = None
        return spawn

    def schedule_respawn(self, player_id: str) -> None:
        data = self.players.get(player_id)
        if data is None:
            return
        h = self._peer_hash(player_id)
        jitter = (h % 1000) / 1000.0  # 0.0 to 1.0
        delay = 2.5 + jitter  # 2.5 to 3.5 seconds
        data.respawn_at = time.time() + delay

    # -- game logic --

    def move_player(self, player_id: str, direction: Direction) -> bool:
        data = self.players.get(player_id)
        if data is None or not data.tank.is_alive:
            return False
        return data.tank.move(direction, self.map.grid)

    def shoot(self, player_id: str) -> Optional['Projectile']:
        data = self.players.get(player_id)
        if data is None or not data.tank.is_alive:
            return None
        proj = data.tank.shoot(player_id)
        # Only add if spawn position is valid (not out of bounds or in wall)
        if proj.is_out_of_bounds(self.map.size) or proj.hits_wall(self.map.grid):
            return None
        self.projectiles.append(proj)
        return proj

    def update_projectiles(self) -> list:
        hits: list[HitInfo] = []
        active: list[Projectile] = []

        for proj in self.projectiles:
            if proj.hits_wall(self.map.grid):
                continue

            # Check collisions at CURRENT position (before advancing)
            hit_something = False
            for pid, pd in self.players.items():
                if pid == proj.owner_id:
                    continue
                if proj.hits_tank(pd.tank):
                    pd.tank.is_alive = False
                    hits.append(HitInfo(victim_id=pid, shooter_id=proj.owner_id))
                    hit_something = True
                    # Award point
                    shooter = self.players.get(proj.owner_id)
                    if shooter:
                        shooter.score += 1
                    break

            if hit_something:
                continue

            # Advance
            proj.advance()

            if proj.is_out_of_bounds(self.map.size) or proj.hits_wall(self.map.grid):
                continue

            # Check collisions at NEW position (after advancing)
            for pid, pd in self.players.items():
                if proj.hits_tank(pd.tank):
                    pd.tank.is_alive = False
                    hits.append(HitInfo(victim_id=pid, shooter_id=proj.owner_id))
                    hit_something = True
                    shooter = self.players.get(proj.owner_id)
                    if shooter:
                        shooter.score += 1
                    break

            if not hit_something:
                active.append(proj)

        # Projectile-on-projectile collisions
        collided: set[int] = set()
        for i in range(len(active)):
            if i in collided:
                continue
            for j in range(i + 1, len(active)):
                if j in collided:
                    continue
                if active[i].row == active[j].row and active[i].col == active[j].col:
                    collided.add(i)
                    collided.add(j)
                    break

        self.projectiles = [p for idx, p in enumerate(active) if idx not in collided]
        return hits

    def check_respawns(self) -> list:
        """Check for players whose respawn timer has elapsed. Returns list of (id, row, col, dir)."""
        now = time.time()
        respawned: list[tuple[str, int, int, Direction]] = []
        for pid, pd in list(self.players.items()):
            if pd.respawn_at is not None and now >= pd.respawn_at:
                spawn = self.respawn_player(pid)
                if spawn:
                    respawned.append((pid, spawn[0], spawn[1], spawn[2]))
        return respawned

    # -- serialisation --

    def to_world_state(self) -> dict:
        return {
            "mapSeed": self.map.seed,
            "gridSize": self.grid_size,
            "players": {
                pid: {
                    "row": pd.tank.row,
                    "col": pd.tank.col,
                    "direction": pd.tank.direction.value,
                    "isAlive": pd.tank.is_alive,
                    "score": pd.score,
                    "displayName": pd.display_name,
                }
                for pid, pd in self.players.items()
            },
            "projectiles": [p.to_dict() for p in self.projectiles],
            "scores": {pid: pd.score for pid, pd in self.players.items()},
        }

    def resize_grid(self, new_size: int, new_seed: int) -> None:
        self.grid_size = new_size
        self.map = Map.generate(new_seed, new_size)
        self.projectiles.clear()

        for pid, pd in self.players.items():
            spawn = self.find_spawn_position(pid)
            pd.tank = Tank(row=spawn[0], col=spawn[1], direction=spawn[2])
            pd.tank.is_alive = True

# ===== Messages =====


# ---------------------------------------------------------------------------
# Client → Server messages
# ---------------------------------------------------------------------------

class ClientMessageType(str, Enum):
    JOIN = "join"
    MOVE = "move"
    SHOOT = "shoot"
    LEAVE = "leave"


@dataclass
class ClientMessage:
    type: ClientMessageType
    direction: Optional[int] = None     # for MOVE
    display_name: Optional[str] = None  # for JOIN

    @staticmethod
    def parse(raw: str) -> 'ClientMessage':
        data = json.loads(raw)
        msg_type = ClientMessageType(data["type"])
        return ClientMessage(
            type=msg_type,
            direction=data.get("direction"),
            display_name=data.get("displayName"),
        )


# ---------------------------------------------------------------------------
# Server → Client messages
# ---------------------------------------------------------------------------

class ServerMessageType(str, Enum):
    WELCOME = "welcome"
    STATE_UPDATE = "stateUpdate"
    PLAYER_JOINED = "playerJoined"
    PLAYER_LEFT = "playerLeft"
    HIT = "hit"
    RESPAWN = "respawn"
    MAP_UPDATE = "mapUpdate"
    ERROR = "error"


def server_msg(msg_type: ServerMessageType, **kwargs: Any) -> str:
    """Build a JSON-encoded server message."""
    payload: dict[str, Any] = {"type": msg_type.value}
    payload.update(kwargs)
    return json.dumps(payload, separators=(",", ":"))


def welcome_msg(player_id: str, world_state: dict) -> str:
    return server_msg(
        ServerMessageType.WELCOME,
        playerId=player_id,
        worldState=world_state,
    )


def state_update_msg(world_state: dict) -> str:
    return server_msg(
        ServerMessageType.STATE_UPDATE,
        **world_state,
    )


def player_joined_msg(player_id: str, display_name: str) -> str:
    return server_msg(
        ServerMessageType.PLAYER_JOINED,
        playerId=player_id,
        displayName=display_name,
    )


def player_left_msg(player_id: str) -> str:
    return server_msg(
        ServerMessageType.PLAYER_LEFT,
        playerId=player_id,
    )


def hit_msg(victim_id: str, shooter_id: str) -> str:
    return server_msg(
        ServerMessageType.HIT,
        victimId=victim_id,
        shooterId=shooter_id,
    )


def respawn_msg(player_id: str, row: int, col: int, direction: int) -> str:
    return server_msg(
        ServerMessageType.RESPAWN,
        playerId=player_id,
        row=row,
        col=col,
        direction=direction,
    )


def map_update_msg(world_state: dict) -> str:
    return server_msg(
        ServerMessageType.MAP_UPDATE,
        **world_state,
    )


def error_msg(message: str) -> str:
    return server_msg(
        ServerMessageType.ERROR,
        message=message,
    )

# ===== Modal App =====

image = modal.Image.debian_slim().pip_install("fastapi[standard]")
app = modal.App("tankgame-server")

TICK_RATE = 0.05  # 50ms = 20 ticks/sec


@app.function(image=image)
@modal.asgi_app()
def web():
    from fastapi import FastAPI, WebSocket, WebSocketDisconnect
    from fastapi.responses import JSONResponse

    seed = random.randint(0, 0xFFFFFFFF)
    state = GameState(seed=seed, grid_size=8)
    conns: dict[str, WebSocket] = {}
    q: asyncio.Queue = asyncio.Queue()

    print(f"[Server] Initialized with map seed {seed}")

    async def broadcast(msg: str, exclude: Optional[str] = None):
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
        while True:
            t0 = time.monotonic()
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

            if state.projectiles:
                hits = state.update_projectiles()
                for h in hits:
                    await broadcast(hit_msg(h.victim_id, h.shooter_id))
                    state.schedule_respawn(h.victim_id)

            for pid, row, col, d in state.check_respawns():
                await broadcast(respawn_msg(pid, row, col, d.value))

            if conns:
                await broadcast(state_update_msg(state.to_world_state()))

            dt = time.monotonic() - t0
            await asyncio.sleep(max(0, TICK_RATE - dt))

    loop_started = [False]

    @asynccontextmanager
    async def lifespan(application):
        yield

    fapp = FastAPI(lifespan=lifespan)

    @fapp.get("/health")
    async def health():
        return JSONResponse({
            "status": "ok",
            "players": len(conns),
            "mapSeed": state.map.seed,
            "gridSize": state.grid_size,
        })

    @fapp.websocket("/ws")
    async def ws_endpoint(ws: WebSocket):
        await ws.accept()
        pid = str(uuid.uuid4())
        joined = False
        try:
            raw = await asyncio.wait_for(ws.receive_text(), timeout=10.0)
            msg = ClientMessage.parse(raw)
            if msg.type != ClientMessageType.JOIN:
                await ws.send_text(error_msg("First message must be join"))
                return
            name = msg.display_name or f"Tank-{pid[:4]}"
            tank = state.add_player(pid, name)
            if tank is None:
                await ws.send_text(error_msg("Failed to join"))
                return
            joined = True
            if not loop_started[0]:
                loop_started[0] = True
                asyncio.create_task(game_loop())
                print("[Server] Game loop started")
            conns[pid] = ws
            print(f"[Server] {name} ({pid[:8]}) joined. Total: {len(conns)}")
            await ws.send_text(welcome_msg(pid, state.to_world_state()))
            await broadcast(player_joined_msg(pid, name), exclude=pid)
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

    return fapp
