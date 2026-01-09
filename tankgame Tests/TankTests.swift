//
//  TankTests.swift
//  tankgame Tests
//
//  Unit tests for Tank struct
//

import XCTest
@testable import Tank_Game

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
        XCTAssertTrue(tank.isAlive)
    }

    // MARK: - Movement Tests

    func testTankMoveUp() {
        var tank = Tank(row: 4, col: 4, direction: .down)
        let grid = createEmptyGrid()

        let success = tank.move(in: .up, grid: grid)

        XCTAssertTrue(success)
        XCTAssertEqual(tank.row, 3)
        XCTAssertEqual(tank.col, 4)
        XCTAssertEqual(tank.direction, .up)
    }

    func testTankMoveDown() {
        var tank = Tank(row: 4, col: 4, direction: .up)
        let grid = createEmptyGrid()

        let success = tank.move(in: .down, grid: grid)

        XCTAssertTrue(success)
        XCTAssertEqual(tank.row, 5)
        XCTAssertEqual(tank.col, 4)
        XCTAssertEqual(tank.direction, .down)
    }

    func testTankMoveLeft() {
        var tank = Tank(row: 4, col: 4, direction: .right)
        let grid = createEmptyGrid()

        let success = tank.move(in: .left, grid: grid)

        XCTAssertTrue(success)
        XCTAssertEqual(tank.row, 4)
        XCTAssertEqual(tank.col, 3)
        XCTAssertEqual(tank.direction, .left)
    }

    func testTankMoveRight() {
        var tank = Tank(row: 4, col: 4, direction: .left)
        let grid = createEmptyGrid()

        let success = tank.move(in: .right, grid: grid)

        XCTAssertTrue(success)
        XCTAssertEqual(tank.row, 4)
        XCTAssertEqual(tank.col, 5)
        XCTAssertEqual(tank.direction, .right)
    }

    // MARK: - Boundary Tests

    func testTankCannotMoveOutOfBoundsTop() {
        var tank = Tank(row: 0, col: 4, direction: .down)
        let grid = createEmptyGrid()

        let success = tank.move(in: .up, grid: grid)

        XCTAssertFalse(success)
        XCTAssertEqual(tank.row, 0) // Position unchanged
        XCTAssertEqual(tank.col, 4)
    }

    func testTankCannotMoveOutOfBoundsBottom() {
        var tank = Tank(row: 7, col: 4, direction: .up)
        let grid = createEmptyGrid()

        let success = tank.move(in: .down, grid: grid)

        XCTAssertFalse(success)
        XCTAssertEqual(tank.row, 7) // Position unchanged
        XCTAssertEqual(tank.col, 4)
    }

    func testTankCannotMoveOutOfBoundsLeft() {
        var tank = Tank(row: 4, col: 0, direction: .right)
        let grid = createEmptyGrid()

        let success = tank.move(in: .left, grid: grid)

        XCTAssertFalse(success)
        XCTAssertEqual(tank.row, 4)
        XCTAssertEqual(tank.col, 0) // Position unchanged
    }

    func testTankCannotMoveOutOfBoundsRight() {
        var tank = Tank(row: 4, col: 7, direction: .left)
        let grid = createEmptyGrid()

        let success = tank.move(in: .right, grid: grid)

        XCTAssertFalse(success)
        XCTAssertEqual(tank.row, 4)
        XCTAssertEqual(tank.col, 7) // Position unchanged
    }

    // MARK: - Wall Collision Tests

    func testTankCannotMoveIntoWall() {
        var tank = Tank(row: 4, col: 4, direction: .down)
        var grid = createEmptyGrid()
        grid[3][4] = .wall // Place wall above tank

        let success = tank.move(in: .up, grid: grid)

        XCTAssertFalse(success)
        XCTAssertEqual(tank.row, 4) // Position unchanged
        XCTAssertEqual(tank.col, 4)
    }

    // MARK: - Shooting Tests

    func testTankShootUp() {
        let tank = Tank(row: 4, col: 4, direction: .up)
        let projectile = tank.shoot()

        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 4)
        XCTAssertEqual(projectile.direction, .up)
    }

    func testTankShootDown() {
        let tank = Tank(row: 4, col: 4, direction: .down)
        let projectile = tank.shoot()

        XCTAssertEqual(projectile.row, 5)
        XCTAssertEqual(projectile.col, 4)
        XCTAssertEqual(projectile.direction, .down)
    }

    func testTankShootLeft() {
        let tank = Tank(row: 4, col: 4, direction: .left)
        let projectile = tank.shoot()

        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 3)
        XCTAssertEqual(projectile.direction, .left)
    }

    func testTankShootRight() {
        let tank = Tank(row: 4, col: 4, direction: .right)
        let projectile = tank.shoot()

        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 5)
        XCTAssertEqual(projectile.direction, .right)
    }

    // MARK: - Codable Tests

    func testTankCodable() throws {
        let tank = Tank(row: 3, col: 5, direction: .left)

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let encoded = try encoder.encode(tank)
        let decoded = try decoder.decode(Tank.self, from: encoded)

        XCTAssertEqual(tank.row, decoded.row)
        XCTAssertEqual(tank.col, decoded.col)
        XCTAssertEqual(tank.direction, decoded.direction)
        XCTAssertEqual(tank.isAlive, decoded.isAlive)
    }

    // MARK: - Helper Methods

    private func createEmptyGrid() -> [[GridCell]] {
        return Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
    }
}
