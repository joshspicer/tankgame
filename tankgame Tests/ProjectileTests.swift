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
    
    func testMoveInDirection() {
        var projectile = Projectile(row: 3, col: 3, direction: .up)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        
        let result = projectile.move(grid: grid)
        
        XCTAssertTrue(result)
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 3)
    }
    
    func testMoveBlockedByWall() {
        var projectile = Projectile(row: 3, col: 3, direction: .up)
        var grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        grid[2][3] = .wall
        
        let result = projectile.move(grid: grid)
        
        XCTAssertFalse(result)
        XCTAssertEqual(projectile.row, 3) // Position unchanged
        XCTAssertEqual(projectile.col, 3)
    }
    
    func testMoveOutOfBoundsTop() {
        var projectile = Projectile(row: 0, col: 3, direction: .up)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        
        let result = projectile.move(grid: grid)
        
        XCTAssertFalse(result)
    }
    
    func testMoveOutOfBoundsBottom() {
        var projectile = Projectile(row: 7, col: 3, direction: .down)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        
        let result = projectile.move(grid: grid)
        
        XCTAssertFalse(result)
    }
    
    func testMoveOutOfBoundsLeft() {
        var projectile = Projectile(row: 3, col: 0, direction: .left)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        
        let result = projectile.move(grid: grid)
        
        XCTAssertFalse(result)
    }
    
    func testMoveOutOfBoundsRight() {
        var projectile = Projectile(row: 3, col: 7, direction: .right)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        
        let result = projectile.move(grid: grid)
        
        XCTAssertFalse(result)
    }
    
    func testMoveInAllDirections() {
        let testCases: [(Direction, Int, Int)] = [
            (.up, 2, 3),
            (.down, 4, 3),
            (.left, 3, 2),
            (.right, 3, 4)
        ]
        
        for (direction, expectedRow, expectedCol) in testCases {
            var projectile = Projectile(row: 3, col: 3, direction: direction)
            let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
            
            let moved = projectile.move(grid: grid)
            
            XCTAssertTrue(moved, "Failed to move in direction \(direction)")
            XCTAssertEqual(projectile.row, expectedRow, "Wrong row for direction \(direction)")
            XCTAssertEqual(projectile.col, expectedCol, "Wrong col for direction \(direction)")
        }
    }
    
    // MARK: - Collision Tests
    
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
