//
//  Direction.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Cardinal directions for tank and projectile movement
///
/// Each direction has an associated angle for rendering and a grid offset for movement calculations.
enum Direction: Int, Codable, CaseIterable {
    case up = 0
    case right = 1
    case down = 2
    case left = 3
    
    /// The rotation angle in radians for rendering (0 = pointing up)
    var angle: Double {
        switch self {
        case .up: return 0
        case .right: return .pi / 2
        case .down: return .pi
        case .left: return -.pi / 2
        }
    }
    
    /// The grid offset for moving one cell in this direction
    /// - Returns: A tuple of (row offset, column offset) where negative row is up and negative column is left
    var offset: (row: Int, col: Int) {
        switch self {
        case .up: return (-1, 0)
        case .down: return (1, 0)
        case .left: return (0, -1)
        case .right: return (0, 1)
        }
    }
}
