//
//  GridGeneratorTests.swift
//  tankgame Tests
//
//  Unit tests for GridGenerator
//

import XCTest
@testable import tankgame

final class GridGeneratorTests: XCTestCase {
    
    // MARK: - Basic Generation Tests
    
    func testGenerateCreatesCorrectSize() {
        let grid = GridGenerator.generate(seed: 12345)
        
        XCTAssertEqual(grid.count, GameConfiguration.gridSize, "Grid should have correct number of rows")
        for row in grid {
            XCTAssertEqual(row.count, GameConfiguration.gridSize, "Each row should have correct number of columns")
        }
    }
    
    func testGenerateWithSameSeedProducesSameGrid() {
        let grid1 = GridGenerator.generate(seed: 12345)
        let grid2 = GridGenerator.generate(seed: 12345)
        
        for row in 0..<GameConfiguration.gridSize {
            for col in 0..<GameConfiguration.gridSize {
                XCTAssertEqual(
                    grid1[row][col], 
                    grid2[row][col],
                    "Same seed should produce identical grid at (\(row),\(col))"
                )
            }
        }
    }
    
    func testGenerateWithDifferentSeedProducesDifferentGrid() {
        let grid1 = GridGenerator.generate(seed: 12345)
        let grid2 = GridGenerator.generate(seed: 54321)
        
        var hasDifference = false
        for row in 0..<GameConfiguration.gridSize {
            for col in 0..<GameConfiguration.gridSize {
                if grid1[row][col] != grid2[row][col] {
                    hasDifference = true
                    break
                }
            }
            if hasDifference { break }
        }
        
        XCTAssertTrue(hasDifference, "Different seeds should produce different grids")
    }
    
    // MARK: - Spawn Protection Tests
    
    func testAllSpawnPositionsAreClear() {
        let grid = GridGenerator.generate(seed: 99999)
        
        // Test all 4 spawn positions
        for i in 0..<4 {
            let spawn = GameConfiguration.spawnPositions[i]
            XCTAssertEqual(
                grid[spawn.row][spawn.col],
                .empty,
                "Spawn position for player \(i) at (\(spawn.row),\(spawn.col)) should be empty"
            )
        }
    }
    
    func testProtectedSpawnAreasAreClear() {
        let grid = GridGenerator.generate(seed: 77777)
        
        // Check all protected cells are empty
        for cellKey in GameConfiguration.protectedSpawnCells {
            let parts = cellKey.split(separator: ",")
            let row = Int(parts[0])!
            let col = Int(parts[1])!
            
            XCTAssertEqual(
                grid[row][col],
                .empty,
                "Protected cell at (\(row),\(col)) should be empty"
            )
        }
    }
    
    func testBorderPathsAreClear() {
        let grid = GridGenerator.generate(seed: 88888)
        let borderCells = GameConfiguration.borderCells()
        
        for cellKey in borderCells {
            let parts = cellKey.split(separator: ",")
            let row = Int(parts[0])!
            let col = Int(parts[1])!
            
            XCTAssertEqual(
                grid[row][col],
                .empty,
                "Border cell at (\(row),\(col)) should be empty"
            )
        }
    }
    
    // MARK: - Wall Density Tests
    
    func testWallDensityIsReasonable() {
        let grid = GridGenerator.generate(seed: 33333)
        
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
        
        let density = Double(wallCount) / Double(totalCells)
        
        XCTAssertGreaterThanOrEqual(
            density, 
            0.0, 
            "Wall density should be non-negative"
        )
        XCTAssertLessThanOrEqual(
            density, 
            GameConfiguration.maxWallDensity, 
            "Wall density should not exceed maximum"
        )
    }
    
    func testGridHasSomeWalls() {
        // Test multiple seeds to ensure walls are generated
        var hasWalls = false
        
        for seed in [111, 222, 333, 444, 555] {
            let grid = GridGenerator.generate(seed: UInt32(seed))
            
            for row in grid {
                for cell in row {
                    if cell == .wall {
                        hasWalls = true
                        break
                    }
                }
                if hasWalls { break }
            }
            
            if hasWalls { break }
        }
        
        XCTAssertTrue(hasWalls, "Generator should create some walls across different seeds")
    }
    
    // MARK: - Seeded RNG Tests
    
    func testSeededRNGProducesSameSequence() {
        var rng1 = SeededRandomNumberGenerator(seed: 12345)
        var rng2 = SeededRandomNumberGenerator(seed: 12345)
        
        for _ in 0..<10 {
            XCTAssertEqual(rng1.next(), rng2.next(), "Same seed should produce same sequence")
        }
    }
    
    func testSeededRNGProducesDifferentSequences() {
        var rng1 = SeededRandomNumberGenerator(seed: 12345)
        var rng2 = SeededRandomNumberGenerator(seed: 54321)
        
        var hasDifference = false
        for _ in 0..<10 {
            if rng1.next() != rng2.next() {
                hasDifference = true
                break
            }
        }
        
        XCTAssertTrue(hasDifference, "Different seeds should produce different sequences")
    }
    
    func testSeededRNGDoubleInRange() {
        var rng = SeededRandomNumberGenerator(seed: 12345)
        
        for _ in 0..<100 {
            let value = rng.nextDouble()
            XCTAssertGreaterThanOrEqual(value, 0.0, "Random double should be >= 0")
            XCTAssertLessThanOrEqual(value, 1.0, "Random double should be <= 1")
        }
    }
    
    // MARK: - Grid Validity Tests
    
    func testGridIsPlayable() {
        // Ensure grid generation creates a playable map
        let grid = GridGenerator.generate(seed: 42)
        
        // Check that at least the corners where players spawn are accessible
        let corners = [(0, 0), (7, 7), (0, 7), (7, 0)]
        
        for corner in corners {
            XCTAssertEqual(
                grid[corner.0][corner.1],
                .empty,
                "Player spawn corner at (\(corner.0),\(corner.1)) must be empty"
            )
        }
    }
    
    func testMultipleGridGenerations() {
        // Test that we can generate multiple grids without issues
        for seed in 1...10 {
            let grid = GridGenerator.generate(seed: UInt32(seed))
            
            XCTAssertEqual(grid.count, GameConfiguration.gridSize)
            XCTAssertEqual(grid[0].count, GameConfiguration.gridSize)
        }
    }
}
