//
//  ProjectileEntity.swift
//  tankgame Shared
//
//  Domain model for a projectile entity
//

import Foundation

/// Represents a projectile (bullet) in the game
struct ProjectileEntity: Codable, Equatable {
    let id: String
    let ownerIndex: Int // Player who fired this projectile
    var position: Position
    let direction: Direction
    var isActive: Bool
    
    init(id: String, ownerIndex: Int, position: Position, direction: Direction) {
        self.id = id
        self.ownerIndex = ownerIndex
        self.position = position
        self.direction = direction
        self.isActive = true
    }
    
    /// Move projectile one step in its direction
    mutating func advance() {
        position = position.moved(in: direction)
    }
}
