//
//  CellType.swift
//  tankgame Shared
//
//  Domain model for grid cell types
//

import Foundation

/// Types of cells on the game board
enum CellType: String, Codable {
    case empty
    case wall
    case destructibleWall
    
    /// Whether entities can move through this cell
    var isPassable: Bool {
        return self == .empty
    }
    
    /// Whether projectiles can pass through this cell
    var blocksProjectiles: Bool {
        return self == .wall || self == .destructibleWall
    }
    
    /// Whether this cell can be destroyed by projectiles
    var isDestructible: Bool {
        return self == .destructibleWall
    }
}
