//
//  Tank.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

struct Tank: Codable {
    var row: Int
    var col: Int
    var direction: Direction
    var isAlive: Bool
    
    init(row: Int, col: Int, direction: Direction = .down) {
        self.row = row
        self.col = col
        self.direction = direction
        self.isAlive = true
    }
    
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
    
    func shoot() -> Projectile {
        let offset = direction.offset
        return Projectile(row: row + offset.row, col: col + offset.col, direction: direction)
    }
}
