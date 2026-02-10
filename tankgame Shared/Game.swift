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
    var aiPlayer: AIPlayer?
}

/// Manages the state of the game
final class Game {
    var map: Map
    var players: [String: PlayerData] = [:]  // Keyed by peerId
    var projectiles: [Projectile] = []
    let localPeerId: String
    private(set) var gridSize: Int

    /// Create a new game state
    init(seed: UInt32, localPeerId: String, gridSize: Int = 8) {
        self.gridSize = gridSize
        self.map = Map.generate(seed: seed, size: gridSize)
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
    /// Returns the new tank if created, or nil if player already exists
    @discardableResult
    func addPlayer(peerId: String) -> Tank? {
        guard players[peerId] == nil else { return nil }

        let spawn = findSpawnPosition(for: peerId)
        let tank = Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
        players[peerId] = PlayerData(tank: tank, score: 0, aiPlayer: nil)
        return tank
    }

    /// Add an AI player with specified difficulty
    /// Returns the new tank if created, or nil if player already exists
    @discardableResult
    func addAIPlayer(id: String, difficulty: AIDifficulty = .easy) -> Tank? {
        guard players[id] == nil else { return nil }

        let spawn = findSpawnPosition(for: id)
        var tank = Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
        tank.isAI = true
        let aiPlayer = AIPlayer(id: id, difficulty: difficulty)
        players[id] = PlayerData(tank: tank, score: 0, aiPlayer: aiPlayer)
        return tank
    }

    /// Add a player at a specific position (for world state sync)
    func addPlayer(peerId: String, row: Int, col: Int, direction: Direction, isAlive: Bool, score: Int, isAI: Bool = false, aiDifficulty: AIDifficulty? = nil) {
        var tank = Tank(row: row, col: col, direction: direction)
        tank.isAlive = isAlive
        tank.isAI = isAI
        let aiPlayer = isAI && aiDifficulty != nil ? AIPlayer(id: peerId, difficulty: aiDifficulty!) : nil
        players[peerId] = PlayerData(tank: tank, score: score, aiPlayer: aiPlayer)
    }

    /// Remove a player and return their tank for explosion animation
    func removePlayer(peerId: String) -> Tank? {
        guard let data = players[peerId] else { return nil }
        players.removeValue(forKey: peerId)
        return data.tank
    }

    /// Find the safest spawn position (farthest from other tanks)
    /// For a new player with given peerId, with jitter to avoid collisions
    func findSpawnPosition(for peerId: String? = nil) -> (row: Int, col: Int, direction: Direction) {
        let gridSize = map.size

        // All perimeter positions (not just corners) for more options
        var perimeterPositions: [(row: Int, col: Int, direction: Direction)] = []
        for i in 0..<gridSize {
            perimeterPositions.append((0, i, .down))           // Top edge
            perimeterPositions.append((gridSize - 1, i, .up))  // Bottom edge
            if i > 0 && i < gridSize - 1 {
                perimeterPositions.append((i, 0, .right))              // Left edge
                perimeterPositions.append((i, gridSize - 1, .left))    // Right edge
            }
        }

        // Filter out walls
        perimeterPositions = perimeterPositions.filter { !map.grid[$0.row][$0.col] }

        // If no other players, use peerId hash to pick a position deterministically
        let alivePlayers = players.values.filter { $0.tank.isAlive }
        if alivePlayers.isEmpty {
            if let peerId = peerId, !perimeterPositions.isEmpty {
                // Use stable hash for deterministic but spread-out positions
                var hash: UInt64 = 5381
                for char in peerId.utf8 {
                    hash = ((hash << 5) &+ hash) &+ UInt64(char)
                }
                let index = Int(hash % UInt64(perimeterPositions.count))
                return perimeterPositions[index]
            }
            return perimeterPositions.first ?? (0, 0, .down)
        }

        // Score each position by minimum distance to other tanks
        var scoredPositions: [(pos: (row: Int, col: Int, direction: Direction), score: Int)] = []

        for pos in perimeterPositions {
            var minDistance = Int.max
            for (_, data) in players {
                guard data.tank.isAlive else { continue }
                let dist = abs(data.tank.row - pos.row) + abs(data.tank.col - pos.col)
                minDistance = min(minDistance, dist)
            }
            scoredPositions.append((pos, minDistance))
        }

        // Sort by distance (farthest first)
        scoredPositions.sort { $0.score > $1.score }

        // Take the top candidates (within 2 of best score) and pick randomly based on peerId
        let bestScore = scoredPositions.first?.score ?? 0
        let candidates = scoredPositions.filter { $0.score >= bestScore - 2 }

        if let peerId = peerId, !candidates.isEmpty {
            // Use peerId hash + current time for jitter
            var hash: UInt64 = 5381
            for char in peerId.utf8 {
                hash = ((hash << 5) &+ hash) &+ UInt64(char)
            }
            // Add time-based jitter
            hash = hash &+ UInt64(Date().timeIntervalSince1970 * 1000) % 997
            let index = Int(hash % UInt64(candidates.count))
            return candidates[index].pos
        }

        return candidates.first?.pos ?? perimeterPositions.first ?? (0, 0, .down)
    }

    /// Determine facing direction based on spawn position
    private func spawnDirection(for row: Int, col: Int, gridSize: Int) -> Direction {
        if row == 0 { return .down }
        if row == gridSize - 1 { return .up }
        if col == 0 { return .right }
        return .left
    }

    /// Respawn a dead player at the safest position
    /// Returns the respawn position, or nil if respawn failed
    @discardableResult
    func respawnPlayer(peerId: String) -> (row: Int, col: Int, direction: Direction)? {
        let spawn = findSpawnPosition(for: peerId)

        if var data = players[peerId] {
            // Player exists - update their position
            data.tank = Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
            data.tank.isAlive = true
            data.tank.isAI = data.aiPlayer != nil  // Preserve AI status
            players[peerId] = data
        } else {
            // Player doesn't exist - create them
            var tank = Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
            tank.isAlive = true
            players[peerId] = PlayerData(tank: tank, score: 0, aiPlayer: nil)
        }

        return spawn
    }

    // MARK: - World State Sync

    /// Create player states array for periodic sync
    func createPlayerStates() -> [PlayerState] {
        players.map { (peerId, data) in
            PlayerState(
                peerId: peerId,
                row: data.tank.row,
                col: data.tank.col,
                direction: data.tank.direction,
                isAlive: data.tank.isAlive,
                isAI: data.tank.isAI,
                aiDifficulty: data.aiPlayer?.difficulty
            )
        }
    }

    /// Apply sync data from elder
    func applySync(players syncPlayers: [PlayerState], scores syncScores: [String: Int]) {
        for playerState in syncPlayers {
            if var data = players[playerState.peerId] {
                // Update existing player
                data.tank.row = playerState.row
                data.tank.col = playerState.col
                data.tank.direction = playerState.direction
                data.tank.isAlive = playerState.isAlive
                data.tank.isAI = playerState.isAI
                data.score = syncScores[playerState.peerId] ?? data.score
                // Update AI difficulty if changed
                if playerState.isAI, let difficulty = playerState.aiDifficulty {
                    if data.aiPlayer == nil {
                        data.aiPlayer = AIPlayer(id: playerState.peerId, difficulty: difficulty)
                    } else {
                        data.aiPlayer?.difficulty = difficulty
                    }
                }
                players[playerState.peerId] = data
            } else {
                // Add missing player
                var tank = Tank(row: playerState.row, col: playerState.col, direction: playerState.direction)
                tank.isAlive = playerState.isAlive
                tank.isAI = playerState.isAI
                let aiPlayer = playerState.isAI && playerState.aiDifficulty != nil ?
                    AIPlayer(id: playerState.peerId, difficulty: playerState.aiDifficulty!) : nil
                players[playerState.peerId] = PlayerData(tank: tank, score: syncScores[playerState.peerId] ?? 0, aiPlayer: aiPlayer)
            }
        }

        // Remove players that aren't in the sync (they left)
        let syncPeerIds = Set(syncPlayers.map(\.peerId))
        for peerId in players.keys {
            if peerId != localPeerId && !syncPeerIds.contains(peerId) {
                players.removeValue(forKey: peerId)
            }
        }
    }

    /// Create world state for syncing new joiners
    func createWorldState() -> WorldState {
        let playerStates = players.map { (peerId, data) in
            PlayerState(
                peerId: peerId,
                row: data.tank.row,
                col: data.tank.col,
                direction: data.tank.direction,
                isAlive: data.tank.isAlive,
                isAI: data.tank.isAI,
                aiDifficulty: data.aiPlayer?.difficulty
            )
        }

        let projectileStates = projectiles.map { $0.toState() }

        return WorldState(
            mapSeed: map.seed,
            gridSize: gridSize,
            players: playerStates,
            projectiles: projectileStates,
            scores: scores
        )
    }

    /// Apply received world state
    func applyWorldState(_ state: WorldState) {
        // Update grid size and regenerate map
        self.gridSize = state.gridSize
        self.map = Map.generate(seed: state.mapSeed, size: state.gridSize)

        // Clear and rebuild players
        self.players.removeAll()
        for playerState in state.players {
            addPlayer(
                peerId: playerState.peerId,
                row: playerState.row,
                col: playerState.col,
                direction: playerState.direction,
                isAlive: playerState.isAlive,
                score: state.scores[playerState.peerId] ?? 0,
                isAI: playerState.isAI,
                aiDifficulty: playerState.aiDifficulty
            )
        }

        // Rebuild projectiles
        self.projectiles = state.projectiles.map { Projectile.from($0) }
    }

    /// Resize the grid (elder only) - returns new world state
    func resizeGrid(to newSize: Int, newSeed: UInt32) {
        self.gridSize = newSize
        self.map = Map.generate(seed: newSeed, size: newSize)
        self.projectiles.removeAll()

        // Respawn all players at new positions
        for peerId in players.keys {
            let spawn = findSpawnPosition(for: peerId)
            var tank = Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
            tank.isAlive = true
            tank.isAI = players[peerId]?.tank.isAI ?? false
            let score = players[peerId]?.score ?? 0
            let aiPlayer = players[peerId]?.aiPlayer
            players[peerId] = PlayerData(tank: tank, score: score, aiPlayer: aiPlayer)
        }
    }

    // MARK: - Game Logic

    /// Hit info containing victim and shooter
    struct HitInfo {
        let victimId: String
        let shooterId: String
    }

    /// Update all projectiles, returns hit info for each destroyed tank
    func updateProjectiles() -> [HitInfo] {
        var hits: [HitInfo] = []
        var activeProjectiles: [Projectile] = []

        for var projectile in projectiles {
            // Check if projectile is currently in a wall (shouldn't happen normally)
            if projectile.hitsWall(grid: map.grid) {
                continue
            }

            // Check tank collisions at CURRENT position (before advancing)
            // This catches adjacent-cell hits where projectile spawns on top of enemy
            var hitSomething = false
            for (peerId, data) in players {
                // Don't let a projectile hit its owner on spawn
                if peerId == projectile.ownerId { continue }

                if projectile.hitsTank(data.tank) {
                    players[peerId]?.tank.isAlive = false
                    hits.append(HitInfo(victimId: peerId, shooterId: projectile.ownerId))
                    hitSomething = true

                    // Award point to shooter
                    if let shooterData = players[projectile.ownerId] {
                        players[projectile.ownerId]?.score = shooterData.score + 1
                    }

                    // If AI was killed, level it up
                    if let aiPlayer = players[peerId]?.aiPlayer {
                        aiPlayer.levelUp()
                    }
                    break
                }
            }

            if hitSomething {
                continue
            }

            // Advance projectile
            projectile.advance()

            // Remove if out of bounds or hit wall
            if projectile.isOutOfBounds(gridSize: map.size) || projectile.hitsWall(grid: map.grid) {
                continue
            }

            // Check tank collisions at NEW position (after advancing)
            for (peerId, data) in players {
                if projectile.hitsTank(data.tank) {
                    players[peerId]?.tank.isAlive = false
                    hits.append(HitInfo(victimId: peerId, shooterId: projectile.ownerId))
                    hitSomething = true

                    // Award point to shooter
                    if let shooterData = players[projectile.ownerId] {
                        players[projectile.ownerId]?.score = shooterData.score + 1
                    }

                    // If AI was killed, level it up
                    if let aiPlayer = players[peerId]?.aiPlayer {
                        aiPlayer.levelUp()
                    }
                    break
                }
            }

            if !hitSomething {
                activeProjectiles.append(projectile)
            }
        }

        projectiles = activeProjectiles
        return hits
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
