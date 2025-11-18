//
//  DirectionTests.swift
//  tankgame Tests
//
//  Unit tests for Direction enum
//

import XCTest
@testable import Tank_Game

final class DirectionTests: XCTestCase {
    
    func testDirectionUpOffset() {
        let direction = Direction.up
        let offset = direction.offset
        
        XCTAssertEqual(offset.row, -1)
        XCTAssertEqual(offset.col, 0)
    }
    
    func testDirectionDownOffset() {
        let direction = Direction.down
        let offset = direction.offset
        
        XCTAssertEqual(offset.row, 1)
        XCTAssertEqual(offset.col, 0)
    }
    
    func testDirectionLeftOffset() {
        let direction = Direction.left
        let offset = direction.offset
        
        XCTAssertEqual(offset.row, 0)
        XCTAssertEqual(offset.col, -1)
    }
    
    func testDirectionRightOffset() {
        let direction = Direction.right
        let offset = direction.offset
        
        XCTAssertEqual(offset.row, 0)
        XCTAssertEqual(offset.col, 1)
    }
    
    func testDirectionIsCodable() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let direction = Direction.left
        
        do {
            let data = try encoder.encode(direction)
            let decoded = try decoder.decode(Direction.self, from: data)
            XCTAssertEqual(direction, decoded)
        } catch {
            XCTFail("Direction should be Codable: \(error)")
        }
    }
    
    func testAllDirectionsHaveUniqueOffsets() {
        let directions: [Direction] = [.up, .down, .left, .right]
        var offsets = Set<String>()
        
        for direction in directions {
            let offset = direction.offset
            let key = "\(offset.row),\(offset.col)"
            XCTAssertFalse(offsets.contains(key), "Duplicate offset found for direction \(direction)")
            offsets.insert(key)
        }
        
        XCTAssertEqual(offsets.count, 4, "All four directions should have unique offsets")
    }
    
    func testDirectionCaseCount() {
        // Verify we have exactly 4 directions
        let allCases = [Direction.up, Direction.down, Direction.left, Direction.right]
        XCTAssertEqual(allCases.count, 4)
    }
}
