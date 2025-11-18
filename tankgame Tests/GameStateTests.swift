//
//  GameStateTests.swift
//  tankgame Tests
//
//  Unit tests for GameState
//

import XCTest
@testable import Tank_Game

final class GameStateTests: XCTestCase {
    
    func testGameStateInitializationWith2Players() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        XCTAssertEqual(gameState.tanks.count, 2)
        XCTAssertEqual(gameState.wins.count, 2)
        XCTAssertEqual(gameState.localPlayerIndex, 0)
        XCTAssertTrue(gameState.projectiles.isEmpty)
    }
    
    func testGameStateInitializationWith4Players() {
        let gameState = GameState(seed: 12345, playerCount: 4, localPlayerIndex: 2)
        
        XCTAssertEqual(gameState.tanks.count, 4)
        XCTAssertEqual(gameState.wins.count, 4)
        XCTAssertEqual(gameState.localPlayerIndex, 2)
    }
    
    func testGameStateSpawnPositions() {
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
    
    func testGameStateAllTanksAliveInitially() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        
        for tank in gameState.tanks {
            XCTAssertTrue(tank.isAlive)
        }
    }
    
    func testGameStateWinsInitializedToZero() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 1)
        
        for wins in gameState.wins {
            XCTAssertEqual(wins, 0)
        }
    }
    
    func testGameStateLocalTankGetter() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 1)
        
        let localTank = gameState.localTank
        XCTAssertEqual(localTank.row, 7) // Player 1 spawns at bottom-right
        XCTAssertEqual(localTank.col, 7)
    }
    
    func testGameStateLocalTankSetter() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        gameState.localTank = Tank(row: 5, col: 5, direction: .right)
        
        XCTAssertEqual(gameState.tanks[0].row, 5)
        XCTAssertEqual(gameState.tanks[0].col, 5)
        XCTAssertEqual(gameState.tanks[0].direction, .right)
    }
    
    func testGameStateResetClearProjectiles() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.projectiles = [
            Projectile(row: 2, col: 3, direction: .up),
            Projectile(row: 4, col: 5, direction: .down)
        ]
        
        gameState.reset(seed: 54321)
        
        XCTAssertTrue(gameState.projectiles.isEmpty)
    }
    
    func testGameStateResetRestoresTankPositions() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Move tanks away from spawn
        gameState.tanks[0] = Tank(row: 4, col: 4, direction: .left)
        gameState.tanks[1] = Tank(row: 3, col: 3, direction: .right)
        
        gameState.reset(seed: 54321)
        
        // Should be back at spawn positions
        XCTAssertEqual(gameState.tanks[0].row, 0)
        XCTAssertEqual(gameState.tanks[0].col, 0)
        XCTAssertEqual(gameState.tanks[1].row, 7)
        XCTAssertEqual(gameState.tanks[1].col, 7)
    }
    
    func testGameStateUpdateProjectilesRemovesOutOfBounds() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.projectiles = [
            Projectile(row: -1, col: 3, direction: .up), // Out of bounds
            Projectile(row: 3, col: 3, direction: .down)  // In bounds
        ]
        
        gameState.updateProjectiles()
        
        XCTAssertEqual(gameState.projectiles.count, 1)
        XCTAssertEqual(gameState.projectiles[0].row, 4) // Advanced one step
    }
    
    func testGameStateUpdateProjectilesRemovesWallHits() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        // Place a wall
        gameState.grid[3][3] = .wall
        
        gameState.projectiles = [
            Projectile(row: 3, col: 3, direction: .up), // Hits wall
            Projectile(row: 5, col: 5, direction: .down) // Misses wall
        ]
        
        gameState.updateProjectiles()
        
        XCTAssertEqual(gameState.projectiles.count, 1)
        XCTAssertEqual(gameState.projectiles[0].row, 6) // Advanced
    }
    
    func testGameStateUpdateProjectilesKillsTanks() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Position projectile to hit tank
        gameState.projectiles = [
            Projectile(row: gameState.tanks[1].row, col: gameState.tanks[1].col, direction: .up)
        ]
        
        gameState.updateProjectiles()
        
        XCTAssertFalse(gameState.tanks[1].isAlive)
        XCTAssertTrue(gameState.projectiles.isEmpty) // Projectile removed after hit
    }
    
    func testGameStateIsRoundOverWithOneTankAlive() {
        var gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        
        gameState.tanks[1].isAlive = false
        gameState.tanks[2].isAlive = false
        
        XCTAssertTrue(gameState.isRoundOver())
    }
    
    func testGameStateIsRoundOverWithAllTanksDead() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        gameState.tanks[0].isAlive = false
        gameState.tanks[1].isAlive = false
        
        XCTAssertTrue(gameState.isRoundOver())
    }
    
    func testGameStateIsRoundNotOverWithMultipleTanksAlive() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        
        XCTAssertFalse(gameState.isRoundOver())
    }
    
    func testGameStateLocalPlayerWonWhenOnlyLocalAlive() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        gameState.tanks[1].isAlive = false
        
        XCTAssertTrue(gameState.localPlayerWon())
    }
    
    func testGameStateLocalPlayerDidNotWinWhenDead() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        gameState.tanks[0].isAlive = false
        
        XCTAssertFalse(gameState.localPlayerWon())
    }
    
    func testGameStateLocalPlayerDidNotWinWithOthersAlive() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        
        XCTAssertFalse(gameState.localPlayerWon())
    }
    
    func testGameStateGetWinnerReturnsCorrectPlayer() {
        var gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        
        gameState.tanks[0].isAlive = false
        gameState.tanks[1].isAlive = false
        // Only tank 2 alive
        
        let winner = gameState.getWinner()
        XCTAssertEqual(winner, 2)
    }
    
    func testGameStateGetWinnerReturnsNilWithMultipleSurvivors() {
        var gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        
        gameState.tanks[0].isAlive = false
        // Tanks 1 and 2 still alive
        
        let winner = gameState.getWinner()
        XCTAssertNil(winner)
    }
    
    func testGameStateGetWinnerReturnsNilWithNoSurvivors() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        gameState.tanks[0].isAlive = false
        gameState.tanks[1].isAlive = false
        
        let winner = gameState.getWinner()
        XCTAssertNil(winner)
    }
    
    func testGameStateGridIsGenerated() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        XCTAssertEqual(gameState.grid.count, 8)
        XCTAssertEqual(gameState.grid[0].count, 8)
    }
    
    func testGameStateDifferentSeedsGenerateDifferentGrids() {
        let gameState1 = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        let gameState2 = GameState(seed: 54321, playerCount: 2, localPlayerIndex: 0)
        
        // Compare some cells to verify they're different
        var hasDifference = false
        for row in 0..<8 {
            for col in 0..<8 {
                if gameState1.grid[row][col] != gameState2.grid[row][col] {
                    hasDifference = true
                    break
                }
            }
            if hasDifference { break }
        }
        
        XCTAssertTrue(hasDifference, "Different seeds should generate different grids")
    }
}
