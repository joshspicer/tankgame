//
//  ProjectileTests.swift
//  tankgame Tests
//
//  Unit tests for Projectile struct
//

import XCTest
@testable import Tank_Game

final class ProjectileTests: XCTestCase {

    // MARK: - Initialization Tests

    func testProjectileInitialization() {
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 4)
        XCTAssertEqual(projectile.direction, .up)
    }

    // MARK: - Advance Tests

    func testProjectileAdvanceUp() {
        var projectile = Projectile(row: 4, col: 4, direction: .up)
        projectile.advance()

        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 4)
    }

    func testProjectileAdvanceDown() {
        var projectile = Projectile(row: 4, col: 4, direction: .down)
        projectile.advance()

        XCTAssertEqual(projectile.row, 5)
        XCTAssertEqual(projectile.col, 4)
    }

    func testProjectileAdvanceLeft() {
        var projectile = Projectile(row: 4, col: 4, direction: .left)
        projectile.advance()

        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 3)
    }

    func testProjectileAdvanceRight() {
        var projectile = Projectile(row: 4, col: 4, direction: .right)
        projectile.advance()

        XCTAssertEqual(projectile.row, 4)
        XCTAssertEqual(projectile.col, 5)
    }

    func testProjectileAdvanceDiagonal() {
        var projectile = Projectile(row: 4, col: 4, direction: .upRight)
        projectile.advance()

        XCTAssertEqual(projectile.row, 3)
        XCTAssertEqual(projectile.col, 5)
    }

    func testProjectileAdvanceMultipleTimes() {
        var projectile = Projectile(row: 4, col: 4, direction: .up)
        projectile.advance()
        projectile.advance()
        projectile.advance()

        XCTAssertEqual(projectile.row, 1)
        XCTAssertEqual(projectile.col, 4)
    }

    // MARK: - Out of Bounds Tests

    func testProjectileIsOutOfBoundsNegativeRow() {
        let projectile = Projectile(row: -1, col: 4, direction: .up)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }

    func testProjectileIsOutOfBoundsNegativeCol() {
        let projectile = Projectile(row: 4, col: -1, direction: .left)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }

    func testProjectileIsOutOfBoundsRowTooLarge() {
        let projectile = Projectile(row: 8, col: 4, direction: .down)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }

    func testProjectileIsOutOfBoundsColTooLarge() {
        let projectile = Projectile(row: 4, col: 8, direction: .right)
        XCTAssertTrue(projectile.isOutOfBounds(gridSize: 8))
    }

    func testProjectileIsNotOutOfBounds() {
        let projectile = Projectile(row: 4, col: 4, direction: .up)
        XCTAssertFalse(projectile.isOutOfBounds(gridSize: 8))
    }

    func testProjectileAtEdgeIsNotOutOfBounds() {
        let projectile1 = Projectile(row: 0, col: 0, direction: .down)
        XCTAssertFalse(projectile1.isOutOfBounds(gridSize: 8))

        let projectile2 = Projectile(row: 7, col: 7, direction: .up)
        XCTAssertFalse(projectile2.isOutOfBounds(gridSize: 8))
    }

    // MARK: - Grid Collision Tests

    func testProjectileHitsWall() {
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        var grid = createEmptyGrid()
        grid[3][4] = .wall

        XCTAssertTrue(projectile.hits(grid: grid))
    }

    func testProjectileDoesNotHitEmptyCell() {
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        let grid = createEmptyGrid()

        XCTAssertFalse(projectile.hits(grid: grid))
    }

    func testProjectileOutOfBoundsDoesNotHitGrid() {
        let projectile = Projectile(row: -1, col: 4, direction: .up)
        let grid = createEmptyGrid()

        XCTAssertFalse(projectile.hits(grid: grid))
    }

    // MARK: - Tank Collision Tests

    func testProjectileHitsAliveTank() {
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        let tank = Tank(row: 3, col: 4, direction: .down)

        XCTAssertTrue(projectile.hits(tank: tank))
    }

    func testProjectileDoesNotHitDeadTank() {
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        var tank = Tank(row: 3, col: 4, direction: .down)
        tank.isAlive = false

        XCTAssertFalse(projectile.hits(tank: tank))
    }

    func testProjectileDoesNotHitTankAtDifferentPosition() {
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        let tank = Tank(row: 3, col: 5, direction: .down)

        XCTAssertFalse(projectile.hits(tank: tank))
    }

    // MARK: - Lizard Collision Tests

    func testProjectileHitsAliveLizard() {
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        let lizard = Lizard(row: 3, col: 4)

        XCTAssertTrue(projectile.hitsLizard(lizard))
    }

    func testProjectileDoesNotHitDeadLizard() {
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        var lizard = Lizard(row: 3, col: 4)
        lizard.isAlive = false

        XCTAssertFalse(projectile.hitsLizard(lizard))
    }

    func testProjectileDoesNotHitLizardAtDifferentPosition() {
        let projectile = Projectile(row: 3, col: 4, direction: .up)
        let lizard = Lizard(row: 3, col: 5)

        XCTAssertFalse(projectile.hitsLizard(lizard))
    }

    // MARK: - Codable Tests

    func testProjectileCodable() throws {
        let projectile = Projectile(row: 3, col: 5, direction: .left)

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let encoded = try encoder.encode(projectile)
        let decoded = try decoder.decode(Projectile.self, from: encoded)

        XCTAssertEqual(projectile.row, decoded.row)
        XCTAssertEqual(projectile.col, decoded.col)
        XCTAssertEqual(projectile.direction, decoded.direction)
    }

    // MARK: - Helper Methods

    private func createEmptyGrid() -> [[GridCell]] {
        return Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
    }
}
