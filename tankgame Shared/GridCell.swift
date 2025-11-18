//
//  GridCell.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Represents the type of cell on the game grid
enum GridCell: Int, Codable {
    /// Empty cell that tanks can move through and projectiles can pass
    case empty = 0
    
    /// Wall cell that blocks tank movement and destroys projectiles
    case wall = 1
}
