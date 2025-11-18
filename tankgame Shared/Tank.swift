//
//  Tank.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Represents a player's tank in the game
/// Tanks can move, shoot projectiles, and be destroyed
struct Tank: Codable {
    /// Current row position on the grid (0-7)
    var row: Int
    
    /// Current column position on the grid (0-7)
    var col: Int
    
    /// Direction the tank is facing
    var direction: Direction
    
    /// Whether the tank is still alive in the current round
    var isAlive: Bool
    
    /// Creates a new tank at the specified position
    /// - Parameters:
    ///   - row: Initial row position (0-7)
    ///   - col: Initial column position (0-7)
    ///   - direction: Initial facing direction (defaults to .down)
    init(row: Int, col: Int, direction: Direction = .down) {
        self.row = row
        self.col = col
        self.direction = direction
        self.isAlive = true
    }
    
    /// Attempts to move the tank in the specified direction
    /// - Parameters:
    ///   - direction: Direction to move
    ///   - grid: Current game grid to check for obstacles
    /// - Returns: true if the move was successful, false if blocked or out of bounds
    mutating func move(in direction: Direction, grid: [[GridCell]]) -> Bool {
        let offset = direction.offset
        let newRow = row + offset.row
        let newCol = col + offset.col
        
        // Check bounds
        guard newRow >= 0, newRow < grid.count,
              newCol >= 0, newCol < grid[0].count else {
            return false
        }
        
        // Check if cell is empty
        guard grid[newRow][newCol] == .empty else {
            return false
        }
        
        row = newRow
        col = newCol
        self.direction = direction
        return true
    }
    
    /// Creates a projectile shot from this tank's current position
    /// The projectile starts one cell ahead of the tank in its facing direction
    /// - Returns: A new projectile positioned one cell in front of the tank
    func shoot() -> Projectile {
        let offset = direction.offset
        return Projectile(row: row + offset.row, col: col + offset.col, direction: direction)
    }
}
