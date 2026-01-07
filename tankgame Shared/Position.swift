//
//  Position.swift
//  tankgame Shared
//
//  Core data structure for grid-based positioning
//

import Foundation

/// Represents a position on the game grid
struct Position: Codable, Equatable {
    var x: Int
    var y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    /// Returns a new position offset by the given delta
    func offset(dx: Int, dy: Int) -> Position {
        return Position(x + dx, y + dy)
    }
    
    /// Check if position is within grid bounds
    func isValid(gridSize: Int) -> Bool {
        return x >= 0 && x < gridSize && y >= 0 && y < gridSize
    }
}
