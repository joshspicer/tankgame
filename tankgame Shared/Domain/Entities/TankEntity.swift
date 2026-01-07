//
//  TankEntity.swift
//  tankgame Shared
//
//  Clean Architecture - Domain Layer
//

import Foundation

/// Tank entity representing a player's tank in the game
struct TankEntity: Equatable, Codable {
    let id: UUID
    let playerID: PlayerID
    var position: Position
    var direction: Direction
    var health: Int
    var isAlive: Bool
    
    // Game mechanics
    let maxHealth: Int = 1
    var lastFireTime: TimeInterval = 0
    let fireRateDelay: TimeInterval = 0.5 // Minimum time between shots
    
    init(id: UUID = UUID(), playerID: PlayerID, position: Position, direction: Direction) {
        self.id = id
        self.playerID = playerID
        self.position = position
        self.direction = direction
        self.health = maxHealth
        self.isAlive = true
    }
    
    /// Check if tank can fire based on fire rate
    func canFire(currentTime: TimeInterval) -> Bool {
        return isAlive && (currentTime - lastFireTime) >= fireRateDelay
    }
    
    /// Update last fire time
    mutating func didFire(at time: TimeInterval) {
        lastFireTime = time
    }
    
    /// Take damage
    mutating func takeDamage(_ amount: Int = 1) {
        health = max(0, health - amount)
        if health == 0 {
            isAlive = false
        }
    }
    
    /// Reset tank to spawn position
    mutating func reset(at position: Position, direction: Direction) {
        self.position = position
        self.direction = direction
        self.health = maxHealth
        self.isAlive = true
        self.lastFireTime = 0
    }
    
    /// Move tank in current direction
    mutating func moveForward() {
        position = position.moved(in: direction)
    }
    
    /// Change tank direction
    mutating func turn(to newDirection: Direction) {
        direction = newDirection
    }
}
