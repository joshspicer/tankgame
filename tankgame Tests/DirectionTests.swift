//
//  DirectionTests.swift
//  tankgame Tests
//
//  Unit tests for Direction enum
//

import XCTest
@testable import Tank_Game

final class DirectionTests: XCTestCase {

    // MARK: - Angle Tests

    func testDirectionAngles() {
        XCTAssertEqual(Direction.up.angle, 0, accuracy: 0.001)
        XCTAssertEqual(Direction.right.angle, .pi / 2, accuracy: 0.001)
        XCTAssertEqual(Direction.down.angle, .pi, accuracy: 0.001)
        XCTAssertEqual(Direction.left.angle, -.pi / 2, accuracy: 0.001)
        XCTAssertEqual(Direction.upRight.angle, .pi / 4, accuracy: 0.001)
        XCTAssertEqual(Direction.downRight.angle, 3 * .pi / 4, accuracy: 0.001)
        XCTAssertEqual(Direction.downLeft.angle, -.pi * 3 / 4, accuracy: 0.001)
        XCTAssertEqual(Direction.upLeft.angle, -.pi / 4, accuracy: 0.001)
    }

    // MARK: - Offset Tests

    func testCardinalDirectionOffsets() {
        XCTAssertEqual(Direction.up.offset.row, -1)
        XCTAssertEqual(Direction.up.offset.col, 0)

        XCTAssertEqual(Direction.down.offset.row, 1)
        XCTAssertEqual(Direction.down.offset.col, 0)

        XCTAssertEqual(Direction.left.offset.row, 0)
        XCTAssertEqual(Direction.left.offset.col, -1)

        XCTAssertEqual(Direction.right.offset.row, 0)
        XCTAssertEqual(Direction.right.offset.col, 1)
    }

    func testDiagonalDirectionOffsets() {
        XCTAssertEqual(Direction.upRight.offset.row, -1)
        XCTAssertEqual(Direction.upRight.offset.col, 1)

        XCTAssertEqual(Direction.downRight.offset.row, 1)
        XCTAssertEqual(Direction.downRight.offset.col, 1)

        XCTAssertEqual(Direction.downLeft.offset.row, 1)
        XCTAssertEqual(Direction.downLeft.offset.col, -1)

        XCTAssertEqual(Direction.upLeft.offset.row, -1)
        XCTAssertEqual(Direction.upLeft.offset.col, -1)
    }

    // MARK: - Diagonal Detection Tests

    func testIsDiagonal() {
        // Cardinal directions should not be diagonal
        XCTAssertFalse(Direction.up.isDiagonal)
        XCTAssertFalse(Direction.down.isDiagonal)
        XCTAssertFalse(Direction.left.isDiagonal)
        XCTAssertFalse(Direction.right.isDiagonal)

        // Diagonal directions should be diagonal
        XCTAssertTrue(Direction.upRight.isDiagonal)
        XCTAssertTrue(Direction.downRight.isDiagonal)
        XCTAssertTrue(Direction.downLeft.isDiagonal)
        XCTAssertTrue(Direction.upLeft.isDiagonal)
    }

    // MARK: - Cardinal Directions Tests

    func testCardinalDirections() {
        let cardinals = Direction.cardinalDirections
        XCTAssertEqual(cardinals.count, 4)
        XCTAssertTrue(cardinals.contains(.up))
        XCTAssertTrue(cardinals.contains(.down))
        XCTAssertTrue(cardinals.contains(.left))
        XCTAssertTrue(cardinals.contains(.right))
        XCTAssertFalse(cardinals.contains(.upRight))
        XCTAssertFalse(cardinals.contains(.downRight))
        XCTAssertFalse(cardinals.contains(.downLeft))
        XCTAssertFalse(cardinals.contains(.upLeft))
    }

    // MARK: - Codable Tests

    func testDirectionCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // Test each direction can be encoded and decoded
        for direction in Direction.allCases {
            let encoded = try encoder.encode(direction)
            let decoded = try decoder.decode(Direction.self, from: encoded)
            XCTAssertEqual(direction, decoded)
        }
    }
}
