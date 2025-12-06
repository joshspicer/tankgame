//
//  AIBotManager.swift
//  tankgame Shared
//
//  Manages multiple AI bot tanks and coordinates their updates
//

import Foundation

/// Manages AI bot tanks and their behavior updates
class AIBotManager {
    
    /// AI controllers for each bot
    private var bots: [AIBotTank] = []
    
    /// Indices of tanks that are controlled by AI bots
    private(set) var botTankIndices: Set<Int> = []
    
    /// Default difficulty level for new bots
    private(set) var difficulty: AIDifficulty = .medium
    
    /// Callback when a bot wants to shoot
    var onBotShoot: ((Int, Projectile) -> Void)?
    
    /// Callback when a bot moves
    var onBotMove: ((Int, Int, Int, Direction) -> Void)?
    
    /// Set the difficulty level for bots
    /// - Parameter difficulty: The difficulty level to use
    func setDifficulty(_ difficulty: AIDifficulty) {
        self.difficulty = difficulty
        // Reinitialize existing bots with new difficulty
        if !bots.isEmpty {
            let indices = Array(botTankIndices)
            initialize(botIndices: indices)
        }
    }
    
    /// Initialize the bot manager with specified bot tank indices
    /// - Parameter botIndices: The indices of tanks to be controlled by AI
    func initialize(botIndices: [Int]) {
        bots = []
        botTankIndices = Set(botIndices)
        
        for index in botIndices {
            bots.append(AIBotTank(tankIndex: index, difficulty: difficulty))
        }
    }
    
    /// Initialize the bot manager with specified bot tank indices and difficulty
    /// - Parameters:
    ///   - botIndices: The indices of tanks to be controlled by AI
    ///   - difficulty: The difficulty level for the bots
    func initialize(botIndices: [Int], difficulty: AIDifficulty) {
        self.difficulty = difficulty
        initialize(botIndices: botIndices)
    }
    
    /// Check if a tank index is controlled by a bot
    func isBot(tankIndex: Int) -> Bool {
        return botTankIndices.contains(tankIndex)
    }
    
    /// Update all bots
    /// - Parameters:
    ///   - tanks: All tanks in the game
    ///   - grid: The game grid
    ///   - projectiles: Current projectiles
    func update(tanks: inout [Tank], grid: [[GridCell]], projectiles: [Projectile]) {
        for i in bots.indices {
            let tankIndex = bots[i].tankIndex
            guard tankIndex < tanks.count && tanks[tankIndex].isAlive else { continue }
            
            // Get movement decision from bot (mutating call)
            let direction = bots[i].update(tank: tanks[tankIndex], grid: grid, allTanks: tanks, projectiles: projectiles)
            
            if let direction = direction {
                // Try to move the tank
                if tanks[tankIndex].move(in: direction, grid: grid) {
                    onBotMove?(tankIndex, tanks[tankIndex].row, tanks[tankIndex].col, tanks[tankIndex].direction)
                }
            }
            
            // Check if bot wants to shoot
            if bots[i].shouldShoot {
                let projectile = tanks[tankIndex].shoot()
                onBotShoot?(tankIndex, projectile)
            }
        }
    }
    
    /// Reset the bot manager
    func reset() {
        // Reinitialize bots with randomized counters (keeping same difficulty)
        let indices = Array(botTankIndices)
        initialize(botIndices: indices)
    }
    
    /// Get the number of active bots
    var botCount: Int {
        return bots.count
    }
    
    /// Check if there are any active bots
    var hasBots: Bool {
        return !bots.isEmpty
    }
    
    /// Get the current difficulty level
    var currentDifficulty: AIDifficulty {
        return difficulty
    }
}
