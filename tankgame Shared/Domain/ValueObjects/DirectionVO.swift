//
//  DirectionVO.swift
//  tankgame Shared
//
//  Clean Architecture - Domain Layer
//

import Foundation

/// Cardinal direction for movement and orientation
enum Direction: String, Codable, CaseIterable {
    case up
    case down
    case left
    case right
    
    /// Get the opposite direction
    var opposite: Direction {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }
    
    /// Get angle in radians for visual representation
    var angleInRadians: CGFloat {
        switch self {
        case .up: return .pi / 2
        case .down: return -.pi / 2
        case .left: return .pi
        case .right: return 0
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
    
    /// Rotate 90 degrees counter-clockwise
    var rotatedCounterClockwise: Direction {
        switch self {
        case .up: return .left
        case .left: return .down
        case .down: return .right
        case .right: return .up
        }
    }
}

import CoreGraphics
