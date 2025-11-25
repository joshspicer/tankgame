//
//  GridGeneratorTests.swift
//  TankGameCoreTests
//
//  Tests for the GridGenerator and SeededRandomNumberGenerator
//

import XCTest
@testable import TankGameCore

final class GridGeneratorTests: XCTestCase {
    
    // MARK: - Grid Size Tests
    
    func testGridSize() {
        let grid = GridGenerator.generate(seed: 12345)
        
        XCTAssertEqual(grid.count, 8)
        for row in grid {
            XCTAssertEqual(row.count, 8)
        }
    }
    
    // MARK: - Determinism Tests
    
    func testSameSeedProducesSameGrid() {
        let seed: UInt32 = 42
        let grid1 = GridGenerator.generate(seed: seed)
        let grid2 = GridGenerator.generate(seed: seed)
        
        for row in 0..<8 {
            for col in 0..<8 {
                XCTAssertEqual(grid1[row][col], grid2[row][col],
                    "Grid cells differ at [\(row)][\(col)]")
            }
        }
    }
    
    func testDifferentSeedsProduceDifferentGrids() {
        let grid1 = GridGenerator.generate(seed: 12345)
        let grid2 = GridGenerator.generate(seed: 54321)
        
        // Grids should differ somewhere (though technically could be same by chance)
        var foundDifference = false
        for row in 0..<8 {
            for col in 0..<8 {
                if grid1[row][col] != grid2[row][col] {
                    foundDifference = true
                    break
                }
            }
            if foundDifference { break }
        }
        
        XCTAssertTrue(foundDifference, "Different seeds should produce different grids")
    }
    
    // MARK: - Protected Areas Tests
    
    func testTopLeftSpawnAreaIsClear() {
        let grid = GridGenerator.generate(seed: 12345)
        
        // Top-left spawn area: (0,0), (0,1), (1,0), (1,1)
        XCTAssertEqual(grid[0][0], .empty, "Top-left spawn area should be clear")
        XCTAssertEqual(grid[0][1], .empty, "Top-left spawn area should be clear")
        XCTAssertEqual(grid[1][0], .empty, "Top-left spawn area should be clear")
        XCTAssertEqual(grid[1][1], .empty, "Top-left spawn area should be clear")
    }
    
    func testBottomRightSpawnAreaIsClear() {
        let grid = GridGenerator.generate(seed: 12345)
        
        // Bottom-right spawn area: (6,6), (6,7), (7,6), (7,7)
        XCTAssertEqual(grid[6][6], .empty, "Bottom-right spawn area should be clear")
        XCTAssertEqual(grid[6][7], .empty, "Bottom-right spawn area should be clear")
        XCTAssertEqual(grid[7][6], .empty, "Bottom-right spawn area should be clear")
        XCTAssertEqual(grid[7][7], .empty, "Bottom-right spawn area should be clear")
    }
    
    func testTopBorderIsClear() {
        let grid = GridGenerator.generate(seed: 99999)
        
        for col in 0..<8 {
            XCTAssertEqual(grid[0][col], .empty, "Top border at col \(col) should be clear")
        }
    }
    
    func testBottomBorderIsClear() {
        let grid = GridGenerator.generate(seed: 99999)
        
        for col in 0..<8 {
            XCTAssertEqual(grid[7][col], .empty, "Bottom border at col \(col) should be clear")
        }
    }
    
    func testLeftBorderIsClear() {
        let grid = GridGenerator.generate(seed: 99999)
        
        for row in 0..<8 {
            XCTAssertEqual(grid[row][0], .empty, "Left border at row \(row) should be clear")
        }
    }
    
    func testRightBorderIsClear() {
        let grid = GridGenerator.generate(seed: 99999)
        
        for row in 0..<8 {
            XCTAssertEqual(grid[row][7], .empty, "Right border at row \(row) should be clear")
        }
    }
    
    // MARK: - Wall Generation Tests
    
    func testGridContainsSomeWalls() {
        // Test multiple seeds to ensure walls are generated
        var foundWall = false
        for seed in [1, 100, 1000, 10000, 100000] as [UInt32] {
            let grid = GridGenerator.generate(seed: seed)
            
            // Check interior cells for walls
            for row in 1..<7 {
                for col in 1..<7 {
                    if grid[row][col] == .wall {
                        foundWall = true
                        break
                    }
                }
                if foundWall { break }
            }
            if foundWall { break }
        }
        
        XCTAssertTrue(foundWall, "Grid should contain some walls")
    }
    
    // MARK: - Seeded RNG Tests
    
    func testSeededRNGDeterminism() {
        var rng1 = SeededRandomNumberGenerator(seed: 42)
        var rng2 = SeededRandomNumberGenerator(seed: 42)
        
        for _ in 0..<100 {
            XCTAssertEqual(rng1.next(), rng2.next())
        }
    }
    
    func testSeededRNGNextDouble() {
        var rng = SeededRandomNumberGenerator(seed: 12345)
        
        for _ in 0..<100 {
            let value = rng.nextDouble()
            XCTAssertGreaterThanOrEqual(value, 0.0)
            XCTAssertLessThanOrEqual(value, 1.0)
        }
    }
    
    func testSeededRNGProducesVariedValues() {
        var rng = SeededRandomNumberGenerator(seed: 999)
        var values = Set<UInt64>()
        
        for _ in 0..<100 {
            values.insert(rng.next())
        }
        
        // Should have many unique values (not all same)
        XCTAssertGreaterThan(values.count, 90, "RNG should produce varied values")
    }
}
