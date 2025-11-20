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
    var currentTime: TimeInterval = 0
    var lastPowerUpSpawnTime: TimeInterval = 0
    var aiControllers: [AIController?] = [] // AI controller for each player (nil for human players)
    var isAIEnabled: Bool = false
    
    // Spawn positions for up to 4 players
    static let spawnPositions: [(row: Int, col: Int, direction: Direction)] = [
        (0, 0, .down),      // Player 0: top-left
        (7, 7, .up),        // Player 1: bottom-right
        (0, 7, .down),      // Player 2: top-right
        (7, 0, .up)         // Player 3: bottom-left
    ]
    
    init(seed: UInt32, playerCount: Int, localPlayerIndex: Int, enableAI: Bool = false) {
        self.grid = GridGenerator.generate(seed: seed)
        self.localPlayerIndex = localPlayerIndex
        self.isAIEnabled = enableAI
        
        // Initialize tanks for all players
        var initialTanks: [Tank] = []
        for i in 0..<playerCount {
            let spawn = GameState.spawnPositions[i]
            initialTanks.append(Tank(row: spawn.row, col: spawn.col, direction: spawn.direction))
        }
        self.tanks = initialTanks
        
        // Initialize wins array
        self.wins = Array(repeating: 0, count: playerCount)
        
        // Initialize AI controllers
        if enableAI {
            self.aiControllers = (0..<playerCount).map { i in
                // Local player is human, others are AI
                return i == localPlayerIndex ? nil : AIController(difficulty: .medium)
            }
        } else {
            self.aiControllers = Array(repeating: nil, count: playerCount)
        }
    }
    
    func reset(seed: UInt32) {
        self.grid = GridGenerator.generate(seed: seed)
        self.projectiles = []
        self.powerUps = []
        self.currentTime = 0
        self.lastPowerUpSpawnTime = 0
        
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
            
            // Check if hit any tank (protected by shield)
            var hitTank = false
            for i in 0..<tanks.count {
                if projectile.hits(tank: tanks[i]) && !tanks[i].hasEffect(.shield) {
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
    }
    
    /// Update power-up effects and spawn new power-ups
    func updatePowerUps() {
        // Update active effects on all tanks
        for i in 0..<tanks.count {
            tanks[i].updateEffects(currentTime: currentTime)
        }
        
        // Check for power-up collection
        for i in 0..<powerUps.count {
            if !powerUps[i].isActive {
                continue
            }
            
            for j in 0..<tanks.count {
                if powerUps[i].isCollectedBy(tank: tanks[j]) {
                    tanks[j].applyPowerUp(powerUps[i], currentTime: currentTime)
                    powerUps[i].isActive = false
                    break
                }
            }
        }
        
        // Remove collected power-ups
        powerUps.removeAll { !$0.isActive }
        
        // Spawn new power-ups periodically (every 15-20 seconds)
        if currentTime - lastPowerUpSpawnTime > 15.0 && powerUps.count < 2 {
            spawnRandomPowerUp()
            lastPowerUpSpawnTime = currentTime
        }
    }
    
    /// Spawn a random power-up at an empty grid location
    private func spawnRandomPowerUp() {
        // Find empty cells
        var emptyCells: [(row: Int, col: Int)] = []
        for row in 0..<grid.count {
            for col in 0..<grid[0].count {
                if grid[row][col] == .empty {
                    // Check if any tank is at this position
                    let tankAtPosition = tanks.contains { $0.row == row && $0.col == col }
                    if !tankAtPosition {
                        emptyCells.append((row, col))
                    }
                }
            }
        }
        
        guard !emptyCells.isEmpty else { return }
        
        // Pick random cell and power-up type
        let randomCell = emptyCells.randomElement()!
        let types: [PowerUpType] = [.health, .speed, .shield, .rapidFire]
        let randomType = types.randomElement()!
        
        let powerUp = PowerUp(row: randomCell.row, col: randomCell.col, type: randomType)
        powerUps.append(powerUp)
    }
    
    /// Update AI-controlled tanks
    func updateAI() -> [(playerIndex: Int, action: AIAction)] {
        guard isAIEnabled else { return [] }
        
        var actions: [(Int, AIAction)] = []
        
        for i in 0..<aiControllers.count {
            guard let controller = aiControllers[i] else { continue }
            if let action = controller.update(tankIndex: i, gameState: self, currentTime: currentTime) {
                actions.append((i, action))
            }
        }
        
        return actions
    }
    
    /// Execute an AI action
    func executeAIAction(playerIndex: Int, action: AIAction) -> GameMessage? {
        guard playerIndex < tanks.count else { return nil }
        
        switch action {
        case .move(let direction):
            if tanks[playerIndex].move(in: direction, grid: grid) {
                return .playerMove(playerIndex: playerIndex, row: tanks[playerIndex].row, col: tanks[playerIndex].col, direction: tanks[playerIndex].direction)
            }
        case .shoot(let direction):
            if tanks[playerIndex].canShoot(currentTime: currentTime) {
                tanks[playerIndex].direction = direction
                let projectile = tanks[playerIndex].shoot()
                projectiles.append(projectile)
                tanks[playerIndex].lastShootTime = currentTime
                return .playerShoot(playerIndex: playerIndex, projectile: projectile)
            }
        }
        
        return nil
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
