//
//  ProjectileTests.swift
//  tankgame Shared
//
//  Unit tests for Projectile struct
//

import XCTest
@testable import tankgame

class ProjectileTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        
        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 4)
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
    
    func testAdvanceDiagonally() {
        var projectile = Projectile(row: 5, col: 5, direction: .upRight)
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 6)
    }
    
    func testMultipleAdvances() {
        var projectile = Projectile(row: 5, col: 5, direction: .up)
        
        projectile.advance()
        XCTAssertEqual(projectile.row, 4)
        
        projectile.advance()
        XCTAssertEqual(projectile.row, 3)
        
        projectile.advance()
        XCTAssertEqual(projectile.row, 2)
    }
    
    // MARK: - Bounds Checking Tests
    
    func testIsOutOfBoundsInside() {
        let projectile = Projectile(row: 4, col: 4, direction: .up)
        
        XCTAssertFalse(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsOutOfBoundsNegativeRow() {
        let projectile = Projectile(row: -1, col: 4, direction: .up)
        
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsOutOfBoundsNegativeCol() {
        let projectile = Projectile(row: 4, col: -1, direction: .left)
        
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsOutOfBoundsTooLargeRow() {
        let projectile = Projectile(row: 8, col: 4, direction: .down)
        
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsOutOfBoundsTooLargeCol() {
        let projectile = Projectile(row: 4, col: 8, direction: .right)
        
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsOutOfBoundsAtEdge() {
        let projectile1 = Projectile(row: 0, col: 0, direction: .up)
        XCTAssertFalse(projectile1.isOutOfBounds(gridSize: 8))
        
        let projectile2 = Projectile(row: 7, col: 7, direction: .down)
        XCTAssertFalse(projectile2.isOutOfBounds(gridSize: 8))
    }
    
    // MARK: - Grid Hit Tests
    
    func testHitsWall() {
        var grid = createEmptyGrid()
        grid[3][4] = .wall
        
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        
        XCTAssertTrue(projectile.hits(grid: grid))
    }
    
    func testDoesNotHitEmptyCell() {
        let grid = createEmptyGrid()
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        
        XCTAssertFalse(projectile.hits(grid: grid))
    }
    
    func testHitsGridOutOfBounds() {
        let grid = createEmptyGrid()
        let projectile = Projectile(row: -1, col: 4, direction: .up)
        
        XCTAssertFalse(projectile.hits(grid: grid), "Out of bounds should return false")
    }
    
    // MARK: - Tank Hit Tests
    
    func testHitsAliveTank() {
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        var tank = Tank(row: 3, col: 4, direction: .down)
        tank.isAlive = true
        
        XCTAssertTrue(projectile.hits(tank: tank))
    }
    
    func testDoesNotHitDeadTank() {
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        var tank = Tank(row: 3, col: 4, direction: .down)
        tank.isAlive = false
        
        XCTAssertFalse(projectile.hits(tank: tank))
    }
    
    func testDoesNotHitTankAtDifferentPosition() {
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        let tank = Tank(row: 4, col: 4, direction: .down)
        
        XCTAssertFalse(projectile.hits(tank: tank))
    }
    
    // MARK: - Lizard Hit Tests
    
    func testHitsAliveLizard() {
        let projectile = Projectile(row: 5, col: 6, direction: .left)
        var lizard = Lizard(row: 5, col: 6)
        lizard.isAlive = true
        
        XCTAssertTrue(projectile.hitsLizard(lizard))
    }
    
    func testDoesNotHitDeadLizard() {
        let projectile = Projectile(row: 5, col: 6, direction: .left)
        var lizard = Lizard(row: 5, col: 6)
        lizard.isAlive = false
        
        XCTAssertFalse(projectile.hitsLizard(lizard))
    }
    
    func testDoesNotHitLizardAtDifferentPosition() {
        let projectile = Projectile(row: 5, col: 6, direction: .left)
        let lizard = Lizard(row: 5, col: 7)
        
        XCTAssertFalse(projectile.hitsLizard(lizard))
    }
    
    // MARK: - Codable Tests
    
    func testProjectileCodable() throws {
        let projectile = Projectile(row: 3, col: 4, direction: .downRight)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(projectile)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Projectile.self, from: data)
        
        XCTAssertEqual(decoded.row, projectile.row)
        XCTAssertEqual(decoded.col, projectile.col)
        XCTAssertEqual(decoded.direction, projectile.direction)
    }
    
    // MARK: - Integration Tests
    
    func testProjectileLifecycle() {
        var projectile = Projectile(row: 5, col: 5, direction: .up)
        let grid = createEmptyGrid()
        
        // Projectile starts in bounds
        XCTAssertFalse(projectile.isOutOfBounds(gridSize: 8))
        
        // Advance several times
        for _ in 0..<5 {
            projectile.advance()
            XCTAssertFalse(projectile.hits(grid: grid), "Should not hit empty grid")
        }
        
        // After 5 advances upward from row 5, should be at row 0
        XCTAssertEqual(projectile.row, 0)
        
        // One more advance should put it out of bounds
        projectile.advance()
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testProjectileHitsWallBeforeExitingGrid() {
        var grid = createEmptyGrid()
        grid[3][5] = .wall
        
        var projectile = Projectile(row: 5, col: 5, direction: .up)
        
        projectile.advance() // row 4
        XCTAssertFalse(projectile.hits(grid: grid))
        
        projectile.advance() // row 3
        XCTAssertTrue(projectile.hits(grid: grid), "Should hit wall at row 3")
    }
    
    // MARK: - Helper Methods
    
    private func createEmptyGrid() -> [[GridCell]] {
        return Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
    }
}
