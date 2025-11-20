//
//  GridGeneratorTests.swift
//  tankgame Tests
//
//  Unit tests for GridGenerator
//

import XCTest
@testable import tankgame_iOS

final class GridGeneratorTests: XCTestCase {
    
    // MARK: - Grid Structure Tests
    
    func testGridSize() {
        let grid = GridGenerator.generate(seed: 12345)
        
        XCTAssertEqual(grid.count, 8, "Grid should have 8 rows")
        for row in grid {
            XCTAssertEqual(row.count, 8, "Each row should have 8 columns")
        }
    }
    
    func testGridOnlyContainsValidCells() {
        let grid = GridGenerator.generate(seed: 12345)
        
        for row in grid {
            for cell in row {
                XCTAssertTrue(cell == .empty || cell == .wall, "Grid should only contain empty or wall cells")
            }
        }
    }
    
    // MARK: - Deterministic Generation Tests
    
    func testSameSeedProducesSameGrid() {
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
    
    func testDifferentSeedsProduceDifferentGrids() {
        let grid1 = GridGenerator.generate(seed: 1)
        let grid2 = GridGenerator.generate(seed: 2)
        
        var hasAtLeastOneDifference = false
        for row in 0..<grid1.count {
            for col in 0..<grid1[row].count {
                if grid1[row][col] != grid2[row][col] {
                    hasAtLeastOneDifference = true
                    break
                }
            }
            if hasAtLeastOneDifference { break }
        }
        
        XCTAssertTrue(hasAtLeastOneDifference, "Different seeds should produce different grids")
    }
    
    // MARK: - Spawn Area Protection Tests
    
    func testTopLeftSpawnAreaIsClear() {
        // Test with multiple seeds to ensure protection is consistent
        for seed in [UInt32(1), 10, 100, 1000, 9999] {
            let grid = GridGenerator.generate(seed: seed)
            
            // Top-left 2x2 area should be clear
            XCTAssertEqual(grid[0][0], .empty, "Spawn position (0,0) should be empty for seed \(seed)")
            XCTAssertEqual(grid[0][1], .empty, "Position (0,1) should be empty for seed \(seed)")
            XCTAssertEqual(grid[1][0], .empty, "Position (1,0) should be empty for seed \(seed)")
            XCTAssertEqual(grid[1][1], .empty, "Position (1,1) should be empty for seed \(seed)")
        }
    }
    
    func testBottomRightSpawnAreaIsClear() {
        // Test with multiple seeds to ensure protection is consistent
        for seed in [UInt32(1), 10, 100, 1000, 9999] {
            let grid = GridGenerator.generate(seed: seed)
            
            // Bottom-right 2x2 area should be clear
            XCTAssertEqual(grid[6][6], .empty, "Position (6,6) should be empty for seed \(seed)")
            XCTAssertEqual(grid[6][7], .empty, "Position (6,7) should be empty for seed \(seed)")
            XCTAssertEqual(grid[7][6], .empty, "Position (7,6) should be empty for seed \(seed)")
            XCTAssertEqual(grid[7][7], .empty, "Spawn position (7,7) should be empty for seed \(seed)")
        }
    }
    
    func testBorderPathsAreClear() {
        // Test with multiple seeds to ensure borders are always clear
        for seed in [UInt32(1), 10, 100, 1000, 9999] {
            let grid = GridGenerator.generate(seed: seed)
            
            // Test top row (row 0)
            for col in 0..<8 {
                XCTAssertEqual(grid[0][col], .empty, "Top border at (0,\(col)) should be empty for seed \(seed)")
            }
            
            // Test bottom row (row 7)
            for col in 0..<8 {
                XCTAssertEqual(grid[7][col], .empty, "Bottom border at (7,\(col)) should be empty for seed \(seed)")
            }
            
            // Test left column (col 0)
            for row in 0..<8 {
                XCTAssertEqual(grid[row][0], .empty, "Left border at (\(row),0) should be empty for seed \(seed)")
            }
            
            // Test right column (col 7)
            for row in 0..<8 {
                XCTAssertEqual(grid[row][7], .empty, "Right border at (\(row),7) should be empty for seed \(seed)")
            }
        }
    }
    
    // MARK: - Wall Density Tests
    
    func testWallDensityIsWithinExpectedRange() {
        // Test multiple seeds
        for seed in [UInt32(1), 10, 100, 1000, 9999, 12345, 54321] {
            let grid = GridGenerator.generate(seed: seed)
            
            var wallCount = 0
            var interiorCellCount = 0
            
            // Count walls only in interior (non-border, non-protected cells)
            for row in 0..<8 {
                for col in 0..<8 {
                    // Skip border cells
                    if row == 0 || row == 7 || col == 0 || col == 7 {
                        continue
                    }
                    
                    // Skip protected spawn areas
                    if (row <= 1 && col <= 1) || (row >= 6 && col >= 6) {
                        continue
                    }
                    
                    interiorCellCount += 1
                    if grid[row][col] == .wall {
                        wallCount += 1
                    }
                }
            }
            
            let density = Double(wallCount) / Double(interiorCellCount)
            
            // Wall density should be between 15% and 30%
            XCTAssertGreaterThanOrEqual(density, 0.15, "Wall density should be at least 15% for seed \(seed)")
            XCTAssertLessThanOrEqual(density, 0.30, "Wall density should be at most 30% for seed \(seed)")
        }
    }
    
    func testGridHasSomeWalls() {
        // Test that grids actually have walls (not all empty)
        for seed in [UInt32(1), 10, 100, 1000, 9999] {
            let grid = GridGenerator.generate(seed: seed)
            
            var hasWalls = false
            for row in grid {
                for cell in row {
                    if cell == .wall {
                        hasWalls = true
                        break
                    }
                }
                if hasWalls { break }
            }
            
            XCTAssertTrue(hasWalls, "Grid should contain at least some walls for seed \(seed)")
        }
    }
    
    // MARK: - Edge Cases
    
    func testSeedZero() {
        let grid = GridGenerator.generate(seed: 0)
        
        XCTAssertEqual(grid.count, 8)
        XCTAssertEqual(grid[0][0], .empty, "Spawn areas should be protected even with seed 0")
        XCTAssertEqual(grid[7][7], .empty, "Spawn areas should be protected even with seed 0")
    }
    
    func testMaxSeed() {
        let grid = GridGenerator.generate(seed: UInt32.max)
        
        XCTAssertEqual(grid.count, 8)
        XCTAssertEqual(grid[0][0], .empty, "Spawn areas should be protected even with max seed")
        XCTAssertEqual(grid[7][7], .empty, "Spawn areas should be protected even with max seed")
    }
}

// MARK: - SeededRandomNumberGenerator Tests

final class SeededRandomNumberGeneratorTests: XCTestCase {
    
