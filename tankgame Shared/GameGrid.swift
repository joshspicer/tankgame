//
//  GameGrid.swift
//  tankgame Shared
//
//  Game arena with walls and obstacles
//

import Foundation

/// Represents the game arena
struct GameGrid: Codable {
    let size: Int
    var walls: Set<Position>
    
    init(size: Int) {
        self.size = size
        self.walls = Set()
        generateWalls()
    }
    
    /// Generate random wall layout
    private mutating func generateWalls() {
        // Add border walls
        for i in 0..<size {
            walls.insert(Position(i, 0))
            walls.insert(Position(i, size - 1))
            walls.insert(Position(0, i))
            walls.insert(Position(size - 1, i))
        }
        
        // Add some interior walls for variety
        let interiorWallCount = size * 2
        var attempts = 0
        while walls.count < size * 4 + interiorWallCount && attempts < 100 {
            let x = Int.random(in: 2..<size-2)
            let y = Int.random(in: 2..<size-2)
            let pos = Position(x, y)
            
            // Don't place walls on spawn positions
            if !isSpawnPosition(pos) {
                walls.insert(pos)
            }
            attempts += 1
        }
    }
    
    /// Check if a position is a spawn position (corners)
    private func isSpawnPosition(_ pos: Position) -> Bool {
        let spawnPositions = [
            Position(1, 1), Position(size-2, size-2),
            Position(1, size-2), Position(size-2, 1),
            Position(size/2, 1), Position(size/2, size-2)
        ]
        return spawnPositions.contains(pos)
    }
    
    /// Check if position has a wall
    func hasWall(at position: Position) -> Bool {
        return walls.contains(position)
    }
}
