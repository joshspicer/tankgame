//
//  Dinosaur.swift
//  tankgame Shared
//
//  AI-controlled dinosaur entity that roams the grid as a hazard
//

import Foundation

struct Dinosaur: Codable {
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
    
    /// Move the dinosaur in the specified direction if the cell is empty
    mutating func move(in direction: Direction, grid: [[GridCell]], tanks: [Tank]) -> Bool {
        let offset = direction.offset
        let newRow = row + offset.row
        let newCol = col + offset.col
        
        // Check bounds
        guard newRow >= 0, newRow < grid.count,
              newCol >= 0, newCol < grid[0].count else {
            return false
        }
        
        // Check if cell is empty (not a wall)
        guard grid[newRow][newCol] == .empty else {
            return false
        }
        
        // Check if cell is not occupied by a tank
        for tank in tanks where tank.isAlive {
            if tank.row == newRow && tank.col == newCol {
                return false
            }
        }
        
        row = newRow
        col = newCol
        self.direction = direction
        return true
    }
    
    /// Check if the dinosaur collides with a tank
    func collidesWith(tank: Tank) -> Bool {
        return tank.isAlive && row == tank.row && col == tank.col
    }
    
    /// Pick a random direction for AI movement
    static func randomDirection(using rng: inout SeededRandomNumberGenerator) -> Direction {
        // Only use cardinal directions (not diagonal) for simpler movement
        let cardinalDirections: [Direction] = [.up, .down, .left, .right]
        let index = Int(rng.next() % UInt64(cardinalDirections.count))
        return cardinalDirections[index]
    }
}
