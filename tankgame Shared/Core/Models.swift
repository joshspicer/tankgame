//
//  Models.swift
//  tankgame Shared
//
//  Core data models for tank game

import Foundation

// MARK: - Direction
enum Direction: String, Codable, CaseIterable {
    case up, down, left, right
    
    var offset: (row: Int, col: Int) {
        switch self {
        case .up: return (-1, 0)
        case .down: return (1, 0)
        case .left: return (0, -1)
        case .right: return (0, 1)
        }
    }
}

// MARK: - Tank
struct Tank: Codable {
    var position: Position
    var direction: Direction
    var isAlive: Bool = true
    
    struct Position: Codable, Equatable {
        var row: Int
        var col: Int
    }
    
    init(row: Int, col: Int, direction: Direction = .down) {
        self.position = Position(row: row, col: col)
        self.direction = direction
    }
    
    mutating func move(_ direction: Direction, in grid: [[Bool]]) -> Bool {
        let offset = direction.offset
        let newPos = Position(row: position.row + offset.row, col: position.col + offset.col)
        
        guard newPos.row >= 0, newPos.row < grid.count,
              newPos.col >= 0, newPos.col < grid[0].count,
              !grid[newPos.row][newPos.col] else { return false }
        
        position = newPos
        self.direction = direction
        return true
    }
    
    func shoot() -> Projectile {
        let offset = direction.offset
        return Projectile(
            position: Position(row: position.row + offset.row, col: position.col + offset.col),
            direction: direction
        )
    }
}

// MARK: - Projectile
struct Projectile: Codable {
    var position: Tank.Position
    var direction: Direction
    
    mutating func advance() {
        let offset = direction.offset
        position.row += offset.row
        position.col += offset.col
    }
    
    func isOutOfBounds(gridSize: Int) -> Bool {
        position.row < 0 || position.row >= gridSize || position.col < 0 || position.col >= gridSize
    }
}

// MARK: - Game State
struct GameState: Codable {
    var tanks: [Tank]
    var projectiles: [Projectile]
    var grid: [[Bool]] // true = wall, false = empty
    var scores: [Int]
    var localPlayerIndex: Int
    
    static func generate(seed: UInt32, playerCount: Int, localIndex: Int) -> GameState {
        // Generate grid with seed
        var rng = SeededRandom(seed: seed)
        var grid = Array(repeating: Array(repeating: false, count: 8), count: 8)
        
        // Add random walls (20% density)
        for row in 1..<7 {
            for col in 1..<7 {
                if rng.next() % 100 < 20 {
                    grid[row][col] = true
                }
            }
        }
        
        // Spawn positions
        let spawns: [(Int, Int, Direction)] = [
            (0, 0, .down), (7, 7, .up), (0, 7, .down), (7, 0, .up), (3, 0, .down), (4, 7, .up)
        ]
        let tanks = (0..<playerCount).map { Tank(row: spawns[$0].0, col: spawns[$0].1, direction: spawns[$0].2) }
        
        return GameState(
            tanks: tanks,
            projectiles: [],
            grid: grid,
            scores: Array(repeating: 0, count: playerCount),
            localPlayerIndex: localIndex
        )
    }
    
    mutating func update() {
        // Update projectiles
        var active: [Projectile] = []
        for var proj in projectiles {
            proj.advance()
            
            guard !proj.isOutOfBounds(gridSize: 8),
                  !grid[proj.position.row][proj.position.col] else { continue }
            
            // Check tank hits
            var hit = false
            for i in tanks.indices {
                if tanks[i].isAlive && tanks[i].position == proj.position {
                    tanks[i].isAlive = false
                    hit = true
                    break
                }
            }
            if !hit { active.append(proj) }
        }
        projectiles = active
    }
    
    var isRoundOver: Bool {
        tanks.filter(\.isAlive).count <= 1
    }
    
    var winner: Int? {
        let alive = tanks.enumerated().filter { $0.element.isAlive }
        return alive.count == 1 ? alive[0].offset : nil
    }
}

// MARK: - Seeded Random
struct SeededRandom {
    private var state: UInt32
    
    init(seed: UInt32) {
        state = seed
    }
    
    mutating func next() -> UInt32 {
        state = state &* 1664525 &+ 1013904223
        return state
    }
}

// MARK: - Network Messages
enum GameMessage: Codable {
    case start(seed: UInt32, playerCount: Int, assignments: [String: Int])
    case move(playerIndex: Int, row: Int, col: Int, direction: Direction)
    case shoot(playerIndex: Int, projectile: Projectile)
    case ready(playerIndex: Int)
}
