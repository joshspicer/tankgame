//
//  GridGeneratorTests.swift
//  tankgame Tests
//
//  Unit tests for GridGenerator
//

import XCTest
@testable import Tank_Game

final class GridGeneratorTests: XCTestCase {

    // MARK: - Grid Generation Tests

    func testGridGenerationSize() {
        let grid = GridGenerator.generate(seed: 12345)

        XCTAssertEqual(grid.count, 8)
        for row in grid {
            XCTAssertEqual(row.count, 8)
        }
    }

    func testSameSeedProducesSameGrid() {
        let seed: UInt32 = 42
        let grid1 = GridGenerator.generate(seed: seed)
        let grid2 = GridGenerator.generate(seed: seed)

        XCTAssertEqual(grid1.count, grid2.count)
        for row in 0..<8 {
            for col in 0..<8 {
                XCTAssertEqual(grid1[row][col], grid2[row][col],
                              "Grid cells at [\(row)][\(col)] should be equal for same seed")
            }
        }
    }

    func testDifferentSeedsProduceDifferentGrids() {
        let grid1 = GridGenerator.generate(seed: 100)
        let grid2 = GridGenerator.generate(seed: 200)

        var hasDifference = false
        for row in 0..<8 {
            for col in 0..<8 {
                if grid1[row][col] != grid2[row][col] {
                    hasDifference = true
                    break
                }
            }
            if hasDifference { break }
        }

        XCTAssertTrue(hasDifference, "Different seeds should produce different grids")
    }

    // MARK: - Protected Cells Tests

    func testTopLeftSpawnAreaIsClear() {
        // Generate multiple grids and verify spawn area is always clear
        for seed in UInt32(0)..<100 {
            let grid = GridGenerator.generate(seed: seed)

            XCTAssertEqual(grid[0][0], .empty, "Top-left corner should be empty (seed: \(seed))")
            XCTAssertEqual(grid[0][1], .empty, "Top-left spawn should be empty (seed: \(seed))")
            XCTAssertEqual(grid[1][0], .empty, "Top-left spawn should be empty (seed: \(seed))")
            XCTAssertEqual(grid[1][1], .empty, "Top-left spawn should be empty (seed: \(seed))")
        }
    }

    func testBottomRightSpawnAreaIsClear() {
        // Generate multiple grids and verify spawn area is always clear
        for seed in UInt32(0)..<100 {
            let grid = GridGenerator.generate(seed: seed)

            XCTAssertEqual(grid[6][6], .empty, "Bottom-right spawn should be empty (seed: \(seed))")
            XCTAssertEqual(grid[6][7], .empty, "Bottom-right spawn should be empty (seed: \(seed))")
            XCTAssertEqual(grid[7][6], .empty, "Bottom-right spawn should be empty (seed: \(seed))")
            XCTAssertEqual(grid[7][7], .empty, "Bottom-right corner should be empty (seed: \(seed))")
        }
    }

    func testBorderPathsAreClear() {
        // Generate multiple grids and verify borders are clear
        for seed in UInt32(0)..<50 {
            let grid = GridGenerator.generate(seed: seed)

            // Check top and bottom rows
            for col in 0..<8 {
                XCTAssertEqual(grid[0][col], .empty, "Top border at col \(col) should be empty (seed: \(seed))")
                XCTAssertEqual(grid[7][col], .empty, "Bottom border at col \(col) should be empty (seed: \(seed))")
            }

            // Check left and right columns
            for row in 0..<8 {
                XCTAssertEqual(grid[row][0], .empty, "Left border at row \(row) should be empty (seed: \(seed))")
                XCTAssertEqual(grid[row][7], .empty, "Right border at row \(row) should be empty (seed: \(seed))")
            }
        }
    }

    // MARK: - Wall Density Tests

    func testWallDensityWithinExpectedRange() {
        let grid = GridGenerator.generate(seed: 12345)

        var wallCount = 0
        var totalInteriorCells = 0

        // Only count interior cells (excluding borders and spawn areas)
        for row in 2..<6 {
            for col in 2..<6 {
                totalInteriorCells += 1
                if grid[row][col] == .wall {
                    wallCount += 1
                }
            }
        }

        let density = Double(wallCount) / Double(totalInteriorCells)

        // Wall density should be between 0% and 50% (generous range)
        // The actual generation logic targets 15-30% but we check a wider range
        XCTAssertGreaterThanOrEqual(density, 0.0)
        XCTAssertLessThanOrEqual(density, 0.5)
    }

    // MARK: - SeededRandomNumberGenerator Tests

    func testSeededRNGDeterminism() {
        var rng1 = SeededRandomNumberGenerator(seed: 42)
        var rng2 = SeededRandomNumberGenerator(seed: 42)

        // Generate 10 numbers from each and verify they match
        for _ in 0..<10 {
            XCTAssertEqual(rng1.next(), rng2.next())
        }
    }

    func testSeededRNGDifferentSeeds() {
        var rng1 = SeededRandomNumberGenerator(seed: 100)
        var rng2 = SeededRandomNumberGenerator(seed: 200)

        let value1 = rng1.next()
        let value2 = rng2.next()

        XCTAssertNotEqual(value1, value2)
    }

    func testSeededRNGNextDoubleBounds() {
        var rng = SeededRandomNumberGenerator(seed: 42)

        for _ in 0..<100 {
            let value = rng.nextDouble()
            XCTAssertGreaterThanOrEqual(value, 0.0)
            XCTAssertLessThanOrEqual(value, 1.0)
        }
    }

    func testSeededRNGNextDoubleDistribution() {
        var rng = SeededRandomNumberGenerator(seed: 42)
        var values: [Double] = []

        for _ in 0..<100 {
            values.append(rng.nextDouble())
        }

        // Check that we get a variety of values (not all the same)
        let uniqueValues = Set(values)
        XCTAssertGreaterThan(uniqueValues.count, 50, "Should generate diverse values")
    }
}
