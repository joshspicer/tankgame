//
//  Player.swift
//  tankgame Shared
//
//  Core player entity
//

import Foundation

/// Represents a player in the game
struct Player: Codable {
    let id: String
    var position: Position
    var direction: Direction
    var isAlive: Bool
    var score: Int
    
    init(id: String, position: Position, direction: Direction = .down) {
        self.id = id
        self.position = position
        self.direction = direction
        self.isAlive = true
        self.score = 0
    }
    
    /// Attempt to move in the given direction
    mutating func move(_ direction: Direction, gridSize: Int, obstacles: Set<Position>) -> Bool {
        let delta = direction.delta
        let newPos = position.offset(dx: delta.dx, dy: delta.dy)
        
        // Check if valid move
        guard newPos.isValid(gridSize: gridSize) else { return false }
        guard !obstacles.contains(newPos) else { return false }
        
        // Update position and direction
        self.position = newPos
        self.direction = direction
        return true
    }
    
    /// Create a projectile from current position
    func shoot() -> Projectile {
        let delta = direction.delta
        let startPos = position.offset(dx: delta.dx, dy: delta.dy)
        return Projectile(position: startPos, direction: direction, ownerId: id)
    }
}
