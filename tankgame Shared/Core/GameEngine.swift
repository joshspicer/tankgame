//
//  GameEngine.swift
//  tankgame Shared
//
//  Core game engine using Command and State patterns

import Foundation
import Combine

/// Main game engine coordinating all game logic
final class GameEngine {

    // MARK: - Publishers
    let roundDidEnd = PassthroughSubject<Winner?, Never>()
    let stateChanged = PassthroughSubject<GameState, Never>()

    // MARK: - State
    private(set) var state: GameState?
    private var updateTimer: Timer?

    // MARK: - Lifecycle
    func start(seed: UInt32, playerCount: Int, localPlayerIndex: Int) {
        state = GameState(seed: seed, playerCount: playerCount, localPlayerIndex: localPlayerIndex)
        stateChanged.send(state!)
        startUpdateLoop()
    }

    func reset() {
        updateTimer?.invalidate()
        state = nil
    }

    private func startUpdateLoop() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.update()
        }
    }

    private func update() {
        guard var state = state else { return }

        // Update projectiles
        state.updateProjectiles()

        // Check for round end
        if state.isRoundOver() {
            if let winner = state.getWinner() {
                state.wins[winner] += 1
            }
            updateTimer?.invalidate()
            self.state = state
            roundDidEnd.send(state.getWinner().map { Winner(index: $0) })
            return
        }

        self.state = state
        stateChanged.send(state)
    }

    // MARK: - Commands
    func execute(_ command: Command) {
        guard var state = state else { return }
        command.execute(on: &state)
        self.state = state
        stateChanged.send(state)
    }
}

// MARK: - Game State
struct GameState {
    var grid: [[Cell]]
    var tanks: [Tank]
    var projectiles: [Projectile]
    var wins: [Int]
    let localPlayerIndex: Int

    init(seed: UInt32, playerCount: Int, localPlayerIndex: Int) {
        self.grid = Grid.generate(seed: seed)
        self.tanks = Tank.createStartingTanks(count: playerCount)
        self.projectiles = []
        self.wins = Array(repeating: 0, count: playerCount)
        self.localPlayerIndex = localPlayerIndex
    }

    mutating func updateProjectiles() {
        projectiles = projectiles.compactMap { projectile in
            var updated = projectile
            updated.advance()

            // Check bounds and walls
            guard !updated.isOutOfBounds(gridSize: 8),
                  !updated.hits(grid: grid) else { return nil }

            // Check tank hits
            for i in tanks.indices {
                if updated.hits(tank: tanks[i]) {
                    tanks[i].isAlive = false
                    return nil
                }
            }

            return updated
        }
    }

    func isRoundOver() -> Bool {
        tanks.filter { $0.isAlive }.count <= 1
    }

    func getWinner() -> Int? {
        let alive = tanks.enumerated().filter { $0.element.isAlive }
        return alive.count == 1 ? alive.first?.offset : nil
    }
}

// MARK: - Command Pattern
protocol Command {
    func execute(on state: inout GameState)
}

struct MoveCommand: Command {
    let playerIndex: Int
    let direction: Direction

    func execute(on state: inout GameState) {
        guard playerIndex < state.tanks.count else { return }
        _ = state.tanks[playerIndex].move(in: direction, grid: state.grid)
    }
}

struct ShootCommand: Command {
    let playerIndex: Int

    func execute(on state: inout GameState) {
        guard playerIndex < state.tanks.count,
              state.tanks[playerIndex].isAlive else { return }
        let projectile = state.tanks[playerIndex].shoot()
        state.projectiles.append(projectile)
    }
}

// MARK: - Supporting Types
struct Winner {
    let index: Int
}

enum Cell: Codable {
    case empty, wall
}
