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
}
