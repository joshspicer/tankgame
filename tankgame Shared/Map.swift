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

    /// Generate spawn positions for any number of players
    /// - For ≤4 players: use corners
    /// - For >4 players: distribute around perimeter
    static func generateSpawnPositions(playerCount: Int, gridSize: Int = 8) -> [(row: Int, col: Int, direction: Direction)] {
        // Corner positions (for first 4 players)
        let corners: [(row: Int, col: Int, direction: Direction)] = [
            (0, 0, .down),                      // Top-left
            (gridSize - 1, gridSize - 1, .up),  // Bottom-right
            (0, gridSize - 1, .down),           // Top-right
            (gridSize - 1, 0, .up)              // Bottom-left
        ]

        if playerCount <= 4 {
            return Array(corners.prefix(playerCount))
        }

        // For more than 4 players, distribute around perimeter
        var positions: [(row: Int, col: Int, direction: Direction)] = []
        let perimeter = (gridSize - 1) * 4
        let spacing = perimeter / playerCount

        var currentPos = 0
        for _ in 0..<playerCount {
            let (row, col, dir) = perimeterPosition(at: currentPos, gridSize: gridSize)
            positions.append((row, col, dir))
            currentPos = (currentPos + spacing) % perimeter
        }

        return positions
    }

    /// Convert perimeter index to grid position
    private static func perimeterPosition(at index: Int, gridSize: Int) -> (row: Int, col: Int, direction: Direction) {
        let sideLength = gridSize - 1
        let side = index / sideLength
        let offset = index % sideLength

        switch side {
        case 0: // Top edge (left to right)
            return (0, offset, .down)
        case 1: // Right edge (top to bottom)
            return (offset, gridSize - 1, .left)
        case 2: // Bottom edge (right to left)
            return (gridSize - 1, gridSize - 1 - offset, .up)
        case 3: // Left edge (bottom to top)
            return (gridSize - 1 - offset, 0, .right)
        default:
            return (0, 0, .down)
        }
    }

    /// Get protected cells around a spawn position (2x2 area)
    static func protectedCells(for spawn: (row: Int, col: Int), gridSize: Int) -> Set<String> {
        var cells = Set<String>()
        for dr in 0...1 {
            for dc in 0...1 {
                let r = min(max(spawn.row + dr - (spawn.row == gridSize - 1 ? 1 : 0), 0), gridSize - 1)
                let c = min(max(spawn.col + dc - (spawn.col == gridSize - 1 ? 1 : 0), 0), gridSize - 1)
                cells.insert("\(r),\(c)")
            }
        }
        return cells
    }

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
