//
//  CGPoint+Geometry.swift
//  Tank Game
//
//  Geometry utilities for CGPoint.
//

import CoreGraphics

extension CGPoint {
    /// Returns the Euclidean distance between this point and another point.
    func distance(to other: CGPoint) -> CGFloat {
        hypot(other.x - x, other.y - y)
    }
}
