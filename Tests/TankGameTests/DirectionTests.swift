//
//  DirectionTests.swift
//  TankGameCoreTests
//
//  Tests for the Direction enum
//

import XCTest
@testable import TankGameCore

final class DirectionTests: XCTestCase {
    
    // MARK: - Offset Tests
    
    func testUpOffset() {
        let direction = Direction.up
        XCTAssertEqual(direction.offset.row, -1)
        XCTAssertEqual(direction.offset.col, 0)
    }
    
    func testDownOffset() {
        let direction = Direction.down
        XCTAssertEqual(direction.offset.row, 1)
        XCTAssertEqual(direction.offset.col, 0)
    }
    
    func testLeftOffset() {
        let direction = Direction.left
        XCTAssertEqual(direction.offset.row, 0)
        XCTAssertEqual(direction.offset.col, -1)
    }
    
    func testRightOffset() {
        let direction = Direction.right
        XCTAssertEqual(direction.offset.row, 0)
        XCTAssertEqual(direction.offset.col, 1)
    }
    
    // MARK: - Angle Tests
    
    func testUpAngle() {
        let direction = Direction.up
        XCTAssertEqual(direction.angle, 0)
    }
    
    func testRightAngle() {
        let direction = Direction.right
        XCTAssertEqual(direction.angle, .pi / 2, accuracy: 0.001)
    }
    
    func testDownAngle() {
        let direction = Direction.down
        XCTAssertEqual(direction.angle, .pi, accuracy: 0.001)
    }
    
    func testLeftAngle() {
        let direction = Direction.left
        XCTAssertEqual(direction.angle, -.pi / 2, accuracy: 0.001)
    }
    
    // MARK: - CaseIterable Tests
    
    func testAllCasesCount() {
        XCTAssertEqual(Direction.allCases.count, 4)
    }
    
    func testAllCasesContainsAllDirections() {
        XCTAssertTrue(Direction.allCases.contains(.up))
        XCTAssertTrue(Direction.allCases.contains(.down))
        XCTAssertTrue(Direction.allCases.contains(.left))
        XCTAssertTrue(Direction.allCases.contains(.right))
    }
    
    // MARK: - Raw Value Tests
    
    func testRawValues() {
        XCTAssertEqual(Direction.up.rawValue, 0)
        XCTAssertEqual(Direction.right.rawValue, 1)
        XCTAssertEqual(Direction.down.rawValue, 2)
        XCTAssertEqual(Direction.left.rawValue, 3)
    }
    
    // MARK: - Codable Tests
    
    func testEncodeDecode() throws {
        let direction = Direction.right
        let encoder = JSONEncoder()
        let data = try encoder.encode(direction)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Direction.self, from: data)
        
        XCTAssertEqual(direction, decoded)
    }
}
