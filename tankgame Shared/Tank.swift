//
//  Tank.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Represents a player's tank in the game
/// 
/// A tank has a position (row, col), a direction it's facing, and an alive status.
/// Tanks can move in any direction and shoot projectiles in the direction they're facing.
struct Tank: Codable {
    /// Row position on the grid (0-based)
    var row: Int
    /// Column position on the grid (0-based)
    var col: Int
    /// The direction the tank is currently facing
    var direction: Direction
    /// Whether the tank is still alive in the current round
    var isAlive: Bool
    
    init(row: Int, col: Int, direction: Direction = .down) {
        self.row = row
        self.col = col
        self.direction = direction
        self.isAlive = true
    }
    
    /// Attempts to move the tank in the specified direction
    /// - Parameters:
    ///   - direction: The direction to move
    ///   - grid: The game grid to check for collisions
    /// - Returns: true if the move was successful, false if blocked
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
    
    /// Creates a projectile in front of the tank
    /// - Returns: A new projectile positioned one cell ahead of the tank
    func shoot() -> Projectile {
        let offset = direction.offset
        return Projectile(row: row + offset.row, col: col + offset.col, direction: direction)
    }
}
