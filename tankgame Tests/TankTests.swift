//
//  TankTests.swift
//  tankgame Tests
//
//  Unit tests for Tank entity
//

import XCTest
@testable import tankgame

final class TankTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testTankInitialization() {
        let tank = Tank(row: 0, col: 0, direction: .down)
        
        XCTAssertEqual(tank.row, 0)
        XCTAssertEqual(tank.col, 0)
        XCTAssertEqual(tank.direction, .down)
        XCTAssertTrue(tank.isAlive)
    }
    
    func testTankDefaultDirection() {
        let tank = Tank(row: 5, col: 3)
        XCTAssertEqual(tank.direction, .down, "Default direction should be down")
    }
    
    // MARK: - Movement Tests
    
    func testSuccessfulMove() {
        var tank = Tank(row: 1, col: 1, direction: .right)
        let emptyGrid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        
        let moved = tank.move(in: .right, grid: emptyGrid)
        
        XCTAssertTrue(moved, "Move should succeed on empty grid")
        XCTAssertEqual(tank.row, 1)
        XCTAssertEqual(tank.col, 2)
        XCTAssertEqual(tank.direction, .right)
    }
    
    func testMoveBlockedByWall() {
        var tank = Tank(row: 1, col: 1, direction: .right)
        var grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        grid[1][2] = .wall
        
        let moved = tank.move(in: .right, grid: grid)
        
        XCTAssertFalse(moved, "Move should be blocked by wall")
        XCTAssertEqual(tank.row, 1, "Position should not change")
        XCTAssertEqual(tank.col, 1, "Position should not change")
    }
    
    func testMoveOutOfBounds() {
        var tank = Tank(row: 0, col: 0, direction: .up)
        let emptyGrid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        
        let moved = tank.move(in: .up, grid: emptyGrid)
        
        XCTAssertFalse(moved, "Move should be blocked at grid boundary")
        XCTAssertEqual(tank.row, 0, "Position should not change")
        XCTAssertEqual(tank.col, 0, "Position should not change")
    }
    
    func testMoveInAllDirections() {
        let emptyGrid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        
        // Test up
        var tank = Tank(row: 4, col: 4, direction: .down)
        XCTAssertTrue(tank.move(in: .up, grid: emptyGrid))
        XCTAssertEqual(tank.row, 3)
        XCTAssertEqual(tank.col, 4)
        
        // Test down
        tank = Tank(row: 4, col: 4, direction: .up)
        XCTAssertTrue(tank.move(in: .down, grid: emptyGrid))
        XCTAssertEqual(tank.row, 5)
        XCTAssertEqual(tank.col, 4)
        
        // Test left
        tank = Tank(row: 4, col: 4, direction: .right)
        XCTAssertTrue(tank.move(in: .left, grid: emptyGrid))
        XCTAssertEqual(tank.row, 4)
        XCTAssertEqual(tank.col, 3)
        
        // Test right
        tank = Tank(row: 4, col: 4, direction: .left)
        XCTAssertTrue(tank.move(in: .right, grid: emptyGrid))
        XCTAssertEqual(tank.row, 4)
        XCTAssertEqual(tank.col, 5)
    }
    
    // MARK: - Shooting Tests
    
    func testShootCreatesProjectile() {
        let tank = Tank(row: 3, col: 3, direction: .right)
        let projectile = tank.shoot()
        
        XCTAssertEqual(projectile.row, 3, "Projectile should be in same row")
        XCTAssertEqual(projectile.col, 4, "Projectile should be one cell ahead")
        XCTAssertEqual(projectile.direction, .right)
    }
    
    func testShootInAllDirections() {
        // Up
        var tank = Tank(row: 3, col: 3, direction: .up)
        var projectile = tank.shoot()
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 3)
        
        // Down
        tank = Tank(row: 3, col: 3, direction: .down)
        projectile = tank.shoot()
        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 3)
        
        // Left
        tank = Tank(row: 3, col: 3, direction: .left)
        projectile = tank.shoot()
        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 2)
        
        // Right
        tank = Tank(row: 3, col: 3, direction: .right)
        projectile = tank.shoot()
        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 4)
    }
    
    // MARK: - Codable Tests
    
    func testTankCodable() throws {
        let tank = Tank(row: 2, col: 3, direction: .left)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(tank)
        
        let decoder = JSONDecoder()
        let decodedTank = try decoder.decode(Tank.self, from: data)
        
        XCTAssertEqual(tank.row, decodedTank.row)
        XCTAssertEqual(tank.col, decodedTank.col)
        XCTAssertEqual(tank.direction, decodedTank.direction)
        XCTAssertEqual(tank.isAlive, decodedTank.isAlive)
    }
}
