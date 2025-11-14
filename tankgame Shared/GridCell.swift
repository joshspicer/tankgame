//
//  GridCell.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Types of cells in the game grid
enum GridCell: Int, Codable {
    case empty = 0
    case wall = 1
}
