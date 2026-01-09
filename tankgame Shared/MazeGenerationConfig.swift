//
//  MazeGenerationConfig.swift
//  tankgame Shared
//
//  Configuration for maze generation including grid size, constraints, and density
//

import Foundation

/// Configuration for maze generation
struct MazeGenerationConfig {
    /// Size of the grid (width and height)
    let gridSize: Int

    /// Minimum wall density (percentage)
    let minWallDensity: Double

    /// Maximum wall density (percentage)
    let maxWallDensity: Double

    /// Cells that must remain clear for spawning
    let protectedCells: Set<String>

    /// Border cells that should remain clear
    let borderCells: Set<String>

    /// Default configuration for 8x8 grid with standard game settings
    static let standard = MazeGenerationConfig(
        gridSize: 8,
        minWallDensity: 0.15,
        maxWallDensity: 0.30,
        protectedCells: Self.standardProtectedCells(),
        borderCells: Self.standardBorderCells()
    )

    /// Calculate standard protected spawn areas (corners)
    private static func standardProtectedCells() -> Set<String> {
        return [
            "0,0", "0,1", "1,0", "1,1", // Top-left spawn area
            "6,6", "6,7", "7,6", "7,7"  // Bottom-right spawn area
        ]
    }

    /// Calculate standard border cells (edges of grid)
    private static func standardBorderCells() -> Set<String> {
        var cells = Set<String>()
        for col in 0..<8 {
            cells.insert("0,\(col)")
            cells.insert("7,\(col)")
        }
        for row in 0..<8 {
            cells.insert("\(row),0")
            cells.insert("\(row),7")
        }
        return cells
    }

    /// Create a custom configuration
    init(gridSize: Int, minWallDensity: Double, maxWallDensity: Double, protectedCells: Set<String>, borderCells: Set<String>) {
        self.gridSize = gridSize
        self.minWallDensity = minWallDensity
        self.maxWallDensity = maxWallDensity
        self.protectedCells = protectedCells
        self.borderCells = borderCells
    }
}
