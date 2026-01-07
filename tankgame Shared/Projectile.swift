//
//  Projectile.swift
//  tankgame Shared
//
//  Projectile entity with movement logic
//

import Foundation

/// Represents a projectile (bullet) in the game
struct Projectile: Codable, Identifiable {
    let id: String
    var position: Position
    let direction: Direction
    let ownerId: String
    
    init(position: Position, direction: Direction, ownerId: String) {
        self.id = UUID().uuidString
        self.position = position
        self.direction = direction
        self.ownerId = ownerId
    }
    
    /// Move projectile one step forward
    mutating func advance() {
        let delta = direction.delta
        position = position.offset(dx: delta.dx, dy: delta.dy)
    }
    
    /// Check if projectile is out of bounds
    func isOutOfBounds(gridSize: Int) -> Bool {
        return !position.isValid(gridSize: gridSize)
    }
}
