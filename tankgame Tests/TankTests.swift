//
//  TankTests.swift
//  tankgame Tests
//
//  Unit tests for Tank struct
//

import XCTest
@testable import tankgame

class TankTests: XCTestCase {
    
    func testTankInitialization() {
        let tank = Tank(row: 2, col: 3, direction: .down)
        XCTAssertEqual(tank.row, 2)
        XCTAssertEqual(tank.col, 3)
        XCTAssertEqual(tank.direction, .down)
        XCTAssertTrue(tank.isAlive)
    }
    
    func testTankDefaultDirection() {
        let tank = Tank(row: 0, col: 0)
        XCTAssertEqual(tank.direction, .down)
    }
    
    func testTankMoveToEmptyCell() {
        var tank = Tank(row: 2, col: 2, direction: .up)
        let grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertTrue(moved)
        XCTAssertEqual(tank.row, 1)
        XCTAssertEqual(tank.col, 2)
        XCTAssertEqual(tank.direction, .up)
    }
    
    func testTankMoveToWall() {
        var tank = Tank(row: 2, col: 2, direction: .up)
        var grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        grid[1][2] = .wall
        
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 2)
        XCTAssertEqual(tank.col, 2)
    }
    
    func testTankMoveOutOfBoundsTop() {
        var tank = Tank(row: 0, col: 2, direction: .up)
        let grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        
        let moved = tank.move(in: .up, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 0)
        XCTAssertEqual(tank.col, 2)
    }
    
    func testTankMoveOutOfBoundsBottom() {
        var tank = Tank(row: 7, col: 2, direction: .down)
        let grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        
        let moved = tank.move(in: .down, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 7)
        XCTAssertEqual(tank.col, 2)
    }
    
    func testTankMoveOutOfBoundsLeft() {
        var tank = Tank(row: 2, col: 0, direction: .left)
        let grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        
        let moved = tank.move(in: .left, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 2)
        XCTAssertEqual(tank.col, 0)
    }
    
    func testTankMoveOutOfBoundsRight() {
        var tank = Tank(row: 2, col: 7, direction: .right)
        let grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        
        let moved = tank.move(in: .right, grid: grid)
        
        XCTAssertFalse(moved)
        XCTAssertEqual(tank.row, 2)
        XCTAssertEqual(tank.col, 7)
    }
    
    func testTankShoot() {
        let tank = Tank(row: 3, col: 4, direction: .up)
        let projectile = tank.shoot()
        
        XCTAssertEqual(projectile.row, 2)
        XCTAssertEqual(projectile.col, 4)
        XCTAssertEqual(projectile.direction, .up)
    }
    
    func testTankShootInAllDirections() {
        let directions: [Direction] = [.up, .down, .left, .right]
        
        for direction in directions {
            let tank = Tank(row: 3, col: 3, direction: direction)
            let projectile = tank.shoot()
            let offset = direction.offset
            
            XCTAssertEqual(projectile.row, 3 + offset.row)
            XCTAssertEqual(projectile.col, 3 + offset.col)
            XCTAssertEqual(projectile.direction, direction)
        }
    }
    
    func testTankCodable() throws {
        let tank = Tank(row: 5, col: 6, direction: .left)
        let encoder = JSONEncoder()
        let data = try encoder.encode(tank)
        
        let decoder = JSONDecoder()
        let decodedTank = try decoder.decode(Tank.self, from: data)
        
        XCTAssertEqual(tank.row, decodedTank.row)
        XCTAssertEqual(tank.col, decodedTank.col)
        XCTAssertEqual(tank.direction, decodedTank.direction)
        XCTAssertEqual(tank.isAlive, decodedTank.isAlive)
    }
}
