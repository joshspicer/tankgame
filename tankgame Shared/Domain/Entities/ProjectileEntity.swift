//
//  ProjectileEntity.swift
//  tankgame Shared
//
//  Clean Architecture - Domain Layer
//

import Foundation

/// Projectile fired by a tank
struct ProjectileEntity: Equatable, Codable {
    let id: UUID
    let ownerID: PlayerID
    var position: Position
    let direction: Direction
    var isActive: Bool
    
    init(id: UUID = UUID(), ownerID: PlayerID, position: Position, direction: Direction) {
        self.id = id
        self.ownerID = ownerID
        self.position = position
        self.direction = direction
        self.isActive = true
    }
    
    /// Move projectile forward one cell
    mutating func advance() {
        position = position.moved(in: direction)
    }
    
    /// Deactivate projectile (hit something or out of bounds)
    mutating func deactivate() {
        isActive = false
    }
}
