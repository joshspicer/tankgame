//
//  ProjectileTests.swift
//  tankgame Tests
//
//  Unit tests for Projectile struct
//

import XCTest
@testable import tankgame

class ProjectileTests: XCTestCase {
    
    func testProjectileInitialization() {
        let projectile = Projectile(row: 2, col: 3, direction: .up)
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 3)
        XCTAssertEqual(projectile.direction, .up)
    }
    
    func testProjectileAdvance() {
        var projectile = Projectile(row: 3, col: 4, direction: .up)
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 4)
    }
    
    func testProjectileAdvanceInAllDirections() {
        let directions: [Direction] = [.up, .down, .left, .right]
        
        for direction in directions {
            var projectile = Projectile(row: 3, col: 3, direction: direction)
            projectile.advance()
            
            let offset = direction.offset
            XCTAssertEqual(projectile.row, 3 + offset.row)
            XCTAssertEqual(projectile.col, 3 + offset.col)
        }
    }
    
    func testProjectileMultipleAdvances() {
        var projectile = Projectile(row: 5, col: 5, direction: .up)
        
        projectile.advance()
        XCTAssertEqual(projectile.row, 4)
        
        projectile.advance()
        XCTAssertEqual(projectile.row, 3)
        
        projectile.advance()
        XCTAssertEqual(projectile.row, 2)
    }
    
    func testProjectileIsOutOfBoundsTop() {
        let projectile = Projectile(row: -1, col: 3, direction: .up)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testProjectileIsOutOfBoundsBottom() {
        let projectile = Projectile(row: 8, col: 3, direction: .down)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testProjectileIsOutOfBoundsLeft() {
        let projectile = Projectile(row: 3, col: -1, direction: .left)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testProjectileIsOutOfBoundsRight() {
        let projectile = Projectile(row: 3, col: 8, direction: .right)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testProjectileIsInBounds() {
        let projectile = Projectile(row: 3, col: 3, direction: .up)
        XCTAssertFalse(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testProjectileHitsWall() {
        var grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        grid[3][4] = .wall
        
        let projectile = Projectile(row: 3, col: 4, direction: .right)
        XCTAssertTrue(projectile.hits(grid: grid))
    }
    
    func testProjectileDoesNotHitEmptyCell() {
        let grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        
        let projectile = Projectile(row: 3, col: 4, direction: .right)
        XCTAssertFalse(projectile.hits(grid: grid))
    }
    
    func testProjectileHitsTank() {
        let tank = Tank(row: 3, col: 4, direction: .down)
        let projectile = Projectile(row: 3, col: 4, direction: .right)
        
        XCTAssertTrue(projectile.hits(tank: tank))
    }
    
    func testProjectileDoesNotHitTankAtDifferentPosition() {
        let tank = Tank(row: 3, col: 4, direction: .down)
        let projectile = Projectile(row: 3, col: 5, direction: .right)
        
        XCTAssertFalse(projectile.hits(tank: tank))
    }
    
    func testProjectileDoesNotHitDeadTank() {
        var tank = Tank(row: 3, col: 4, direction: .down)
        tank.isAlive = false
        let projectile = Projectile(row: 3, col: 4, direction: .right)
        
        XCTAssertFalse(projectile.hits(tank: tank))
    }
    
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
