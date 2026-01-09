//
//  GameStateTests.swift
//  tankgame Tests
//
//  Unit tests for GameState class
//

import XCTest
@testable import Tank_Game

final class GameStateTests: XCTestCase {

    // MARK: - Initialization Tests

    func testGameStateInitialization() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)

        XCTAssertEqual(gameState.tanks.count, 2)
        XCTAssertEqual(gameState.wins.count, 2)
        XCTAssertEqual(gameState.localPlayerIndex, 0)
        XCTAssertEqual(gameState.projectiles.count, 0)
        XCTAssertEqual(gameState.grid.count, 8)
    }

    func testGameStateInitializationWithFourPlayers() {
        let gameState = GameState(seed: 12345, playerCount: 4, localPlayerIndex: 2)

        XCTAssertEqual(gameState.tanks.count, 4)
        XCTAssertEqual(gameState.wins.count, 4)
        XCTAssertEqual(gameState.localPlayerIndex, 2)
    }

    func testTanksStartAtSpawnPositions() {
        let gameState = GameState(seed: 12345, playerCount: 4, localPlayerIndex: 0)

        // Player 0: top-left (0, 0)
        XCTAssertEqual(gameState.tanks[0].row, 0)
        XCTAssertEqual(gameState.tanks[0].col, 0)
        XCTAssertEqual(gameState.tanks[0].direction, .down)

        // Player 1: bottom-right (7, 7)
        XCTAssertEqual(gameState.tanks[1].row, 7)
        XCTAssertEqual(gameState.tanks[1].col, 7)
        XCTAssertEqual(gameState.tanks[1].direction, .up)

        // Player 2: top-right (0, 7)
        XCTAssertEqual(gameState.tanks[2].row, 0)
        XCTAssertEqual(gameState.tanks[2].col, 7)
        XCTAssertEqual(gameState.tanks[2].direction, .down)

        // Player 3: bottom-left (7, 0)
        XCTAssertEqual(gameState.tanks[3].row, 7)
        XCTAssertEqual(gameState.tanks[3].col, 0)
        XCTAssertEqual(gameState.tanks[3].direction, .up)
    }

    func testAllTanksStartAlive() {
        let gameState = GameState(seed: 12345, playerCount: 4, localPlayerIndex: 0)

        for tank in gameState.tanks {
            XCTAssertTrue(tank.isAlive)
        }
    }

    func testWinsInitializedToZero() {
        let gameState = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)

        for wins in gameState.wins {
            XCTAssertEqual(wins, 0)
        }
    }

    // MARK: - Local Tank Tests

    func testLocalTankGetter() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 1)

        let localTank = gameState.localTank
        XCTAssertEqual(localTank.row, gameState.tanks[1].row)
        XCTAssertEqual(localTank.col, gameState.tanks[1].col)
    }

    func testLocalTankSetter() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)

        var modifiedTank = gameState.localTank
        modifiedTank.row = 5
        modifiedTank.col = 5
        gameState.localTank = modifiedTank

        XCTAssertEqual(gameState.tanks[0].row, 5)
        XCTAssertEqual(gameState.tanks[0].col, 5)
    }

    // MARK: - Reset Tests

    func testResetClearsProjectiles() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.projectiles.append(Projectile(row: 3, col: 3, direction: .up))
        gameState.projectiles.append(Projectile(row: 4, col: 4, direction: .down))

        gameState.reset(seed: 54321)

        XCTAssertEqual(gameState.projectiles.count, 0)
    }

    func testResetRestoresTanksToSpawnPositions() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)

        // Move tanks
        gameState.tanks[0].row = 5
        gameState.tanks[0].col = 5
        gameState.tanks[1].row = 2
        gameState.tanks[1].col = 2

        gameState.reset(seed: 54321)

        // Verify tanks are back at spawn positions
        XCTAssertEqual(gameState.tanks[0].row, 0)
        XCTAssertEqual(gameState.tanks[0].col, 0)
        XCTAssertEqual(gameState.tanks[1].row, 7)
        XCTAssertEqual(gameState.tanks[1].col, 7)
    }

    func testResetMakesAllTanksAlive() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)

        // Kill tanks
        gameState.tanks[0].isAlive = false
        gameState.tanks[1].isAlive = false

        gameState.reset(seed: 54321)

        // Verify all tanks are alive
        for tank in gameState.tanks {
            XCTAssertTrue(tank.isAlive)
        }
    }

    // MARK: - Projectile Update Tests

    func testUpdateProjectilesAdvancesProjectiles() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.projectiles.append(Projectile(row: 4, col: 4, direction: .up))

        gameState.updateProjectiles()

        XCTAssertEqual(gameState.projectiles.count, 1)
        XCTAssertEqual(gameState.projectiles[0].row, 3)
        XCTAssertEqual(gameState.projectiles[0].col, 4)
    }

    func testUpdateProjectilesRemovesOutOfBoundsProjectiles() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.projectiles.append(Projectile(row: 0, col: 4, direction: .up))

        gameState.updateProjectiles()

        XCTAssertEqual(gameState.projectiles.count, 0)
    }

    func testUpdateProjectilesRemovesProjectilesThatHitWalls() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        // Place a wall
        gameState.grid[3][4] = .wall
        // Place a projectile heading toward the wall
        gameState.projectiles.append(Projectile(row: 4, col: 4, direction: .up))

        gameState.updateProjectiles()

        // Projectile should be removed after hitting the wall
        XCTAssertEqual(gameState.projectiles.count, 0)
    }

    func testUpdateProjectilesKillsTanksAndRemovesProjectile() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        // Place tank at specific location
        gameState.tanks[1].row = 3
        gameState.tanks[1].col = 4
        // Place projectile that will hit the tank
        gameState.projectiles.append(Projectile(row: 4, col: 4, direction: .up))

        gameState.updateProjectiles()

        // Tank should be dead, projectile should be removed
        XCTAssertFalse(gameState.tanks[1].isAlive)
        XCTAssertEqual(gameState.projectiles.count, 0)
    }

    // MARK: - Round Over Tests

    func testRoundIsNotOverWithMultipleAliveTanks() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)

        XCTAssertFalse(gameState.isRoundOver())
    }

    func testRoundIsOverWithOneTankAlive() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.tanks[1].isAlive = false

        XCTAssertTrue(gameState.isRoundOver())
    }

    func testRoundIsOverWithNoTanksAlive() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.tanks[0].isAlive = false
        gameState.tanks[1].isAlive = false

        XCTAssertTrue(gameState.isRoundOver())
    }

    // MARK: - Winner Tests

    func testLocalPlayerWonWhenOnlyOneAlive() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.tanks[1].isAlive = false

        XCTAssertTrue(gameState.localPlayerWon())
    }

    func testLocalPlayerDidNotWinWhenDead() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.tanks[0].isAlive = false

        XCTAssertFalse(gameState.localPlayerWon())
    }

    func testLocalPlayerDidNotWinWithMultipleAliveTanks() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)

        XCTAssertFalse(gameState.localPlayerWon())
    }

    func testGetWinnerReturnsCorrectPlayerIndex() {
        var gameState = GameState(seed: 12345, playerCount: 4, localPlayerIndex: 0)
        gameState.tanks[0].isAlive = false
        gameState.tanks[1].isAlive = false
        gameState.tanks[2].isAlive = true
        gameState.tanks[3].isAlive = false

        let winner = gameState.getWinner()

        XCTAssertEqual(winner, 2)
    }

    func testGetWinnerReturnsNilWithMultipleSurvivors() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.tanks[0].isAlive = true
        gameState.tanks[1].isAlive = true

        let winner = gameState.getWinner()

        XCTAssertNil(winner)
    }

    func testGetWinnerReturnsNilWithNoSurvivors() {
        var gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        gameState.tanks[0].isAlive = false
        gameState.tanks[1].isAlive = false

        let winner = gameState.getWinner()

        XCTAssertNil(winner)
    }

    // MARK: - Lizard Tests

    func testLizardsSpawnedWhenEnabled() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)

        if gameState.lizardsEnabled {
            XCTAssertEqual(gameState.lizards.count, GameState.lizardCount)
        }
    }

    func testLizardsStartAlive() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)

        for lizard in gameState.lizards {
            XCTAssertTrue(lizard.isAlive)
        }
    }
}
