//
//  DirectionTests.swift
//  tankgame Shared
//
//  Unit tests for Direction enum
//

import XCTest
@testable import tankgame

class DirectionTests: XCTestCase {
    
    // MARK: - Angle Tests
    
    func testCardinalAngles() {
        XCTAssertEqual(Direction.up.angle, 0, accuracy: 0.001)
        XCTAssertEqual(Direction.right.angle, .pi / 2, accuracy: 0.001)
        XCTAssertEqual(Direction.down.angle, .pi, accuracy: 0.001)
        XCTAssertEqual(Direction.left.angle, -.pi / 2, accuracy: 0.001)
    }
    
    func testDiagonalAngles() {
        XCTAssertEqual(Direction.upRight.angle, .pi / 4, accuracy: 0.001)
        XCTAssertEqual(Direction.downRight.angle, 3 * .pi / 4, accuracy: 0.001)
        XCTAssertEqual(Direction.downLeft.angle, -.pi * 3 / 4, accuracy: 0.001)
        XCTAssertEqual(Direction.upLeft.angle, -.pi / 4, accuracy: 0.001)
    }
    
    // MARK: - Offset Tests
    
    func testCardinalOffsets() {
        XCTAssertEqual(Direction.up.offset.row, -1)
        XCTAssertEqual(Direction.up.offset.col, 0)
        
        XCTAssertEqual(Direction.down.offset.row, 1)
        XCTAssertEqual(Direction.down.offset.col, 0)
        
        XCTAssertEqual(Direction.left.offset.row, 0)
        XCTAssertEqual(Direction.left.offset.col, -1)
        
        XCTAssertEqual(Direction.right.offset.row, 0)
        XCTAssertEqual(Direction.right.offset.col, 1)
    }
    
    func testDiagonalOffsets() {
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
    
    func testCardinalDirectionsAreNotDiagonal() {
        XCTAssertFalse(Direction.up.isDiagonal)
        XCTAssertFalse(Direction.down.isDiagonal)
        XCTAssertFalse(Direction.left.isDiagonal)
        XCTAssertFalse(Direction.right.isDiagonal)
    }
    
    func testDiagonalDirectionsAreDiagonal() {
        XCTAssertTrue(Direction.upRight.isDiagonal)
        XCTAssertTrue(Direction.downRight.isDiagonal)
        XCTAssertTrue(Direction.downLeft.isDiagonal)
        XCTAssertTrue(Direction.upLeft.isDiagonal)
    }
    
    // MARK: - Cardinal Directions Tests
    
    func testCardinalDirectionsArray() {
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
        let direction = Direction.upRight
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(direction)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Direction.self, from: data)
        
        XCTAssertEqual(decoded, direction)
    }
    
    func testAllDirectionsCodable() throws {
        for direction in Direction.allCases {
            let encoder = JSONEncoder()
            let data = try encoder.encode(direction)
            
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(Direction.self, from: data)
            
            XCTAssertEqual(decoded, direction, "Direction \(direction) should be codable")
        }
    }
    
    // MARK: - All Cases Tests
    
    func testAllCasesCount() {
        XCTAssertEqual(Direction.allCases.count, 8, "Should have exactly 8 directions")
    }
    
    func testAllCasesContainsAllDirections() {
        let allCases = Direction.allCases
        
        XCTAssertTrue(allCases.contains(.up))
        XCTAssertTrue(allCases.contains(.down))
        XCTAssertTrue(allCases.contains(.left))
        XCTAssertTrue(allCases.contains(.right))
        XCTAssertTrue(allCases.contains(.upRight))
        XCTAssertTrue(allCases.contains(.downRight))
        XCTAssertTrue(allCases.contains(.downLeft))
        XCTAssertTrue(allCases.contains(.upLeft))
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
    
    func testInitFromRawValue() {
        XCTAssertEqual(Direction(rawValue: 0), .up)
        XCTAssertEqual(Direction(rawValue: 1), .right)
        XCTAssertEqual(Direction(rawValue: 2), .down)
        XCTAssertEqual(Direction(rawValue: 3), .left)
        XCTAssertEqual(Direction(rawValue: 4), .upRight)
        XCTAssertEqual(Direction(rawValue: 5), .downRight)
        XCTAssertEqual(Direction(rawValue: 6), .downLeft)
        XCTAssertEqual(Direction(rawValue: 7), .upLeft)
        XCTAssertNil(Direction(rawValue: 8))
        XCTAssertNil(Direction(rawValue: -1))
    }
}
