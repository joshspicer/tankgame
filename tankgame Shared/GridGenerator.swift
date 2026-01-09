//
//  GridGenerator.swift
//  tankgame Shared
//
//  Procedural maze generation with configurable parameters and constraints
//

import Foundation

/// Generates game grids/mazes with walls and empty cells
struct GridGenerator {

    /// The configuration for maze generation
    private let config: MazeGenerationConfig

    /// Initialize with a custom configuration
    init(config: MazeGenerationConfig = .standard) {
        self.config = config
    }

    /// Generate a grid using the provided seed and configuration
    /// - Parameter seed: Random seed for reproducible generation
    /// - Returns: 2D array of GridCell representing the maze
    func generate(seed: UInt32) -> [[GridCell]] {
        var rng = SeededRandomNumberGenerator(seed: seed)
        var grid = createEmptyGrid()

        let wallDensity = calculateWallDensity(using: &rng)
        placeWalls(in: &grid, density: wallDensity, using: &rng)

        return grid
    }

    /// Static convenience method for backward compatibility
    static func generate(seed: UInt32) -> [[GridCell]] {
        let generator = GridGenerator()
        return generator.generate(seed: seed)
    }

    // MARK: - Private Helper Methods

    /// Create an empty grid filled with empty cells
    private func createEmptyGrid() -> [[GridCell]] {
        return Array(
            repeating: Array(repeating: GridCell.empty, count: config.gridSize),
            count: config.gridSize
        )
    }

    /// Calculate random wall density within configured bounds
    private func calculateWallDensity(using rng: inout SeededRandomNumberGenerator) -> Double {
        let range = config.maxWallDensity - config.minWallDensity
        return config.minWallDensity + (rng.nextDouble() * range)
    }

    /// Place walls in the grid according to density and constraints
    private func placeWalls(
        in grid: inout [[GridCell]],
        density: Double,
        using rng: inout SeededRandomNumberGenerator
    ) {
        for row in 0..<config.gridSize {
            for col in 0..<config.gridSize {
                if shouldPlaceWall(at: row, col: col, density: density, using: &rng) {
                    grid[row][col] = .wall
                }
            }
        }
    }

    /// Determine if a wall should be placed at the given position
    private func shouldPlaceWall(
        at row: Int,
        col: Int,
        density: Double,
        using rng: inout SeededRandomNumberGenerator
    ) -> Bool {
        let key = "\(row),\(col)"

        // Don't place walls in protected cells (spawn areas)
        if config.protectedCells.contains(key) {
            return false
        }

        // Don't place walls in border cells (edge paths)
        if config.borderCells.contains(key) {
            return false
        }

        // Place wall based on random density
        return rng.nextDouble() < density
    }
}
