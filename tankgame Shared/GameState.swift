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
    var powerUps: [PowerUp] = []
    var wins: [Int] // Wins for each player
    var localPlayerIndex: Int // Index of the local player in tanks array
    
    // Active power-up timers for each player
    var activePowerUps: [[PowerUpType: TimeInterval]] = []
    
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
        
        // Initialize active power-ups tracking
        self.activePowerUps = Array(repeating: [:], count: playerCount)
        
        // Spawn initial power-ups
        spawnPowerUps()
    }
    
    func reset(seed: UInt32) {
        self.grid = GridGenerator.generate(seed: seed)
        self.projectiles = []
        self.powerUps = []
        self.activePowerUps = Array(repeating: [:], count: tanks.count)
        
        // Reset all tanks to their spawn positions
        for i in 0..<tanks.count {
            let spawn = GameState.spawnPositions[i]
            tanks[i] = Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
        }
        
        // Spawn new power-ups
        spawnPowerUps()
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
            
            // Check if hit destructible wall - destroy it
            if projectile.hitsDestructibleWall(grid: grid) {
                grid[projectile.row][projectile.col] = .empty
                continue // Remove this projectile
            }
            
            // Check if hit solid wall
            if projectile.hits(grid: grid) {
                continue // Remove this projectile
            }
            
            // Check if hit any tank
            var hitTank = false
            for i in 0..<tanks.count {
                if projectile.hits(tank: tanks[i]) {
                    tanks[i].takeDamage()
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
    
    /// Spawn power-ups at random empty locations
    func spawnPowerUps() {
        powerUps.removeAll()
        
        // Find empty cells
        var emptyCells: [(row: Int, col: Int)] = []
        for row in 2..<6 { // Only spawn in center area
            for col in 2..<6 {
                if grid[row][col] == .empty {
                    emptyCells.append((row, col))
                }
            }
        }
        
        // Spawn 2-3 random power-ups
        let powerUpCount = Int.random(in: 2...3)
        for _ in 0..<min(powerUpCount, emptyCells.count) {
            guard let randomCell = emptyCells.randomElement() else { break }
            emptyCells.removeAll { $0.row == randomCell.row && $0.col == randomCell.col }
            
            let types: [PowerUpType] = [.health, .rapidFire, .speedBoost]
            let randomType = types.randomElement() ?? .health
            
            powerUps.append(PowerUp(row: randomCell.row, col: randomCell.col, type: randomType))
        }
    }
    
    /// Check and collect power-ups for all tanks
    func checkPowerUpCollisions() -> [(playerIndex: Int, powerUpType: PowerUpType)] {
        var collected: [(Int, PowerUpType)] = []
        
        for i in 0..<tanks.count {
            let tank = tanks[i]
            for j in 0..<powerUps.count {
                if powerUps[j].isCollectedBy(tank: tank) {
                    let powerUpType = powerUps[j].type
                    collected.append((i, powerUpType))
                    powerUps[j].isActive = false
                    
                    // Apply power-up effect
                    applyPowerUp(type: powerUpType, to: i)
                }
            }
        }
        
        // Remove collected power-ups
        powerUps.removeAll { !$0.isActive }
        
        return collected
    }
    
    /// Apply power-up effect to a tank
    private func applyPowerUp(type: PowerUpType, to playerIndex: Int) {
        switch type {
        case .health:
            tanks[playerIndex].heal(1)
        case .rapidFire, .speedBoost:
            activePowerUps[playerIndex][type] = type.duration
        }
    }
    
    /// Update active power-up timers
    func updatePowerUpTimers(delta: TimeInterval) {
        for i in 0..<activePowerUps.count {
            var updated: [PowerUpType: TimeInterval] = [:]
            for (type, remaining) in activePowerUps[i] {
                let newRemaining = remaining - delta
                if newRemaining > 0 {
                    updated[type] = newRemaining
                }
            }
            activePowerUps[i] = updated
        }
    }
    
    /// Check if a player has a specific power-up active
    func hasPowerUp(_ type: PowerUpType, for playerIndex: Int) -> Bool {
        return activePowerUps[playerIndex][type] != nil
    }
}
