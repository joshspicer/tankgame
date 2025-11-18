//
//  TankTests.swift
//  tankgame Tests
//
//  Unit tests for Tank entity
//

import XCTest
@testable import Tank_Game

final class TankTests: XCTestCase {
    
    func testTankInitialization() {
        let tank = Tank(row: 2, col: 3, direction: .up)
        
        XCTAssertEqual(tank.row, 2)
        XCTAssertEqual(tank.col, 3)
        XCTAssertEqual(tank.direction, .up)
        XCTAssertTrue(tank.isAlive)
    }
    
    func testTankDefaultDirection() {
        let tank = Tank(row: 0, col: 0)
        XCTAssertEqual(tank.direction, .down)
    }
    
    func testTankMoveUp() {
        var tank = Tank(row: 2, col: 2, direction: .down)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 5), count: 5)
        
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertTrue(moved)
        XCTAssertEqual(tank.row, 1)
        XCTAssertEqual(tank.col, 2)
        XCTAssertEqual(tank.direction, .up)
    }
    
    func testTankMoveDown() {
        var tank = Tank(row: 2, col: 2, direction: .up)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 5), count: 5)
        
        let moved = tank.move(in: .down, grid: grid)
        
        XCTAssertTrue(moved)
        XCTAssertEqual(tank.row, 3)
        XCTAssertEqual(tank.col, 2)
        XCTAssertEqual(tank.direction, .down)
    }
    
    func testTankMoveLeft() {
        var tank = Tank(row: 2, col: 2, direction: .right)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 5), count: 5)
        
        let moved = tank.move(in: .left, grid: grid)
        
        XCTAssertTrue(moved)
        XCTAssertEqual(tank.row, 2)
        XCTAssertEqual(tank.col, 1)
        XCTAssertEqual(tank.direction, .left)
    }
    
    func testTankMoveRight() {
        var tank = Tank(row: 2, col: 2, direction: .left)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 5), count: 5)
        
        let moved = tank.move(in: .right, grid: grid)
        
        XCTAssertTrue(moved)
        XCTAssertEqual(tank.row, 2)
        XCTAssertEqual(tank.col, 3)
        XCTAssertEqual(tank.direction, .right)
    }
    
    func testTankCannotMoveOutOfBoundsTop() {
        var tank = Tank(row: 0, col: 2, direction: .down)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 5), count: 5)
        
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 0) // Position unchanged
        XCTAssertEqual(tank.col, 2)
    }
    
    func testTankCannotMoveOutOfBoundsBottom() {
        var tank = Tank(row: 4, col: 2, direction: .up)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 5), count: 5)
        
        let moved = tank.move(in: .down, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 4) // Position unchanged
        XCTAssertEqual(tank.col, 2)
    }
    
    func testTankCannotMoveOutOfBoundsLeft() {
        var tank = Tank(row: 2, col: 0, direction: .right)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 5), count: 5)
        
        let moved = tank.move(in: .left, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 2)
        XCTAssertEqual(tank.col, 0) // Position unchanged
    }
    
    func testTankCannotMoveOutOfBoundsRight() {
        var tank = Tank(row: 2, col: 4, direction: .left)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 5), count: 5)
        
        let moved = tank.move(in: .right, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 2)
        XCTAssertEqual(tank.col, 4) // Position unchanged
    }
    
    func testTankCannotMoveIntoWall() {
        var tank = Tank(row: 2, col: 2, direction: .down)
        var grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 5), count: 5)
        grid[1][2] = .wall // Place wall above tank
        
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 2) // Position unchanged
        XCTAssertEqual(tank.col, 2)
    }
    
    func testTankShootCreatesProjectile() {
        let tank = Tank(row: 2, col: 3, direction: .up)
        
        let projectile = tank.shoot()
        
        XCTAssertEqual(projectile.row, 1) // One cell in front of tank
        XCTAssertEqual(projectile.col, 3)
        XCTAssertEqual(projectile.direction, .up)
    }
    
    func testTankShootInAllDirections() {
        // Test shooting up
        var tank = Tank(row: 2, col: 2, direction: .up)
        var projectile = tank.shoot()
        XCTAssertEqual(projectile.row, 1)
        XCTAssertEqual(projectile.col, 2)
        
        // Test shooting down
        tank.direction = .down
        projectile = tank.shoot()
        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 2)
        
        // Test shooting left
        tank.direction = .left
        projectile = tank.shoot()
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 1)
        
        // Test shooting right
        tank.direction = .right
        projectile = tank.shoot()
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 3)
    }
    
    func testTankIsAliveByDefault() {
        let tank = Tank(row: 0, col: 0)
        XCTAssertTrue(tank.isAlive)
    }
}
