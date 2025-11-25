//
//  ProjectileTests.swift
//  TankGameCoreTests
//
//  Unit tests for Projectile struct
//

import XCTest
@testable import TankGameCore

final class ProjectileTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        let projectile = Projectile(row: 5, col: 5, direction: .up)
        XCTAssertEqual(projectile.row, 5)
        XCTAssertEqual(projectile.col, 5)
        XCTAssertEqual(projectile.direction, .up)
    }
    
    // MARK: - Advance Tests
    
    func testAdvanceUp() {
        var projectile = Projectile(row: 5, col: 5, direction: .up)
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 5)
    }
    
    func testAdvanceDown() {
        var projectile = Projectile(row: 5, col: 5, direction: .down)
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 6)
        XCTAssertEqual(projectile.col, 5)
    }
    
    func testAdvanceLeft() {
        var projectile = Projectile(row: 5, col: 5, direction: .left)
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 5)
        XCTAssertEqual(projectile.col, 4)
    }
    
    func testAdvanceRight() {
        var projectile = Projectile(row: 5, col: 5, direction: .right)
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 5)
        XCTAssertEqual(projectile.col, 6)
    }
    
    func testAdvanceDiagonal() {
        var projectile = Projectile(row: 5, col: 5, direction: .upRight)
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 6)
    }
    
    func testMultipleAdvances() {
        var projectile = Projectile(row: 5, col: 5, direction: .up)
        
        projectile.advance()
        projectile.advance()
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 5)
    }
    
    // MARK: - Out of Bounds Tests
    
    func testIsNotOutOfBounds() {
        let projectile = Projectile(row: 5, col: 5, direction: .up)
        XCTAssertFalse(projectile.isOutOfBounds(gridSize: 10))
    }
    
    func testIsOutOfBoundsTop() {
        let projectile = Projectile(row: -1, col: 5, direction: .up)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 10))
    }
    
    func testIsOutOfBoundsBottom() {
        let projectile = Projectile(row: 10, col: 5, direction: .down)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 10))
    }
    
    func testIsOutOfBoundsLeft() {
        let projectile = Projectile(row: 5, col: -1, direction: .left)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 10))
    }
    
    func testIsOutOfBoundsRight() {
        let projectile = Projectile(row: 5, col: 10, direction: .right)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 10))
    }
    
    func testEdgeIsNotOutOfBounds() {
        XCTAssertFalse(Projectile(row: 0, col: 0, direction: .up).isOutOfBounds(gridSize: 10))
        XCTAssertFalse(Projectile(row: 9, col: 9, direction: .up).isOutOfBounds(gridSize: 10))
        XCTAssertFalse(Projectile(row: 0, col: 9, direction: .up).isOutOfBounds(gridSize: 10))
        XCTAssertFalse(Projectile(row: 9, col: 0, direction: .up).isOutOfBounds(gridSize: 10))
    }
    
    // MARK: - Wall Collision Tests
    
    func testHitsWall() {
        var grid = createEmptyGrid(size: 10)
        grid[5][5] = .wall
        
        let projectile = Projectile(row: 5, col: 5, direction: .up)
        XCTAssertTrue(projectile.hits(grid: grid))
    }
    
    func testDoesNotHitEmptyCell() {
        let grid = createEmptyGrid(size: 10)
        
        let projectile = Projectile(row: 5, col: 5, direction: .up)
        XCTAssertFalse(projectile.hits(grid: grid))
    }
    
    func testDoesNotHitOutOfBounds() {
        let grid = createEmptyGrid(size: 10)
        
        let projectile = Projectile(row: -1, col: 5, direction: .up)
        XCTAssertFalse(projectile.hits(grid: grid))
    }
    
    // MARK: - Tank Collision Tests
    
    func testHitsAliveTank() {
        let tank = Tank(row: 5, col: 5)
        let projectile = Projectile(row: 5, col: 5, direction: .up)
        
        XCTAssertTrue(projectile.hits(tank: tank))
    }
    
    func testDoesNotHitDeadTank() {
        var tank = Tank(row: 5, col: 5)
        tank.isAlive = false
        let projectile = Projectile(row: 5, col: 5, direction: .up)
        
        XCTAssertFalse(projectile.hits(tank: tank))
    }
    
    func testDoesNotHitTankAtDifferentPosition() {
        let tank = Tank(row: 5, col: 5)
        let projectile = Projectile(row: 3, col: 3, direction: .up)
        
        XCTAssertFalse(projectile.hits(tank: tank))
    }
    
    func testDoesNotHitTankWithSameRowDifferentCol() {
        let tank = Tank(row: 5, col: 5)
        let projectile = Projectile(row: 5, col: 3, direction: .up)
        
        XCTAssertFalse(projectile.hits(tank: tank))
    }
    
    func testDoesNotHitTankWithSameColDifferentRow() {
        let tank = Tank(row: 5, col: 5)
        let projectile = Projectile(row: 3, col: 5, direction: .up)
        
        XCTAssertFalse(projectile.hits(tank: tank))
    }
    
    // MARK: - Codable Tests
    
    func testCodable() throws {
        let projectile = Projectile(row: 3, col: 7, direction: .downLeft)
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(projectile)
        let decoded = try decoder.decode(Projectile.self, from: data)
        
        XCTAssertEqual(decoded.row, projectile.row)
        XCTAssertEqual(decoded.col, projectile.col)
        XCTAssertEqual(decoded.direction, projectile.direction)
    }
    
    // MARK: - Helper Methods
    
    private func createEmptyGrid(size: Int) -> [[GridCell]] {
        return Array(repeating: Array(repeating: GridCell.empty, count: size), count: size)
    }
}
