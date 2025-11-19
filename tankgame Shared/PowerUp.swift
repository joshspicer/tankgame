//
//  PowerUp.swift
//  tankgame Shared
//
//  Power-ups that can be collected by tanks
//

import Foundation

enum PowerUpType: Int, Codable, CaseIterable {
    case health = 0      // Restores tank health
    case speedBoost = 1  // Temporarily increases movement speed
    case shield = 2      // Temporary invulnerability
    case rapidFire = 3   // Decreased cooldown between shots
    
    var duration: TimeInterval? {
        switch self {
        case .health: return nil // Instant effect
        case .speedBoost: return 8.0
        case .shield: return 6.0
        case .rapidFire: return 10.0
        }
    }
    
    var emoji: String {
        switch self {
        case .health: return "❤️"
        case .speedBoost: return "⚡"
        case .shield: return "🛡️"
        case .rapidFire: return "🔥"
        }
    }
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
}

/// Active power-up effects on a tank
struct ActivePowerUp: Codable {
    let type: PowerUpType
    var expirationTime: TimeInterval
    
    func isExpired(currentTime: TimeInterval) -> Bool {
        return currentTime >= expirationTime
    }
}
