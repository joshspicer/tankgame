"""
Local test script for the game server.
Run with: python3 server/test_local.py
"""

import asyncio
import json
import sys
import os

# Add parent to path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from server.game_server import Direction, GameState, Map, SeededRNG


def test_seeded_rng():
    """Verify the LCG produces deterministic results."""
    rng1 = SeededRNG(42)
    rng2 = SeededRNG(42)
    for _ in range(100):
        assert rng1.next() == rng2.next(), "RNG should be deterministic"
    print("✓ SeededRNG is deterministic")


def test_map_generation():
    """Verify maps are identical for same seed."""
    m1 = Map.generate(12345, 8)
    m2 = Map.generate(12345, 8)
    assert m1.grid == m2.grid, "Maps with same seed should be identical"

    m3 = Map.generate(99999, 8)
    assert m1.grid != m3.grid, "Maps with different seeds should differ"
    print("✓ Map generation is deterministic")


def test_map_borders_clear():
    """Verify border cells are always empty."""
    for seed in [0, 42, 12345, 0xFFFFFFFF]:
        m = Map.generate(seed, 8)
        for i in range(8):
            assert not m.grid[0][i], f"Top border should be clear at (0,{i})"
            assert not m.grid[7][i], f"Bottom border should be clear at (7,{i})"
            assert not m.grid[i][0], f"Left border should be clear at ({i},0)"
            assert not m.grid[i][7], f"Right border should be clear at ({i},7)"
    print("✓ Map borders are always clear")


def test_game_state():
    """Test basic game operations."""
    gs = GameState(seed=42, grid_size=8)

    # Add players
    t1 = gs.add_player("player-1", "Alice")
    assert t1 is not None, "Should add player"
    assert t1.is_alive, "New player should be alive"

    t2 = gs.add_player("player-2", "Bob")
    assert t2 is not None, "Should add second player"

    # Duplicate add
    assert gs.add_player("player-1") is None, "Duplicate should return None"

    # Move player
    moved = gs.move_player("player-1", Direction.DOWN)
    # May or may not succeed depending on spawn position
    print(f"  Player 1 at ({gs.players['player-1'].tank.row}, {gs.players['player-1'].tank.col})")

    # Shoot
    proj = gs.shoot("player-1")
    # May be None if projectile would spawn in wall
    if proj:
        assert len(gs.projectiles) == 1
        print(f"  Projectile at ({proj.row}, {proj.col}) going {proj.direction.name}")

    # Remove player
    removed = gs.remove_player("player-2")
    assert removed is not None, "Should return removed tank"
    assert "player-2" not in gs.players

    # World state serialization
    ws = gs.to_world_state()
    assert ws["mapSeed"] == 42
    assert ws["gridSize"] == 8
    assert "player-1" in ws["players"]

    print("✓ GameState operations work correctly")


def test_collision():
    """Test projectile-tank collision."""
    gs = GameState(seed=42, grid_size=8)

    # Place two players manually for collision test
    gs.add_player("shooter")
    gs.add_player("target")

    # Position them for a guaranteed hit
    gs.players["shooter"].tank.row = 0
    gs.players["shooter"].tank.col = 0
    gs.players["shooter"].tank.direction = Direction.RIGHT

    gs.players["target"].tank.row = 0
    gs.players["target"].tank.col = 2
    gs.players["target"].tank.is_alive = True

    # Create projectile heading toward target
    from server.game_server import Projectile
    gs.projectiles = [Projectile(row=0, col=1, direction=Direction.RIGHT, owner_id="shooter")]

    hits = gs.update_projectiles()
    assert len(hits) == 1, f"Expected 1 hit, got {len(hits)}"
    assert hits[0].victim_id == "target"
    assert hits[0].shooter_id == "shooter"
    assert not gs.players["target"].tank.is_alive, "Target should be dead"
    assert gs.players["shooter"].score == 1, "Shooter should have 1 point"

    print("✓ Collision detection works correctly")


def test_respawn():
    """Test respawn scheduling and execution."""
    gs = GameState(seed=42, grid_size=8)
    gs.add_player("player-1")

    gs.players["player-1"].tank.is_alive = False
    gs.schedule_respawn("player-1")

    assert gs.players["player-1"].respawn_at is not None, "Should have respawn time"

    # Force respawn by setting time to past
    gs.players["player-1"].respawn_at = 0

    respawned = gs.check_respawns()
    assert len(respawned) == 1, "Should respawn one player"
    assert respawned[0][0] == "player-1"
    assert gs.players["player-1"].tank.is_alive, "Player should be alive after respawn"

    print("✓ Respawn system works correctly")


if __name__ == "__main__":
    print("Running game state tests...\n")
    test_seeded_rng()
    test_map_generation()
    test_map_borders_clear()
    test_game_state()
    test_collision()
    test_respawn()
    print("\n✅ All tests passed!")
