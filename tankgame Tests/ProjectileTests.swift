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
        let projectile = Projectile(row: 2, col: 3, direction: .right)
        
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 3)
        XCTAssertEqual(projectile.direction, .right)
    }
    
    // MARK: - Movement Tests
    
    func testAdvanceInDirection() {
        var projectile = Projectile(row: 3, col: 3, direction: .up)
        
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 3)
    }
    
    func testAdvanceInAllDirections() {
        let testCases: [(Direction, Int, Int)] = [
            (.up, 2, 3),
            (.down, 4, 3),
            (.left, 3, 2),
            (.right, 3, 4)
        ]
        
        for (direction, expectedRow, expectedCol) in testCases {
            var projectile = Projectile(row: 3, col: 3, direction: direction)
            
            projectile.advance()
            
            XCTAssertEqual(projectile.row, expectedRow, "Wrong row for direction \(direction)")
            XCTAssertEqual(projectile.col, expectedCol, "Wrong col for direction \(direction)")
        }
    }
    
    // MARK: - Bounds Tests
    
    func testIsOutOfBoundsTop() {
        let projectile = Projectile(row: -1, col: 3, direction: .up)
        
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsOutOfBoundsBottom() {
        let projectile = Projectile(row: 8, col: 3, direction: .down)
        
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsOutOfBoundsLeft() {
        let projectile = Projectile(row: 3, col: -1, direction: .left)
        
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsOutOfBoundsRight() {
        let projectile = Projectile(row: 3, col: 8, direction: .right)
        
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsNotOutOfBounds() {
        let projectile = Projectile(row: 3, col: 3, direction: .up)
        
        XCTAssertFalse(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testIsNotOutOfBoundsAtEdges() {
        let edgePositions = [(0, 0), (0, 7), (7, 0), (7, 7)]
        
        for (row, col) in edgePositions {
            let projectile = Projectile(row: row, col: col, direction: .up)
            XCTAssertFalse(projectile.isOutOfBounds(gridSize: 8), "(\(row), \(col)) should be in bounds")
        }
    }
    
    // MARK: - Wall Collision Tests
    
    func testHitsWall() {
        var grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        grid[3][4] = .wall
        
        let projectile = Projectile(row: 3, col: 4, direction: .right)
        
        XCTAssertTrue(projectile.hits(grid: grid))
    }
    
    func testDoesNotHitEmptyCell() {
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        let projectile = Projectile(row: 3, col: 4, direction: .right)
        
        XCTAssertFalse(projectile.hits(grid: grid))
    }
    
    func testHitsReturnsFalseWhenOutOfBounds() {
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        let projectile = Projectile(row: -1, col: 4, direction: .up)
        
        XCTAssertFalse(projectile.hits(grid: grid))
    }
    
    // MARK: - Tank Collision Tests
    
    func testHitsTankAtPosition() {
        let projectile = Projectile(row: 3, col: 4, direction: .right)
        let tank = Tank(row: 3, col: 4, direction: .down)
        
        let hits = projectile.hits(tank: tank)
        
        XCTAssertTrue(hits)
    }
    
    func testDoesNotHitTankAtDifferentPosition() {
        let projectile = Projectile(row: 3, col: 4, direction: .right)
        let tank = Tank(row: 3, col: 5, direction: .down)
        
        let hits = projectile.hits(tank: tank)
        
        XCTAssertFalse(hits)
    }
    
    func testDoesNotHitDeadTank() {
        let projectile = Projectile(row: 3, col: 4, direction: .right)
        var tank = Tank(row: 3, col: 4, direction: .down)
        tank.isAlive = false
        
        let hits = projectile.hits(tank: tank)
        
        XCTAssertFalse(hits)
    }
    
    // MARK: - Codable Tests
    
    func testProjectileEncodingDecoding() throws {
        let projectile = Projectile(row: 5, col: 6, direction: .left)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(projectile)
        
        let decoder = JSONDecoder()
        let decodedProjectile = try decoder.decode(Projectile.self, from: data)
        
        XCTAssertEqual(decodedProjectile.row, projectile.row)
        XCTAssertEqual(decodedProjectile.col, projectile.col)
        XCTAssertEqual(decodedProjectile.direction, projectile.direction)
    }
}
