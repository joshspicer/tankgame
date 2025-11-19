//
//  GridGenerator.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

struct GridGenerator {
    static func generate(seed: UInt32) -> [[GridCell]] {
        var rng = SeededRandomNumberGenerator(seed: seed)
        var grid = Array(repeating: Array(repeating: GridCell.empty, count: 8), count: 8)
        
        // Keep spawn corners clear (top-left and bottom-right)
        let protectedCells: Set<String> = [
            "0,0", "0,1", "1,0", "1,1", // Top-left spawn area
            "6,6", "6,7", "7,6", "7,7", // Bottom-right spawn area
            "0,6", "0,7", "1,6", "1,7", // Top-right spawn area (player 2)
            "6,0", "6,1", "7,0", "7,1"  // Bottom-left spawn area (player 3)
        ]
        
        // Keep the border paths clear (row 0, row 7, col 0, col 7)
        let borderCells: Set<String> = {
            var cells = Set<String>()
            for col in 0..<8 {
                cells.insert("0,\(col)")
                cells.insert("7,\(col)")
            }
            for row in 0..<8 {
                cells.insert("\(row),0")
                cells.insert("\(row),7")
            }
            return cells
        }()
        
        // Choose generation strategy randomly
        let strategy = Int(rng.next() % 5)
        
        switch strategy {
        case 0:
            // Classic random walls with variable density
            generateRandomWalls(&grid, rng: &rng, protectedCells: protectedCells, borderCells: borderCells)
        case 1:
            // Maze-like corridors
            generateMazePattern(&grid, rng: &rng, protectedCells: protectedCells, borderCells: borderCells)
        case 2:
            // Room-based structure
            generateRoomStructure(&grid, rng: &rng, protectedCells: protectedCells, borderCells: borderCells)
        case 3:
            // Symmetric pattern (mirror horizontal or vertical)
            generateSymmetricPattern(&grid, rng: &rng, protectedCells: protectedCells, borderCells: borderCells)
        case 4:
            // Mixed terrain with hazards and breakable walls
            generateMixedTerrain(&grid, rng: &rng, protectedCells: protectedCells, borderCells: borderCells)
        default:
            generateRandomWalls(&grid, rng: &rng, protectedCells: protectedCells, borderCells: borderCells)
        }
        
        return grid
    }
    
    // Strategy 0: Classic random walls
    private static func generateRandomWalls(_ grid: inout [[GridCell]], rng: inout SeededRandomNumberGenerator, protectedCells: Set<String>, borderCells: Set<String>) {
        let wallDensity = 0.15 + (rng.nextDouble() * 0.15)
        
        for row in 0..<8 {
            for col in 0..<8 {
                let key = "\(row),\(col)"
                if !protectedCells.contains(key) && !borderCells.contains(key) && rng.nextDouble() < wallDensity {
                    grid[row][col] = .wall
                }
            }
        }
    }
    
    // Strategy 1: Maze-like corridors
    private static func generateMazePattern(_ grid: inout [[GridCell]], rng: inout SeededRandomNumberGenerator, protectedCells: Set<String>, borderCells: Set<String>) {
        // Create a grid pattern with walls
        for row in 0..<8 {
            for col in 0..<8 {
                let key = "\(row),\(col)"
                if protectedCells.contains(key) || borderCells.contains(key) {
                    continue
                }
                
                // Create alternating wall pattern
                if (row % 2 == 1) && (col % 2 == 1) {
                    grid[row][col] = .wall
                } else if (row % 2 == 1 || col % 2 == 1) && rng.nextDouble() < 0.3 {
                    grid[row][col] = rng.nextDouble() < 0.7 ? .wall : .breakableWall
                }
            }
        }
    }
    
