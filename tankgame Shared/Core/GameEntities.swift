//
//  GameEntities.swift
//  tankgame Shared
//
//  Core game entities using Factory pattern

import Foundation

// MARK: - Direction
enum Direction: String, Codable {
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
    var row: Int
    var col: Int
    var direction: Direction
    var isAlive: Bool

    init(row: Int, col: Int, direction: Direction) {
        self.row = row
        self.col = col
        self.direction = direction
        self.isAlive = true
    }

    mutating func move(in direction: Direction, grid: [[Cell]]) -> Bool {
        let offset = direction.offset
        let newRow = row + offset.row
        let newCol = col + offset.col

        guard newRow >= 0, newRow < grid.count,
              newCol >= 0, newCol < grid[0].count,
              grid[newRow][newCol] == .empty else { return false }

        row = newRow
        col = newCol
        self.direction = direction
        return true
    }

    func shoot() -> Projectile {
        let offset = direction.offset
        return Projectile(row: row + offset.row, col: col + offset.col, direction: direction)
    }

    // Factory method for creating starting tanks
    static func createStartingTanks(count: Int) -> [Tank] {
        let positions: [(Int, Int, Direction)] = [
            (0, 0, .down),      // Top-left
            (7, 7, .up),        // Bottom-right
            (0, 7, .down),      // Top-right
            (7, 0, .up),        // Bottom-left
            (3, 0, .right),     // Mid-left
            (3, 7, .left)       // Mid-right
        ]
        return positions.prefix(count).map { Tank(row: $0.0, col: $0.1, direction: $0.2) }
    }
}

// MARK: - Projectile
struct Projectile: Codable {
    var row: Int
    var col: Int
    let direction: Direction

    mutating func advance() {
        let offset = direction.offset
        row += offset.row
        col += offset.col
    }

    func isOutOfBounds(gridSize: Int) -> Bool {
        row < 0 || row >= gridSize || col < 0 || col >= gridSize
    }

    func hits(grid: [[Cell]]) -> Bool {
        guard row >= 0, row < grid.count, col >= 0, col < grid[0].count else { return false }
        return grid[row][col] == .wall
    }

    func hits(tank: Tank) -> Bool {
        tank.isAlive && tank.row == row && tank.col == col
    }
}

// MARK: - Grid
struct Grid {
    static func generate(seed: UInt32) -> [[Cell]] {
        var rng = SeededRandomGenerator(seed: seed)
        var grid = Array(repeating: Array(repeating: Cell.empty, count: 8), count: 8)

        // Add random walls (20% density)
        for row in 0..<8 {
            for col in 0..<8 {
                if rng.next() < 0.2 {
                    grid[row][col] = .wall
                }
            }
        }

        // Clear starting positions
        let starts = [(0,0), (7,7), (0,7), (7,0), (3,0), (3,7)]
        for pos in starts {
            grid[pos.0][pos.1] = .empty
        }

        return grid
    }
}

// MARK: - Random Generator
struct SeededRandomGenerator {
    private var seed: UInt32

    init(seed: UInt32) {
        self.seed = seed
    }

    mutating func next() -> Double {
        seed = (seed &* 1103515245 &+ 12345) & 0x7fffffff
        return Double(seed) / Double(0x7fffffff)
    }
}
