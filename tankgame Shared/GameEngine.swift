//
//  GameEngine.swift
//  tankgame Shared
//
//  Consolidated game engine using Strategy pattern

import Foundation

/// Game engine - Strategy pattern for different game modes
final class GameEngine {

    // MARK: - State
    private(set) var tanks: [Tank] = []
    private(set) var projectiles: [Projectile] = []
    private(set) var grid: [[Cell]] = []
    private(set) var scores: [Int] = []

    let localPlayerIndex: Int
    private let playerCount: Int

    // MARK: - Configuration
    private let gridSize = 8
    private let spawnPoints: [(Position, Direction)] = [
        (Position(row: 0, col: 0), .down),
        (Position(row: 7, col: 7), .up),
        (Position(row: 0, col: 7), .down),
        (Position(row: 7, col: 0), .up),
        (Position(row: 3, col: 0), .right),
        (Position(row: 4, col: 7), .left)
    ]

    // MARK: - Initialization
    init(playerCount: Int, localPlayerIndex: Int) {
        self.playerCount = playerCount
        self.localPlayerIndex = localPlayerIndex
        self.scores = Array(repeating: 0, count: playerCount)
    }

    func startRound(seed: UInt32) {
        // Generate grid
        grid = generateGrid(seed: seed)

        // Create tanks
        tanks = (0..<playerCount).map { i in
            let spawn = spawnPoints[i]
            return Tank(position: spawn.0, direction: spawn.1, playerIndex: i)
        }

        // Clear projectiles
        projectiles = []
    }

    // MARK: - Game Loop
    func update() {
        let context = GameContext(grid: grid, entities: tanks.map { $0 as GameEntity })

        // Update projectiles
        for i in 0..<projectiles.count {
            projectiles[i].update(in: context)
        }

        // Check projectile-tank collisions
        for projectile in projectiles where projectile.isAlive {
            for i in 0..<tanks.count where tanks[i].isAlive {
                if projectile.hits(tanks[i]) {
                    tanks[i].isAlive = false
                }
            }
        }

        // Remove dead projectiles
        projectiles.removeAll { !$0.isAlive }
    }

    // MARK: - Player Actions
    func moveTank(_ index: Int) -> Bool {
        guard index < tanks.count, tanks[index].isAlive else { return false }
        return tanks[index].move(in: grid)
    }

    func rotateTank(_ index: Int, clockwise: Bool) {
        guard index < tanks.count, tanks[index].isAlive else { return }
        tanks[index].direction.rotate(clockwise: clockwise)
    }

    func shootProjectile(from index: Int) {
        guard index < tanks.count, tanks[index].isAlive else { return }
        let projectile = tanks[index].createProjectile()
        if projectile.position.isValid() {
            projectiles.append(projectile)
        }
    }

    // MARK: - Game State
    func isRoundOver() -> Bool {
        return tanks.filter { $0.isAlive }.count <= 1
    }

    func winner() -> Int? {
        let alive = tanks.enumerated().filter { $0.element.isAlive }
        return alive.count == 1 ? alive.first?.offset : nil
    }

    func recordWin(for playerIndex: Int) {
        scores[playerIndex] += 1
    }

    // MARK: - Grid Generation
    private func generateGrid(seed: UInt32) -> [[Cell]] {
        var rng = SeededRandom(seed: seed)
        var grid = Array(repeating: Array(repeating: Cell.empty, count: gridSize), count: gridSize)

        // Add random walls (15% density)
        for row in 1..<(gridSize-1) {
            for col in 1..<(gridSize-1) {
                if rng.next() < 0.15 {
                    grid[row][col] = .wall
                }
            }
        }

        // Clear spawn points
        for spawn in spawnPoints {
            let pos = spawn.0
            if pos.row >= 0 && pos.row < gridSize && pos.col >= 0 && pos.col < gridSize {
                grid[pos.row][pos.col] = .empty
            }
        }

        return grid
    }
}

/// Seeded random number generator
struct SeededRandom {
    private var state: UInt32

    init(seed: UInt32) {
        self.state = seed
    }

    mutating func next() -> Double {
        // Linear congruential generator
        state = (state &* 1664525 &+ 1013904223)
        return Double(state) / Double(UInt32.max)
    }
}
