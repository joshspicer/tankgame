//
//  Tank.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Represents a player's tank with position, direction, and alive status
struct Tank: Codable {
    var row: Int
    var col: Int
    var direction: Direction
    var isAlive: Bool
    
    /// Initializes a new tank at the specified position
    /// - Parameters:
    ///   - row: Grid row position
    ///   - col: Grid column position
    ///   - direction: Initial facing direction
    init(row: Int, col: Int, direction: Direction = .down) {
        self.row = row
        self.col = col
        self.direction = direction
        self.isAlive = true
    }
    
    /// Attempts to move the tank in the specified direction
    /// - Parameters:
    ///   - direction: Direction to move
    ///   - grid: Current game grid for collision detection
    /// - Returns: true if move was successful, false if blocked
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
    
    /// Creates a projectile fired from this tank in its current direction
    /// - Returns: A new projectile positioned one cell ahead of the tank
    func shoot() -> Projectile {
        let offset = direction.offset
        return Projectile(row: row + offset.row, col: col + offset.col, direction: direction)
    }
}
