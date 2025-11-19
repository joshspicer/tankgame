//
//  PowerUp.swift
//  tankgame Shared
//
//  Created by jospicer on 11/19/25.
//

import Foundation

enum PowerUpType: String, Codable {
    case health
    case rapidFire
    case speedBoost
    
    var duration: TimeInterval {
        switch self {
        case .health:
            return 0 // Instant effect
        case .rapidFire:
            return 5.0
        case .speedBoost:
            return 5.0
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
    
    func isCollectedBy(tank: Tank) -> Bool {
        return isActive && tank.isAlive && tank.row == row && tank.col == col
    }
}
