//
//  LizardSpawner.swift
//  tankgame Shared
//
//  Handles lizard spawning logic extracted from GameState
//

import Foundation

/// Handles spawning of lizards at random valid positions
class LizardSpawner {
    
    /// Spawn lizards at random empty positions
    /// - Parameters:
    ///   - seed: Random seed for deterministic placement
    ///   - grid: The game grid
    ///   - count: Number of lizards to spawn
    ///   - spawnPositions: Player spawn positions to avoid
    /// - Returns: Array of spawned lizards
    static func spawnLizards(seed: UInt32, grid: [[GridCell]], count: Int, spawnPositions: [(row: Int, col: Int, direction: Direction)]) -> [Lizard] {
        // Use seed for deterministic placement
        srand48(Int(seed) + 1000) // Offset seed to get different positions from grid
        
        var newLizards: [Lizard] = []
        var attempts = 0
        let maxAttempts = 100
        
        while newLizards.count < count && attempts < maxAttempts {
            attempts += 1
            
            // Generate random position
            let row = Int(drand48() * Double(grid.count))
            let col = Int(drand48() * Double(grid[0].count))
            
            // Check if position is valid (empty and not near spawn points)
            guard grid[row][col] == .empty else { continue }
            guard !isNearSpawnPoint(row: row, col: col, spawnPositions: spawnPositions) else { continue }
            guard !isOccupiedByLizard(row: row, col: col, lizards: newLizards) else { continue }
            
            // Create lizard with random direction using the static constant from Direction
            let direction = Direction.cardinalDirections.randomElement() ?? .right
            
            newLizards.append(Lizard(row: row, col: col, direction: direction))
        }
        
        return newLizards
    }
    
    /// Check if a position is near any spawn point
    /// - Parameters:
    ///   - row: Row to check
    ///   - col: Column to check
    ///   - spawnPositions: Array of spawn positions to avoid
    /// - Returns: True if position is within 2 cells of any spawn point
    private static func isNearSpawnPoint(row: Int, col: Int, spawnPositions: [(row: Int, col: Int, direction: Direction)]) -> Bool {
        for spawn in spawnPositions {
            let distance = abs(spawn.row - row) + abs(spawn.col - col)
            if distance < 2 {
                return true
            }
        }
        return false
    }
    
    /// Check if a position is occupied by another lizard
    /// - Parameters:
    ///   - row: Row to check
    ///   - col: Column to check
    ///   - lizards: Existing lizards
    /// - Returns: True if position is occupied
    private static func isOccupiedByLizard(row: Int, col: Int, lizards: [Lizard]) -> Bool {
        return lizards.contains { $0.row == row && $0.col == col }
    }
}
