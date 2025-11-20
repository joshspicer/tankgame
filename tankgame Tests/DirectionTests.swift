//
//  DirectionTests.swift
//  tankgame Tests
//
//  Unit tests for Direction enum
//

import XCTest
@testable import tankgame_iOS

final class DirectionTests: XCTestCase {
    
    // MARK: - Angle Tests
    
    func testAngleUp() {
        XCTAssertEqual(Direction.up.angle, 0, accuracy: 0.001)
    }
    
    func testAngleRight() {
        XCTAssertEqual(Direction.right.angle, .pi / 2, accuracy: 0.001)
    }
    
    func testAngleDown() {
        XCTAssertEqual(Direction.down.angle, .pi, accuracy: 0.001)
    }
    
    func testAngleLeft() {
        XCTAssertEqual(Direction.left.angle, -.pi / 2, accuracy: 0.001)
    }
    
    // MARK: - Offset Tests
    
    func testOffsetUp() {
        let offset = Direction.up.offset
        XCTAssertEqual(offset.row, -1)
        XCTAssertEqual(offset.col, 0)
    }
    
    func testOffsetDown() {
        let offset = Direction.down.offset
        XCTAssertEqual(offset.row, 1)
        XCTAssertEqual(offset.col, 0)
    }
    
    func testOffsetLeft() {
        let offset = Direction.left.offset
        XCTAssertEqual(offset.row, 0)
        XCTAssertEqual(offset.col, -1)
    }
    
    func testOffsetRight() {
        let offset = Direction.right.offset
        XCTAssertEqual(offset.row, 0)
        XCTAssertEqual(offset.col, 1)
    }
    
    // MARK: - CaseIterable Tests
    
    func testAllCases() {
        let allDirections = Direction.allCases
        
        XCTAssertEqual(allDirections.count, 4, "Should have exactly 4 directions")
        XCTAssertTrue(allDirections.contains(.up))
        XCTAssertTrue(allDirections.contains(.right))
        XCTAssertTrue(allDirections.contains(.down))
        XCTAssertTrue(allDirections.contains(.left))
    }
    
    // MARK: - Raw Value Tests
    
    func testRawValues() {
        XCTAssertEqual(Direction.up.rawValue, 0)
        XCTAssertEqual(Direction.right.rawValue, 1)
        XCTAssertEqual(Direction.down.rawValue, 2)
        XCTAssertEqual(Direction.left.rawValue, 3)
    }
    
    func testInitFromRawValue() {
        XCTAssertEqual(Direction(rawValue: 0), .up)
        XCTAssertEqual(Direction(rawValue: 1), .right)
        XCTAssertEqual(Direction(rawValue: 2), .down)
        XCTAssertEqual(Direction(rawValue: 3), .left)
        XCTAssertNil(Direction(rawValue: 4), "Invalid raw value should return nil")
    }
    
    // MARK: - Codable Tests
    
    func testDirectionCodable() throws {
        let direction = Direction.left
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(direction)
        
        let decoder = JSONDecoder()
        let decodedDirection = try decoder.decode(Direction.self, from: data)
        
        XCTAssertEqual(direction, decodedDirection)
    }
    
    func testAllDirectionsCodable() throws {
        for direction in Direction.allCases {
            let encoder = JSONEncoder()
            let data = try encoder.encode(direction)
            
            let decoder = JSONDecoder()
            let decodedDirection = try decoder.decode(Direction.self, from: data)
            
            XCTAssertEqual(direction, decodedDirection)
        }
    }
    
    // MARK: - Offset Application Tests
    
    func testOffsetApplicationSequence() {
        // Test that applying offsets in sequence produces expected results
        var row = 4, col = 4
        
        // Move up
        var offset = Direction.up.offset
        row += offset.row
        col += offset.col
        XCTAssertEqual(row, 3)
        XCTAssertEqual(col, 4)
        
        // Move right
        offset = Direction.right.offset
        row += offset.row
        col += offset.col
        XCTAssertEqual(row, 3)
        XCTAssertEqual(col, 5)
        
        // Move down
        offset = Direction.down.offset
        row += offset.row
        col += offset.col
        XCTAssertEqual(row, 4)
        XCTAssertEqual(col, 5)
        
        // Move left
        offset = Direction.left.offset
        row += offset.row
        col += offset.col
        XCTAssertEqual(row, 4)
        XCTAssertEqual(col, 4)
    }
}
