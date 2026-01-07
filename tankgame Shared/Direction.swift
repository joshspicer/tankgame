//
//  Direction.swift
//  tankgame Shared
//
//  Cardinal directions for tank movement
//

import Foundation

/// Cardinal directions for tank movement and shooting
enum Direction: String, Codable {
    case up, down, left, right
    
    /// Get the position offset for this direction
    var delta: (dx: Int, dy: Int) {
        switch self {
        case .up: return (0, -1)
        case .down: return (0, 1)
        case .left: return (-1, 0)
        case .right: return (1, 0)
        }
    }
    
    /// Rotate 90 degrees clockwise
    var rotatedClockwise: Direction {
        switch self {
        case .up: return .right
        case .right: return .down
        case .down: return .left
        case .left: return .up
        }
    }
}
