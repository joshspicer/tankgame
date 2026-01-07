//
//  BoardGenerator.swift
//  tankgame Shared
//
//  Generates game boards with procedural generation
//

import Foundation

/// Generates game boards with various patterns
struct BoardGenerator {
    
    /// Generate a standard 8x8 board with walls
    static func generateStandardBoard(seed: UInt32) -> GameBoard {
        var rng = SeededRandomGenerator(seed: seed)
        var board = GameBoard(rows: 8, cols: 8)
        
        // Add perimeter walls
        for row in 0..<8 {
            for col in 0..<8 {
                if row == 0 || row == 7 || col == 0 || col == 7 {
                    if shouldPlaceWall(row: row, col: col) {
                        board.setCell(at: Position(row: row, col: col), to: .wall)
                    }
                }
            }
        }
        
        // Add some internal walls randomly
        let internalWallCount = 8 + rng.nextInt(max: 8)
        for _ in 0..<internalWallCount {
            let row = 1 + rng.nextInt(max: 6)
            let col = 1 + rng.nextInt(max: 6)
            let position = Position(row: row, col: col)
            
            // Don't place walls on spawn positions
            if !isSpawnPosition(position) {
                let isDestructible = rng.nextBool()
                board.setCell(at: position, to: isDestructible ? .destructibleWall : .wall)
            }
        }
        
        return board
    }
    
    /// Standard spawn positions for 2-6 players
    static let spawnPositions: [Position] = [
        Position(row: 1, col: 1),     // Player 0
        Position(row: 6, col: 6),     // Player 1
        Position(row: 1, col: 6),     // Player 2
        Position(row: 6, col: 1),     // Player 3
        Position(row: 3, col: 1),     // Player 4
        Position(row: 3, col: 6),     // Player 5
    ]
    
    /// Standard spawn directions
    static let spawnDirections: [Direction] = [
        .down,  // Player 0
        .up,    // Player 1
        .down,  // Player 2
        .up,    // Player 3
        .right, // Player 4
        .left,  // Player 5
    ]
    
    private static func shouldPlaceWall(row: Int, col: Int) -> Bool {
        // Don't place walls at corners (near spawn points)
        if (row <= 1 && col <= 1) || (row <= 1 && col >= 6) ||
           (row >= 6 && col <= 1) || (row >= 6 && col >= 6) {
            return false
        }
        return true
    }
    
    private static func isSpawnPosition(_ position: Position) -> Bool {
        return spawnPositions.contains(position)
    }
}

/// Simple seeded random number generator
struct SeededRandomGenerator {
    private var state: UInt32
    
    init(seed: UInt32) {
        self.state = seed
    }
    
    mutating func next() -> UInt32 {
        // Linear congruential generator
        state = (state &* 1664525 &+ 1013904223)
        return state
    }
    
    mutating func nextInt(max: Int) -> Int {
        return Int(next() % UInt32(max))
    }
    
    mutating func nextBool() -> Bool {
        return next() % 2 == 0
    }
}
