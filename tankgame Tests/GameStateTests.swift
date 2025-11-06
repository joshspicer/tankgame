//
//  GameStateTests.swift
//  tankgame Tests
//
//  Unit tests for GameState class
//

import XCTest
@testable import tankgame

class GameStateTests: XCTestCase {
    
    func testGameStateInitializationPlayer1() {
        let state = GameState(seed: 12345, isPlayer1: true)
        
        XCTAssertTrue(state.isLocalPlayer1)
        
        // Player 1 starts at top-left
        XCTAssertEqual(state.localTank.row, 0)
        XCTAssertEqual(state.localTank.col, 0)
        XCTAssertEqual(state.localTank.direction, .down)
        XCTAssertTrue(state.localTank.isAlive)
        
        // Remote player (Player 2) starts at bottom-right
        XCTAssertEqual(state.remoteTank.row, 7)
        XCTAssertEqual(state.remoteTank.col, 7)
        XCTAssertEqual(state.remoteTank.direction, .up)
        XCTAssertTrue(state.remoteTank.isAlive)
        
        XCTAssertEqual(state.projectiles.count, 0)
        XCTAssertEqual(state.localWins, 0)
        XCTAssertEqual(state.remoteWins, 0)
    }
    
    func testGameStateInitializationPlayer2() {
        let state = GameState(seed: 12345, isPlayer1: false)
        
        XCTAssertFalse(state.isLocalPlayer1)
        
        // Player 2 starts at bottom-right
        XCTAssertEqual(state.localTank.row, 7)
        XCTAssertEqual(state.localTank.col, 7)
        XCTAssertEqual(state.localTank.direction, .up)
        XCTAssertTrue(state.localTank.isAlive)
        
        // Remote player (Player 1) starts at top-left
        XCTAssertEqual(state.remoteTank.row, 0)
        XCTAssertEqual(state.remoteTank.col, 0)
        XCTAssertEqual(state.remoteTank.direction, .down)
        XCTAssertTrue(state.remoteTank.isAlive)
        
        XCTAssertEqual(state.projectiles.count, 0)
        XCTAssertEqual(state.localWins, 0)
        XCTAssertEqual(state.remoteWins, 0)
    }
    
    func testGameStateGridSize() {
        let state = GameState(seed: 12345, isPlayer1: true)
        
        XCTAssertEqual(state.grid.count, 8)
        for row in state.grid {
            XCTAssertEqual(row.count, 8)
        }
    }
    
    func testGameStateReset() {
        let state = GameState(seed: 12345, isPlayer1: true)
        
        // Modify the state
        state.localTank.isAlive = false
        state.remoteTank.isAlive = false
        state.projectiles.append(Projectile(row: 3, col: 3, direction: .up))
        
        // Reset with different seed
        state.reset(seed: 54321)
        
        // Tanks should be reset to starting positions
        XCTAssertEqual(state.localTank.row, 0)
        XCTAssertEqual(state.localTank.col, 0)
        XCTAssertTrue(state.localTank.isAlive)
        
        XCTAssertEqual(state.remoteTank.row, 7)
        XCTAssertEqual(state.remoteTank.col, 7)
        XCTAssertTrue(state.remoteTank.isAlive)
        
        // Projectiles should be cleared
        XCTAssertEqual(state.projectiles.count, 0)
        
        // Wins should be preserved
        XCTAssertEqual(state.localWins, 0)
        XCTAssertEqual(state.remoteWins, 0)
    }
    
    func testUpdateProjectilesAdvancesProjectiles() {
        let state = GameState(seed: 12345, isPlayer1: true)
        state.projectiles.append(Projectile(row: 3, col: 3, direction: .up))
        
        state.updateProjectiles()
        
        XCTAssertEqual(state.projectiles.count, 1)
        XCTAssertEqual(state.projectiles[0].row, 2)
        XCTAssertEqual(state.projectiles[0].col, 3)
    }
    
