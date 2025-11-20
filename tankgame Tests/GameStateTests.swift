//
//  GameStateTests.swift
//  tankgame Tests
//
//  Unit tests for GameState logic
//

import XCTest
@testable import tankgame_iOS

final class GameStateTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testGameStateInitialization() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        XCTAssertEqual(gameState.tanks.count, 2, "Should have 2 tanks")
        XCTAssertEqual(gameState.wins.count, 2, "Should have wins array for 2 players")
        XCTAssertEqual(gameState.localPlayerIndex, 0)
        XCTAssertEqual(gameState.projectiles.count, 0, "Should start with no projectiles")
        XCTAssertEqual(gameState.grid.count, 8, "Grid should be 8x8")
    }
    
    func testInitialTankPositions() {
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
    
    func testInitialWinsAreZero() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        for wins in gameState.wins {
            XCTAssertEqual(wins, 0, "All players should start with 0 wins")
        }
    }
    
    // MARK: - Reset Tests
    
    func testResetResetsGrid() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        let originalGrid = gameState.grid
        
        gameState.reset(seed: 54321)
        
        var gridChanged = false
        for row in 0..<originalGrid.count {
            for col in 0..<originalGrid[row].count {
                if originalGrid[row][col] != gameState.grid[row][col] {
                    gridChanged = true
                    break
                }
            }
            if gridChanged { break }
        }
        
        XCTAssertTrue(gridChanged, "Reset with different seed should change grid")
    }
    
    func testResetClearsProjectiles() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.projectiles.append(Projectile(row: 3, col: 3, direction: .up))
        gameState.projectiles.append(Projectile(row: 4, col: 4, direction: .down))
        
        gameState.reset(seed: 12345)
        
        XCTAssertEqual(gameState.projectiles.count, 0, "Reset should clear all projectiles")
    }
    
    func testResetRestoresTankPositions() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Modify tank positions
        gameState.tanks[0].row = 5
        gameState.tanks[0].col = 5
        gameState.tanks[1].isAlive = false
        
        gameState.reset(seed: 12345)
        
        // Verify tanks are back at spawn positions
        XCTAssertEqual(gameState.tanks[0].row, 0)
        XCTAssertEqual(gameState.tanks[0].col, 0)
        XCTAssertTrue(gameState.tanks[0].isAlive)
        
        XCTAssertEqual(gameState.tanks[1].row, 7)
        XCTAssertEqual(gameState.tanks[1].col, 7)
        XCTAssertTrue(gameState.tanks[1].isAlive)
    }
    
    func testResetDoesNotChangeWins() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.wins[0] = 3
        gameState.wins[1] = 2
        
        gameState.reset(seed: 12345)
        
        XCTAssertEqual(gameState.wins[0], 3, "Reset should not change win count")
        XCTAssertEqual(gameState.wins[1], 2, "Reset should not change win count")
    }
    
    // MARK: - Local Tank Tests
    
    func testLocalTankGetter() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 1)
        
        let localTank = gameState.localTank
        
        XCTAssertEqual(localTank.row, gameState.tanks[1].row)
        XCTAssertEqual(localTank.col, gameState.tanks[1].col)
    }
    
    func testLocalTankSetter() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 1)
        
        var modifiedTank = gameState.localTank
        modifiedTank.row = 5
        modifiedTank.col = 5
        gameState.localTank = modifiedTank
        
        XCTAssertEqual(gameState.tanks[1].row, 5)
        XCTAssertEqual(gameState.tanks[1].col, 5)
    }
    
    // MARK: - Projectile Update Tests
    
    func testUpdateProjectilesAdvancesPosition() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.projectiles.append(Projectile(row: 3, col: 3, direction: .up))
        
        gameState.updateProjectiles()
        
        XCTAssertEqual(gameState.projectiles.count, 1)
        XCTAssertEqual(gameState.projectiles[0].row, 2, "Projectile should advance")
    }
    
    func testUpdateProjectilesRemovesOutOfBounds() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.projectiles.append(Projectile(row: 0, col: 3, direction: .up))
        
        gameState.updateProjectiles()
        
        XCTAssertEqual(gameState.projectiles.count, 0, "Out of bounds projectile should be removed")
    }
    
    func testUpdateProjectilesRemovesWallHits() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Find a wall in the grid
        var wallPosition: (row: Int, col: Int)?
        for row in 0..<gameState.grid.count {
            for col in 0..<gameState.grid[row].count {
                if gameState.grid[row][col] == .wall {
                    wallPosition = (row, col)
                    break
                }
            }
            if wallPosition != nil { break }
        }
        
        guard let wallPos = wallPosition else {
            XCTFail("Test grid should have at least one wall")
            return
        }
        
        // Create projectile that will hit the wall
        gameState.projectiles.append(Projectile(row: wallPos.row - 1, col: wallPos.col, direction: .down))
        
        gameState.updateProjectiles()
        
        XCTAssertEqual(gameState.projectiles.count, 0, "Projectile hitting wall should be removed")
    }
    
    func testUpdateProjectilesKillsTank() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Place projectile to hit tank at (7,7)
        gameState.projectiles.append(Projectile(row: 6, col: 7, direction: .down))
        
        XCTAssertTrue(gameState.tanks[1].isAlive, "Tank should be alive initially")
        
        gameState.updateProjectiles()
        
        XCTAssertFalse(gameState.tanks[1].isAlive, "Tank should be dead after being hit")
        XCTAssertEqual(gameState.projectiles.count, 0, "Projectile should be removed after hitting tank")
    }
    
    func testUpdateProjectilesWithMultipleProjectiles() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Add multiple projectiles
        gameState.projectiles.append(Projectile(row: 3, col: 3, direction: .up))
        gameState.projectiles.append(Projectile(row: 4, col: 4, direction: .down))
        gameState.projectiles.append(Projectile(row: 0, col: 0, direction: .up)) // Will go out of bounds
        
        gameState.updateProjectiles()
        
        // Two should remain (one went out of bounds)
        XCTAssertEqual(gameState.projectiles.count, 2, "Only valid projectiles should remain")
    }
    
    // MARK: - Round Over Tests
    
    func testRoundNotOverWithAllTanksAlive() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        
        XCTAssertFalse(gameState.isRoundOver(), "Round should not be over with all tanks alive")
    }
    
    func testRoundNotOverWithTwoTanksAlive() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        gameState.tanks[2].isAlive = false
        
        XCTAssertFalse(gameState.isRoundOver(), "Round should not be over with 2 tanks alive")
    }
    
    func testRoundOverWithOneTankAlive() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        gameState.tanks[1].isAlive = false
        gameState.tanks[2].isAlive = false
        
        XCTAssertTrue(gameState.isRoundOver(), "Round should be over with only 1 tank alive")
    }
    
    func testRoundOverWithNoTanksAlive() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.tanks[0].isAlive = false
        gameState.tanks[1].isAlive = false
        
        XCTAssertTrue(gameState.isRoundOver(), "Round should be over with no tanks alive")
    }
    
    // MARK: - Winner Tests
    
    func testGetWinnerReturnsOnlySurvivor() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        gameState.tanks[0].isAlive = false
        gameState.tanks[2].isAlive = false
        
        let winner = gameState.getWinner()
        
        XCTAssertEqual(winner, 1, "Winner should be player 1")
    }
    
    func testGetWinnerReturnsNilWithMultipleSurvivors() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        gameState.tanks[2].isAlive = false
        
        let winner = gameState.getWinner()
        
        XCTAssertNil(winner, "Should be no winner with multiple survivors")
    }
    
    func testGetWinnerReturnsNilWithNoSurvivors() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.tanks[0].isAlive = false
        gameState.tanks[1].isAlive = false
        
        let winner = gameState.getWinner()
        
        XCTAssertNil(winner, "Should be no winner when all tanks are dead")
    }
    
    func testLocalPlayerWon() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        gameState.tanks[1].isAlive = false
        gameState.tanks[2].isAlive = false
        
        XCTAssertTrue(gameState.localPlayerWon(), "Local player should be winner")
    }
    
    func testLocalPlayerDidNotWin() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        gameState.tanks[0].isAlive = false
        gameState.tanks[2].isAlive = false
        
        XCTAssertFalse(gameState.localPlayerWon(), "Local player should not be winner")
    }
    
    func testLocalPlayerDidNotWinWhenDead() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 1)
        gameState.tanks[1].isAlive = false
        
        XCTAssertFalse(gameState.localPlayerWon(), "Dead local player cannot win")
    }
    
    func testLocalPlayerDidNotWinWithMultipleSurvivors() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        gameState.tanks[2].isAlive = false
        
        XCTAssertFalse(gameState.localPlayerWon(), "Local player should not win with multiple survivors")
    }
    
    // MARK: - Integration Tests
    
    func testCompleteGameScenario() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Simulate a game where player 0 shoots and kills player 1
        let projectile = gameState.localTank.shoot()
        gameState.projectiles.append(projectile)
        
        // Move projectile towards opponent (multiple updates may be needed)
        var maxUpdates = 20 // Prevent infinite loop
        while gameState.tanks[1].isAlive && maxUpdates > 0 {
            gameState.updateProjectiles()
            maxUpdates -= 1
        }
        
        // Check if round is over
        if gameState.isRoundOver() {
            let winner = gameState.getWinner()
            if let winner = winner {
                gameState.wins[winner] += 1
            }
            
            // Local player should have won
            XCTAssertEqual(winner, 0, "Player 0 should win")
            XCTAssertEqual(gameState.wins[0], 1, "Player 0 should have 1 win")
            XCTAssertTrue(gameState.localPlayerWon())
        }
    }
}
