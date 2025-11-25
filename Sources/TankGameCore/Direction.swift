//
//  Direction.swift
//  TankGameCore
//
//  Direction enum for tank and projectile movement
//

import Foundation

public enum Direction: Int, Codable, CaseIterable {
    case up = 0
    case right = 1
    case down = 2
    case left = 3
    case upRight = 4
    case downRight = 5
    case downLeft = 6
    case upLeft = 7
    
    public var angle: Double {
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
    
    public var offset: (row: Int, col: Int) {
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
    public var isDiagonal: Bool {
        switch self {
        case .upRight, .downRight, .downLeft, .upLeft:
            return true
        case .up, .down, .left, .right:
            return false
        }
    }
}
