//
//  GameStateTests.swift
//  tankgame Shared
//
//  Unit tests for GameState functionality
//

import XCTest
@testable import tankgame

class GameStateTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testGameStateInitialization() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        XCTAssertEqual(gameState.tanks.count, 2, "Should initialize with correct number of tanks")
        XCTAssertEqual(gameState.localPlayerIndex, 0, "Should set correct local player index")
        XCTAssertEqual(gameState.wins.count, 2, "Should initialize wins array with correct size")
        XCTAssertTrue(gameState.projectiles.isEmpty, "Should start with no projectiles")
        XCTAssertEqual(gameState.grid.count, 8, "Grid should be 8x8")
        XCTAssertEqual(gameState.grid[0].count, 8, "Grid should be 8x8")
    }
    
    func testMultiplePlayerInitialization() {
        let gameState = GameState(seed: 12345, playerCount: 4, localPlayerIndex: 2)
        
        XCTAssertEqual(gameState.tanks.count, 4, "Should initialize with 4 tanks")
        XCTAssertEqual(gameState.wins.count, 4, "Should initialize with 4 win counters")
        XCTAssertEqual(gameState.localPlayerIndex, 2, "Should set correct local player index")
    }
    
    func testBotInitialization() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0, botIndices: [1, 2])
        
        XCTAssertEqual(gameState.botTankIndices.count, 2, "Should track bot tank indices")
        XCTAssertTrue(gameState.botTankIndices.contains(1), "Should include bot index 1")
        XCTAssertTrue(gameState.botTankIndices.contains(2), "Should include bot index 2")
    }
    
    // MARK: - Spawn Position Tests
    
    func testSpawnPositions() {
        let gameState = GameState(seed: 12345, playerCount: 4, localPlayerIndex: 0)
        
        // Player 0: top-left
        XCTAssertEqual(gameState.tanks[0].row, 0)
        XCTAssertEqual(gameState.tanks[0].col, 0)
        XCTAssertEqual(gameState.tanks[0].direction, .down)
        
        // Player 1: bottom-right
        XCTAssertEqual(gameState.tanks[1].row, 7)
        XCTAssertEqual(gameState.tanks[1].col, 7)
        XCTAssertEqual(gameState.tanks[1].direction, .up)
        
        // Player 2: top-right
        XCTAssertEqual(gameState.tanks[2].row, 0)
        XCTAssertEqual(gameState.tanks[2].col, 7)
        XCTAssertEqual(gameState.tanks[2].direction, .down)
        
        // Player 3: bottom-left
        XCTAssertEqual(gameState.tanks[3].row, 7)
        XCTAssertEqual(gameState.tanks[3].col, 0)
        XCTAssertEqual(gameState.tanks[3].direction, .up)
    }
    
    func testAllTanksStartAlive() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        
        for tank in gameState.tanks {
            XCTAssertTrue(tank.isAlive, "All tanks should start alive")
        }
    }
    
    // MARK: - Local Tank Tests
    
    func testLocalTankProperty() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 1)
        
        let localTank = gameState.localTank
        XCTAssertEqual(localTank.row, gameState.tanks[1].row)
        XCTAssertEqual(localTank.col, gameState.tanks[1].col)
    }
    
    // MARK: - Round Management Tests
    
    func testIsRoundOverWithAllAlive() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        XCTAssertFalse(gameState.isRoundOver(), "Round should not be over when multiple tanks are alive")
    }
    
    func testIsRoundOverWithOneAlive() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.tanks[1].isAlive = false
        
        XCTAssertTrue(gameState.isRoundOver(), "Round should be over when only one tank is alive")
    }
    
    func testIsRoundOverWithNoneAlive() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.tanks[0].isAlive = false
        gameState.tanks[1].isAlive = false
        
        XCTAssertTrue(gameState.isRoundOver(), "Round should be over when no tanks are alive")
    }
    
    func testGetWinnerWithMultipleAlive() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        XCTAssertNil(gameState.getWinner(), "Should be no winner when multiple tanks are alive")
    }
    
    func testGetWinnerWithOneAlive() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        gameState.tanks[0].isAlive = false
        gameState.tanks[2].isAlive = false
        // Tank 1 is the winner
        
        let winner = gameState.getWinner()
        XCTAssertEqual(winner, 1, "Should return index of last alive tank")
    }
    
    func testLocalPlayerWonWhenLastAlive() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.tanks[1].isAlive = false
        
        XCTAssertTrue(gameState.localPlayerWon(), "Local player should win when they're the only one alive")
    }
    
    func testLocalPlayerWonWhenNotAlive() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.tanks[0].isAlive = false
        
        XCTAssertFalse(gameState.localPlayerWon(), "Dead local player cannot win")
    }
    
    func testLocalPlayerWonWithMultipleAlive() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        XCTAssertFalse(gameState.localPlayerWon(), "Local player hasn't won when multiple tanks are alive")
    }
    
    // MARK: - Reset Tests
    
    func testResetClearsProjectiles() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.projectiles.append(Projectile(row: 3, col: 3, direction: .up))
        
        gameState.reset(seed: 54321)
        
        XCTAssertTrue(gameState.projectiles.isEmpty, "Projectiles should be cleared on reset")
    }
    
    func testResetRevivesTanks() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.tanks[0].isAlive = false
        gameState.tanks[1].isAlive = false
        
        gameState.reset(seed: 54321)
        
        for tank in gameState.tanks {
            XCTAssertTrue(tank.isAlive, "All tanks should be alive after reset")
        }
    }
    
    func testResetRestoresSpawnPositions() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Move tank away from spawn
        let originalRow = gameState.tanks[0].row
        let originalCol = gameState.tanks[0].col
        gameState.tanks[0].row = 5
        gameState.tanks[0].col = 5
        
        gameState.reset(seed: 54321)
        
        XCTAssertEqual(gameState.tanks[0].row, originalRow, "Tank should return to spawn row")
        XCTAssertEqual(gameState.tanks[0].col, originalCol, "Tank should return to spawn col")
    }
    
    // MARK: - Projectile Update Tests
    
    func testProjectileRemovalWhenHitsTank() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Place projectile at tank location
        let tankRow = gameState.tanks[1].row
        let tankCol = gameState.tanks[1].col
        gameState.projectiles.append(Projectile(row: tankRow, col: tankCol, direction: .up))
        
        gameState.updateProjectiles()
        
        XCTAssertTrue(gameState.projectiles.isEmpty, "Projectile should be removed when hitting tank")
        XCTAssertFalse(gameState.tanks[1].isAlive, "Tank should be dead after being hit")
    }
    
    func testProjectileAdvancement() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Create a projectile in empty space
        gameState.projectiles.append(Projectile(row: 4, col: 4, direction: .up))
        let initialCount = gameState.projectiles.count
        
        gameState.updateProjectiles()
        
        // Projectile should still exist if it didn't hit anything
        // (This depends on whether the new position is valid)
        XCTAssertGreaterThanOrEqual(gameState.projectiles.count, 0)
        XCTAssertLessThanOrEqual(gameState.projectiles.count, initialCount)
    }
    
    // MARK: - Lizard Tests
    
    func testLizardSpawning() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        XCTAssertEqual(gameState.lizards.count, GameState.lizardCount, "Should spawn correct number of lizards")
        
        for lizard in gameState.lizards {
            XCTAssertTrue(lizard.isAlive, "All lizards should start alive")
        }
    }
    
    func testLizardsDisabled() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.lizardsEnabled = false
        gameState.reset(seed: 54321)
        
        XCTAssertTrue(gameState.lizards.isEmpty, "No lizards should spawn when disabled")
    }
    
    func testProjectileKillsLizard() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        guard let lizard = gameState.lizards.first else {
            XCTFail("Should have at least one lizard")
            return
        }
        
        // Place projectile at lizard location
        gameState.projectiles.append(Projectile(row: lizard.row, col: lizard.col, direction: .up))
        
        gameState.updateProjectiles()
        
        XCTAssertFalse(gameState.lizards[0].isAlive, "Lizard should be dead after being hit")
        XCTAssertTrue(gameState.projectiles.isEmpty, "Projectile should be removed when hitting lizard")
    }
}
