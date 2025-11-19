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
    var statistics: [PlayerStatistics] // Stats for each player
    var currentTime: TimeInterval = 0
    
    // Power-up spawn settings
    private var nextPowerUpSpawnTime: TimeInterval = 0
    private let powerUpSpawnInterval: TimeInterval = 15.0 // Spawn every 15 seconds
    private let maxPowerUps = 3 // Maximum power-ups on map at once
    
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
        
        // Initialize statistics
        self.statistics = (0..<playerCount).map { _ in PlayerStatistics() }
        
        // Set first power-up spawn time
        self.nextPowerUpSpawnTime = powerUpSpawnInterval
    }
    
    func reset(seed: UInt32) {
        self.grid = GridGenerator.generate(seed: seed)
        self.projectiles = []
        self.powerUps = []
        self.currentTime = 0
        self.nextPowerUpSpawnTime = powerUpSpawnInterval
        
        // Reset all tanks to their spawn positions
        for i in 0..<tanks.count {
            let spawn = GameState.spawnPositions[i]
            tanks[i] = Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
        }
        
        // Reset round statistics but keep wins
        for i in 0..<statistics.count {
            statistics[i].resetRound()
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
            
            // Check if hit destructible wall - destroy it and remove projectile
            if projectile.hitsDestructibleWall(grid: grid) {
                grid[projectile.row][projectile.col] = .empty
                continue
            }
            
            // Check if hit regular wall
            if projectile.hits(grid: grid) {
                continue // Remove this projectile
            }
            
            // Check if hit any tank
            var hitTank = false
            for i in 0..<tanks.count {
                if projectile.hits(tank: tanks[i]) {
                    tanks[i].takeDamage(currentTime: currentTime)
                    hitTank = true
                    
                    // Update statistics
                    if let shooterIndex = projectile.ownerIndex {
                        statistics[shooterIndex].hits += 1
                    }
                    
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
    
    /// Update power-ups and spawn new ones
    func updatePowerUps(deltaTime: TimeInterval) {
        currentTime += deltaTime
        
        // Update tank power-ups
        for i in 0..<tanks.count {
            tanks[i].updatePowerUps(currentTime: currentTime)
        }
        
        // Check if it's time to spawn a new power-up
        if currentTime >= nextPowerUpSpawnTime && powerUps.count < maxPowerUps {
            spawnRandomPowerUp()
            nextPowerUpSpawnTime = currentTime + powerUpSpawnInterval
        }
        
        // Check for power-up collection
        for i in 0..<tanks.count {
            guard tanks[i].isAlive else { continue }
            
            for j in 0..<powerUps.count {
                if powerUps[j].isActive && 
                   powerUps[j].row == tanks[i].row && 
                   powerUps[j].col == tanks[i].col {
                    // Collect power-up
                    tanks[i].applyPowerUp(powerUps[j].type, currentTime: currentTime)
                    powerUps[j].isActive = false
                    
                    // Update statistics
                    statistics[i].powerUpsCollected += 1
                }
            }
        }
        
        // Remove collected power-ups
        powerUps.removeAll { !$0.isActive }
    }
    
    /// Spawn a random power-up at an empty location
    private func spawnRandomPowerUp() {
        // Find empty cells
        var emptyCells: [(row: Int, col: Int)] = []
        for row in 0..<8 {
            for col in 0..<8 {
                if grid[row][col] == .empty {
                    // Make sure no tank is on this cell
                    let tankOnCell = tanks.contains { $0.row == row && $0.col == col }
                    if !tankOnCell {
                        emptyCells.append((row, col))
                    }
                }
            }
        }
        
        guard !emptyCells.isEmpty else { return }
        
        // Pick random cell and random power-up type
        let randomCell = emptyCells.randomElement()!
        let randomType = PowerUpType.allCases.randomElement()!
        
        let powerUp = PowerUp(row: randomCell.row, col: randomCell.col, type: randomType)
        powerUps.append(powerUp)
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
