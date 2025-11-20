//
//  TankGameTests.swift
//  Example unit tests for Tank Game
//
//  This file demonstrates how to write unit tests for the Tank Game.
//  To use these tests, create an Xcode test target and add this file to it.
//

import XCTest
@testable import tankgame

/// Example unit tests for core game logic
class TankGameTests: XCTestCase {
    
    // MARK: - Direction Tests
    
    func testDirectionOffsets() {
        XCTAssertEqual(Direction.up.offset.row, -1)
        XCTAssertEqual(Direction.up.offset.col, 0)
        
        XCTAssertEqual(Direction.down.offset.row, 1)
        XCTAssertEqual(Direction.down.offset.col, 0)
        
        XCTAssertEqual(Direction.left.offset.row, 0)
        XCTAssertEqual(Direction.left.offset.col, -1)
        
        XCTAssertEqual(Direction.right.offset.row, 0)
        XCTAssertEqual(Direction.right.offset.col, 1)
    }
    
    // MARK: - Tank Tests
    
    func testTankInitialization() {
        let tank = Tank(row: 3, col: 4, direction: .down)
        XCTAssertEqual(tank.row, 3)
        XCTAssertEqual(tank.col, 4)
        XCTAssertEqual(tank.direction, .down)
        XCTAssertTrue(tank.isAlive)
    }
    
    func testTankMovement() {
        var tank = Tank(row: 3, col: 3, direction: .up)
        let emptyGrid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        
        // Move up should succeed
        let moved = tank.move(in: .up, grid: emptyGrid)
        XCTAssertTrue(moved)
        XCTAssertEqual(tank.row, 2)
        XCTAssertEqual(tank.col, 3)
        XCTAssertEqual(tank.direction, .up)
    }
    
    func testTankCannotMoveThroughWalls() {
        var tank = Tank(row: 3, col: 3, direction: .up)
        var grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        grid[2][3] = .wall  // Place wall in front of tank
        
        // Move up should fail due to wall
        let moved = tank.move(in: .up, grid: grid)
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 3)  // Position unchanged
        XCTAssertEqual(tank.col, 3)
    }
    
    func testTankCannotMoveOutOfBounds() {
        var tank = Tank(row: 0, col: 0, direction: .up)
        let emptyGrid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        
        // Move up from top edge should fail
        let moved = tank.move(in: .up, grid: emptyGrid)
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 0)  // Position unchanged
        XCTAssertEqual(tank.col, 0)
    }
    
    func testTankShoot() {
        let tank = Tank(row: 3, col: 3, direction: .right)
        let projectile = tank.shoot()
        
        // Projectile should be one cell ahead in the facing direction
        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 4)
        XCTAssertEqual(projectile.direction, .right)
    }
    
    // MARK: - Projectile Tests
    
    func testProjectileAdvance() {
        var projectile = Projectile(row: 3, col: 3, direction: .up)
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 3)
    }
    
    func testProjectileOutOfBounds() {
        let projectile1 = Projectile(row: -1, col: 3, direction: .up)
        XCTAssertTrue(projectile1.isOutOfBounds(gridSize: 8))
        
        let projectile2 = Projectile(row: 8, col: 3, direction: .down)
        XCTAssertTrue(projectile2.isOutOfBounds(gridSize: 8))
        
        let projectile3 = Projectile(row: 3, col: 3, direction: .up)
        XCTAssertFalse(projectile3.isOutOfBounds(gridSize: 8))
    }
    
    func testProjectileHitsWall() {
        var grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        grid[3][3] = .wall
        
        let projectile1 = Projectile(row: 3, col: 3, direction: .up)
        XCTAssertTrue(projectile1.hits(grid: grid))
        
        let projectile2 = Projectile(row: 3, col: 4, direction: .up)
        XCTAssertFalse(projectile2.hits(grid: grid))
    }
    
    func testProjectileHitsTank() {
        let tank = Tank(row: 3, col: 3, direction: .up)
        
        let projectile1 = Projectile(row: 3, col: 3, direction: .up)
        XCTAssertTrue(projectile1.hits(tank: tank))
        
        let projectile2 = Projectile(row: 3, col: 4, direction: .up)
        XCTAssertFalse(projectile2.hits(tank: tank))
    }
    
    // MARK: - GridGenerator Tests
    
    func testGridGeneratorDeterminism() {
        let seed: UInt32 = 12345
        let grid1 = GridGenerator.generate(seed: seed)
        let grid2 = GridGenerator.generate(seed: seed)
        
        // Same seed should produce identical grids
        XCTAssertEqual(grid1.count, grid2.count)
        for row in 0..<grid1.count {
            XCTAssertEqual(grid1[row], grid2[row])
        }
    }
    
    func testGridGeneratorSpawnProtection() {
        let grid = GridGenerator.generate(seed: 12345)
        
        // Top-left spawn area should be clear
        XCTAssertEqual(grid[0][0], .empty)
        XCTAssertEqual(grid[0][1], .empty)
        XCTAssertEqual(grid[1][0], .empty)
        XCTAssertEqual(grid[1][1], .empty)
        
        // Bottom-right spawn area should be clear
        XCTAssertEqual(grid[6][6], .empty)
        XCTAssertEqual(grid[6][7], .empty)
        XCTAssertEqual(grid[7][6], .empty)
        XCTAssertEqual(grid[7][7], .empty)
    }
    
    // MARK: - GameState Tests
    
    func testGameStateInitialization() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        XCTAssertEqual(gameState.tanks.count, 2)
        XCTAssertEqual(gameState.wins.count, 2)
        XCTAssertEqual(gameState.localPlayerIndex, 0)
        XCTAssertTrue(gameState.tanks[0].isAlive)
        XCTAssertTrue(gameState.tanks[1].isAlive)
    }
    
    func testGameStateReset() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Modify state
        gameState.tanks[0].isAlive = false
        gameState.projectiles.append(Projectile(row: 3, col: 3, direction: .up))
        
        // Reset
        gameState.reset(seed: 54321)
        
        // Should be back to initial state
        XCTAssertTrue(gameState.tanks[0].isAlive)
        XCTAssertTrue(gameState.tanks[1].isAlive)
        XCTAssertEqual(gameState.projectiles.count, 0)
    }
    
    func testGameStateRoundOver() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Round not over when both tanks alive
        XCTAssertFalse(gameState.isRoundOver())
        
        // Round over when only one tank alive
        gameState.tanks[1].isAlive = false
        XCTAssertTrue(gameState.isRoundOver())
        
        // Round over when no tanks alive
        gameState.tanks[0].isAlive = false
        XCTAssertTrue(gameState.isRoundOver())
    }
    
    func testGameStateGetWinner() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // No winner when both alive
        XCTAssertNil(gameState.getWinner())
        
        // Player 0 wins when player 1 destroyed
        gameState.tanks[1].isAlive = false
        XCTAssertEqual(gameState.getWinner(), 0)
        
        // No winner when both destroyed
        gameState.tanks[0].isAlive = false
        XCTAssertNil(gameState.getWinner())
    }
    
    func testGameStateProjectileUpdates() {
        let gameState = GameState(seed: 12345, playerCount: 2, localPlayerIndex: 0)
        
        // Add a projectile
        gameState.projectiles.append(Projectile(row: 3, col: 3, direction: .up))
        XCTAssertEqual(gameState.projectiles.count, 1)
        
        // Update projectiles
        gameState.updateProjectiles()
        
        // Projectile should have moved
        XCTAssertEqual(gameState.projectiles[0].row, 2)
        XCTAssertEqual(gameState.projectiles[0].col, 3)
    }
}
