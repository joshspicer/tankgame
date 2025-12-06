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
    case upRight = 4
    case downRight = 5
    case downLeft = 6
    case upLeft = 7
    
    var angle: Double {
        switch self {
        case .up: return 0
        case .right: return .pi / 2
        case .down: return .pi
        case .left: return -.pi / 2
        case .upRight: return .pi / 4
        case .downRight: return 3 * .pi / 4
        case .downLeft: return -.pi * 3 / 4
        case .upLeft: return -.pi / 4
        }
    }
    
    var offset: (row: Int, col: Int) {
        switch self {
        case .up: return (-1, 0)
        case .down: return (1, 0)
        case .left: return (0, -1)
        case .right: return (0, 1)
        case .upRight: return (-1, 1)
        case .downRight: return (1, 1)
        case .downLeft: return (1, -1)
        case .upLeft: return (-1, -1)
        }
    }
    
    /// Whether this is a diagonal direction
    var isDiagonal: Bool {
        switch self {
        case .upRight, .downRight, .downLeft, .upLeft:
            return true
        case .up, .down, .left, .right:
            return false
        }
    }
    
    /// The opposite direction
    var opposite: Direction {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        case .upRight: return .downLeft
        case .downRight: return .upLeft
        case .downLeft: return .upRight
        case .upLeft: return .downRight
        }
    }
    
    /// All cardinal (non-diagonal) directions
    static let cardinalDirections: [Direction] = [.up, .down, .left, .right]
}
