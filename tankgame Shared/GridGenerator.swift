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
        var grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        
        // Keep spawn corners clear (top-left and bottom-right)
        let protectedCells: Set<String> = [
            "0,0", "0,1", "1,0", "1,1", // Top-left spawn area
            "6,6", "6,7", "7,6", "7,7"  // Bottom-right spawn area
        ]
        
        // Add random walls (~20% density)
        for row in 0..<8 {
            for col in 0..<8 {
                let key = "\(row),\(col)"
                if !protectedCells.contains(key) && rng.next() < 0.20 {
                    grid[row][col] = .wall
                }
            }
        }
        
        // Ensure guaranteed paths from (0,0) to (7,7)
        // Clear vertical path down middle-left
        for row in 0..<8 {
            grid[row][2] = .empty
        }
        
        // Clear horizontal path across middle
        for col in 0..<8 {
            grid[4][col] = .empty
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
    
    mutating func next() -> Double {
        return Double(next() as UInt64) / Double(UInt64.max)
    }
}
