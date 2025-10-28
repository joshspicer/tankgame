//
//  Direction.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

enum Direction: Int, Codable, CaseIterable {
    case up = 0
    case right = 1
    case down = 2
    case left = 3
    
    var angle: Double {
        switch self {
        case .up: return 0
        case .right: return .pi / 2
        case .down: return .pi
        case .left: return -.pi / 2
        }
    }
    
    var offset: (row: Int, col: Int) {
        switch self {
        case .up: return (-1, 0)
        case .down: return (1, 0)
        case .left: return (0, -1)
        case .right: return (0, 1)
        }
    }
}
