//
//  GameBoard.swift
//  tankgame Shared
//
//  Domain model for the game board
//

import Foundation

/// Represents the game board with grid cells
struct GameBoard: Codable {
    let rows: Int
    let cols: Int
    private(set) var cells: [[CellType]]
    
    /// Initialize with given dimensions
    init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
        self.cells = Array(repeating: Array(repeating: .empty, count: cols), count: rows)
    }
    
    /// Initialize with existing cell data
    init(cells: [[CellType]]) {
        self.rows = cells.count
        self.cols = cells.isEmpty ? 0 : cells[0].count
        self.cells = cells
    }
    
    /// Get cell type at position
    func cellType(at position: Position) -> CellType? {
        guard position.isValid(rows: rows, cols: cols) else { return nil }
        return cells[position.row][position.col]
    }
    
    /// Set cell type at position
    mutating func setCell(at position: Position, to type: CellType) {
        guard position.isValid(rows: rows, cols: cols) else { return }
        cells[position.row][position.col] = type
    }
    
    /// Check if position is empty and passable
    func isPassable(at position: Position) -> Bool {
        guard let cellType = cellType(at: position) else { return false }
        return cellType.isPassable
    }
    
    /// Check if position is within bounds
    func isValid(position: Position) -> Bool {
        return position.isValid(rows: rows, cols: cols)
    }
    
    /// Destroy a destructible wall at position
    mutating func destroyWallIfPossible(at position: Position) -> Bool {
        guard let cellType = cellType(at: position), cellType.isDestructible else {
            return false
        }
        setCell(at: position, to: .empty)
        return true
    }
}
