//
//  GridGenerator.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

struct GridGenerator {
    static func generate(seed: UInt32) -> [[GridCell]] {
        var rng = SeededRandomNumberGenerator(seed: seed)
        let size = GameConfiguration.gridSize
        var grid = Array(repeating: Array(repeating: GridCell.empty, count: size), count: size)
        
        // Use protected cells from configuration (supports all 4 player spawns)
        let protectedCells = GameConfiguration.protectedSpawnCells
        let borderCells = GameConfiguration.borderCells()
        
        // Generate random wall density using configuration
        let wallDensity = GameConfiguration.minWallDensity + 
                         (rng.nextDouble() * (GameConfiguration.maxWallDensity - GameConfiguration.minWallDensity))
        
        // Add random walls with variable density only to interior cells
        for row in 0..<size {
            for col in 0..<size {
                let key = "\(row),\(col)"
                if !protectedCells.contains(key) && !borderCells.contains(key) && rng.nextDouble() < wallDensity {
                    grid[row][col] = .wall
                }
            }
        }
        
        return grid
    }
}

// Seeded random number generator for consistent grid generation
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt32
    
    init(seed: UInt32) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        // Linear congruential generator
        state = state &* 1664525 &+ 1013904223
        return UInt64(state)
    }
    
    mutating func nextDouble() -> Double {
        // Note: next() returns UInt64(state) where state is UInt32, so value is always <= UInt32.max
        let value = next()
        return Double(value) / Double(UInt32.max)
    }
}
