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
    var activePowerUps: [Int: [ActivePowerUp]] = [:] // playerIndex -> active power-ups
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
        self.powerUps = []
        self.activePowerUps = [:]
        
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
                    // Check if tank has shield
                    if tanks[i].hasShield {
                        tanks[i].hasShield = false // Remove shield
                        // Remove the shield power-up from active list
                        activePowerUps[i]?.removeAll { $0.type == .shield }
                    } else {
                        tanks[i].isAlive = false
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
    
    func spawnPowerUp() {
        // Find empty cells for power-up spawn
        var emptyCells: [(row: Int, col: Int)] = []
        for row in 0..<8 {
            for col in 0..<8 {
                if grid[row][col] == .empty {
                    // Check if no tank is on this cell
                    let tankOnCell = tanks.contains { $0.row == row && $0.col == col && $0.isAlive }
                    // Check if no power-up is on this cell
                    let powerUpOnCell = powerUps.contains { $0.row == row && $0.col == col && $0.isActive }
                    if !tankOnCell && !powerUpOnCell {
                        emptyCells.append((row, col))
                    }
                }
            }
        }
        
        // Spawn power-up at random empty cell
        if let cell = emptyCells.randomElement() {
            let powerUp = PowerUp(row: cell.row, col: cell.col, type: PowerUp.randomType())
            powerUps.append(powerUp)
        }
    }
    
    func checkPowerUpCollisions(currentTime: TimeInterval) {
        for i in 0..<tanks.count {
            guard tanks[i].isAlive else { continue }
            
            let tank = tanks[i]
            for j in 0..<powerUps.count {
                guard powerUps[j].isActive else { continue }
                
                if tank.row == powerUps[j].row && tank.col == powerUps[j].col {
                    // Tank collected power-up
                    let powerUpType = powerUps[j].type
                    powerUps[j].isActive = false
                    
                    // Add active power-up for this player
                    let activePowerUp = ActivePowerUp(type: powerUpType, expiresAt: currentTime + powerUpType.duration)
                    if activePowerUps[i] == nil {
                        activePowerUps[i] = []
                    }
                    activePowerUps[i]?.append(activePowerUp)
                    
                    // Apply shield immediately if it's a shield power-up
                    if powerUpType == .shield {
                        tanks[i].hasShield = true
                    }
                }
            }
        }
        
        // Remove inactive power-ups
        powerUps.removeAll { !$0.isActive }
    }
    
    func updateActivePowerUps(currentTime: TimeInterval) {
        // Remove expired power-ups and update shields
        for playerIndex in activePowerUps.keys {
            activePowerUps[playerIndex]?.removeAll { powerUp in
                if currentTime >= powerUp.expiresAt {
                    // Remove shield when it expires
                    if powerUp.type == .shield {
                        tanks[playerIndex].hasShield = false
                    }
                    return true
                }
                return false
            }
            
            // Remove empty arrays
            if activePowerUps[playerIndex]?.isEmpty == true {
                activePowerUps.removeValue(forKey: playerIndex)
            }
        }
    }
    
    func hasPowerUp(playerIndex: Int, type: PowerUpType) -> Bool {
        return activePowerUps[playerIndex]?.contains { $0.type == type } ?? false
    }
}
