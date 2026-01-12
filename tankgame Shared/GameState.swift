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
    
    /// AI bot manager for controlling bot tanks
    var botManager: AIBotManager = AIBotManager()
    
    /// Indices of tanks controlled by AI bots
    var botTankIndices: Set<Int> = []
    
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
    
    init(seed: UInt32, playerCount: Int, localPlayerIndex: Int, botIndices: [Int] = []) {
        self.grid = GridGenerator.generate(seed: seed)
        self.localPlayerIndex = localPlayerIndex
        self.botTankIndices = Set(botIndices)
        
        // Initialize tanks for all players
        var initialTanks: [Tank] = []
        for i in 0..<playerCount {
            let spawn = GameState.spawnPositions[i]
            initialTanks.append(Tank(row: spawn.row, col: spawn.col, direction: spawn.direction))
        }
        self.tanks = initialTanks
        
        // Initialize wins array
        self.wins = Array(repeating: 0, count: playerCount)
        
        // Initialize bot manager
        botManager.initialize(botIndices: botIndices)
        
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
        
        // Reset bot manager
        botManager.reset()
        
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
        projectiles = projectiles.compactMap { projectile in
            var p = projectile
            p.advance()
            
            // Remove if out of bounds or hit wall
            guard !p.isOutOfBounds(gridSize: 8) && !p.hits(grid: grid) else { return nil }
            
            // Check for tank hits
            for i in 0..<tanks.count where p.hits(tank: tanks[i]) {
                tanks[i].isAlive = false
                return nil
            }
            
            // Check for lizard hits
            for i in 0..<lizards.count where lizards[i].isAlive && p.hitsLizard(lizards[i]) {
                lizards[i].isAlive = false
                return nil
            }
            
            return p
        }
    }
    
    /// Update all lizards' AI behavior
    func updateLizards() {
        func isValid(_ row: Int, _ col: Int) -> Bool {
            row >= 0 && row < grid.count && col >= 0 && col < grid[0].count
        }
        
        for i in lizards.indices where lizards[i].isAlive {
            var obstacleGrid = grid
            // Mark tanks as obstacles
            for tank in tanks where tank.isAlive && isValid(tank.row, tank.col) {
                obstacleGrid[tank.row][tank.col] = .wall
            }
            // Mark other lizards as obstacles
            for (j, lizard) in lizards.enumerated() where j != i && lizard.isAlive && isValid(lizard.row, lizard.col) {
                obstacleGrid[lizard.row][lizard.col] = .wall
            }
            _ = lizards[i].update(grid: obstacleGrid)
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
