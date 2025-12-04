//
//  GameState.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Manages the state of a game round including tanks, projectiles, lizards, and grid
final class GameState {
    var grid: [[GridCell]]
    var tanks: [Tank] // Array of all tanks (index = player index)
    var projectiles: [Projectile] = []
    var lizards: [Lizard] = [] // AI-controlled lizard creatures
    var wins: [Int] // Wins for each player
    var localPlayerIndex: Int // Index of the local player in tanks array
    
    /// Whether lizards are enabled for this game
    var lizardsEnabled: Bool = true
    
    /// Number of lizards to spawn
    static let lizardCount: Int = 2
    
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
        
        // Initialize tanks for all players
        var initialTanks: [Tank] = []
        for i in 0..<playerCount {
            let spawn = GameState.spawnPositions[i]
            initialTanks.append(Tank(row: spawn.row, col: spawn.col, direction: spawn.direction))
        }
        self.tanks = initialTanks
        
        // Initialize wins array
        self.wins = Array(repeating: 0, count: playerCount)
        
        // Initialize lizards
        spawnLizards(seed: seed)
    }
    
    func reset(seed: UInt32) {
        self.grid = GridGenerator.generate(seed: seed)
        self.projectiles = []
        
        // Reset all tanks to their spawn positions
        for i in 0..<tanks.count {
            let spawn = GameState.spawnPositions[i]
            tanks[i] = Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
        }
        
        // Reset lizards
        spawnLizards(seed: seed)
    }
    
    /// Spawn lizards at random empty positions using the LizardSpawner
    private func spawnLizards(seed: UInt32) {
        guard lizardsEnabled else {
            lizards = []
            return
        }
        
        lizards = LizardSpawner.spawnLizards(
            seed: seed,
            grid: grid,
            count: GameState.lizardCount,
            spawnPositions: GameState.spawnPositions
        )
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
                    hitTank = true
                    break
                }
            }
            
            if hitTank {
                continue
            }
            
            // Check if hit any lizard
            var hitLizard = false
            for i in 0..<lizards.count {
                if lizards[i].isAlive && projectile.hitsLizard(lizards[i]) {
                    lizards[i].isAlive = false
                    hitLizard = true
                    break
                }
            }
            
            if hitLizard {
                continue
            }
            
            activeProjectiles.append(projectile)
        }
        
        projectiles = activeProjectiles
    }
    
    /// Update all lizards' AI behavior
    func updateLizards() {
        for i in 0..<lizards.count {
            if lizards[i].isAlive {
                // Create a grid that includes tank positions as obstacles
                var obstacleGrid = grid
                for tank in tanks where tank.isAlive {
                    if tank.row >= 0 && tank.row < obstacleGrid.count &&
                       tank.col >= 0 && tank.col < obstacleGrid[0].count {
                        obstacleGrid[tank.row][tank.col] = .wall
                    }
                }
                // Also treat other lizards as obstacles
                for (j, otherLizard) in lizards.enumerated() where j != i && otherLizard.isAlive {
                    if otherLizard.row >= 0 && otherLizard.row < obstacleGrid.count &&
                       otherLizard.col >= 0 && otherLizard.col < obstacleGrid[0].count {
                        obstacleGrid[otherLizard.row][otherLizard.col] = .wall
                    }
                }
                _ = lizards[i].update(grid: obstacleGrid)
            }
        }
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
