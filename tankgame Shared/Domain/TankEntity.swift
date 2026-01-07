//
//  TankEntity.swift
//  tankgame Shared
//
//  Domain model for a tank entity
//

import Foundation

/// Represents a tank in the game
struct TankEntity: Codable, Equatable {
    let id: String
    let playerIndex: Int
    var position: Position
    var direction: Direction
    var isAlive: Bool
    var canShoot: Bool // Cooldown management
    
    init(id: String, playerIndex: Int, position: Position, direction: Direction) {
        self.id = id
        self.playerIndex = playerIndex
        self.position = position
        self.direction = direction
        self.isAlive = true
        self.canShoot = true
    }
    
    /// Create a projectile from this tank's current state
    func createProjectile() -> ProjectileEntity {
        let projectilePosition = position.moved(in: direction)
        return ProjectileEntity(
            id: UUID().uuidString,
            ownerIndex: playerIndex,
            position: projectilePosition,
            direction: direction
        )
    }
}
