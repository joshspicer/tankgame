//
//  TankTests.swift
//  tankgame Shared
//
//  Unit tests for Tank struct
//

import XCTest
@testable import tankgame

class TankTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testDefaultInitialization() {
        let tank = Tank(row: 3, col: 4)
        
        XCTAssertEqual(tank.row, 3)
        XCTAssertEqual(tank.col, 4)
        XCTAssertEqual(tank.direction, .down, "Default direction should be down")
        XCTAssertTrue(tank.isAlive, "Tank should start alive")
    }
    
    func testInitializationWithDirection() {
        let tank = Tank(row: 2, col: 5, direction: .up)
        
        XCTAssertEqual(tank.row, 2)
        XCTAssertEqual(tank.col, 5)
        XCTAssertEqual(tank.direction, .up)
        XCTAssertTrue(tank.isAlive)
    }
    
    // MARK: - Movement Tests
    
    func testSuccessfulMovement() {
        var tank = Tank(row: 4, col: 4, direction: .down)
        let grid = createEmptyGrid()
        
        let moved = tank.move(in: .right, grid: grid)
        
        XCTAssertTrue(moved, "Movement should succeed in empty grid")
        XCTAssertEqual(tank.row, 4, "Row should stay same when moving right")
        XCTAssertEqual(tank.col, 5, "Col should increase when moving right")
        XCTAssertEqual(tank.direction, .right, "Direction should update after move")
    }
    
    func testMovementUpdatesDirection() {
        var tank = Tank(row: 4, col: 4, direction: .down)
        let grid = createEmptyGrid()
        
        _ = tank.move(in: .up, grid: grid)
        XCTAssertEqual(tank.direction, .up)
        
        _ = tank.move(in: .left, grid: grid)
        XCTAssertEqual(tank.direction, .left)
    }
    
    func testMovementBlockedByWall() {
        var tank = Tank(row: 4, col: 4, direction: .down)
        var grid = createEmptyGrid()
        grid[4][5] = .wall // Place wall to the right
        
        let moved = tank.move(in: .right, grid: grid)
        
        XCTAssertFalse(moved, "Movement should fail when blocked by wall")
        XCTAssertEqual(tank.row, 4, "Position should not change")
        XCTAssertEqual(tank.col, 4, "Position should not change")
    }
    
    func testMovementBlockedByBounds() {
        var tank = Tank(row: 0, col: 4, direction: .down)
        let grid = createEmptyGrid()
        
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertFalse(moved, "Movement should fail at grid boundary")
        XCTAssertEqual(tank.row, 0, "Position should not change")
        XCTAssertEqual(tank.col, 4, "Position should not change")
    }
    
    func testMovementInAllDirections() {
        let grid = createEmptyGrid()
        
        // Test cardinal directions
        var tank = Tank(row: 4, col: 4)
        XCTAssertTrue(tank.move(in: .up, grid: grid))
        XCTAssertEqual(tank.row, 3)
        
        tank = Tank(row: 4, col: 4)
        XCTAssertTrue(tank.move(in: .down, grid: grid))
        XCTAssertEqual(tank.row, 5)
        
        tank = Tank(row: 4, col: 4)
        XCTAssertTrue(tank.move(in: .left, grid: grid))
        XCTAssertEqual(tank.col, 3)
        
        tank = Tank(row: 4, col: 4)
        XCTAssertTrue(tank.move(in: .right, grid: grid))
        XCTAssertEqual(tank.col, 5)
    }
    
    func testDiagonalMovement() {
        let grid = createEmptyGrid()
        var tank = Tank(row: 4, col: 4)
        
        let moved = tank.move(in: .upRight, grid: grid)
        XCTAssertTrue(moved)
        XCTAssertEqual(tank.row, 3)
        XCTAssertEqual(tank.col, 5)
    }
    
    func testMovementAtCorners() {
        let grid = createEmptyGrid()
        
        // Top-left corner
        var tank = Tank(row: 0, col: 0)
        XCTAssertFalse(tank.move(in: .up, grid: grid))
        XCTAssertFalse(tank.move(in: .left, grid: grid))
        XCTAssertFalse(tank.move(in: .upLeft, grid: grid))
        
        // Bottom-right corner
        tank = Tank(row: 7, col: 7)
        XCTAssertFalse(tank.move(in: .down, grid: grid))
        XCTAssertFalse(tank.move(in: .right, grid: grid))
        XCTAssertFalse(tank.move(in: .downRight, grid: grid))
    }
    
    // MARK: - Shooting Tests
    
    func testShootCreatesProjectile() {
        let tank = Tank(row: 4, col: 4, direction: .up)
        
        let projectile = tank.shoot()
        
        XCTAssertEqual(projectile.row, 3, "Projectile should be one cell ahead")
        XCTAssertEqual(projectile.col, 4)
        XCTAssertEqual(projectile.direction, .up, "Projectile should inherit tank direction")
    }
    
    func testShootInDifferentDirections() {
        // Shooting up
        var tank = Tank(row: 4, col: 4, direction: .up)
        var projectile = tank.shoot()
        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 4)
        
        // Shooting down
        tank = Tank(row: 4, col: 4, direction: .down)
        projectile = tank.shoot()
        XCTAssertEqual(projectile.row, 5)
        XCTAssertEqual(projectile.col, 4)
        
        // Shooting left
        tank = Tank(row: 4, col: 4, direction: .left)
        projectile = tank.shoot()
        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 3)
        
        // Shooting right
        tank = Tank(row: 4, col: 4, direction: .right)
        projectile = tank.shoot()
        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 5)
    }
    
    func testShootDiagonally() {
        let tank = Tank(row: 4, col: 4, direction: .upRight)
        let projectile = tank.shoot()
        
        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 5)
        XCTAssertEqual(projectile.direction, .upRight)
    }
    
    // MARK: - Codable Tests
    
    func testTankCodable() throws {
        let tank = Tank(row: 3, col: 5, direction: .upRight)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(tank)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Tank.self, from: data)
        
        XCTAssertEqual(decoded.row, tank.row)
        XCTAssertEqual(decoded.col, tank.col)
        XCTAssertEqual(decoded.direction, tank.direction)
        XCTAssertEqual(decoded.isAlive, tank.isAlive)
    }
    
    func testDeadTankCodable() throws {
        var tank = Tank(row: 3, col: 5, direction: .left)
        tank.isAlive = false
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(tank)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Tank.self, from: data)
        
        XCTAssertFalse(decoded.isAlive)
    }
    
    // MARK: - Helper Methods
    
    private func createEmptyGrid() -> [[GridCell]] {
        return Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
    }
}
