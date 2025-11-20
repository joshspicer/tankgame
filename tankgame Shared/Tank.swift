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
    var activeEffects: [PowerUpEffect] = []
    var lastShootTime: TimeInterval = 0
    
    init(row: Int, col: Int, direction: Direction = .down) {
        self.row = row
        self.col = col
        self.direction = direction
        self.isAlive = true
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
        
        // Check if cell is empty
        guard grid[newRow][newCol] == .empty else {
            return false
        }
        
        row = newRow
        col = newCol
        self.direction = direction
        return true
    }
    
    func shoot() -> Projectile {
        let offset = direction.offset
        return Projectile(row: row + offset.row, col: col + offset.col, direction: direction)
    }
    
    /// Apply a power-up effect to this tank
    mutating func applyPowerUp(_ powerUp: PowerUp, currentTime: TimeInterval) {
        switch powerUp.type {
        case .health:
            isAlive = true
        case .speed:
            activeEffects.append(PowerUpEffect(type: .speed, expirationTime: currentTime + 10.0))
        case .shield:
            activeEffects.append(PowerUpEffect(type: .shield, expirationTime: currentTime + 8.0))
        case .rapidFire:
            activeEffects.append(PowerUpEffect(type: .rapidFire, expirationTime: currentTime + 12.0))
        }
    }
    
    /// Remove expired power-up effects
    mutating func updateEffects(currentTime: TimeInterval) {
        activeEffects.removeAll { $0.isExpired(currentTime: currentTime) }
    }
    
    /// Check if tank has a specific power-up effect active
    func hasEffect(_ type: PowerUpType) -> Bool {
        return activeEffects.contains { $0.type == type }
    }
    
    /// Check if tank can shoot based on rapid fire effect
    func canShoot(currentTime: TimeInterval) -> Bool {
        let cooldown = hasEffect(.rapidFire) ? 0.2 : 0.5
        return currentTime - lastShootTime >= cooldown
    }
}
