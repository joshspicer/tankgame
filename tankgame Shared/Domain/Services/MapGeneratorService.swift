//
//  MapGeneratorService.swift
//  tankgame Shared
//
//  Clean Architecture - Domain Layer
//

import Foundation

/// Service for generating procedural game maps
struct MapGeneratorService {
    
    /// Generate a random map with walls
    func generateMap(size: Int, seed: UInt32, wallDensity: Double = 0.15) -> GameMapEntity {
        var map = GameMapEntity(size: size, seed: seed)
        
        // Seed the random number generator
        var generator = SeededRandomGenerator(seed: seed)
        
        // Define spawn positions (corners) - keep these clear
        let spawnPositions = [
            Position(row: 0, col: 0),
            Position(row: size - 1, col: size - 1),
            Position(row: 0, col: size - 1),
            Position(row: size - 1, col: 0)
        ]
        
        // Add random walls
        for row in 0..<size {
            for col in 0..<size {
                let position = Position(row: row, col: col)
                
                // Skip spawn positions and adjacent cells
                var nearSpawn = false
                for spawn in spawnPositions {
                    if position.distance(to: spawn) <= 1 {
                        nearSpawn = true
                        break
                    }
                }
                
                if !nearSpawn && generator.nextDouble() < wallDensity {
                    map.setCellType(.wall, at: position)
                }
            }
        }
        
        // Add border walls
        addBorderWalls(to: &map)
        
        return map
    }
    
    /// Add walls around the map border
    private func addBorderWalls(to map: inout GameMapEntity) {
        for i in 0..<map.size {
            // Top and bottom borders
            map.setCellType(.wall, at: Position(row: 0, col: i))
            map.setCellType(.wall, at: Position(row: map.size - 1, col: i))
            
            // Left and right borders
            map.setCellType(.wall, at: Position(row: i, col: 0))
            map.setCellType(.wall, at: Position(row: i, col: map.size - 1))
        }
    }
}

/// Seeded random number generator for reproducible map generation
struct SeededRandomGenerator {
    private var state: UInt32
    
    init(seed: UInt32) {
        self.state = seed
    }
    
    /// Generate next random UInt32
    mutating func next() -> UInt32 {
        // Simple Linear Congruential Generator
        state = (1103515245 &* state &+ 12345) & 0x7FFFFFFF
        return state
    }
    
    /// Generate random double between 0 and 1
    mutating func nextDouble() -> Double {
        return Double(next()) / Double(UInt32.max)
    }
    
    /// Generate random int in range
    mutating func nextInt(max: Int) -> Int {
        return Int(next() % UInt32(max))
    }
}
