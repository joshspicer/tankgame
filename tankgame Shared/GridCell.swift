//
//  GridCell.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

enum GridCell: Int, Codable {
    case empty = 0
    case wall = 1
    case breakableWall = 2  // Walls that can be destroyed by projectiles
    case hazard = 3         // Dangerous terrain (water/lava) - damages tanks
    case powerUp = 4        // Power-up locations (could enhance tank abilities)
    
    var isBlocking: Bool {
        switch self {
        case .wall, .breakableWall:
            return true
        case .empty, .hazard, .powerUp:
            return false
        }
    }
    
    var isDestructible: Bool {
        return self == .breakableWall
    }
    
    var isDangerous: Bool {
        return self == .hazard
    }
}