    // Strategy 2: Room-based structure
    private static func generateRoomStructure(_ grid: inout [[GridCell]], rng: inout SeededRandomNumberGenerator, protectedCells: Set<String>, borderCells: Set<String>) {
        // Define room areas
        let rooms = [
            (2...3, 2...3), // Center-left room
            (2...3, 4...5), // Center-right room
            (4...5, 2...3), // Lower-left room
            (4...5, 4...5)  // Lower-right room
        ]
        
        // Fill rooms with occasional obstacles
        for room in rooms {
            for row in room.0 {
                for col in room.1 {
                    let key = "\(row),\(col)"
                    if !protectedCells.contains(key) && rng.nextDouble() < 0.15 {
                        grid[row][col] = rng.nextDouble() < 0.5 ? .breakableWall : .powerUp
                    }
                }
            }
        }
        
        // Add connecting corridors with some walls
        for row in 2...5 {
            for col in 2...5 {
                let key = "\(row),\(col)"
                if !protectedCells.contains(key) && rng.nextDouble() < 0.1 {
                    grid[row][col] = .wall
                }
            }
        }
    }
    
    // Strategy 3: Symmetric pattern
    private static func generateSymmetricPattern(_ grid: inout [[GridCell]], rng: inout SeededRandomNumberGenerator, protectedCells: Set<String>, borderCells: Set<String>) {
        let horizontalSymmetry = rng.nextDouble() < 0.5
        
        // Generate one half, mirror to other half
        for row in 0..<8 {
            for col in 0..<8 {
                let key = "\(row),\(col)"
                if protectedCells.contains(key) || borderCells.contains(key) {
                    continue
                }
                
                // Only generate for one half
                let shouldGenerate = horizontalSymmetry ? (col < 4) : (row < 4)
                
                if shouldGenerate {
                    if rng.nextDouble() < 0.2 {
                        let cellType: GridCell = {
                            let r = rng.nextDouble()
                            if r < 0.6 { return .wall }
                            else if r < 0.85 { return .breakableWall }
                            else { return .hazard }
                        }()
                        grid[row][col] = cellType
                        
                        // Mirror to other side
                        if horizontalSymmetry {
                            let mirrorCol = 7 - col
                            let mirrorKey = "\(row),\(mirrorCol)"
                            if !protectedCells.contains(mirrorKey) && !borderCells.contains(mirrorKey) {
                                grid[row][mirrorCol] = cellType
                            }
                        } else {
                            let mirrorRow = 7 - row
                            let mirrorKey = "\(mirrorRow),\(col)"
                            if !protectedCells.contains(mirrorKey) && !borderCells.contains(mirrorKey) {
                                grid[mirrorRow][col] = cellType
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Strategy 4: Mixed terrain with various cell types
    private static func generateMixedTerrain(_ grid: inout [[GridCell]], rng: inout SeededRandomNumberGenerator, protectedCells: Set<String>, borderCells: Set<String>) {
        // Create regions with different characteristics
        for row in 0..<8 {
            for col in 0..<8 {
                let key = "\(row),\(col)"
                if protectedCells.contains(key) || borderCells.contains(key) {
                    continue
                }
                
                // Determine region type based on position
                let centerDist = abs(row - 3.5) + abs(col - 3.5)
                
                if centerDist < 3 {
                    // Center area: more breakable walls and power-ups
                    let r = rng.nextDouble()
                    if r < 0.15 {
                        grid[row][col] = .breakableWall
                    } else if r < 0.20 {
                        grid[row][col] = .powerUp
                    }
                } else {
                    // Outer area: regular walls and hazards
                    let r = rng.nextDouble()
                    if r < 0.15 {
                        grid[row][col] = .wall
                    } else if r < 0.22 {
                        grid[row][col] = .hazard
                    } else if r < 0.27 {
                        grid[row][col] = .breakableWall
                    }
                }
            }
        }
    }
}

// Seeded random number generator for consistent grid generation
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt32
    
    init(seed: UInt32) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        // Linear congruential generator
        state = state &* 1664525 &+ 1013904223
        return UInt64(state)
    }
    
    mutating func nextDouble() -> Double {
        // Note: next() returns UInt64(state) where state is UInt32, so value is always <= UInt32.max
        let value = next()
        return Double(value) / Double(UInt32.max)
    }
}
