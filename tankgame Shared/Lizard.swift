//
//  Lizard.swift
//  tankgame Shared
//
//  Represents a lizard creature that roams the game field as an AI-controlled entity
//

import Foundation

/// A lizard creature that wanders the game field
/// Lizards move randomly and can be destroyed by projectiles
struct Lizard: Codable {
    var row: Int
    var col: Int
    var direction: Direction
    var isAlive: Bool
    var moveCounter: Int = 0
    
    /// The interval between lizard movements (in update ticks)
    static let moveInterval: Int = 15
    
    init(row: Int, col: Int, direction: Direction = .right) {
        self.row = row
        self.col = col
        self.direction = direction
        self.isAlive = true
    }
    
    /// Attempt to move the lizard in its current direction
    /// - Parameter grid: The game grid to check for obstacles
    /// - Returns: True if the move was successful, false if blocked
    mutating func move(grid: [[GridCell]]) -> Bool {
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
        return true
    }
    
    /// Update the lizard's AI behavior
    /// - Parameter grid: The game grid for movement checks
    /// - Returns: True if the lizard moved this update
    mutating func update(grid: [[GridCell]]) -> Bool {
        moveCounter += 1
        
        guard moveCounter >= Lizard.moveInterval else {
            return false
        }
        
        moveCounter = 0
        
        // Try to move in current direction
        if move(grid: grid) {
            return true
        }
        
        // If blocked, try a random new direction
        let directions: [Direction] = [.up, .down, .left, .right]
        let shuffledDirections = directions.shuffled()
        
        for newDirection in shuffledDirections {
            direction = newDirection
            if move(grid: grid) {
                return true
            }
        }
        
        return false
    }
    
    /// Change direction randomly
    mutating func changeDirection() {
        let directions: [Direction] = [.up, .down, .left, .right]
        direction = directions.randomElement() ?? .right
    }
}
