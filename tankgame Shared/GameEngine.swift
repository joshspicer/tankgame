//
//  GameEngine.swift
//  tankgame Shared
//
//  Core game logic and state management
//

import Foundation

/// Main game engine that manages game state and rules
class GameEngine {
    
    // MARK: - Properties
    
    private(set) var grid: GameGrid
    private(set) var players: [String: Player] = [:]
    private(set) var projectiles: [Projectile] = []
    private(set) var isGameActive: Bool = false
    
    let gridSize: Int
    private let maxPlayers: Int
    
    // MARK: - Initialization
    
    init(gridSize: Int = 12, maxPlayers: Int = 6) {
        self.gridSize = gridSize
        self.maxPlayers = maxPlayers
        self.grid = GameGrid(size: gridSize)
    }
    
    // MARK: - Game Lifecycle
    
    /// Start a new game with the given player IDs
    func startGame(playerIds: [String]) {
        guard playerIds.count >= 2 && playerIds.count <= maxPlayers else {
            print("Invalid player count: \(playerIds.count). Need 2-\(maxPlayers) players.")
            return
        }
        
        // Reset state
        players.removeAll()
        projectiles.removeAll()
        grid = GameGrid(size: gridSize)
        
        // Spawn players at designated positions
        let spawnPositions = getSpawnPositions(for: playerIds.count)
        for (index, playerId) in playerIds.enumerated() {
            let (pos, dir) = spawnPositions[index]
            players[playerId] = Player(id: playerId, position: pos, direction: dir)
        }
        
        isGameActive = true
    }
    
    /// Get spawn positions based on player count
    private func getSpawnPositions(for playerCount: Int) -> [(Position, Direction)] {
        let s = gridSize
        let positions: [(Position, Direction)] = [
            (Position(1, 1), .down),           // Top-left
            (Position(s-2, s-2), .up),         // Bottom-right
            (Position(1, s-2), .right),        // Bottom-left
            (Position(s-2, 1), .left),         // Top-right
            (Position(s/2, 1), .down),         // Top-center
            (Position(s/2, s-2), .up)          // Bottom-center
        ]
        return Array(positions.prefix(playerCount))
    }
    
    /// Check if game is over (only one player alive or all dead)
    func checkGameOver() -> String? {
        let alivePlayers = players.values.filter { $0.isAlive }
        
        if alivePlayers.count <= 1 {
            isGameActive = false
            if let winner = alivePlayers.first {
                return winner.id
            }
            return nil // Draw
        }
        return nil
    }
    
    // MARK: - Player Actions
    
    /// Move player in the given direction
    func movePlayer(id: String, direction: Direction) -> Bool {
        guard isGameActive, var player = players[id], player.isAlive else { return false }
        
        // Collect obstacles (walls + other players)
        var obstacles = grid.walls
        for otherPlayer in players.values where otherPlayer.id != id && otherPlayer.isAlive {
            obstacles.insert(otherPlayer.position)
        }
        
        // Attempt move
        let moved = player.move(direction, gridSize: gridSize, obstacles: obstacles)
        if moved {
            players[id] = player
        }
        return moved
    }
    
    /// Player shoots a projectile
    func shootProjectile(playerId: String) {
        guard isGameActive, let player = players[playerId], player.isAlive else { return }
        let projectile = player.shoot()
        projectiles.append(projectile)
    }
    
    // MARK: - Game Update
    
    /// Update game state (advance projectiles, check collisions)
    func update() {
        guard isGameActive else { return }
        
        // Advance all projectiles
        var activeProjectiles: [Projectile] = []
        
        for var projectile in projectiles {
            projectile.advance()
            
            // Check if out of bounds or hit wall
            if projectile.isOutOfBounds(gridSize: gridSize) || grid.hasWall(at: projectile.position) {
                continue // Remove projectile
            }
            
            // Check if hit any player
            var hitPlayer = false
            for (playerId, player) in players where player.isAlive {
                if player.position == projectile.position {
                    // Hit! Kill player and award point to shooter
                    players[playerId]?.isAlive = false
                    if playerId != projectile.ownerId {
                        players[projectile.ownerId]?.score += 1
                    }
                    hitPlayer = true
                    break
                }
            }
            
            if !hitPlayer {
                activeProjectiles.append(projectile)
            }
        }
        
        projectiles = activeProjectiles
    }
    
    // MARK: - State Access
    
    func getPlayer(id: String) -> Player? {
        return players[id]
    }
    
    func getAllPlayers() -> [Player] {
        return Array(players.values)
    }
}
