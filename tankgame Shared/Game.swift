//
//  Game.swift
//  Tank Game
//
//  Game state management for rounds, tanks, projectiles, and scoring.
//

import Foundation

/// Manages the state of a game round
final class Game {
    var map: Map
    var tanks: [Tank]
    var projectiles: [Projectile] = []
    var scores: [Int]
    let localPlayerIndex: Int
    let playerCount: Int
    
    /// Create a new game state
    init(seed: UInt32, playerCount: Int, localPlayerIndex: Int) {
        self.map = Map.generate(seed: seed)
        self.playerCount = playerCount
        self.localPlayerIndex = localPlayerIndex
        self.scores = Array(repeating: 0, count: playerCount)
        
        // Spawn tanks at their starting positions
        self.tanks = (0..<playerCount).map { i in
            let spawn = Map.spawnPositions[i]
            return Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
        }
    }
    
    /// The local player's tank
    var localTank: Tank {
        get { tanks[localPlayerIndex] }
        set { tanks[localPlayerIndex] = newValue }
    }
    
    /// Reset for a new round with a new seed
    func reset(seed: UInt32) {
        self.map = Map.generate(seed: seed)
        self.projectiles = []
        
        // Reset tanks to spawn positions
        for i in 0..<tanks.count {
            let spawn = Map.spawnPositions[i]
            tanks[i] = Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
        }
    }
    
    // MARK: - Game Logic
    
    /// Update all projectiles, returns indices of hit tanks
    func updateProjectiles() -> [Int] {
        var hitTanks: [Int] = []
        var activeProjectiles: [Projectile] = []
        
        for var projectile in projectiles {
            projectile.advance()
            
            // Remove if out of bounds or hit wall
            if projectile.isOutOfBounds(gridSize: map.size) || projectile.hitsWall(grid: map.grid) {
                continue
            }
            
            // Check tank collisions
            var hitSomething = false
            for (i, tank) in tanks.enumerated() {
                if projectile.hitsTank(tank) {
                    tanks[i].isAlive = false
                    hitTanks.append(i)
                    hitSomething = true
                    break
                }
            }
            
            if !hitSomething {
                activeProjectiles.append(projectile)
            }
        }
        
        projectiles = activeProjectiles
        return hitTanks
    }
    
    /// Check if the round is over (1 or fewer tanks alive)
    var isRoundOver: Bool {
        tanks.filter(\.isAlive).count <= 1
    }
    
    /// Get the winner's index, or nil if no winner
    var winner: Int? {
        let alive = tanks.enumerated().filter { $0.element.isAlive }
        return alive.count == 1 ? alive.first?.offset : nil
    }
    
    /// Record a win for a player
    func recordWin(_ playerIndex: Int) {
        guard playerIndex >= 0 && playerIndex < scores.count else { return }
        scores[playerIndex] += 1
    }
}
