//
//  ProjectileTests.swift
//  tankgame Tests
//
//  Unit tests for Projectile entity
//

import XCTest
@testable import Tank_Game

final class ProjectileTests: XCTestCase {
    
    func testProjectileInitialization() {
        let projectile = Projectile(row: 3, col: 4, direction: .left)
        
        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 4)
        XCTAssertEqual(projectile.direction, .left)
    }
    
    func testProjectileAdvanceUp() {
        var projectile = Projectile(row: 3, col: 2, direction: .up)
        
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 2)
    }
    
    func testProjectileAdvanceDown() {
        var projectile = Projectile(row: 3, col: 2, direction: .down)
        
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 2)
    }
    
    func testProjectileAdvanceLeft() {
        var projectile = Projectile(row: 2, col: 3, direction: .left)
        
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 2)
    }
    
    func testProjectileAdvanceRight() {
        var projectile = Projectile(row: 2, col: 3, direction: .right)
        
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 4)
    }
    
    func testProjectileIsOutOfBoundsTop() {
        let projectile = Projectile(row: -1, col: 2, direction: .up)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testProjectileIsOutOfBoundsBottom() {
        let projectile = Projectile(row: 8, col: 2, direction: .down)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testProjectileIsOutOfBoundsLeft() {
        let projectile = Projectile(row: 2, col: -1, direction: .left)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testProjectileIsOutOfBoundsRight() {
        let projectile = Projectile(row: 2, col: 8, direction: .right)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testProjectileIsInBounds() {
        let projectile = Projectile(row: 4, col: 5, direction: .up)
        XCTAssertFalse(projectile.isOutOfBounds(gridSize: 8))
    }
    
    func testProjectileHitsWall() {
        let projectile = Projectile(row: 2, col: 3, direction: .up)
        var grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 5), count: 5)
        grid[2][3] = .wall
        
        XCTAssertTrue(projectile.hits(grid: grid))
    }
    
    func testProjectileDoesNotHitEmptyCell() {
        let projectile = Projectile(row: 2, col: 3, direction: .up)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 5), count: 5)
        
        XCTAssertFalse(projectile.hits(grid: grid))
    }
    
    func testProjectileHitsGridReturnsFalseForOutOfBounds() {
        let projectile = Projectile(row: -1, col: 3, direction: .up)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 5), count: 5)
        
        XCTAssertFalse(projectile.hits(grid: grid))
    }
    
    func testProjectileHitsLiveTank() {
        let projectile = Projectile(row: 2, col: 3, direction: .up)
        let tank = Tank(row: 2, col: 3, direction: .down)
        
        XCTAssertTrue(projectile.hits(tank: tank))
    }
    
    func testProjectileDoesNotHitTankAtDifferentPosition() {
        let projectile = Projectile(row: 2, col: 3, direction: .up)
        let tank = Tank(row: 2, col: 4, direction: .down)
        
        XCTAssertFalse(projectile.hits(tank: tank))
    }
    
    func testProjectileDoesNotHitDeadTank() {
        let projectile = Projectile(row: 2, col: 3, direction: .up)
        var tank = Tank(row: 2, col: 3, direction: .down)
        tank.isAlive = false
        
        XCTAssertFalse(projectile.hits(tank: tank))
    }
    
    func testProjectileAdvanceMultipleTimes() {
        var projectile = Projectile(row: 5, col: 5, direction: .up)
        
        projectile.advance()
        projectile.advance()
        projectile.advance()
        
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 5)
    }
}
