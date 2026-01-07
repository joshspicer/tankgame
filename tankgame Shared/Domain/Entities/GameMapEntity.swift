//
//  GameMapEntity.swift
//  tankgame Shared
//
//  Clean Architecture - Domain Layer
//

import Foundation

/// Game map with grid-based layout
struct GameMapEntity: Equatable, Codable {
    let id: UUID
    let size: Int
    var grid: [[GridCellType]]
    let seed: UInt32
    
    init(id: UUID = UUID(), size: Int, seed: UInt32) {
        self.id = id
        self.size = size
        self.seed = seed
        self.grid = Array(repeating: Array(repeating: .empty, count: size), count: size)
    }
    
    /// Get cell type at position
    func cellType(at position: Position) -> GridCellType? {
        guard position.isValid(gridSize: size) else { return nil }
        return grid[position.row][position.col]
    }
    
    /// Set cell type at position
    mutating func setCellType(_ type: GridCellType, at position: Position) {
        guard position.isValid(gridSize: size) else { return }
        grid[position.row][position.col] = type
    }
    
    /// Check if position is passable
    func isPassable(at position: Position) -> Bool {
        guard let cellType = cellType(at: position) else { return false }
        return cellType.isPassable
    }
    
    /// Check if position blocks projectiles
    func blocksProjectiles(at position: Position) -> Bool {
        guard let cellType = cellType(at: position) else { return true }
        return cellType.blocksProjectiles
    }
}
