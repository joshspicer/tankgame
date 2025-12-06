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
    
    /// Default difficulty level for bots
    var defaultDifficulty: AIBotDifficulty = .medium
    
    /// Callback when a bot wants to shoot
    var onBotShoot: ((Int, Projectile) -> Void)?
    
    /// Callback when a bot moves
    var onBotMove: ((Int, Int, Int, Direction) -> Void)?
    
    /// Initialize the bot manager with specified bot tank indices
    /// - Parameters:
    ///   - botIndices: The indices of tanks to be controlled by AI
    ///   - difficulty: Optional difficulty level (defaults to manager's default)
    func initialize(botIndices: [Int], difficulty: AIBotDifficulty? = nil) {
        bots = []
        botTankIndices = Set(botIndices)
        
        let difficultyLevel = difficulty ?? defaultDifficulty
        
        for index in botIndices {
            bots.append(AIBotTank(tankIndex: index, difficulty: difficultyLevel))
        }
    }
    
    /// Initialize bots with varying difficulty levels
    /// - Parameter botConfigs: Array of tuples (tankIndex, difficulty)
    func initializeWithVaryingDifficulties(botConfigs: [(index: Int, difficulty: AIBotDifficulty)]) {
        bots = []
        botTankIndices = Set(botConfigs.map { $0.index })
        
        for config in botConfigs {
            bots.append(AIBotTank(tankIndex: config.index, difficulty: config.difficulty))
        }
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
        // Reinitialize bots with randomized counters, keeping current difficulties
        let currentBots = bots
        bots = []
        
        for bot in currentBots {
            bots.append(AIBotTank(tankIndex: bot.tankIndex, difficulty: bot.difficulty))
        }
    }
    
    /// Set difficulty for all bots
    func setDifficulty(_ difficulty: AIBotDifficulty) {
        defaultDifficulty = difficulty
        let indices = Array(botTankIndices)
        initialize(botIndices: indices, difficulty: difficulty)
    }
    
    /// Get the difficulty of a specific bot
    func getDifficulty(forBotAt tankIndex: Int) -> AIBotDifficulty? {
        return bots.first { $0.tankIndex == tankIndex }?.difficulty
    }
    
    /// Get the number of active bots
    var botCount: Int {
        return bots.count
    }
    
    /// Check if there are any active bots
    var hasBots: Bool {
        return !bots.isEmpty
    }
}
