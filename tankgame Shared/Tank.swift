//
//  Tank.swift
//  Tank Game
//
//  Simple tank entity with position, direction, and movement.
//

import Foundation

/// Cardinal directions for tank movement
enum Direction: Int, Codable, CaseIterable {
    case up = 0, right, down, left
    
    var offset: (row: Int, col: Int) {
        switch self {
        case .up:    return (-1, 0)
        case .right: return (0, 1)
        case .down:  return (1, 0)
        case .left:  return (0, -1)
        }
    }
    
    var rotation: Double {
        // SpriteKit: positive rotation is counter-clockwise
        // Turret is drawn pointing up (+Y), so:
        switch self {
        case .up:    return 0
        case .right: return -.pi / 2   // 90° clockwise
        case .down:  return .pi        // 180°
        case .left:  return .pi / 2    // 90° counter-clockwise
        }
    }
}

/// Tank entity representing a player in the game
struct Tank: Codable, Equatable {
    var row: Int
    var col: Int
    var direction: Direction
    var isAlive: Bool = true
    var isAI: Bool = false
    
    /// Attempt to move in a direction, returns true if successful
    mutating func move(_ dir: Direction, on grid: [[Bool]]) -> Bool {
        let newRow = row + dir.offset.row
        let newCol = col + dir.offset.col
        
        // Check bounds
        guard newRow >= 0, newRow < grid.count,
              newCol >= 0, newCol < grid[0].count else {
            direction = dir // Update facing even if can't move
            return false
        }
        
        // Check for wall (true = wall)
        guard !grid[newRow][newCol] else {
            direction = dir
            return false
        }
        
        row = newRow
        col = newCol
        direction = dir
        return true
    }
    
    /// Create a projectile fired from this tank
    func shoot() -> Projectile {
        Projectile(
            row: row + direction.offset.row,
            col: col + direction.offset.col,
            direction: direction,
            ownerId: "" // Set by caller
        )
    }
}
