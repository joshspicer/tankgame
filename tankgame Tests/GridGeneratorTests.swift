//
//  GridGeneratorTests.swift
//  tankgame Tests
//
//  Unit tests for GridGenerator
//

import XCTest
@testable import Tank_Game

final class GridGeneratorTests: XCTestCase {
    
    func testGridGeneratorCreates8x8Grid() {
        let grid = GridGenerator.generate(seed: 12345)
        
        XCTAssertEqual(grid.count, 8, "Grid should have 8 rows")
        XCTAssertEqual(grid[0].count, 8, "Grid should have 8 columns")
        
        // Verify all rows have 8 columns
        for row in grid {
            XCTAssertEqual(row.count, 8)
        }
    }
    
    func testGridGeneratorSameSeedProducesSameGrid() {
        let seed: UInt32 = 42
        
        let grid1 = GridGenerator.generate(seed: seed)
        let grid2 = GridGenerator.generate(seed: seed)
        
        XCTAssertEqual(grid1.count, grid2.count)
        
        for row in 0..<grid1.count {
            for col in 0..<grid1[row].count {
                XCTAssertEqual(grid1[row][col], grid2[row][col],
                             "Same seed should produce identical grids at [\(row)][\(col)]")
            }
        }
    }
    
    func testGridGeneratorDifferentSeedsProduceDifferentGrids() {
        let grid1 = GridGenerator.generate(seed: 111)
        let grid2 = GridGenerator.generate(seed: 222)
        
        // Check if grids are different
        var hasDifference = false
        for row in 0..<grid1.count {
            for col in 0..<grid1[row].count {
                if grid1[row][col] != grid2[row][col] {
                    hasDifference = true
                    break
                }
            }
            if hasDifference { break }
        }
        
        XCTAssertTrue(hasDifference, "Different seeds should produce different grids")
    }
    
    func testGridGeneratorHasEmptyAndWallCells() {
        let grid = GridGenerator.generate(seed: 12345)
        
        var hasEmpty = false
        var hasWall = false
        
        for row in grid {
            for cell in row {
                if cell == .empty { hasEmpty = true }
                if cell == .wall { hasWall = true }
            }
        }
        
        XCTAssertTrue(hasEmpty, "Grid should contain empty cells")
        XCTAssertTrue(hasWall, "Grid should contain wall cells")
    }
    
    func testGridGeneratorKeepsCornersEmpty() {
        let grid = GridGenerator.generate(seed: 12345)
        
        // Check all four corners are empty (spawn positions)
        XCTAssertEqual(grid[0][0], .empty, "Top-left corner should be empty")
        XCTAssertEqual(grid[0][7], .empty, "Top-right corner should be empty")
        XCTAssertEqual(grid[7][0], .empty, "Bottom-left corner should be empty")
        XCTAssertEqual(grid[7][7], .empty, "Bottom-right corner should be empty")
    }
    
    func testGridGeneratorKeepsBordersClear() {
        let grid = GridGenerator.generate(seed: 12345)
        
        // Check entire borders are empty
        for col in 0..<8 {
            XCTAssertEqual(grid[0][col], .empty, "Top border at column \(col) should be empty")
            XCTAssertEqual(grid[7][col], .empty, "Bottom border at column \(col) should be empty")
        }
        
        for row in 0..<8 {
            XCTAssertEqual(grid[row][0], .empty, "Left border at row \(row) should be empty")
            XCTAssertEqual(grid[row][7], .empty, "Right border at row \(row) should be empty")
        }
    }
    
    func testGridGeneratorProtectsSpawnAreas() {
        let grid = GridGenerator.generate(seed: 12345)
        
        // Top-left spawn area (2x2)
        for row in 0..<2 {
            for col in 0..<2 {
                XCTAssertEqual(grid[row][col], .empty, "Top-left spawn area [\(row)][\(col)] should be empty")
            }
        }
        
        // Bottom-right spawn area (2x2)
        for row in 6..<8 {
            for col in 6..<8 {
                XCTAssertEqual(grid[row][col], .empty, "Bottom-right spawn area [\(row)][\(col)] should be empty")
            }
        }
    }
    
    func testGridGeneratorAllCellsAreValidTypes() {
        let grid = GridGenerator.generate(seed: 99999)
        
        for row in 0..<grid.count {
            for col in 0..<grid[row].count {
                let cell = grid[row][col]
                XCTAssertTrue(cell == .empty || cell == .wall,
                            "Cell at [\(row)][\(col)] should be either empty or wall")
            }
        }
    }
    
    func testGridGeneratorIsReproducible() {
        let seed: UInt32 = 777
        let grids = (0..<10).map { _ in GridGenerator.generate(seed: seed) }
        
        // All grids should be identical
        for i in 1..<grids.count {
            for row in 0..<grids[0].count {
                for col in 0..<grids[0][row].count {
                    XCTAssertEqual(grids[0][row][col], grids[i][row][col],
                                 "Grid generation should be reproducible")
                }
            }
        }
    }
    
    func testGridGeneratorVariousSeeds() {
        // Test that generator works with various seed values
        let seeds: [UInt32] = [0, 1, 100, 1000, 10000, UInt32.max]
        
        for seed in seeds {
            let grid = GridGenerator.generate(seed: seed)
            XCTAssertEqual(grid.count, 8, "Grid should be 8x8 for seed \(seed)")
            XCTAssertEqual(grid[0].count, 8, "Grid should be 8x8 for seed \(seed)")
        }
    }
}
