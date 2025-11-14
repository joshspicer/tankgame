//
//  Projectile.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// A projectile fired by a tank, moving in a straight line
struct Projectile: Codable {
    var row: Int
    var col: Int
    var direction: Direction
    
    /// Advances the projectile one cell in its direction
    mutating func advance() {
        let offset = direction.offset
        row += offset.row
        col += offset.col
    }
    
    /// Checks if the projectile has moved outside the grid bounds
    /// - Parameter gridSize: Size of the square grid
    /// - Returns: true if out of bounds
    func isOutOfBounds(gridSize: Int) -> Bool {
        return row < 0 || row >= gridSize || col < 0 || col >= gridSize
    }
    
    /// Checks if the projectile has hit a wall
    /// - Parameter grid: Current game grid
    /// - Returns: true if projectile position contains a wall
    func hits(grid: [[GridCell]]) -> Bool {
        guard row >= 0, row < grid.count,
              col >= 0, col < grid[0].count else {
            return false
        }
        return grid[row][col] == .wall
    }
    
    /// Checks if the projectile has hit a tank
    /// - Parameter tank: Tank to check collision with
    /// - Returns: true if projectile position matches tank position and tank is alive
    func hits(tank: Tank) -> Bool {
        return tank.isAlive && row == tank.row && col == tank.col
    }
}
