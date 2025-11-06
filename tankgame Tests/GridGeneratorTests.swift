//
//  GridGeneratorTests.swift
//  tankgame Tests
//
//  Unit tests for GridGenerator
//

import XCTest
@testable import tankgame

class GridGeneratorTests: XCTestCase {
    
    func testGridGeneratorCreatesCorrectSize() {
        let grid = GridGenerator.generate(seed: 12345)
        
        XCTAssertEqual(grid.count, 8)
        for row in grid {
            XCTAssertEqual(row.count, 8)
        }
    }
    
    func testGridGeneratorWithSameSeedProducesSameGrid() {
        let seed: UInt32 = 42
        let grid1 = GridGenerator.generate(seed: seed)
        let grid2 = GridGenerator.generate(seed: seed)
        
        for row in 0..<8 {
            for col in 0..<8 {
                XCTAssertEqual(grid1[row][col], grid2[row][col],
                             "Grids with same seed should be identical at (\(row), \(col))")
            }
        }
    }
    
    func testGridGeneratorWithDifferentSeedProducesDifferentGrid() {
        let grid1 = GridGenerator.generate(seed: 12345)
        let grid2 = GridGenerator.generate(seed: 54321)
        
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
        
        XCTAssertTrue(foundDifference, "Grids with different seeds should be different")
    }
    
    func testGridGeneratorKeepsTopLeftSpawnClear() {
        let grid = GridGenerator.generate(seed: 99999)
        
        // Top-left spawn area should be clear
        XCTAssertEqual(grid[0][0], .empty)
        XCTAssertEqual(grid[0][1], .empty)
        XCTAssertEqual(grid[1][0], .empty)
        XCTAssertEqual(grid[1][1], .empty)
    }
    
    func testGridGeneratorKeepsBottomRightSpawnClear() {
        let grid = GridGenerator.generate(seed: 99999)
        
        // Bottom-right spawn area should be clear
        XCTAssertEqual(grid[6][6], .empty)
        XCTAssertEqual(grid[6][7], .empty)
        XCTAssertEqual(grid[7][6], .empty)
        XCTAssertEqual(grid[7][7], .empty)
    }
    
    func testGridGeneratorKeepsBordersClear() {
        let grid = GridGenerator.generate(seed: 88888)
        
        // Check top and bottom rows
        for col in 0..<8 {
            XCTAssertEqual(grid[0][col], .empty, "Top border at col \(col) should be clear")
            XCTAssertEqual(grid[7][col], .empty, "Bottom border at col \(col) should be clear")
        }
        
        // Check left and right columns
        for row in 0..<8 {
            XCTAssertEqual(grid[row][0], .empty, "Left border at row \(row) should be clear")
            XCTAssertEqual(grid[row][7], .empty, "Right border at row \(row) should be clear")
        }
    }
    
    func testSeededRandomNumberGenerator() {
        var rng1 = SeededRandomNumberGenerator(seed: 12345)
        var rng2 = SeededRandomNumberGenerator(seed: 12345)
        
        // Same seed should produce same sequence
        for _ in 0..<10 {
            XCTAssertEqual(rng1.next(), rng2.next())
        }
    }
    
    func testSeededRandomNumberGeneratorDouble() {
        var rng = SeededRandomNumberGenerator(seed: 12345)
        
        // Generate several doubles and ensure they're in valid range [0, 1]
        for _ in 0..<100 {
            let value = rng.nextDouble()
            XCTAssertGreaterThanOrEqual(value, 0.0)
            XCTAssertLessThanOrEqual(value, 1.0)
        }
    }
    
    func testSeededRandomNumberGeneratorDifferentSeeds() {
        var rng1 = SeededRandomNumberGenerator(seed: 111)
        var rng2 = SeededRandomNumberGenerator(seed: 222)
        
        // Different seeds should produce different sequences
        var foundDifference = false
        for _ in 0..<10 {
            if rng1.next() != rng2.next() {
                foundDifference = true
                break
            }
        }
        
        XCTAssertTrue(foundDifference, "Different seeds should produce different random sequences")
    }
}
