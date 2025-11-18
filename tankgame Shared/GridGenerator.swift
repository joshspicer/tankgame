//
//  GridGenerator.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Procedurally generates game grids with random wall placement
///
/// Generates an 8x8 grid with walls placed randomly, ensuring:
/// - Spawn corners (top-left and bottom-right) remain clear
/// - Border cells remain clear for easy navigation
/// - Wall density varies between 15-30% for gameplay variety
struct GridGenerator {
    /// Generates a deterministic 8x8 game grid based on a seed value
    /// - Parameter seed: The seed for random generation (same seed = same grid)
    /// - Returns: An 8x8 grid of GridCell values
    static func generate(seed: UInt32) -> [[GridCell]] {
        var rng = SeededRandomNumberGenerator(seed: seed)
        var grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        
        // Keep spawn corners clear (top-left and bottom-right)
        let protectedCells: Set<String> = [
            "0,0", "0,1", "1,0", "1,1", // Top-left spawn area
            "6,6", "6,7", "7,6", "7,7"  // Bottom-right spawn area
        ]
        
        // Keep the border paths clear (row 0, row 7, col 0, col 7)
        let borderCells: Set<String> = {
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
        }()
        
        // Generate random wall density between 15% and 30%
        let wallDensity = 0.15 + (rng.nextDouble() * 0.15)
        
        // Add random walls with variable density only to interior cells
        for row in 0..<8 {
            for col in 0..<8 {
                let key = "\(row),\(col)"
                if !protectedCells.contains(key) && !borderCells.contains(key) && rng.nextDouble() < wallDensity {
                    grid[row][col] = .wall
                }
            }
        }
        
        return grid
    }
}

/// A seeded random number generator for deterministic grid generation
///
/// Uses a Linear Congruential Generator (LCG) algorithm to produce consistent
/// pseudo-random sequences from a given seed. This ensures all players generate
/// identical grids when given the same seed value.
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt32
    
    /// Creates a new seeded random number generator
    /// - Parameter seed: The initial seed value
    init(seed: UInt32) {
        self.state = seed
    }
    
    /// Generates the next random UInt64 value
    /// - Returns: A pseudo-random 64-bit unsigned integer
    mutating func next() -> UInt64 {
        // Linear congruential generator
        state = state &* 1664525 &+ 1013904223
        return UInt64(state)
    }
    
    /// Generates a random Double value between 0.0 and 1.0
    /// - Returns: A pseudo-random double-precision floating point value in [0, 1]
    mutating func nextDouble() -> Double {
        // Note: next() returns UInt64(state) where state is UInt32, so value is always <= UInt32.max
        let value = next()
        return Double(value) / Double(UInt32.max)
    }
}
