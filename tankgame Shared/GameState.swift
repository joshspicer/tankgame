//
//  GameState.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Manages the state of a game round including tanks, projectiles, and grid
final class GameState {
    var grid: [[GridCell]]
    var tanks: [Tank] // Array of all tanks (index = player index)
    var projectiles: [Projectile] = []
    var localPlayerIndex: Int // Index of the local player in tanks array
    
    /// Centralized scoring engine for tracking scores and statistics
    let scoringEngine: ScoringEngine
    
    /// Convenience accessor for backward compatibility with existing code
    var wins: [Int] {
        return scoringEngine.scores
    }
    
    // Spawn positions for up to 4 players
    static let spawnPositions: [(row: Int, col: Int, direction: Direction)] = [
        (0, 0, .down),      // Player 0: top-left
        (7, 7, .up),        // Player 1: bottom-right
        (0, 7, .down),      // Player 2: top-right
        (7, 0, .up)         // Player 3: bottom-left
    ]
    
    init(seed: UInt32, playerCount: Int, localPlayerIndex: Int) {
        self.grid = GridGenerator.generate(seed: seed)
        self.localPlayerIndex = localPlayerIndex
        
        // Initialize scoring engine
        self.scoringEngine = ScoringEngine(playerCount: playerCount, mode: .roundWins)
        
        // Initialize tanks for all players
        var initialTanks: [Tank] = []
        for i in 0..<playerCount {
            let spawn = GameState.spawnPositions[i]
            initialTanks.append(Tank(row: spawn.row, col: spawn.col, direction: spawn.direction))
        }
        self.tanks = initialTanks
    }
    
    func reset(seed: UInt32) {
        self.grid = GridGenerator.generate(seed: seed)
        self.projectiles = []
        
        // Reset streaks for new round
        scoringEngine.resetStreaks()
        
        // Reset all tanks to their spawn positions
        for i in 0..<tanks.count {
            let spawn = GameState.spawnPositions[i]
            tanks[i] = Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
        }
    }
    
    var localTank: Tank {
        get { tanks[localPlayerIndex] }
        set { tanks[localPlayerIndex] = newValue }
    }
    
    func updateProjectiles() {
        var activeProjectiles: [Projectile] = []
        
        for var projectile in projectiles {
            projectile.advance()
            
            // Check if out of bounds or hit wall
            if projectile.isOutOfBounds(gridSize: 8) || projectile.hits(grid: grid) {
                continue // Remove this projectile
            }
            
            // Check if hit any tank
            var hitTank = false
            for i in 0..<tanks.count {
                if projectile.hits(tank: tanks[i]) {
                    tanks[i].isAlive = false
                    
                    // Record the kill in the scoring engine
                    if projectile.ownerIndex >= 0 && projectile.ownerIndex != i {
                        scoringEngine.recordKill(by: projectile.ownerIndex, victim: i)
                    }
                    
                    hitTank = true
                    break
                }
            }
            
            if hitTank {
                continue
            }
            
            activeProjectiles.append(projectile)
        }
        
        projectiles = activeProjectiles
    }
    
    /// Record the round win in the scoring engine
    func recordRoundWin(by playerIndex: Int) {
        scoringEngine.recordRoundWin(by: playerIndex)
    }
    
    func isRoundOver() -> Bool {
        let aliveTanks = tanks.filter { $0.isAlive }
        return aliveTanks.count <= 1
    }
    
    func localPlayerWon() -> Bool {
        // Local player won if they're the only one alive
        if !tanks[localPlayerIndex].isAlive {
            return false
        }
        
        let aliveTanks = tanks.filter { $0.isAlive }
        return aliveTanks.count == 1
    }
    
    func getWinner() -> Int? {
        let aliveTanks = tanks.enumerated().filter { $0.element.isAlive }
        if aliveTanks.count == 1 {
            return aliveTanks.first?.offset
        }
        return nil
    }
}
