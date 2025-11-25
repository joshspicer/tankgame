//
//  DirectionTests.swift
//  TankGameCoreTests
//
//  Unit tests for Direction enum
//

import XCTest
@testable import TankGameCore

final class DirectionTests: XCTestCase {
    
    // MARK: - Cardinal Direction Tests
    
    func testUpDirection() {
        let direction = Direction.up
        XCTAssertEqual(direction.offset.row, -1)
        XCTAssertEqual(direction.offset.col, 0)
        XCTAssertEqual(direction.angle, 0)
        XCTAssertFalse(direction.isDiagonal)
    }
    
    func testDownDirection() {
        let direction = Direction.down
        XCTAssertEqual(direction.offset.row, 1)
        XCTAssertEqual(direction.offset.col, 0)
        XCTAssertEqual(direction.angle, .pi)
        XCTAssertFalse(direction.isDiagonal)
    }
    
    func testLeftDirection() {
        let direction = Direction.left
        XCTAssertEqual(direction.offset.row, 0)
        XCTAssertEqual(direction.offset.col, -1)
        XCTAssertEqual(direction.angle, -.pi / 2)
        XCTAssertFalse(direction.isDiagonal)
    }
    
    func testRightDirection() {
        let direction = Direction.right
        XCTAssertEqual(direction.offset.row, 0)
        XCTAssertEqual(direction.offset.col, 1)
        XCTAssertEqual(direction.angle, .pi / 2)
        XCTAssertFalse(direction.isDiagonal)
    }
    
    // MARK: - Diagonal Direction Tests
    
    func testUpRightDirection() {
        let direction = Direction.upRight
        XCTAssertEqual(direction.offset.row, -1)
        XCTAssertEqual(direction.offset.col, 1)
        XCTAssertEqual(direction.angle, .pi / 4)
        XCTAssertTrue(direction.isDiagonal)
    }
    
    func testUpLeftDirection() {
        let direction = Direction.upLeft
        XCTAssertEqual(direction.offset.row, -1)
        XCTAssertEqual(direction.offset.col, -1)
        XCTAssertEqual(direction.angle, -.pi / 4)
        XCTAssertTrue(direction.isDiagonal)
    }
    
    func testDownRightDirection() {
        let direction = Direction.downRight
        XCTAssertEqual(direction.offset.row, 1)
        XCTAssertEqual(direction.offset.col, 1)
        XCTAssertEqual(direction.angle, 3 * .pi / 4)
        XCTAssertTrue(direction.isDiagonal)
    }
    
    func testDownLeftDirection() {
        let direction = Direction.downLeft
        XCTAssertEqual(direction.offset.row, 1)
        XCTAssertEqual(direction.offset.col, -1)
        XCTAssertEqual(direction.angle, -.pi * 3 / 4)
        XCTAssertTrue(direction.isDiagonal)
    }
    
    // MARK: - Raw Value Tests
    
    func testRawValues() {
        XCTAssertEqual(Direction.up.rawValue, 0)
        XCTAssertEqual(Direction.right.rawValue, 1)
        XCTAssertEqual(Direction.down.rawValue, 2)
        XCTAssertEqual(Direction.left.rawValue, 3)
        XCTAssertEqual(Direction.upRight.rawValue, 4)
        XCTAssertEqual(Direction.downRight.rawValue, 5)
        XCTAssertEqual(Direction.downLeft.rawValue, 6)
        XCTAssertEqual(Direction.upLeft.rawValue, 7)
    }
    
    // MARK: - Codable Tests
    
    func testCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        for direction in Direction.allCases {
            let data = try encoder.encode(direction)
            let decoded = try decoder.decode(Direction.self, from: data)
            XCTAssertEqual(direction, decoded)
        }
    }
    
    // MARK: - All Cases Test
    
    func testAllCasesCount() {
        XCTAssertEqual(Direction.allCases.count, 8)
    }
}
