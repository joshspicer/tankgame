//
//  GameStateTests.swift
//  TankGameCoreTests
//
//  Tests for the GameState class
//

import XCTest
@testable import TankGameCore

final class GameStateTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testInitializationWithTwoPlayers() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        XCTAssertEqual(state.tanks.count, 2)
        XCTAssertEqual(state.wins.count, 2)
        XCTAssertEqual(state.localPlayerIndex, 0)
        XCTAssertTrue(state.projectiles.isEmpty)
    }
    
    func testInitializationWithFourPlayers() {
        let state = GameState(seed: 12345, playerCount: 4, localPlayerIndex: 2)
        
        XCTAssertEqual(state.tanks.count, 4)
        XCTAssertEqual(state.wins.count, 4)
        XCTAssertEqual(state.localPlayerIndex, 2)
    }
    
    func testInitialTankPositions() {
        let state = GameState(seed: 12345, playerCount: 4, localPlayerIndex: 0)
        
        // Player 0: top-left
        XCTAssertEqual(state.tanks[0].row, 0)
        XCTAssertEqual(state.tanks[0].col, 0)
        XCTAssertEqual(state.tanks[0].direction, .down)
        
        // Player 1: bottom-right
        XCTAssertEqual(state.tanks[1].row, 7)
        XCTAssertEqual(state.tanks[1].col, 7)
        XCTAssertEqual(state.tanks[1].direction, .up)
        
        // Player 2: top-right
        XCTAssertEqual(state.tanks[2].row, 0)
        XCTAssertEqual(state.tanks[2].col, 7)
        XCTAssertEqual(state.tanks[2].direction, .down)
        
        // Player 3: bottom-left
        XCTAssertEqual(state.tanks[3].row, 7)
        XCTAssertEqual(state.tanks[3].col, 0)
        XCTAssertEqual(state.tanks[3].direction, .up)
    }
    
    func testAllTanksStartAlive() {
        let state = GameState(seed: 12345, playerCount: 4, localPlayerIndex: 0)
        
        for tank in state.tanks {
            XCTAssertTrue(tank.isAlive)
        }
    }
    
    func testWinsInitializedToZero() {
        let state = GameState(seed: 12345, playerCount: 4, localPlayerIndex: 0)
        
        for wins in state.wins {
            XCTAssertEqual(wins, 0)
        }
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
    
    // MARK: - Reset Tests
    
    func testResetClearsProjectiles() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        state.projectiles.append(Projectile(row: 4, col: 4, direction: .up))
        
        state.reset(seed: 54321)
        
        XCTAssertTrue(state.projectiles.isEmpty)
    }
    
    func testResetRestoresTankPositions() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Move tanks from starting positions
        state.tanks[0].row = 5
        state.tanks[0].col = 5
        state.tanks[1].isAlive = false
        
        state.reset(seed: 54321)
        
        // Check tanks are back at spawn positions
        XCTAssertEqual(state.tanks[0].row, 0)
        XCTAssertEqual(state.tanks[0].col, 0)
        XCTAssertEqual(state.tanks[1].row, 7)
        XCTAssertEqual(state.tanks[1].col, 7)
        XCTAssertTrue(state.tanks[0].isAlive)
        XCTAssertTrue(state.tanks[1].isAlive)
    }
    
    // MARK: - Round Over Tests
    
    func testRoundNotOverWithMultipleTanksAlive() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        XCTAssertFalse(state.isRoundOver())
    }
    
    func testRoundOverWithOneTankAlive() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        state.tanks[1].isAlive = false
        
        XCTAssertTrue(state.isRoundOver())
    }
    
    func testRoundOverWithNoTanksAlive() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        state.tanks[0].isAlive = false
        state.tanks[1].isAlive = false
        
        XCTAssertTrue(state.isRoundOver())
    }
    
    // MARK: - Winner Tests
    
    func testLocalPlayerWonWhenOnlyAlive() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        state.tanks[1].isAlive = false
        
        XCTAssertTrue(state.localPlayerWon())
    }
    
    func testLocalPlayerNotWonWhenDead() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        state.tanks[0].isAlive = false
        
        XCTAssertFalse(state.localPlayerWon())
    }
    
    func testLocalPlayerNotWonWithMultipleAlive() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        XCTAssertFalse(state.localPlayerWon())
    }
    
    func testGetWinnerReturnsWinnerIndex() {
        let state = GameState(seed: 12345, playerCount: 3, localPlayerIndex: 0)
        state.tanks[0].isAlive = false
        state.tanks[2].isAlive = false
        
        XCTAssertEqual(state.getWinner(), 1)
    }
    
    func testGetWinnerReturnsNilWithMultipleAlive() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        XCTAssertNil(state.getWinner())
    }
    
    func testGetWinnerReturnsNilWithNoneAlive() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        state.tanks[0].isAlive = false
        state.tanks[1].isAlive = false
        
        XCTAssertNil(state.getWinner())
    }
    
    // MARK: - Projectile Update Tests
    
    func testUpdateProjectilesAdvancesProjectiles() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Add a projectile far from any tank
        state.projectiles.append(Projectile(row: 4, col: 4, direction: .right))
        
        state.updateProjectiles()
        
        XCTAssertEqual(state.projectiles.count, 1)
        XCTAssertEqual(state.projectiles[0].row, 4)
        XCTAssertEqual(state.projectiles[0].col, 5)
    }
    
    func testUpdateProjectilesRemovesOutOfBounds() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Add a projectile about to go out of bounds
        state.projectiles.append(Projectile(row: 0, col: 4, direction: .up))
        
        state.updateProjectiles()
        
        XCTAssertTrue(state.projectiles.isEmpty)
    }
    
    func testUpdateProjectilesKillsTank() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Position projectile to hit tank 1 after advance
        // Tank 1 is at (7, 7), so we need projectile at (6, 7) moving down
        state.projectiles.append(Projectile(row: 6, col: 7, direction: .down))
        
        state.updateProjectiles()
        
        XCTAssertFalse(state.tanks[1].isAlive)
        XCTAssertTrue(state.projectiles.isEmpty)
    }
    
    func testUpdateProjectilesDoesNotKillDeadTank() {
        let state = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        state.tanks[1].isAlive = false
        
        // Position projectile at dead tank's position
        state.projectiles.append(Projectile(row: 6, col: 7, direction: .down))
        
        state.updateProjectiles()
        
        // Projectile should still exist (didn't "hit" dead tank)
        XCTAssertEqual(state.projectiles.count, 1)
    }
}
