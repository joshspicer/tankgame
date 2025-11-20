//
//  TankTests.swift
//  tankgame Tests
//
//  Unit tests for Tank entity
//

import XCTest
@testable import tankgame_iOS

final class TankTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testTankInitialization() {
        let tank = Tank(row: 3, col: 4, direction: .up)
        
        XCTAssertEqual(tank.row, 3)
        XCTAssertEqual(tank.col, 4)
        XCTAssertEqual(tank.direction, .up)
        XCTAssertTrue(tank.isAlive)
    }
    
    func testTankDefaultDirection() {
        let tank = Tank(row: 0, col: 0)
        
        XCTAssertEqual(tank.direction, .down, "Default direction should be down")
    }
    
    // MARK: - Movement Tests
    
    func testSuccessfulMove() {
        var tank = Tank(row: 3, col: 3, direction: .up)
        let grid = createEmptyGrid(size: 8)
        
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertTrue(moved, "Tank should move successfully on empty grid")
        XCTAssertEqual(tank.row, 2, "Tank should move up one row")
        XCTAssertEqual(tank.col, 3, "Tank column should not change")
        XCTAssertEqual(tank.direction, .up, "Tank direction should update")
    }
    
    func testMoveUpdatesDirection() {
        var tank = Tank(row: 3, col: 3, direction: .up)
        let grid = createEmptyGrid(size: 8)
        
        _ = tank.move(in: .right, grid: grid)
        
        XCTAssertEqual(tank.direction, .right, "Tank direction should update even if position changes")
    }
    
    func testMovementInAllDirections() {
        let grid = createEmptyGrid(size: 8)
        
        // Test up
        var tank = Tank(row: 4, col: 4, direction: .down)
        XCTAssertTrue(tank.move(in: .up, grid: grid))
        XCTAssertEqual(tank.row, 3)
        XCTAssertEqual(tank.col, 4)
        
        // Test down
        XCTAssertTrue(tank.move(in: .down, grid: grid))
        XCTAssertEqual(tank.row, 4)
        XCTAssertEqual(tank.col, 4)
        
        // Test left
        XCTAssertTrue(tank.move(in: .left, grid: grid))
        XCTAssertEqual(tank.row, 4)
        XCTAssertEqual(tank.col, 3)
        
        // Test right
        XCTAssertTrue(tank.move(in: .right, grid: grid))
        XCTAssertEqual(tank.row, 4)
        XCTAssertEqual(tank.col, 4)
    }
    
    func testMoveBlockedByWall() {
        var grid = createEmptyGrid(size: 8)
        grid[2][3] = .wall
        
        var tank = Tank(row: 3, col: 3, direction: .up)
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertFalse(moved, "Tank should not move into wall")
        XCTAssertEqual(tank.row, 3, "Tank position should not change")
        XCTAssertEqual(tank.col, 3, "Tank position should not change")
    }
    
    func testMoveBlockedByTopBoundary() {
        var tank = Tank(row: 0, col: 3, direction: .up)
        let grid = createEmptyGrid(size: 8)
        
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertFalse(moved, "Tank should not move beyond top boundary")
        XCTAssertEqual(tank.row, 0, "Tank should stay at boundary")
    }
    
    func testMoveBlockedByBottomBoundary() {
        var tank = Tank(row: 7, col: 3, direction: .down)
        let grid = createEmptyGrid(size: 8)
        
        let moved = tank.move(in: .down, grid: grid)
        
        XCTAssertFalse(moved, "Tank should not move beyond bottom boundary")
        XCTAssertEqual(tank.row, 7, "Tank should stay at boundary")
    }
    
    func testMoveBlockedByLeftBoundary() {
        var tank = Tank(row: 3, col: 0, direction: .left)
        let grid = createEmptyGrid(size: 8)
        
        let moved = tank.move(in: .left, grid: grid)
        
        XCTAssertFalse(moved, "Tank should not move beyond left boundary")
        XCTAssertEqual(tank.col, 0, "Tank should stay at boundary")
    }
    
    func testMoveBlockedByRightBoundary() {
        var tank = Tank(row: 3, col: 7, direction: .right)
        let grid = createEmptyGrid(size: 8)
        
        let moved = tank.move(in: .right, grid: grid)
        
        XCTAssertFalse(moved, "Tank should not move beyond right boundary")
        XCTAssertEqual(tank.col, 7, "Tank should stay at boundary")
    }
    
    // MARK: - Shooting Tests
    
    func testShootCreatesProjectile() {
        let tank = Tank(row: 3, col: 3, direction: .up)
        
        let projectile = tank.shoot()
        
        XCTAssertEqual(projectile.direction, .up, "Projectile should match tank direction")
        XCTAssertEqual(projectile.row, 2, "Projectile should be one cell ahead of tank")
        XCTAssertEqual(projectile.col, 3, "Projectile should match tank column")
    }
    
    func testShootInAllDirections() {
        // Shoot up
        var tank = Tank(row: 3, col: 3, direction: .up)
        var projectile = tank.shoot()
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 3)
        
        // Shoot down
        tank = Tank(row: 3, col: 3, direction: .down)
        projectile = tank.shoot()
        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 3)
        
        // Shoot left
        tank = Tank(row: 3, col: 3, direction: .left)
        projectile = tank.shoot()
        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 2)
        
        // Shoot right
        tank = Tank(row: 3, col: 3, direction: .right)
        projectile = tank.shoot()
        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 4)
    }
    
    // MARK: - Codable Tests
    
    func testTankCodable() throws {
        let tank = Tank(row: 5, col: 6, direction: .left)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(tank)
        
        let decoder = JSONDecoder()
        let decodedTank = try decoder.decode(Tank.self, from: data)
        
        XCTAssertEqual(tank.row, decodedTank.row)
        XCTAssertEqual(tank.col, decodedTank.col)
        XCTAssertEqual(tank.direction, decodedTank.direction)
        XCTAssertEqual(tank.isAlive, decodedTank.isAlive)
    }
    
    // MARK: - Helper Methods
    
    private func createEmptyGrid(size: Int) -> [[GridCell]] {
        return Array(repeating: Array(repeating: GridCell.empty, count: size), count: size)
    }
}
