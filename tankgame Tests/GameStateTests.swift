//
//  GameStateTests.swift
//  tankgame Tests
//
//  Unit tests for GameState logic
//

import XCTest
@testable import tankgame

final class GameStateTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testGameStateInitialization() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        XCTAssertEqual(state.tanks.count, 2, "Should create correct number of tanks")
        XCTAssertEqual(state.wins.count, 2, "Should create wins array for all players")
        XCTAssertEqual(state.localPlayerIndex, 0)
        XCTAssertTrue(state.projectiles.isEmpty, "Should start with no projectiles")
    }
    
    func testInitialTankPositions() {
        let state = GameState(seed: 12345, playerCount: 4, localPlayerIndex: 0)
        
        // Verify spawn positions match configuration
        XCTAssertEqual(state.tanks[0].row, 0)
        XCTAssertEqual(state.tanks[0].col, 0)
        XCTAssertEqual(state.tanks[0].direction, .down)
        
        XCTAssertEqual(state.tanks[1].row, 7)
        XCTAssertEqual(state.tanks[1].col, 7)
        XCTAssertEqual(state.tanks[1].direction, .up)
        
        XCTAssertEqual(state.tanks[2].row, 0)
        XCTAssertEqual(state.tanks[2].col, 7)
        XCTAssertEqual(state.tanks[2].direction, .down)
        
        XCTAssertEqual(state.tanks[3].row, 7)
        XCTAssertEqual(state.tanks[3].col, 0)
        XCTAssertEqual(state.tanks[3].direction, .up)
    }
    
    func testAllTanksStartAlive() {
        let state = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        
        for tank in state.tanks {
            XCTAssertTrue(tank.isAlive, "All tanks should start alive")
        }
    }
    
    // MARK: - Reset Tests
    
    func testResetClearsProjectiles() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        state.projectiles.append(Projectile(row: 3, col: 3, direction: .right))
        
        state.reset(seed: 54321)
        
        XCTAssertTrue(state.projectiles.isEmpty, "Reset should clear all projectiles")
    }
    
    func testResetRestoresTankPositions() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Move tank away from spawn
        _ = state.tanks[0].move(in: .down, grid: state.grid)
        XCTAssertNotEqual(state.tanks[0].row, 0, "Tank should have moved")
        
        state.reset(seed: 12345)
        
        XCTAssertEqual(state.tanks[0].row, 0, "Tank should be back at spawn")
        XCTAssertEqual(state.tanks[0].col, 0, "Tank should be back at spawn")
    }
    
    func testResetRevivesTanks() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        state.tanks[0].isAlive = false
        
        state.reset(seed: 12345)
        
        XCTAssertTrue(state.tanks[0].isAlive, "Reset should revive all tanks")
    }
    
    // MARK: - Local Tank Tests
    
    func testLocalTankGetter() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 1)
        
        let localTank = state.localTank
        XCTAssertEqual(localTank.row, state.tanks[1].row)
        XCTAssertEqual(localTank.col, state.tanks[1].col)
    }
    
    func testLocalTankSetter() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        var newTank = state.localTank
        newTank.row = 5
        newTank.col = 5
        state.localTank = newTank
        
        XCTAssertEqual(state.tanks[0].row, 5)
        XCTAssertEqual(state.tanks[0].col, 5)
    }
    
    // MARK: - Projectile Update Tests
    
    func testUpdateProjectilesAdvances() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        state.projectiles.append(Projectile(row: 3, col: 3, direction: .right))
        
        state.updateProjectiles()
        
        XCTAssertEqual(state.projectiles.count, 1)
        XCTAssertEqual(state.projectiles[0].col, 4, "Projectile should advance")
    }
    
    func testUpdateProjectilesRemovesOutOfBounds() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        state.projectiles.append(Projectile(row: 7, col: 7, direction: .right))
        
        state.updateProjectiles()
        
        XCTAssertTrue(state.projectiles.isEmpty, "Out of bounds projectile should be removed")
    }
    
    func testUpdateProjectilesRemovesWallHits() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Find a wall position
        var wallPos: (row: Int, col: Int)?
        for row in 0..<8 {
            for col in 0..<8 {
                if state.grid[row][col] == .wall {
                    wallPos = (row, col)
                    break
                }
            }
            if wallPos != nil { break }
        }
        
        if let wallPos = wallPos {
            // Place projectile one cell before wall
            let direction: Direction = wallPos.col > 0 ? .right : .down
            let startPos = direction == .right ? 
                (wallPos.row, wallPos.col - 1) : 
                (wallPos.row - 1, wallPos.col)
            
            state.projectiles.append(Projectile(
                row: startPos.0, 
                col: startPos.1, 
                direction: direction
            ))
            
            state.updateProjectiles()
            
            XCTAssertTrue(state.projectiles.isEmpty, "Projectile hitting wall should be removed")
        }
    }
    
    func testUpdateProjectilesKillsTank() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Place projectile at tank position
        state.projectiles.append(Projectile(
            row: state.tanks[1].row - 1,
            col: state.tanks[1].col,
            direction: .down
        ))
        
        XCTAssertTrue(state.tanks[1].isAlive, "Tank should start alive")
        
        state.updateProjectiles()
        
        XCTAssertFalse(state.tanks[1].isAlive, "Tank should be killed by projectile")
        XCTAssertTrue(state.projectiles.isEmpty, "Projectile should be removed after hit")
    }
    
    // MARK: - Round Status Tests
    
    func testIsRoundOverAllAlive() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        XCTAssertFalse(state.isRoundOver(), "Round should not be over with all tanks alive")
    }
    
    func testIsRoundOverOneAlive() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        state.tanks[1].isAlive = false
        
        XCTAssertTrue(state.isRoundOver(), "Round should be over with one tank alive")
    }
    
    func testIsRoundOverNoneAlive() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        state.tanks[0].isAlive = false
        state.tanks[1].isAlive = false
        
        XCTAssertTrue(state.isRoundOver(), "Round should be over with no tanks alive")
    }
    
    // MARK: - Winner Detection Tests
    
    func testGetWinnerWhenOneAlive() {
        let state = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        state.tanks[0].isAlive = false
        state.tanks[2].isAlive = false
        
        let winner = state.getWinner()
        XCTAssertEqual(winner, 1, "Player 1 should be the winner")
    }
    
    func testGetWinnerWhenMultipleAlive() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        let winner = state.getWinner()
        XCTAssertNil(winner, "Should have no winner when multiple tanks alive")
    }
    
    func testGetWinnerWhenNoneAlive() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        state.tanks[0].isAlive = false
        state.tanks[1].isAlive = false
        
        let winner = state.getWinner()
        XCTAssertNil(winner, "Should have no winner when no tanks alive")
    }
    
    func testLocalPlayerWon() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        state.tanks[1].isAlive = false
        
        XCTAssertTrue(state.localPlayerWon(), "Local player should have won")
    }
    
    func testLocalPlayerLost() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        state.tanks[0].isAlive = false
        
        XCTAssertFalse(state.localPlayerWon(), "Local player should have lost")
    }
    
    // MARK: - Grid Generation Tests
    
    func testGridIsGeneratedWithSeed() {
        let state1 = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        let state2 = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 1)
        
        // Same seed should generate identical grids
        for row in 0..<8 {
            for col in 0..<8 {
                XCTAssertEqual(
                    state1.grid[row][col], 
                    state2.grid[row][col],
                    "Same seed should produce identical grid at (\(row),\(col))"
                )
            }
        }
    }
    
    func testSpawnPointsAreClear() {
        let state = GameState(seed: 12345, playerCount: 4, localPlayerIndex: 0)
        
        // Check all spawn positions are empty
        for i in 0..<4 {
            let spawn = GameConfiguration.spawnPositions[i]
            XCTAssertEqual(
                state.grid[spawn.row][spawn.col],
                .empty,
                "Spawn point for player \(i) should be clear"
            )
        }
    }
}
