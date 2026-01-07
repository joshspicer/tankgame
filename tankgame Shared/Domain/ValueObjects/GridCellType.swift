//
//  GridCellType.swift
//  tankgame Shared
//
//  Clean Architecture - Domain Layer
//

import Foundation

/// Type of cell in the game grid
enum GridCellType: String, Codable {
    case empty
    case wall
    
    /// Check if entities can pass through this cell
    var isPassable: Bool {
        switch self {
        case .empty:
            return true
        case .wall:
            return false
        }
    }
    
    /// Check if projectiles are blocked by this cell
    var blocksProjectiles: Bool {
        switch self {
        case .empty:
            return false
        case .wall:
            return true
        }
    }
}
