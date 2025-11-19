//
//  DirectionTests.swift
//  tankgame Tests
//
//  Unit tests for Direction enum
//

import XCTest
@testable import tankgame_iOS

final class DirectionTests: XCTestCase {
    
    // MARK: - Offset Tests
    
    func testUpOffset() {
        let direction = Direction.up
        let offset = direction.offset
        
        XCTAssertEqual(offset.row, -1)
        XCTAssertEqual(offset.col, 0)
    }
    
    func testDownOffset() {
        let direction = Direction.down
        let offset = direction.offset
        
        XCTAssertEqual(offset.row, 1)
        XCTAssertEqual(offset.col, 0)
    }
    
    func testLeftOffset() {
        let direction = Direction.left
        let offset = direction.offset
        
        XCTAssertEqual(offset.row, 0)
        XCTAssertEqual(offset.col, -1)
    }
    
    func testRightOffset() {
        let direction = Direction.right
        let offset = direction.offset
        
        XCTAssertEqual(offset.row, 0)
        XCTAssertEqual(offset.col, 1)
    }
    
    // MARK: - Opposite Tests
    
    func testOppositeOfUp() {
        XCTAssertEqual(Direction.up.opposite, .down)
    }
    
    func testOppositeOfDown() {
        XCTAssertEqual(Direction.down.opposite, .up)
    }
    
    func testOppositeOfLeft() {
        XCTAssertEqual(Direction.left.opposite, .right)
    }
    
    func testOppositeOfRight() {
        XCTAssertEqual(Direction.right.opposite, .left)
    }
    
    func testDoubleOppositeIsOriginal() {
        let directions: [Direction] = [.up, .down, .left, .right]
        
        for direction in directions {
            XCTAssertEqual(direction.opposite.opposite, direction)
        }
    }
    
    // MARK: - Codable Tests
    
    func testDirectionEncodingDecoding() throws {
        let directions: [Direction] = [.up, .down, .left, .right]
        
        for direction in directions {
            let encoder = JSONEncoder()
            let data = try encoder.encode(direction)
            
            let decoder = JSONDecoder()
            let decodedDirection = try decoder.decode(Direction.self, from: data)
            
            XCTAssertEqual(decodedDirection, direction, "Failed for direction \(direction)")
        }
    }
    
    // MARK: - All Cases Tests
    
    func testAllCasesCount() {
        XCTAssertEqual(Direction.allCases.count, 4)
    }
    
    func testAllCasesContainsAllDirections() {
        XCTAssertTrue(Direction.allCases.contains(.up))
        XCTAssertTrue(Direction.allCases.contains(.down))
        XCTAssertTrue(Direction.allCases.contains(.left))
        XCTAssertTrue(Direction.allCases.contains(.right))
    }
}
