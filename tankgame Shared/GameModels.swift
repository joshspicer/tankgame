//
//  GameModels.swift
//  tankgame Shared
//
//  Complete rewrite - All game models in one place
//

import Foundation

// MARK: - Core Game Models

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

struct Position: Codable, Equatable {
    var row: Int
    var col: Int
}

struct Tank: Codable, Identifiable {
    let id: Int // player index
    var position: Position
    var direction: Direction
    var isAlive: Bool = true
}

struct Bullet: Codable {
    let id: String
    var position: Position
    var direction: Direction

    init(position: Position, direction: Direction) {
        self.id = UUID().uuidString
        self.position = position
        self.direction = direction
    }

    mutating func advance() {
        let offset = direction.offset
        position.row += offset.row
        position.col += offset.col
    }
}

enum Cell: Codable {
    case empty
    case wall
}

typealias Grid = [[Cell]]

// MARK: - Player Model

struct Player: Identifiable, Codable {
    let id: String // peer ID
    let name: String
    var isReady: Bool = false
}

// MARK: - Network Messages

enum GameMessage: Codable {
    case startGame(seed: UInt32, players: [String]) // host -> clients, peerID array in play order
    case move(playerId: String, position: Position, direction: Direction)
    case shoot(playerId: String, bullet: Bullet)
    case hit(playerId: String)
    case roundEnd(winnerId: String?)
}

// MARK: - Game State

struct GameState {
    var grid: Grid
    var tanks: [Tank]
    var bullets: [Bullet] = []
    var scores: [String: Int] = [:] // playerId -> wins
    var localPlayerId: String
    var playerIds: [String] // Array of player IDs corresponding to tank indices

    static let gridSize = 8
    static let spawnPositions: [(row: Int, col: Int, direction: Direction)] = [
        (0, 0, .down),
        (7, 7, .up),
        (0, 7, .down),
        (7, 0, .up),
        (3, 0, .down),
        (3, 7, .up)
    ]

    static func generateGrid(seed: UInt32) -> Grid {
        var rng = SeededRandomNumberGenerator(seed: seed)
        var grid = Array(repeating: Array(repeating: Cell.empty, count: gridSize), count: gridSize)

        // Add some random walls (20% coverage)
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                // Don't place walls at spawn positions
                let isSpawn = spawnPositions.contains { $0.row == row && $0.col == col }
                if !isSpawn && rng.next() % 5 == 0 {
                    grid[row][col] = .wall
                }
            }
        }

        return grid
    }

    mutating func reset(seed: UInt32) {
        grid = GameState.generateGrid(seed: seed)
        bullets = []

        // Reset tanks to spawn positions
        for i in 0..<tanks.count {
            let spawn = GameState.spawnPositions[i]
            tanks[i].position = Position(row: spawn.row, col: spawn.col)
            tanks[i].direction = spawn.direction
            tanks[i].isAlive = true
        }
    }
}

// MARK: - Seeded Random Number Generator

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt32) {
        state = UInt64(seed)
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}
