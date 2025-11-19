//
//  GridGeneratorTests.swift
//  tankgame Tests
//
//  Unit tests for GridGenerator
//

import XCTest
@testable import tankgame_iOS

final class GridGeneratorTests: XCTestCase {
    
    // MARK: - Grid Generation Tests
    
    func testGenerateCreatesCorrectSize() {
        let grid = GridGenerator.generate(seed: 12345)
        
        XCTAssertEqual(grid.count, 8, "Grid should have 8 rows")
        XCTAssertEqual(grid[0].count, 8, "Grid should have 8 columns")
    }
    
    func testGenerateAllRowsSameLength() {
        let grid = GridGenerator.generate(seed: 12345)
        
        let firstRowLength = grid[0].count
        for row in grid {
            XCTAssertEqual(row.count, firstRowLength, "All rows should have same length")
        }
    }
    
    func testGenerateSameSeedProducesSameGrid() {
        let seed: UInt32 = 42
        let grid1 = GridGenerator.generate(seed: seed)
        let grid2 = GridGenerator.generate(seed: seed)
        
        XCTAssertEqual(grid1.count, grid2.count)
        for i in 0..<grid1.count {
            for j in 0..<grid1[i].count {
                XCTAssertEqual(grid1[i][j], grid2[i][j], "Grids with same seed should be identical at [\(i)][\(j)]")
            }
        }
    }
    
    func testGenerateDifferentSeedsProduceDifferentGrids() {
        let grid1 = GridGenerator.generate(seed: 12345)
        let grid2 = GridGenerator.generate(seed: 67890)
        
        var hasDifference = false
        for i in 0..<grid1.count {
            for j in 0..<grid1[i].count {
                if grid1[i][j] != grid2[i][j] {
                    hasDifference = true
                    break
                }
            }
            if hasDifference { break }
        }
        
        XCTAssertTrue(hasDifference, "Different seeds should produce different grids")
    }
    
    func testGenerateSpawnPositionsAreEmpty() {
        let grid = GridGenerator.generate(seed: 12345)
        
        // Test all four spawn positions
        let spawnPositions = [
            (0, 0),  // Top-left
            (7, 7),  // Bottom-right
            (0, 7),  // Top-right
            (7, 0)   // Bottom-left
        ]
        
        for (row, col) in spawnPositions {
            XCTAssertEqual(grid[row][col], .empty, "Spawn position [\(row)][\(col)] should be empty")
        }
    }
    
    func testGenerateContainsBothEmptyAndWallCells() {
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
    
    func testGenerateWallPercentageInReasonableRange() {
        let grid = GridGenerator.generate(seed: 12345)
        
        var wallCount = 0
        var totalCells = 0
        
        for row in grid {
            for cell in row {
                totalCells += 1
                if cell == .wall {
                    wallCount += 1
                }
            }
        }
        
        let wallPercentage = Double(wallCount) / Double(totalCells)
        
        // Check that walls are between 10% and 50% of the grid
        XCTAssertGreaterThan(wallPercentage, 0.1, "Grid should have at least 10% walls")
        XCTAssertLessThan(wallPercentage, 0.5, "Grid should have no more than 50% walls")
    }
    
    // MARK: - Edge Cases
    
    func testGenerateWithZeroSeed() {
        let grid = GridGenerator.generate(seed: 0)
        
        XCTAssertEqual(grid.count, 8)
        XCTAssertEqual(grid[0].count, 8)
    }
    
    func testGenerateWithMaxSeed() {
        let grid = GridGenerator.generate(seed: UInt32.max)
        
        XCTAssertEqual(grid.count, 8)
        XCTAssertEqual(grid[0].count, 8)
    }
    
    func testGenerateIsReproducible() {
        let seed: UInt32 = 99999
        
        // Generate same grid multiple times
        let grids = (0..<5).map { _ in GridGenerator.generate(seed: seed) }
        
        // All grids should be identical
        for i in 1..<grids.count {
            for row in 0..<grids[0].count {
                for col in 0..<grids[0][row].count {
                    XCTAssertEqual(grids[i][row][col], grids[0][row][col],
                                   "Grid \(i) differs from grid 0 at [\(row)][\(col)]")
                }
            }
        }
    }
}
