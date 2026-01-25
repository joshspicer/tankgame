//
//  Game.swift
//  Tank Game
//
//  Game state management for continuous play with dynamic join/leave.
//

import Foundation

/// Player data stored in the game
struct PlayerData {
    var tank: Tank
    var score: Int
}

/// Manages the state of the game
final class Game {
    var map: Map
    var players: [String: PlayerData] = [:]  // Keyed by peerId
    var projectiles: [Projectile] = []
    let localPeerId: String

    /// Create a new game state
    init(seed: UInt32, localPeerId: String) {
        self.map = Map.generate(seed: seed)
        self.localPeerId = localPeerId

        // Add local player
        addPlayer(peerId: localPeerId)
    }

    /// The local player's tank
    var localTank: Tank {
        get { players[localPeerId]?.tank ?? Tank(row: 0, col: 0, direction: .down) }
        set { players[localPeerId]?.tank = newValue }
    }

    /// Get score for a player
    func score(for peerId: String) -> Int {
        players[peerId]?.score ?? 0
    }

    /// All scores keyed by peerId
    var scores: [String: Int] {
        var result: [String: Int] = [:]
        for (peerId, data) in players {
            result[peerId] = data.score
        }
        return result
    }

    // MARK: - Player Management

    /// Add a player at the safest spawn position
    @discardableResult
    func addPlayer(peerId: String) -> Tank? {
        guard players[peerId] == nil else { return players[peerId]?.tank }

        let spawn = findSpawnPosition(for: peerId)
        let tank = Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
        players[peerId] = PlayerData(tank: tank, score: 0)
        return tank
    }

    /// Add a player at a specific position (for world state sync)
    func addPlayer(peerId: String, row: Int, col: Int, direction: Direction, isAlive: Bool, score: Int) {
        var tank = Tank(row: row, col: col, direction: direction)
        tank.isAlive = isAlive
        players[peerId] = PlayerData(tank: tank, score: score)
    }

    /// Remove a player and return their tank for explosion animation
    func removePlayer(peerId: String) -> Tank? {
        guard let data = players[peerId] else { return nil }
        players.removeValue(forKey: peerId)
        return data.tank
    }

    /// Find the safest spawn position (farthest from other tanks)
    /// For a new player with given peerId
    func findSpawnPosition(for peerId: String? = nil) -> (row: Int, col: Int, direction: Direction) {
        let gridSize = map.size

        // Corner positions
        let corners: [(row: Int, col: Int, direction: Direction)] = [
            (0, 0, .down),                      // Top-left
            (gridSize - 1, gridSize - 1, .up),  // Bottom-right
            (0, gridSize - 1, .left),           // Top-right
            (gridSize - 1, 0, .right)           // Bottom-left
        ]

        // If no other players, use peerId hash to pick a corner deterministically
        let alivePlayers = players.values.filter { $0.tank.isAlive }
        if alivePlayers.isEmpty {
            if let peerId = peerId {
                let cornerIndex = abs(peerId.hashValue) % corners.count
                return corners[cornerIndex]
            }
            return corners[0]
        }

        // Find the corner farthest from all other tanks
        var bestPosition = corners[0]
        var bestMinDistance: Int = -1

        for corner in corners {
            // Skip if wall
            guard !map.grid[corner.row][corner.col] else { continue }

            // Calculate minimum distance to any alive tank
            var minDistance = Int.max
            for (_, data) in players {
                guard data.tank.isAlive else { continue }
                let dist = abs(data.tank.row - corner.row) + abs(data.tank.col - corner.col)
                minDistance = min(minDistance, dist)
            }

            if minDistance > bestMinDistance {
                bestMinDistance = minDistance
                bestPosition = corner
            }
        }

        // If all corners occupied, search the full perimeter
        if bestMinDistance <= 1 {
            for row in 0..<gridSize {
                for col in 0..<gridSize {
                    guard row == 0 || row == gridSize - 1 || col == 0 || col == gridSize - 1 else { continue }
                    guard !map.grid[row][col] else { continue }

                    var minDistance = Int.max
                    for (_, data) in players {
                        guard data.tank.isAlive else { continue }
                        let dist = abs(data.tank.row - row) + abs(data.tank.col - col)
                        minDistance = min(minDistance, dist)
                    }

                    if minDistance > bestMinDistance {
                        bestMinDistance = minDistance
                        let direction = spawnDirection(for: row, col: col, gridSize: gridSize)
                        bestPosition = (row, col, direction)
                    }
                }
            }
        }

        return bestPosition
    }

    /// Determine facing direction based on spawn position
    private func spawnDirection(for row: Int, col: Int, gridSize: Int) -> Direction {
        if row == 0 { return .down }
        if row == gridSize - 1 { return .up }
        if col == 0 { return .right }
        return .left
    }

    /// Respawn a dead player at the safest position
    func respawnPlayer(peerId: String) {
        guard var data = players[peerId] else { return }

        let spawn = findSpawnPosition(for: peerId)
        data.tank = Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
        data.tank.isAlive = true
        players[peerId] = data
    }

    // MARK: - World State Sync

    /// Create world state for syncing new joiners
    func createWorldState() -> WorldState {
        let playerStates = players.map { (peerId, data) in
            PlayerState(
                peerId: peerId,
                row: data.tank.row,
                col: data.tank.col,
                direction: data.tank.direction,
                isAlive: data.tank.isAlive
            )
        }

        let projectileStates = projectiles.map { $0.toState() }

        return WorldState(
            mapSeed: map.seed,
            players: playerStates,
            projectiles: projectileStates,
            scores: scores
        )
    }

    /// Apply received world state
    func applyWorldState(_ state: WorldState) {
        // Regenerate map with same seed
        self.map = Map.generate(seed: state.mapSeed)

        // Clear and rebuild players
        self.players.removeAll()
        for playerState in state.players {
            addPlayer(
                peerId: playerState.peerId,
                row: playerState.row,
                col: playerState.col,
                direction: playerState.direction,
                isAlive: playerState.isAlive,
                score: state.scores[playerState.peerId] ?? 0
            )
        }

        // Rebuild projectiles
        self.projectiles = state.projectiles.map { Projectile.from($0) }
    }

    // MARK: - Game Logic

    /// Update all projectiles, returns peerIds of hit tanks
    func updateProjectiles() -> [String] {
        var hitPeers: [String] = []
        var activeProjectiles: [Projectile] = []

        for var projectile in projectiles {
            // Check if projectile is currently in a wall
            if projectile.hitsWall(grid: map.grid) {
                continue
            }

            projectile.advance()

            // Remove if out of bounds or hit wall
            if projectile.isOutOfBounds(gridSize: map.size) || projectile.hitsWall(grid: map.grid) {
                continue
            }

            // Check tank collisions
            var hitSomething = false
            for (peerId, data) in players {
                if projectile.hitsTank(data.tank) {
                    players[peerId]?.tank.isAlive = false
                    hitPeers.append(peerId)
                    hitSomething = true

                    // Award point to shooter
                    if let shooterData = players[projectile.ownerId] {
                        players[projectile.ownerId]?.score = shooterData.score + 1
                    }
                    break
                }
            }

            if !hitSomething {
                activeProjectiles.append(projectile)
            }
        }

        projectiles = activeProjectiles
        return hitPeers
    }

    /// Number of alive players
    var aliveCount: Int {
        players.values.filter(\.tank.isAlive).count
    }

    /// Get all peer IDs sorted alphabetically
    var sortedPeerIds: [String] {
        players.keys.sorted()
    }
}
