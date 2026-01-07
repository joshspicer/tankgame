//
//  Position.swift
//  tankgame Shared
//
//  Core domain value object for grid positions
//

import Foundation

/// Immutable value object representing a position on the game grid
struct Position: Codable, Equatable, Hashable {
    let row: Int
    let col: Int
    
    /// Check if position is within grid bounds
    func isValid(rows: Int, cols: Int) -> Bool {
        return row >= 0 && row < rows && col >= 0 && col < cols
    }
    
    /// Calculate new position by moving in a direction
    func moved(in direction: Direction) -> Position {
        let offset = direction.offset
        return Position(row: row + offset.row, col: col + offset.col)
    }
    
    /// Calculate Manhattan distance to another position
    func distance(to other: Position) -> Int {
        return abs(row - other.row) + abs(col - other.col)
    }
}
