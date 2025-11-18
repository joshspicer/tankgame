//
//  Projectile.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Represents a projectile (bullet) traveling across the game grid
///
/// Projectiles move in a straight line in their assigned direction until they:
/// - Hit a wall
/// - Go out of bounds
/// - Hit a tank
struct Projectile: Codable {
    /// The projectile's vertical position on the grid
    var row: Int
    /// The projectile's horizontal position on the grid
    var col: Int
    /// The direction the projectile is traveling
    var direction: Direction
    
    /// Moves the projectile one cell forward in its direction
    mutating func advance() {
        let offset = direction.offset
        row += offset.row
        col += offset.col
    }
    
    /// Checks if the projectile is outside the grid boundaries
    /// - Parameter gridSize: The size of the square grid (e.g., 8 for an 8x8 grid)
    /// - Returns: true if the projectile is out of bounds
    func isOutOfBounds(gridSize: Int) -> Bool {
        return row < 0 || row >= gridSize || col < 0 || col >= gridSize
    }
    
    /// Checks if the projectile has hit a wall on the grid
    /// - Parameter grid: The game grid to check
    /// - Returns: true if the projectile's position contains a wall
    func hits(grid: [[GridCell]]) -> Bool {
        guard row >= 0, row < grid.count,
              col >= 0, col < grid[0].count else {
            return false
        }
        return grid[row][col] == .wall
    }
    
    /// Checks if the projectile has hit a specific tank
    /// - Parameter tank: The tank to check for collision
    /// - Returns: true if the projectile occupies the same cell as a living tank
    func hits(tank: Tank) -> Bool {
        return tank.isAlive && row == tank.row && col == tank.col
    }
}
