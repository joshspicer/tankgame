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
        
        // Add random walls (~20% density) only to interior cells
        for row in 0..<8 {
            for col in 0..<8 {
                let key = "\(row),\(col)"
                if !protectedCells.contains(key) && !borderCells.contains(key) && rng.nextDouble() < 0.20 {
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
