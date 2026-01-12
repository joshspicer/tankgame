//
//  RenderingUtilities.swift
//  tankgame Shared
//
//  Shared rendering utilities to avoid code duplication
//

import SpriteKit

/// Protocol providing common rendering utilities
protocol GridPositionConvertible {
    var tileSize: CGFloat { get }
    var gridSize: Int { get }
}

extension GridPositionConvertible {
    /// Convert grid coordinates to scene position
    func gridPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * tileSize + tileSize / 2,
            y: CGFloat(gridSize - 1 - row) * tileSize + tileSize / 2
        )
    }
}

/// Rotation utilities
enum RenderingUtilities {
    /// Calculate the shortest rotation difference between two angles
    static func shortestRotationDifference(from: CGFloat, to: CGFloat) -> CGFloat {
        var diff = to - from
        while diff > .pi { diff -= 2 * .pi }
        while diff < -.pi { diff += 2 * .pi }
        return diff
    }
}
