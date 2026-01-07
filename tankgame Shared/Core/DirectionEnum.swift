//
//  DirectionEnum.swift
//  tankgame Shared
//
//  Core domain enum for movement directions
//

import Foundation

/// Cardinal directions for tank movement and projectiles
enum Direction: String, Codable, CaseIterable {
    case up
    case down
    case left
    case right
    
    /// Row and column offset for this direction
    var offset: (row: Int, col: Int) {
        switch self {
        case .up: return (-1, 0)
        case .down: return (1, 0)
        case .left: return (0, -1)
        case .right: return (0, 1)
        }
    }
    
    /// Opposite direction
    var opposite: Direction {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }
    
    /// Angle in radians for rendering (0 = right, π/2 = down)
    var angle: Double {
        switch self {
        case .up: return -.pi / 2
        case .down: return .pi / 2
        case .left: return .pi
        case .right: return 0
        }
    }
}
