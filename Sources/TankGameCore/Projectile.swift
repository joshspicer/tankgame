//
//  Projectile.swift
//  TankGameCore
//
//  Projectile struct for tank game
//

import Foundation

public struct Projectile: Codable {
    public var row: Int
    public var col: Int
    public var direction: Direction
    
    public init(row: Int, col: Int, direction: Direction) {
        self.row = row
        self.col = col
        self.direction = direction
    }
    
    public mutating func advance() {
        let offset = direction.offset
        row += offset.row
        col += offset.col
    }
    
    public func isOutOfBounds(gridSize: Int) -> Bool {
        return row < 0 || row >= gridSize || col < 0 || col >= gridSize
    }
    
    public func hits(grid: [[GridCell]]) -> Bool {
        // Guard against empty grid
        guard !grid.isEmpty, !grid[0].isEmpty else {
            return false
        }
        guard row >= 0, row < grid.count,
              col >= 0, col < grid[0].count else {
            return false
        }
        return grid[row][col] == .wall
    }
    
    public func hits(tank: Tank) -> Bool {
        return tank.isAlive && row == tank.row && col == tank.col
    }
}
