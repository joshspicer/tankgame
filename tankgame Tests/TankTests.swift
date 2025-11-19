//
//  TankTests.swift
//  tankgame Tests
//
//  Unit tests for Tank entity
//

import XCTest
@testable import tankgame_iOS

final class TankTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testTankInitialization() {
        let tank = Tank(row: 3, col: 4, direction: .up)
        
        XCTAssertEqual(tank.row, 3)
        XCTAssertEqual(tank.col, 4)
        XCTAssertEqual(tank.direction, .up)
        XCTAssertTrue(tank.isAlive)
    }
    
    func testTankDefaultDirection() {
        let tank = Tank(row: 0, col: 0)
        XCTAssertEqual(tank.direction, .down)
    }
    
    // MARK: - Movement Tests
    
    func testValidMovement() {
        var tank = Tank(row: 3, col: 3, direction: .up)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertTrue(moved)
        XCTAssertEqual(tank.row, 2)
        XCTAssertEqual(tank.col, 3)
        XCTAssertEqual(tank.direction, .up)
    }
    
    func testMovementUpdateDirection() {
        var tank = Tank(row: 3, col: 3, direction: .up)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        
        let moved = tank.move(in: .right, grid: grid)
        
        XCTAssertTrue(moved)
        XCTAssertEqual(tank.row, 3)
        XCTAssertEqual(tank.col, 4)
        XCTAssertEqual(tank.direction, .right)
    }
    
    func testMovementBlockedByWall() {
        var tank = Tank(row: 3, col: 3, direction: .up)
        var grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        grid[2][3] = .wall
        
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 3) // Position unchanged
        XCTAssertEqual(tank.col, 3)
    }
    
    func testMovementBlockedByTopBoundary() {
        var tank = Tank(row: 0, col: 3, direction: .up)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 0)
        XCTAssertEqual(tank.col, 3)
    }
    
    func testMovementBlockedByBottomBoundary() {
        var tank = Tank(row: 7, col: 3, direction: .down)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        
        let moved = tank.move(in: .down, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 7)
        XCTAssertEqual(tank.col, 3)
    }
    
    func testMovementBlockedByLeftBoundary() {
        var tank = Tank(row: 3, col: 0, direction: .left)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        
        let moved = tank.move(in: .left, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 3)
        XCTAssertEqual(tank.col, 0)
    }
    
    func testMovementBlockedByRightBoundary() {
        var tank = Tank(row: 3, col: 7, direction: .right)
        let grid: [[GridCell]] = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        
        let moved = tank.move(in: .right, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 3)
        XCTAssertEqual(tank.col, 7)
    }
    
    // MARK: - Shooting Tests
    
    func testShootCreatesProjectileInFrontOfTank() {
        let tank = Tank(row: 3, col: 3, direction: .up)
        
        let projectile = tank.shoot()
        
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 3)
        XCTAssertEqual(projectile.direction, .up)
    }
    
    func testShootInAllDirections() {
        let directions: [(Direction, Int, Int)] = [
            (.up, -1, 0),
            (.down, 1, 0),
            (.left, 0, -1),
            (.right, 0, 1)
        ]
        
        for (direction, rowOffset, colOffset) in directions {
            let tank = Tank(row: 3, col: 3, direction: direction)
            let projectile = tank.shoot()
            
            XCTAssertEqual(projectile.row, 3 + rowOffset, "Failed for direction \(direction)")
            XCTAssertEqual(projectile.col, 3 + colOffset, "Failed for direction \(direction)")
            XCTAssertEqual(projectile.direction, direction)
        }
    }
    
    // MARK: - Codable Tests
    
    func testTankEncodingDecoding() throws {
        let tank = Tank(row: 5, col: 6, direction: .left)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(tank)
        
        let decoder = JSONDecoder()
        let decodedTank = try decoder.decode(Tank.self, from: data)
        
        XCTAssertEqual(decodedTank.row, tank.row)
        XCTAssertEqual(decodedTank.col, tank.col)
        XCTAssertEqual(decodedTank.direction, tank.direction)
        XCTAssertEqual(decodedTank.isAlive, tank.isAlive)
    }
}
