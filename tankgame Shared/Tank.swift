//
//  Tank.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Represents a player's tank on the game grid
/// 
/// A tank has a position (row, col), a facing direction, and an alive state.
/// Tanks can move within the grid boundaries (avoiding walls) and shoot projectiles in their facing direction.
struct Tank: Codable {
    /// The tank's vertical position on the grid (0 = top)
    var row: Int
    /// The tank's horizontal position on the grid (0 = left)
    var col: Int
    /// The direction the tank is currently facing
    var direction: Direction
    /// Whether the tank is still alive (false after being hit by a projectile)
    var isAlive: Bool
    
    /// Creates a new tank at the specified position
    /// - Parameters:
    ///   - row: The initial row position
    ///   - col: The initial column position
    ///   - direction: The initial facing direction (defaults to down)
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
    /// - Returns: true if the move was successful, false if blocked by walls or boundaries
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
    
    /// Creates a projectile fired from the tank in its current direction
    /// - Returns: A new projectile positioned one cell ahead of the tank
    func shoot() -> Projectile {
        let offset = direction.offset
        return Projectile(row: row + offset.row, col: col + offset.col, direction: direction)
    }
}