    func testUpdateProjectilesRemovesOutOfBounds() {
        let state = GameState(seed: 12345, isPlayer1: true)
        state.projectiles.append(Projectile(row: 0, col: 3, direction: .up))
        
        state.updateProjectiles()
        
        // Projectile should be removed (out of bounds)
        XCTAssertEqual(state.projectiles.count, 0)
    }
    
    func testUpdateProjectilesRemovesWallCollisions() {
        let state = GameState(seed: 12345, isPlayer1: true)
        
        // Find a wall in the grid
        var wallRow = -1
        var wallCol = -1
        for row in 0..<8 {
            for col in 0..<8 {
                if state.grid[row][col] == .wall {
                    wallRow = row
                    wallCol = col
                    break
                }
            }
            if wallRow != -1 { break }
        }
        
        // If there's a wall, test collision
        if wallRow != -1 {
            state.projectiles.append(Projectile(row: wallRow - 1, col: wallCol, direction: .down))
            state.updateProjectiles()
            
            // Projectile should be removed (hit wall)
            XCTAssertEqual(state.projectiles.count, 0)
        }
    }
    
    func testUpdateProjectilesHitsLocalTank() {
        let state = GameState(seed: 12345, isPlayer1: true)
        
        // Place projectile to hit local tank
        let localRow = state.localTank.row
        let localCol = state.localTank.col
        state.projectiles.append(Projectile(row: localRow - 1, col: localCol, direction: .down))
        
        state.updateProjectiles()
        
        // Local tank should be dead
        XCTAssertFalse(state.localTank.isAlive)
        // Projectile should be removed
        XCTAssertEqual(state.projectiles.count, 0)
    }
    
    func testUpdateProjectilesHitsRemoteTank() {
        let state = GameState(seed: 12345, isPlayer1: true)
        
        // Place projectile to hit remote tank
        let remoteRow = state.remoteTank.row
        let remoteCol = state.remoteTank.col
        state.projectiles.append(Projectile(row: remoteRow + 1, col: remoteCol, direction: .up))
        
        state.updateProjectiles()
        
        // Remote tank should be dead
        XCTAssertFalse(state.remoteTank.isAlive)
        // Projectile should be removed
        XCTAssertEqual(state.projectiles.count, 0)
    }
    
    func testIsRoundOverWhenLocalTankDead() {
        let state = GameState(seed: 12345, isPlayer1: true)
        state.localTank.isAlive = false
        
        XCTAssertTrue(state.isRoundOver())
    }
    
    func testIsRoundOverWhenRemoteTankDead() {
        let state = GameState(seed: 12345, isPlayer1: true)
        state.remoteTank.isAlive = false
        
        XCTAssertTrue(state.isRoundOver())
    }
    
    func testIsRoundOverWhenBothTanksAlive() {
        let state = GameState(seed: 12345, isPlayer1: true)
        
        XCTAssertFalse(state.isRoundOver())
    }
    
    func testIsRoundOverWhenBothTanksDead() {
        let state = GameState(seed: 12345, isPlayer1: true)
        state.localTank.isAlive = false
        state.remoteTank.isAlive = false
        
        XCTAssertTrue(state.isRoundOver())
    }
    
    func testLocalPlayerWonWhenRemoteTankDead() {
        let state = GameState(seed: 12345, isPlayer1: true)
        state.remoteTank.isAlive = false
        
        XCTAssertTrue(state.localPlayerWon())
    }
    
    func testLocalPlayerLostWhenLocalTankDead() {
        let state = GameState(seed: 12345, isPlayer1: true)
        state.localTank.isAlive = false
        
        XCTAssertFalse(state.localPlayerWon())
    }
    
    func testLocalPlayerLostWhenBothTanksDead() {
        let state = GameState(seed: 12345, isPlayer1: true)
        state.localTank.isAlive = false
        state.remoteTank.isAlive = false
        
        // If both are dead, local player didn't win
        XCTAssertFalse(state.localPlayerWon())
    }
}
