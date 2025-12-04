//
//  CollisionDetection.swift
//  tankgame Shared
//
//  Collision detection utilities for game entities
//

import Foundation

/// Utility class for collision detection between game entities
class CollisionDetection {
    
    /// Check if a position hits a wall in the grid
    /// - Parameters:
    ///   - row: Row position
    ///   - col: Column position
    ///   - grid: Game grid
    /// - Returns: True if position is a wall
    static func hitsWall(row: Int, col: Int, grid: [[GridCell]]) -> Bool {
        guard row >= 0, row < grid.count,
              col >= 0, col < grid[0].count else {
            return false
        }
        return grid[row][col] == .wall
    }
    
    /// Check if a position is out of bounds
    /// - Parameters:
    ///   - row: Row position
    ///   - col: Column position
    ///   - rowCount: Number of rows in the grid
    ///   - colCount: Number of columns in the grid (defaults to rowCount for square grids)
    /// - Returns: True if position is out of bounds
    static func isOutOfBounds(row: Int, col: Int, rowCount: Int, colCount: Int? = nil) -> Bool {
        let columns = colCount ?? rowCount
        return row < 0 || row >= rowCount || col < 0 || col >= columns
    }
    
    /// Check if two positions match (same row and column)
    /// - Parameters:
    ///   - row1: First row
    ///   - col1: First column
    ///   - row2: Second row
    ///   - col2: Second column
    /// - Returns: True if positions match
    static func positionsMatch(row1: Int, col1: Int, row2: Int, col2: Int) -> Bool {
        return row1 == row2 && col1 == col2
    }
    
    /// Check if a projectile hits a tank
    /// - Parameters:
    ///   - projectile: The projectile
    ///   - tank: The tank
    /// - Returns: True if projectile hits the tank
    static func projectileHitsTank(_ projectile: Projectile, _ tank: Tank) -> Bool {
        return tank.isAlive && positionsMatch(row1: projectile.row, col1: projectile.col, row2: tank.row, col2: tank.col)
    }
    
    /// Check if a projectile hits a lizard
    /// - Parameters:
    ///   - projectile: The projectile
    ///   - lizard: The lizard
    /// - Returns: True if projectile hits the lizard
    static func projectileHitsLizard(_ projectile: Projectile, _ lizard: Lizard) -> Bool {
        return lizard.isAlive && positionsMatch(row1: projectile.row, col1: projectile.col, row2: lizard.row, col2: lizard.col)
    }
}
