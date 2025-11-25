//
//  ProjectileTests.swift
//  TankGameCoreTests
//
//  Tests for the Projectile struct
//

import XCTest
@testable import TankGameCore

final class ProjectileTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        
        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 4)
        XCTAssertEqual(projectile.direction, .up)
    }
    
    // MARK: - Advance Tests
    
    func testAdvanceUp() {
        var projectile = Projectile(row: 4, col: 4, direction: .up)
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 4)
    }
    
    func testAdvanceDown() {
        var projectile = Projectile(row: 4, col: 4, direction: .down)
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 5)
        XCTAssertEqual(projectile.col, 4)
    }
    
    func testAdvanceLeft() {
        var projectile = Projectile(row: 4, col: 4, direction: .left)
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 3)
    }
    
    func testAdvanceRight() {
        var projectile = Projectile(row: 4, col: 4, direction: .right)
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 5)
    }
    
    func testMultipleAdvances() {
        var projectile = Projectile(row: 4, col: 4, direction: .right)
        projectile.advance()
        projectile.advance()
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 7)
    }
    
    // MARK: - Out of Bounds Tests
    
    func testIsOutOfBoundsTopEdge() {
        let projectile = Projectile(row: -1, col: 4, direction: .up)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsOutOfBoundsBottomEdge() {
        let projectile = Projectile(row: 8, col: 4, direction: .down)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsOutOfBoundsLeftEdge() {
        let projectile = Projectile(row: 4, col: -1, direction: .left)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsOutOfBoundsRightEdge() {
        let projectile = Projectile(row: 4, col: 8, direction: .right)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsNotOutOfBounds() {
        let projectile = Projectile(row: 4, col: 4, direction: .up)
        XCTAssertFalse(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsNotOutOfBoundsAtEdge() {
        let projectile = Projectile(row: 0, col: 0, direction: .up)
        XCTAssertFalse(projectile.isOutOfBounds(gridSize: 8))
    }
    
    // MARK: - Wall Collision Tests
    
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
    
    func testDoesNotHitWhenOutOfBounds() {
        let grid = createEmptyGrid()
        
        let projectile = Projectile(row: -1, col: 4, direction: .up)
        XCTAssertFalse(projectile.hits(grid: grid))
    }
    
    // MARK: - Tank Collision Tests
    
    func testHitsAliveTank() {
        let tank = Tank(row: 3, col: 4, direction: .down)
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        
        XCTAssertTrue(projectile.hits(tank: tank))
    }
    
    func testDoesNotHitDeadTank() {
        var tank = Tank(row: 3, col: 4, direction: .down)
        tank.isAlive = false
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        
        XCTAssertFalse(projectile.hits(tank: tank))
    }
    
    func testDoesNotHitTankAtDifferentPosition() {
        let tank = Tank(row: 3, col: 4, direction: .down)
        let projectile = Projectile(row: 5, col: 6, direction: .up)
        
        XCTAssertFalse(projectile.hits(tank: tank))
    }
    
    func testDoesNotHitTankInDifferentRow() {
        let tank = Tank(row: 3, col: 4, direction: .down)
        let projectile = Projectile(row: 4, col: 4, direction: .up)
        
        XCTAssertFalse(projectile.hits(tank: tank))
    }
    
    func testDoesNotHitTankInDifferentColumn() {
        let tank = Tank(row: 3, col: 4, direction: .down)
        let projectile = Projectile(row: 3, col: 5, direction: .up)
        
        XCTAssertFalse(projectile.hits(tank: tank))
    }
    
    // MARK: - Codable Tests
    
    func testEncodeDecode() throws {
        let projectile = Projectile(row: 3, col: 5, direction: .left)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(projectile)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Projectile.self, from: data)
        
        XCTAssertEqual(projectile.row, decoded.row)
        XCTAssertEqual(projectile.col, decoded.col)
        XCTAssertEqual(projectile.direction, decoded.direction)
    }
    
    // MARK: - Helper Methods
    
    private func createEmptyGrid() -> [[GridCell]] {
        return Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
    }
}
