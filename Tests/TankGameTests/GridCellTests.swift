//
//  GridCellTests.swift
//  TankGameCoreTests
//
//  Tests for the GridCell enum
//

import XCTest
@testable import TankGameCore

final class GridCellTests: XCTestCase {
    
    // MARK: - Raw Value Tests
    
    func testEmptyRawValue() {
        XCTAssertEqual(GridCell.empty.rawValue, 0)
    }
    
    func testWallRawValue() {
        XCTAssertEqual(GridCell.wall.rawValue, 1)
    }
    
    // MARK: - Creation from Raw Value Tests
    
    func testCreateEmptyFromRawValue() {
        let cell = GridCell(rawValue: 0)
        XCTAssertEqual(cell, .empty)
    }
    
    func testCreateWallFromRawValue() {
        let cell = GridCell(rawValue: 1)
        XCTAssertEqual(cell, .wall)
    }
    
    func testInvalidRawValue() {
        let cell = GridCell(rawValue: 99)
        XCTAssertNil(cell)
    }
    
    // MARK: - Codable Tests
    
    func testEncodeDecodeEmpty() throws {
        let cell = GridCell.empty
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(cell)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(GridCell.self, from: data)
        
        XCTAssertEqual(cell, decoded)
    }
    
    func testEncodeDecodeWall() throws {
        let cell = GridCell.wall
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(cell)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(GridCell.self, from: data)
        
        XCTAssertEqual(cell, decoded)
    }
    
    // MARK: - Equality Tests
    
    func testEmptyEquality() {
        XCTAssertEqual(GridCell.empty, GridCell.empty)
    }
    
    func testWallEquality() {
        XCTAssertEqual(GridCell.wall, GridCell.wall)
    }
    
    func testInequality() {
        XCTAssertNotEqual(GridCell.empty, GridCell.wall)
    }
}