    func testDeterministicGeneration() {
        var rng1 = SeededRandomNumberGenerator(seed: 42)
        var rng2 = SeededRandomNumberGenerator(seed: 42)
        
        // Generate 10 numbers and verify they're identical
        for _ in 0..<10 {
            XCTAssertEqual(rng1.next(), rng2.next(), "Same seed should produce same sequence")
        }
    }
    
    func testDifferentSeedsProduceDifferentSequences() {
        var rng1 = SeededRandomNumberGenerator(seed: 1)
        var rng2 = SeededRandomNumberGenerator(seed: 2)
        
        let value1 = rng1.next()
        let value2 = rng2.next()
        
        XCTAssertNotEqual(value1, value2, "Different seeds should produce different values")
    }
    
    func testNextDoubleRange() {
        var rng = SeededRandomNumberGenerator(seed: 12345)
        
        // Test 100 values to ensure they're all in [0, 1] range
        for _ in 0..<100 {
            let value = rng.nextDouble()
            XCTAssertGreaterThanOrEqual(value, 0.0, "Random double should be >= 0")
            XCTAssertLessThanOrEqual(value, 1.0, "Random double should be <= 1")
        }
    }
    
    func testNextDoubleDistribution() {
        var rng = SeededRandomNumberGenerator(seed: 54321)
        
        var valuesBelow05 = 0
        var valuesAbove05 = 0
        
        // Generate many values and verify rough distribution
        for _ in 0..<1000 {
            let value = rng.nextDouble()
            if value < 0.5 {
                valuesBelow05 += 1
            } else {
                valuesAbove05 += 1
            }
        }
        
        // With 1000 samples, we expect roughly 500/500 split
        // Allow for reasonable variance (e.g., 350-650 range)
        XCTAssertGreaterThan(valuesBelow05, 350, "Should have reasonable distribution below 0.5")
        XCTAssertGreaterThan(valuesAbove05, 350, "Should have reasonable distribution above 0.5")
    }
}
