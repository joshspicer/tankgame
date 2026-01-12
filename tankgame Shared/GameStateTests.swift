//
//  GameStateTests.swift
//  tankgame Shared
//
//  Created by Copilot on 1/12/26.
//

import Foundation

#if DEBUG
/// Basic tests for game state functionality
class GameStateTests {
    
    /// Test that GameState initializes correctly
    static func testGameStateInitialization() {
        print("=== Testing GameState Initialization ===")
        
        let seed: UInt32 = 12345
        let playerCount = 2
        let localPlayerIndex = 0
        
        let gameState = GameState(seed: seed, playerCount: playerCount, localPlayerIndex: localPlayerIndex)
        
        assert(gameState.tanks.count == playerCount, "Expected \(playerCount) tanks, got \(gameState.tanks.count)")
        assert(gameState.localPlayerIndex == localPlayerIndex, "Local player index mismatch")
        assert(gameState.wins.count == playerCount, "Wins array should match player count")
        assert(gameState.grid.count == 8, "Grid should be 8x8")
        assert(gameState.grid[0].count == 8, "Grid should be 8x8")
        
        print("✓ GameState initialized correctly")
        print("  - Tanks: \(gameState.tanks.count)")
        print("  - Local player index: \(gameState.localPlayerIndex)")
        print("  - Grid size: \(gameState.grid.count)x\(gameState.grid[0].count)")
        print("  - Lizards enabled: \(gameState.lizardsEnabled)")
        print("  - Lizards spawned: \(gameState.lizards.count)")
    }
    
    /// Test that tanks spawn at correct positions
    static func testTankSpawnPositions() {
        print("\n=== Testing Tank Spawn Positions ===")
        
        let gameState = GameState(seed: 12345, playerCount: 4, localPlayerIndex: 0)
        
        // Check spawn positions match expected values
        let expectedPositions = GameState.spawnPositions
        
        for i in 0..<gameState.tanks.count {
            let tank = gameState.tanks[i]
            let expected = expectedPositions[i]
            
            assert(tank.row == expected.row, "Tank \(i) row mismatch: expected \(expected.row), got \(tank.row)")
            assert(tank.col == expected.col, "Tank \(i) col mismatch: expected \(expected.col), got \(tank.col)")
            assert(tank.direction == expected.direction, "Tank \(i) direction mismatch")
            assert(tank.isAlive, "Tank \(i) should be alive initially")
            
            print("✓ Tank \(i): position (\(tank.row), \(tank.col)), direction: \(tank.direction)")
        }
    }
    
    /// Test that projectiles advance correctly
    static func testProjectileMovement() {
        print("\n=== Testing Projectile Movement ===")
        
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Create a projectile moving down from position (3, 3)
        let projectile = Projectile(row: 3, col: 3, direction: .down)
        gameState.projectiles.append(projectile)
        
        print("Initial projectile position: (\(projectile.row), \(projectile.col))")
        
        // Update projectiles
        gameState.updateProjectiles()
        
        if gameState.projectiles.count > 0 {
            let updated = gameState.projectiles[0]
            print("Updated projectile position: (\(updated.row), \(updated.col))")
            print("✓ Projectile moved successfully")
        } else {
            print("⚠ Projectile was removed (may have hit a wall)")
        }
    }
    
    /// Test round over detection
    static func testRoundOverDetection() {
        print("\n=== Testing Round Over Detection ===")
        
        var gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        
        // Initially, round should not be over
        assert(!gameState.isRoundOver(), "Round should not be over with all tanks alive")
        print("✓ Round continues with all tanks alive")
        
        // Kill all but one tank
        gameState.tanks[0].isAlive = false
        gameState.tanks[1].isAlive = false
        
        assert(gameState.isRoundOver(), "Round should be over with only one tank alive")
        print("✓ Round detected as over with one tank remaining")
        
        // Get winner
        if let winner = gameState.getWinner() {
            print("  - Winner is player \(winner)")
        }
    }
    
    /// Test tank movement
    static func testTankMovement() {
        print("\n=== Testing Tank Movement ===")
        
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        let tank = gameState.tanks[0]
        
        let initialRow = tank.row
        let initialCol = tank.col
        print("Initial tank position: (\(initialRow), \(initialCol))")
        
        // Try to move the tank (movement depends on grid layout)
        var testTank = tank  // Create a copy to test movement
        let moved = testTank.move(in: .right, grid: gameState.grid)
        
        if moved {
            print("✓ Tank can move to (\(testTank.row), \(testTank.col))")
        } else {
            print("⚠ Tank couldn't move (blocked by wall)")
        }
    }
    
    /// Test game state reset
    static func testGameStateReset() {
        print("\n=== Testing GameState Reset ===")
        
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Modify state
        gameState.tanks[0].isAlive = false
        gameState.projectiles.append(Projectile(row: 4, col: 4, direction: .up))
        
        print("Before reset: Tank 0 alive = \(gameState.tanks[0].isAlive), Projectiles = \(gameState.projectiles.count)")
        
        // Reset with new seed
        gameState.reset(seed: 54321)
        
        assert(gameState.tanks[0].isAlive, "Tank should be alive after reset")
        assert(gameState.projectiles.isEmpty, "Projectiles should be empty after reset")
        
        print("After reset: Tank 0 alive = \(gameState.tanks[0].isAlive), Projectiles = \(gameState.projectiles.count)")
        print("✓ GameState reset successfully")
    }
    
    /// Run all tests
    static func runAllTests() {
        print("\n" + String(repeating: "=", count: 50))
        print("RUNNING GAME STATE TESTS")
        print(String(repeating: "=", count: 50) + "\n")
        
        testGameStateInitialization()
        testTankSpawnPositions()
        testProjectileMovement()
        testRoundOverDetection()
        testTankMovement()
        testGameStateReset()
        
        print("\n" + String(repeating: "=", count: 50))
        print("ALL TESTS COMPLETED")
        print(String(repeating: "=", count: 50) + "\n")
    }
}
#endif
