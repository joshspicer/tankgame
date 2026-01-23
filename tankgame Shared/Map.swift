//
//  Map.swift
//  Tank Game
//
//  Procedural map generation with seeded randomness for multiplayer.
//

import Foundation

/// Generates game maps with walls and spawn points
struct Map {
    /// Grid of walls (true = wall, false = empty)
    let grid: [[Bool]]
    let size: Int
    let seed: UInt32
    
    /// Spawn positions for up to 4 players (row, col, direction)
    static let spawnPositions: [(row: Int, col: Int, direction: Direction)] = [
        (0, 0, .down),      // Player 0: top-left
        (7, 7, .up),        // Player 1: bottom-right
        (0, 7, .down),      // Player 2: top-right
        (7, 0, .up)         // Player 3: bottom-left
    ]
    
    /// Create a new map with a random seed
    static func random() -> Map {
        generate(seed: UInt32.random(in: 0...UInt32.max))
    }
    
    /// Generate a map from a seed (deterministic for multiplayer sync)
    static func generate(seed: UInt32) -> Map {
        var rng = SeededRNG(seed: seed)
        let size = 8
        var grid = Array(repeating: Array(repeating: false, count: size), count: size)
        
        // Protected spawn corners (2x2 areas in each corner)
        let protected: Set<String> = [
            "0,0", "0,1", "1,0", "1,1",  // Top-left
            "6,6", "6,7", "7,6", "7,7",  // Bottom-right
            "0,6", "0,7", "1,6", "1,7",  // Top-right
            "6,0", "6,1", "7,0", "7,1"   // Bottom-left
        ]
        
        // Keep border paths clear
        let border: Set<String> = {
            var cells = Set<String>()
            for i in 0..<size {
                cells.insert("0,\(i)")
                cells.insert("\(size-1),\(i)")
                cells.insert("\(i),0")
                cells.insert("\(i),\(size-1)")
            }
            return cells
        }()
        
        // Random wall density (15-30%)
        let density = 0.15 + (rng.nextDouble() * 0.15)
        
        // Place walls only in interior cells
        for row in 0..<size {
            for col in 0..<size {
                let key = "\(row),\(col)"
                if !protected.contains(key) && !border.contains(key) && rng.nextDouble() < density {
                    grid[row][col] = true
                }
            }
        }
        
        return Map(grid: grid, size: size, seed: seed)
    }
}

// MARK: - Seeded Random Number Generator

/// Deterministic RNG for multiplayer map synchronization
struct SeededRNG: RandomNumberGenerator {
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
        Double(next()) / Double(UInt32.max)
    }
}
