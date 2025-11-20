//
//  Projectile.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

struct Projectile: Codable {
    var row: Int
    var col: Int
    var direction: Direction
    var bouncesRemaining: Int = 1
    
    mutating func advance() {
        let offset = direction.offset
        row += offset.row
        col += offset.col
    }
    
    func isOutOfBounds(gridSize: Int) -> Bool {
        return row < 0 || row >= gridSize || col < 0 || col >= gridSize
    }
    
    func hits(grid: [[GridCell]]) -> Bool {
        guard row >= 0, row < grid.count,
              col >= 0, col < grid[0].count else {
            return false
        }
        return grid[row][col] == .wall
    }
    
    func hits(tank: Tank) -> Bool {
        return tank.isAlive && row == tank.row && col == tank.col
    }
    
    /// Check if projectile would hit a wall in the next position
    func wouldHitWall(grid: [[GridCell]]) -> (hits: Bool, wallRow: Int, wallCol: Int) {
        let offset = direction.offset
        let nextRow = row + offset.row
        let nextCol = col + offset.col
        
        guard nextRow >= 0, nextRow < grid.count,
              nextCol >= 0, nextCol < grid[0].count else {
            return (false, -1, -1)
        }
        
        if grid[nextRow][nextCol] == .wall {
            return (true, nextRow, nextCol)
        }
        return (false, -1, -1)
    }
    
    /// Bounce the projectile off a wall by reflecting its direction
    mutating func bounce(wallRow: Int, wallCol: Int) -> Bool {
        guard bouncesRemaining > 0 else { return false }
        
        // Determine if we hit a horizontal or vertical wall
        let offset = direction.offset
        let hitVerticalWall = (wallCol != col) // Hit left/right wall
        let hitHorizontalWall = (wallRow != row) // Hit top/bottom wall
        
        // Reflect direction based on wall orientation
        if hitVerticalWall {
            // Bounce off vertical wall: left <-> right
            switch direction {
            case .left: direction = .right
            case .right: direction = .left
            default: break
            }
        }
        
        if hitHorizontalWall {
            // Bounce off horizontal wall: up <-> down
            switch direction {
            case .up: direction = .down
            case .down: direction = .up
            default: break
            }
        }
        
        bouncesRemaining -= 1
        return true
    }
}
