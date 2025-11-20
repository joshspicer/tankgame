//
//  PowerUp.swift
//  tankgame Shared
//
//  Power-up entity for enhancing tank abilities
//

import Foundation

enum PowerUpType: String, Codable {
    case health      // Restores tank if dead or provides extra life
    case speed       // Increases movement speed temporarily
    case shield      // Provides temporary invulnerability
    case rapidFire   // Allows faster shooting temporarily
}

struct PowerUp: Codable {
    var row: Int
    var col: Int
    var type: PowerUpType
    var isActive: Bool = true
    
    init(row: Int, col: Int, type: PowerUpType) {
        self.row = row
        self.col = col
        self.type = type
    }
    
    /// Check if a tank is at this power-up's position
    func isCollectedBy(tank: Tank) -> Bool {
        return isActive && tank.isAlive && tank.row == row && tank.col == col
    }
}

/// Power-up effects applied to a tank
struct PowerUpEffect: Codable {
    var type: PowerUpType
    var expirationTime: TimeInterval
    
    func isExpired(currentTime: TimeInterval) -> Bool {
        return currentTime >= expirationTime
    }
}
