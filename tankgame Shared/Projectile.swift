//
//  Projectile.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Represents a projectile shot by a tank
/// Projectiles travel in straight lines and destroy tanks on impact
struct Projectile: Codable {
    /// Current row position on the grid
    var row: Int
    
    /// Current column position on the grid
    var col: Int
    
    /// Direction the projectile is traveling
    var direction: Direction
    
    /// Advances the projectile one cell in its travel direction
    mutating func advance() {
        let offset = direction.offset
        row += offset.row
        col += offset.col
    }
    
    /// Checks if the projectile has moved outside the grid boundaries
    /// - Parameter gridSize: Size of the grid (typically 8x8)
    /// - Returns: true if the projectile is out of bounds
    func isOutOfBounds(gridSize: Int) -> Bool {
        return row < 0 || row >= gridSize || col < 0 || col >= gridSize
    }
    
    /// Checks if the projectile has hit a wall on the grid
    /// - Parameter grid: Current game grid
    /// - Returns: true if the projectile's position contains a wall
    func hits(grid: [[GridCell]]) -> Bool {
        guard row >= 0, row < grid.count,
              col >= 0, col < grid[0].count else {
            return false
        }
        return grid[row][col] == .wall
    }
    
    /// Checks if the projectile has hit a tank
    /// - Parameter tank: Tank to check for collision
    /// - Returns: true if the projectile's position matches an alive tank's position
    func hits(tank: Tank) -> Bool {
        return tank.isAlive && row == tank.row && col == tank.col
    }
}
