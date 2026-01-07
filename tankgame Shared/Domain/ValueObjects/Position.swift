//
//  Position.swift
//  tankgame Shared
//
//  Clean Architecture - Domain Layer
//

import Foundation

/// Immutable value object representing a position on the game grid
struct Position: Equatable, Hashable, Codable {
    let row: Int
    let col: Int
    
    init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
    
    /// Check if position is within grid bounds
    func isValid(gridSize: Int) -> Bool {
        return row >= 0 && row < gridSize && col >= 0 && col < gridSize
    }
    
    /// Move position in a direction
    func moved(in direction: Direction) -> Position {
        switch direction {
        case .up:
            return Position(row: row - 1, col: col)
        case .down:
            return Position(row: row + 1, col: col)
        case .left:
            return Position(row: row, col: col - 1)
        case .right:
            return Position(row: row, col: col + 1)
        }
    }
    
    /// Calculate Manhattan distance to another position
    func distance(to other: Position) -> Int {
        return abs(row - other.row) + abs(col - other.col)
    }
    
    /// Check if two positions are adjacent
    func isAdjacent(to other: Position) -> Bool {
        return distance(to: other) == 1
    }
}
