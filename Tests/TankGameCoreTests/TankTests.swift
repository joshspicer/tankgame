//
//  TankTests.swift
//  TankGameCoreTests
//
//  Unit tests for Tank struct
//

import XCTest
@testable import TankGameCore

final class TankTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testDefaultInitialization() {
        let tank = Tank(row: 0, col: 0)
        XCTAssertEqual(tank.row, 0)
        XCTAssertEqual(tank.col, 0)
        XCTAssertEqual(tank.direction, .down)
        XCTAssertTrue(tank.isAlive)
    }
    
    func testInitializationWithDirection() {
        let tank = Tank(row: 3, col: 5, direction: .right)
        XCTAssertEqual(tank.row, 3)
        XCTAssertEqual(tank.col, 5)
        XCTAssertEqual(tank.direction, .right)
        XCTAssertTrue(tank.isAlive)
    }
    
    // MARK: - Movement Tests
    
    func testMoveUp() {
        var tank = Tank(row: 5, col: 5)
        let grid = createEmptyGrid(size: 10)
        
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertTrue(moved)
        XCTAssertEqual(tank.row, 4)
        XCTAssertEqual(tank.col, 5)
        XCTAssertEqual(tank.direction, .up)
    }
    
    func testMoveDown() {
        var tank = Tank(row: 5, col: 5)
        let grid = createEmptyGrid(size: 10)
        
        let moved = tank.move(in: .down, grid: grid)
        
        XCTAssertTrue(moved)
        XCTAssertEqual(tank.row, 6)
        XCTAssertEqual(tank.col, 5)
        XCTAssertEqual(tank.direction, .down)
    }
    
    func testMoveLeft() {
        var tank = Tank(row: 5, col: 5)
        let grid = createEmptyGrid(size: 10)
        
        let moved = tank.move(in: .left, grid: grid)
        
        XCTAssertTrue(moved)
        XCTAssertEqual(tank.row, 5)
        XCTAssertEqual(tank.col, 4)
        XCTAssertEqual(tank.direction, .left)
    }
    
    func testMoveRight() {
        var tank = Tank(row: 5, col: 5)
        let grid = createEmptyGrid(size: 10)
        
        let moved = tank.move(in: .right, grid: grid)
        
        XCTAssertTrue(moved)
        XCTAssertEqual(tank.row, 5)
        XCTAssertEqual(tank.col, 6)
        XCTAssertEqual(tank.direction, .right)
    }
    
    func testMoveDiagonal() {
        var tank = Tank(row: 5, col: 5)
        let grid = createEmptyGrid(size: 10)
        
        let moved = tank.move(in: .upRight, grid: grid)
        
        XCTAssertTrue(moved)
        XCTAssertEqual(tank.row, 4)
        XCTAssertEqual(tank.col, 6)
        XCTAssertEqual(tank.direction, .upRight)
    }
    
    // MARK: - Boundary Tests
    
    func testMoveBlockedByTopBoundary() {
        var tank = Tank(row: 0, col: 5)
        let grid = createEmptyGrid(size: 10)
        
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 0)
        XCTAssertEqual(tank.col, 5)
    }
    
    func testMoveBlockedByBottomBoundary() {
        var tank = Tank(row: 9, col: 5)
        let grid = createEmptyGrid(size: 10)
        
        let moved = tank.move(in: .down, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 9)
        XCTAssertEqual(tank.col, 5)
    }
    
    func testMoveBlockedByLeftBoundary() {
        var tank = Tank(row: 5, col: 0)
        let grid = createEmptyGrid(size: 10)
        
        let moved = tank.move(in: .left, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 5)
        XCTAssertEqual(tank.col, 0)
    }
    
    func testMoveBlockedByRightBoundary() {
        var tank = Tank(row: 5, col: 9)
        let grid = createEmptyGrid(size: 10)
        
        let moved = tank.move(in: .right, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 5)
        XCTAssertEqual(tank.col, 9)
    }
    
    // MARK: - Wall Collision Tests
    
    func testMoveBlockedByWall() {
        var tank = Tank(row: 5, col: 5)
        var grid = createEmptyGrid(size: 10)
        grid[4][5] = .wall
        
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 5)
        XCTAssertEqual(tank.col, 5)
    }
    
    // MARK: - Shooting Tests
    
    func testShootUp() {
        let tank = Tank(row: 5, col: 5, direction: .up)
        let projectile = tank.shoot()
        
        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 5)
        XCTAssertEqual(projectile.direction, .up)
    }
    
    func testShootDown() {
        let tank = Tank(row: 5, col: 5, direction: .down)
        let projectile = tank.shoot()
        
        XCTAssertEqual(projectile.row, 6)
        XCTAssertEqual(projectile.col, 5)
        XCTAssertEqual(projectile.direction, .down)
    }
    
    func testShootLeft() {
        let tank = Tank(row: 5, col: 5, direction: .left)
        let projectile = tank.shoot()
        
        XCTAssertEqual(projectile.row, 5)
        XCTAssertEqual(projectile.col, 4)
        XCTAssertEqual(projectile.direction, .left)
    }
    
    func testShootRight() {
        let tank = Tank(row: 5, col: 5, direction: .right)
        let projectile = tank.shoot()
        
        XCTAssertEqual(projectile.row, 5)
        XCTAssertEqual(projectile.col, 6)
        XCTAssertEqual(projectile.direction, .right)
    }
    
    func testShootDiagonal() {
        let tank = Tank(row: 5, col: 5, direction: .upRight)
        let projectile = tank.shoot()
        
        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 6)
        XCTAssertEqual(projectile.direction, .upRight)
    }
    
    // MARK: - Codable Tests
    
    func testCodable() throws {
        let tank = Tank(row: 3, col: 7, direction: .left)
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(tank)
        let decoded = try decoder.decode(Tank.self, from: data)
        
        XCTAssertEqual(decoded.row, tank.row)
        XCTAssertEqual(decoded.col, tank.col)
        XCTAssertEqual(decoded.direction, tank.direction)
        XCTAssertEqual(decoded.isAlive, tank.isAlive)
    }
    
    // MARK: - Helper Methods
    
    private func createEmptyGrid(size: Int) -> [[GridCell]] {
        return Array(repeating: Array(repeating: GridCell.empty, count: size), count: size)
    }
}
