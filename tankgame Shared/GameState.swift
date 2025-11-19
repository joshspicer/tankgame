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
    var wins: [Int] // Wins for each player
    var localPlayerIndex: Int // Index of the local player in tanks array
    
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
    }
    
    func reset(seed: UInt32) {
        self.grid = GridGenerator.generate(seed: seed)
        self.projectiles = []
        
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
            
            // Check if out of bounds
            if projectile.isOutOfBounds(gridSize: 8) {
                continue // Remove this projectile
            }
            
            // Check if hit a wall or breakable wall
            if projectile.hits(grid: grid) {
                // Destroy breakable walls
                if grid[projectile.row][projectile.col].isDestructible {
                    grid[projectile.row][projectile.col] = .empty
                }
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
            
            activeProjectiles.append(projectile)
        }
        
        projectiles = activeProjectiles
        
        // Check if any tank is on a hazard
        for i in 0..<tanks.count {
            let tank = tanks[i]
            if tank.isAlive && grid[tank.row][tank.col].isDangerous {
                tanks[i].isAlive = false
            }
        }
        
        // Check if any tank collected a power-up
        for i in 0..<tanks.count {
            let tank = tanks[i]
            if tank.isAlive && grid[tank.row][tank.col] == .powerUp {
                // For now, just remove the power-up (could add effects later)
                grid[tank.row][tank.col] = .empty
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
