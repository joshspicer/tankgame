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
    case destructibleWall = 2
    
    var isPassable: Bool {
        return self == .empty
    }
    
    var canBeDestroyed: Bool {
        return self == .destructibleWall
    }
}
