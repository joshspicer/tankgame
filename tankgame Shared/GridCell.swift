//
//  GridCell.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

enum GridCell: Int, Codable {
    case empty = 0
    case wall = 1  // Indestructible wall (steel/concrete)
    case destructibleWall = 2  // Destructible wall (brick)
}
