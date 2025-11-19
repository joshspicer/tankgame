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
    var health: Int
    var activePowerUps: [ActivePowerUp] = []
    var lastShotTime: TimeInterval = 0
    
    init(row: Int, col: Int, direction: Direction = .down) {
        self.row = row
        self.col = col
        self.direction = direction
        self.isAlive = true
        self.health = 3 // Start with 3 health points
    }
    
    /// Check if tank has a specific power-up active
    func hasActivePowerUp(_ type: PowerUpType, currentTime: TimeInterval) -> Bool {
        return activePowerUps.contains { $0.type == type && !$0.isExpired(currentTime: currentTime) }
    }
    
    /// Get fire rate cooldown based on active power-ups
    func getFireCooldown(currentTime: TimeInterval) -> TimeInterval {
        return hasActivePowerUp(.rapidFire, currentTime: currentTime) ? 0.2 : 0.5
    }
    
    /// Check if tank can shoot based on cooldown
    func canShoot(currentTime: TimeInterval) -> Bool {
        let cooldown = getFireCooldown(currentTime: currentTime)
        return currentTime - lastShotTime >= cooldown
    }
    
    /// Update last shot time
    mutating func recordShot(currentTime: TimeInterval) {
        lastShotTime = currentTime
    }
    
    /// Apply damage to tank
    mutating func takeDamage(currentTime: TimeInterval) {
        // Shield protects from damage
        if hasActivePowerUp(.shield, currentTime: currentTime) {
            return
        }
        
        health -= 1
        if health <= 0 {
            isAlive = false
        }
    }
    
    /// Clean up expired power-ups
    mutating func updatePowerUps(currentTime: TimeInterval) {
        activePowerUps.removeAll { $0.isExpired(currentTime: currentTime) }
    }
    
    /// Add a power-up effect
    mutating func applyPowerUp(_ type: PowerUpType, currentTime: TimeInterval) {
        switch type {
        case .health:
            health = min(health + 1, 3) // Max 3 health
        case .speedBoost, .shield, .rapidFire:
            if let duration = type.duration {
                let effect = ActivePowerUp(type: type, expirationTime: currentTime + duration)
                // Remove existing effect of same type and add new one
                activePowerUps.removeAll { $0.type == type }
                activePowerUps.append(effect)
            }
        }
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
        
        // Check if cell is passable
        guard grid[newRow][newCol].isPassable else {
            return false
        }
        
        row = newRow
        col = newCol
        self.direction = direction
        return true
    }
    
    func shoot(ownerIndex: Int? = nil) -> Projectile {
        let offset = direction.offset
        return Projectile(row: row + offset.row, col: col + offset.col, direction: direction, ownerIndex: ownerIndex)
    }
}
