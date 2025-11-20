//
//  PowerUp.swift
//  tankgame Shared
//
//  Created by agent on 11/20/25.
//

import Foundation

enum PowerUpType: String, Codable {
    case speedBoost     // Faster movement
    case rapidFire      // Faster shooting
    case shield         // Protection from one hit
    
    var duration: TimeInterval {
        switch self {
        case .speedBoost: return 8.0
        case .rapidFire: return 8.0
        case .shield: return 10.0
        }
    }
    
    var color: (r: CGFloat, g: CGFloat, b: CGFloat) {
        switch self {
        case .speedBoost: return (0.2, 0.8, 1.0) // Cyan
        case .rapidFire: return (1.0, 0.5, 0.0)  // Orange
        case .shield: return (0.0, 1.0, 0.5)      // Green
        }
    }
}

struct PowerUp: Codable {
    var row: Int
    var col: Int
    var type: PowerUpType
    var isActive: Bool
    
    init(row: Int, col: Int, type: PowerUpType) {
        self.row = row
        self.col = col
        self.type = type
        self.isActive = true
    }
    
    static func randomType() -> PowerUpType {
        let types: [PowerUpType] = [.speedBoost, .rapidFire, .shield]
        return types.randomElement() ?? .speedBoost
    }
}

struct ActivePowerUp {
    let type: PowerUpType
    let expiresAt: TimeInterval
}
