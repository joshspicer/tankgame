//
//  ProjectileTests.swift
//  tankgame Tests
//
//  Unit tests for Projectile entity
//

import XCTest
@testable import tankgame_iOS

final class ProjectileTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testProjectileInitialization() {
        let projectile = Projectile(row: 2, col: 3, direction: .up)
        
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 3)
        XCTAssertEqual(projectile.direction, .up)
    }
    
    // MARK: - Advance Tests
    
    func testAdvanceUp() {
        var projectile = Projectile(row: 5, col: 3, direction: .up)
        
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 4, "Projectile should move up one row")
        XCTAssertEqual(projectile.col, 3, "Column should not change")
    }
    
    func testAdvanceDown() {
        var projectile = Projectile(row: 5, col: 3, direction: .down)
        
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 6, "Projectile should move down one row")
        XCTAssertEqual(projectile.col, 3, "Column should not change")
    }
    
    func testAdvanceLeft() {
        var projectile = Projectile(row: 5, col: 3, direction: .left)
        
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 5, "Row should not change")
        XCTAssertEqual(projectile.col, 2, "Projectile should move left one column")
    }
    
    func testAdvanceRight() {
        var projectile = Projectile(row: 5, col: 3, direction: .right)
        
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 5, "Row should not change")
        XCTAssertEqual(projectile.col, 4, "Projectile should move right one column")
    }
    
    func testMultipleAdvances() {
        var projectile = Projectile(row: 5, col: 5, direction: .up)
        
        projectile.advance()
        projectile.advance()
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 2, "Projectile should move 3 cells up")
        XCTAssertEqual(projectile.col, 5, "Column should not change")
    }
    
    // MARK: - Boundary Tests
    
    func testIsOutOfBoundsTop() {
        var projectile = Projectile(row: 0, col: 3, direction: .up)
        
        XCTAssertFalse(projectile.isOutOfBounds(gridSize: 8), "Should be in bounds initially")
        
        projectile.advance()
        
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8), "Should be out of bounds after moving beyond top")
        XCTAssertEqual(projectile.row, -1)
    }
    
    func testIsOutOfBoundsBottom() {
        var projectile = Projectile(row: 7, col: 3, direction: .down)
        
        XCTAssertFalse(projectile.isOutOfBounds(gridSize: 8), "Should be in bounds initially")
        
        projectile.advance()
        
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8), "Should be out of bounds after moving beyond bottom")
        XCTAssertEqual(projectile.row, 8)
    }
    
    func testIsOutOfBoundsLeft() {
        var projectile = Projectile(row: 3, col: 0, direction: .left)
        
        XCTAssertFalse(projectile.isOutOfBounds(gridSize: 8), "Should be in bounds initially")
        
        projectile.advance()
        
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8), "Should be out of bounds after moving beyond left")
        XCTAssertEqual(projectile.col, -1)
    }
    
    func testIsOutOfBoundsRight() {
        var projectile = Projectile(row: 3, col: 7, direction: .right)
        
        XCTAssertFalse(projectile.isOutOfBounds(gridSize: 8), "Should be in bounds initially")
        
        projectile.advance()
        
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8), "Should be out of bounds after moving beyond right")
        XCTAssertEqual(projectile.col, 8)
    }
    
    // MARK: - Grid Collision Tests
    
    func testHitsWall() {
        var grid = createEmptyGrid(size: 8)
        grid[3][4] = .wall
        
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        
        XCTAssertTrue(projectile.hits(grid: grid), "Projectile should hit wall")
    }
    
    func testDoesNotHitEmptyCell() {
        let grid = createEmptyGrid(size: 8)
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        
        XCTAssertFalse(projectile.hits(grid: grid), "Projectile should not hit empty cell")
    }
    
    func testHitsGridOutOfBounds() {
        let grid = createEmptyGrid(size: 8)
        let projectile = Projectile(row: -1, col: 4, direction: .up)
        
        XCTAssertFalse(projectile.hits(grid: grid), "Out of bounds projectile should not register as hitting grid")
    }
    
    // MARK: - Tank Collision Tests
    
    func testHitsAliveTank() {
        let tank = Tank(row: 3, col: 4, direction: .down)
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        
        XCTAssertTrue(projectile.hits(tank: tank), "Projectile should hit tank at same position")
    }
    
    func testDoesNotHitDeadTank() {
        var tank = Tank(row: 3, col: 4, direction: .down)
        tank.isAlive = false
        
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        
        XCTAssertFalse(projectile.hits(tank: tank), "Projectile should not hit dead tank")
    }
    
    func testDoesNotHitTankAtDifferentPosition() {
        let tank = Tank(row: 3, col: 4, direction: .down)
        let projectile = Projectile(row: 3, col: 5, direction: .up)
        
        XCTAssertFalse(projectile.hits(tank: tank), "Projectile should not hit tank at different position")
    }
    
    func testHitDetectionAfterAdvance() {
        let tank = Tank(row: 3, col: 4, direction: .down)
        var projectile = Projectile(row: 4, col: 4, direction: .up)
        
        XCTAssertFalse(projectile.hits(tank: tank), "Should not hit before advancing")
        
        projectile.advance()
        
        XCTAssertTrue(projectile.hits(tank: tank), "Should hit after advancing")
    }
    
    // MARK: - Codable Tests
    
    func testProjectileCodable() throws {
        let projectile = Projectile(row: 2, col: 7, direction: .right)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(projectile)
        
        let decoder = JSONDecoder()
        let decodedProjectile = try decoder.decode(Projectile.self, from: data)
        
        XCTAssertEqual(projectile.row, decodedProjectile.row)
        XCTAssertEqual(projectile.col, decodedProjectile.col)
        XCTAssertEqual(projectile.direction, decodedProjectile.direction)
    }
    
    // MARK: - Helper Methods
    
    private func createEmptyGrid(size: Int) -> [[GridCell]] {
        return Array(repeating: Array(repeating: GridCell.empty, count: size), count: size)
    }
}
