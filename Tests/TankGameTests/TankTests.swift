//
//  TankTests.swift
//  TankGameCoreTests
//
//  Tests for the Tank struct
//

import XCTest
@testable import TankGameCore

final class TankTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        let tank = Tank(row: 3, col: 4, direction: .up)
        
        XCTAssertEqual(tank.row, 3)
        XCTAssertEqual(tank.col, 4)
        XCTAssertEqual(tank.direction, .up)
        XCTAssertTrue(tank.isAlive)
    }
    
    func testDefaultDirection() {
        let tank = Tank(row: 0, col: 0)
        XCTAssertEqual(tank.direction, .down)
    }
    
    // MARK: - Movement Tests
    
    func testMoveUp() {
        let grid = createEmptyGrid()
        var tank = Tank(row: 4, col: 4, direction: .down)
        
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertTrue(moved)
        XCTAssertEqual(tank.row, 3)
        XCTAssertEqual(tank.col, 4)
        XCTAssertEqual(tank.direction, .up)
    }
    
    func testMoveDown() {
        let grid = createEmptyGrid()
        var tank = Tank(row: 4, col: 4, direction: .up)
        
        let moved = tank.move(in: .down, grid: grid)
        
        XCTAssertTrue(moved)
        XCTAssertEqual(tank.row, 5)
        XCTAssertEqual(tank.col, 4)
        XCTAssertEqual(tank.direction, .down)
    }
    
    func testMoveLeft() {
        let grid = createEmptyGrid()
        var tank = Tank(row: 4, col: 4, direction: .right)
        
        let moved = tank.move(in: .left, grid: grid)
        
        XCTAssertTrue(moved)
        XCTAssertEqual(tank.row, 4)
        XCTAssertEqual(tank.col, 3)
        XCTAssertEqual(tank.direction, .left)
    }
    
    func testMoveRight() {
        let grid = createEmptyGrid()
        var tank = Tank(row: 4, col: 4, direction: .left)
        
        let moved = tank.move(in: .right, grid: grid)
        
        XCTAssertTrue(moved)
        XCTAssertEqual(tank.row, 4)
        XCTAssertEqual(tank.col, 5)
        XCTAssertEqual(tank.direction, .right)
    }
    
    // MARK: - Boundary Tests
    
    func testCannotMoveUpAtTopBoundary() {
        let grid = createEmptyGrid()
        var tank = Tank(row: 0, col: 4)
        
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 0)
    }
    
    func testCannotMoveDownAtBottomBoundary() {
        let grid = createEmptyGrid()
        var tank = Tank(row: 7, col: 4)
        
        let moved = tank.move(in: .down, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 7)
    }
    
    func testCannotMoveLeftAtLeftBoundary() {
        let grid = createEmptyGrid()
        var tank = Tank(row: 4, col: 0)
        
        let moved = tank.move(in: .left, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.col, 0)
    }
    
    func testCannotMoveRightAtRightBoundary() {
        let grid = createEmptyGrid()
        var tank = Tank(row: 4, col: 7)
        
        let moved = tank.move(in: .right, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.col, 7)
    }
    
    // MARK: - Wall Collision Tests
    
    func testCannotMoveIntoWall() {
        var grid = createEmptyGrid()
        grid[3][4] = .wall  // Place wall above tank
        var tank = Tank(row: 4, col: 4)
        
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 4)
    }
    
    // MARK: - Shooting Tests
    
    func testShootUp() {
        let tank = Tank(row: 4, col: 4, direction: .up)
        let projectile = tank.shoot()
        
        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 4)
        XCTAssertEqual(projectile.direction, .up)
    }
    
    func testShootDown() {
        let tank = Tank(row: 4, col: 4, direction: .down)
        let projectile = tank.shoot()
        
        XCTAssertEqual(projectile.row, 5)
        XCTAssertEqual(projectile.col, 4)
        XCTAssertEqual(projectile.direction, .down)
    }
    
    func testShootLeft() {
        let tank = Tank(row: 4, col: 4, direction: .left)
        let projectile = tank.shoot()
        
        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 3)
        XCTAssertEqual(projectile.direction, .left)
    }
    
    func testShootRight() {
        let tank = Tank(row: 4, col: 4, direction: .right)
        let projectile = tank.shoot()
        
        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 5)
        XCTAssertEqual(projectile.direction, .right)
    }
    
    // MARK: - Codable Tests
    
    func testEncodeDecode() throws {
        var tank = Tank(row: 3, col: 5, direction: .left)
        tank.isAlive = false
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(tank)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Tank.self, from: data)
        
        XCTAssertEqual(tank.row, decoded.row)
        XCTAssertEqual(tank.col, decoded.col)
        XCTAssertEqual(tank.direction, decoded.direction)
        XCTAssertEqual(tank.isAlive, decoded.isAlive)
    }
    
    // MARK: - Helper Methods
    
    private func createEmptyGrid() -> [[GridCell]] {
        return Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
    }
}
