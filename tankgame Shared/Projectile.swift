//
//  Projectile.swift
//  Tank Game
//
//  Projectile fired by tanks with simple collision detection.
//

import Foundation

/// Projectile entity with movement and collision
struct Projectile: Codable, Equatable {
    var row: Int
    var col: Int
    var direction: Direction
    var ownerIndex: Int
    
    /// Move the projectile one step forward
    mutating func advance() {
        row += direction.offset.row
        col += direction.offset.col
    }
    
    /// Check if projectile is out of grid bounds
    func isOutOfBounds(gridSize: Int) -> Bool {
        row < 0 || row >= gridSize || col < 0 || col >= gridSize
    }
    
    /// Check if projectile hits a wall
    func hitsWall(grid: [[Bool]]) -> Bool {
        guard !isOutOfBounds(gridSize: grid.count) else { return false }
        return grid[row][col]
    }
    
    /// Check if projectile hits a tank
    func hitsTank(_ tank: Tank) -> Bool {
        tank.isAlive && tank.row == row && tank.col == col
    }
}
