//
//  GridCell.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Represents the type of a single cell in the game grid
enum GridCell: Int, Codable {
    /// An empty cell that tanks can move through and projectiles can pass through
    case empty = 0
    /// A wall cell that blocks tank movement and stops projectiles
    case wall = 1
}
