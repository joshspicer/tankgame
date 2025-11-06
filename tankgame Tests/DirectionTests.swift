//
//  DirectionTests.swift
//  tankgame Tests
//
//  Unit tests for Direction enum
//

import XCTest
@testable import tankgame

class DirectionTests: XCTestCase {
    
    func testDirectionAngles() {
        XCTAssertEqual(Direction.up.angle, 0, accuracy: 0.001)
        XCTAssertEqual(Direction.right.angle, .pi / 2, accuracy: 0.001)
        XCTAssertEqual(Direction.down.angle, .pi, accuracy: 0.001)
        XCTAssertEqual(Direction.left.angle, -.pi / 2, accuracy: 0.001)
    }
    
    func testDirectionOffsets() {
        XCTAssertEqual(Direction.up.offset.row, -1)
        XCTAssertEqual(Direction.up.offset.col, 0)
        
        XCTAssertEqual(Direction.down.offset.row, 1)
        XCTAssertEqual(Direction.down.offset.col, 0)
        
        XCTAssertEqual(Direction.left.offset.row, 0)
        XCTAssertEqual(Direction.left.offset.col, -1)
        
        XCTAssertEqual(Direction.right.offset.row, 0)
        XCTAssertEqual(Direction.right.offset.col, 1)
    }
    
    func testDirectionCaseIterable() {
        let allDirections = Direction.allCases
        XCTAssertEqual(allDirections.count, 4)
        XCTAssertTrue(allDirections.contains(.up))
        XCTAssertTrue(allDirections.contains(.down))
        XCTAssertTrue(allDirections.contains(.left))
        XCTAssertTrue(allDirections.contains(.right))
    }
    
    func testDirectionCodable() throws {
        let direction = Direction.up
        let encoder = JSONEncoder()
        let data = try encoder.encode(direction)
        
        let decoder = JSONDecoder()
        let decodedDirection = try decoder.decode(Direction.self, from: data)
        
        XCTAssertEqual(direction, decodedDirection)
    }
}
