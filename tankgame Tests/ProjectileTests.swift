//
//  ProjectileTests.swift
//  tankgame Tests
//
//  Unit tests for Projectile entity
//

import XCTest
@testable import tankgame

final class ProjectileTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testProjectileInitialization() {
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        
        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 4)
        XCTAssertEqual(projectile.direction, .up)
    }
    
    // MARK: - Movement Tests
    
    func testProjectileAdvance() {
        var projectile = Projectile(row: 3, col: 3, direction: .right)
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 4, "Projectile should move one cell right")
    }
    
    func testProjectileAdvanceInAllDirections() {
        // Up
        var projectile = Projectile(row: 3, col: 3, direction: .up)
        projectile.advance()
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 3)
        
        // Down
        projectile = Projectile(row: 3, col: 3, direction: .down)
        projectile.advance()
        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 3)
        
        // Left
        projectile = Projectile(row: 3, col: 3, direction: .left)
        projectile.advance()
        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 2)
        
        // Right
        projectile = Projectile(row: 3, col: 3, direction: .right)
        projectile.advance()
        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 4)
    }
    
    func testProjectileMultipleAdvances() {
        var projectile = Projectile(row: 0, col: 0, direction: .right)
        
        projectile.advance()
        XCTAssertEqual(projectile.col, 1)
        
        projectile.advance()
        XCTAssertEqual(projectile.col, 2)
        
        projectile.advance()
        XCTAssertEqual(projectile.col, 3)
    }
    
    // MARK: - Bounds Detection Tests
    
    func testIsOutOfBoundsWithinGrid() {
        let projectile = Projectile(row: 3, col: 3, direction: .right)
        XCTAssertFalse(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsOutOfBoundsBeyondRight() {
        let projectile = Projectile(row: 3, col: 8, direction: .right)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsOutOfBoundsBeyondBottom() {
        let projectile = Projectile(row: 8, col: 3, direction: .down)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsOutOfBoundsNegativeRow() {
        let projectile = Projectile(row: -1, col: 3, direction: .up)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsOutOfBoundsNegativeCol() {
        let projectile = Projectile(row: 3, col: -1, direction: .left)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsOutOfBoundsEdgeCases() {
        // Top-left corner
        var projectile = Projectile(row: 0, col: 0, direction: .up)
        XCTAssertFalse(projectile.isOutOfBounds(gridSize: 8), "Corner position should be valid")
        
        // Bottom-right corner
        projectile = Projectile(row: 7, col: 7, direction: .down)
        XCTAssertFalse(projectile.isOutOfBounds(gridSize: 8), "Corner position should be valid")
    }
    
    // MARK: - Wall Collision Tests
    
    func testHitsWall() {
        var grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        grid[3][4] = .wall
        
        let projectile = Projectile(row: 3, col: 4, direction: .right)
        XCTAssertTrue(projectile.hits(grid: grid))
    }
    
    func testDoesNotHitEmptyCell() {
        let grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        
        let projectile = Projectile(row: 3, col: 4, direction: .right)
        XCTAssertFalse(projectile.hits(grid: grid))
    }
    
    func testHitsWallOutOfBounds() {
        let grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        
        let projectile = Projectile(row: -1, col: 3, direction: .up)
        XCTAssertFalse(projectile.hits(grid: grid), "Out of bounds projectile should not hit wall")
    }
    
    // MARK: - Tank Collision Tests
    
    func testHitsTank() {
        let tank = Tank(row: 3, col: 4, direction: .down)
        let projectile = Projectile(row: 3, col: 4, direction: .right)
        
        XCTAssertTrue(projectile.hits(tank: tank))
    }
    
    func testDoesNotHitTankDifferentPosition() {
        let tank = Tank(row: 3, col: 4, direction: .down)
        let projectile = Projectile(row: 3, col: 5, direction: .right)
        
        XCTAssertFalse(projectile.hits(tank: tank))
    }
    
    func testDoesNotHitDeadTank() {
        var tank = Tank(row: 3, col: 4, direction: .down)
        tank.isAlive = false
        let projectile = Projectile(row: 3, col: 4, direction: .right)
        
        XCTAssertFalse(projectile.hits(tank: tank), "Should not hit dead tank")
    }
    
    // MARK: - Codable Tests
    
    func testProjectileCodable() throws {
        let projectile = Projectile(row: 5, col: 6, direction: .left)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(projectile)
        
        let decoder = JSONDecoder()
        let decodedProjectile = try decoder.decode(Projectile.self, from: data)
        
        XCTAssertEqual(projectile.row, decodedProjectile.row)
        XCTAssertEqual(projectile.col, decodedProjectile.col)
        XCTAssertEqual(projectile.direction, decodedProjectile.direction)
    }
}
