//
//  GridCellTests.swift
//  TankGameCoreTests
//
//  Unit tests for GridCell enum
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
    
    // MARK: - Initialization from Raw Value Tests
    
    func testInitFromRawValueEmpty() {
        let cell = GridCell(rawValue: 0)
        XCTAssertEqual(cell, .empty)
    }
    
    func testInitFromRawValueWall() {
        let cell = GridCell(rawValue: 1)
        XCTAssertEqual(cell, .wall)
    }
    
    func testInitFromInvalidRawValue() {
        let cell = GridCell(rawValue: 2)
        XCTAssertNil(cell)
    }
    
    // MARK: - Codable Tests
    
    func testCodableEmpty() throws {
        let cell = GridCell.empty
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(cell)
        let decoded = try decoder.decode(GridCell.self, from: data)
        
        XCTAssertEqual(cell, decoded)
    }
    
    func testCodableWall() throws {
        let cell = GridCell.wall
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(cell)
        let decoded = try decoder.decode(GridCell.self, from: data)
        
        XCTAssertEqual(cell, decoded)
    }
    
    // MARK: - Grid Creation Tests
    
    func testEmptyGridCreation() {
        let size = 8
        let grid = Array(repeating: Array(repeating: GridCell.empty, count: size), count: size)
        
        XCTAssertEqual(grid.count, size)
        XCTAssertEqual(grid[0].count, size)
        
        for row in grid {
            for cell in row {
                XCTAssertEqual(cell, .empty)
            }
        }
    }
    
    func testMixedGridCreation() {
        var grid = Array(repeating: Array(repeating: GridCell.empty, count: 3), count: 3)
        grid[1][1] = .wall
        
        XCTAssertEqual(grid[0][0], .empty)
        XCTAssertEqual(grid[1][1], .wall)
        XCTAssertEqual(grid[2][2], .empty)
    }
}
