//
//  GridCellTests.swift
//  tankgame Tests
//
//  Unit tests for GridCell enum
//

import XCTest
@testable import tankgame

class GridCellTests: XCTestCase {
    
    func testGridCellEmpty() {
        let cell = GridCell.empty
        XCTAssertEqual(cell.rawValue, 0)
    }
    
    func testGridCellWall() {
        let cell = GridCell.wall
        XCTAssertEqual(cell.rawValue, 1)
    }
    
    func testGridCellEquality() {
        XCTAssertEqual(GridCell.empty, GridCell.empty)
        XCTAssertEqual(GridCell.wall, GridCell.wall)
        XCTAssertNotEqual(GridCell.empty, GridCell.wall)
    }
    
    func testGridCellCodable() throws {
        let cell = GridCell.wall
        let encoder = JSONEncoder()
        let data = try encoder.encode(cell)
        
        let decoder = JSONDecoder()
        let decodedCell = try decoder.decode(GridCell.self, from: data)
        
        XCTAssertEqual(cell, decodedCell)
    }
    
    func testGridCellInitFromRawValue() {
        XCTAssertEqual(GridCell(rawValue: 0), .empty)
        XCTAssertEqual(GridCell(rawValue: 1), .wall)
        XCTAssertNil(GridCell(rawValue: 2))
    }
}
