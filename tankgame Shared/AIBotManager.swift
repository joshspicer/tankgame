//
//  AIBotManager.swift
//  tankgame Shared
//
//  Manages AI bots in the game, handling their updates and actions
//

import Foundation

/// Manages all AI bots in the game
class AIBotManager {
    /// All active AI bots
    private(set) var bots: [AIBot] = []
    
    /// Callback when a bot moves
    var onBotMove: ((Int, Int, Int, Direction) -> Void)?
    
    /// Callback when a bot shoots
    var onBotShoot: ((Int, Projectile) -> Void)?
    
    /// Whether AI bots are enabled for this game
    private(set) var isEnabled: Bool = false
    
    /// Add an AI bot for a specific player index
    func addBot(playerIndex: Int, difficulty: AIBotDifficulty = .medium) {
        let bot = AIBot(playerIndex: playerIndex, difficulty: difficulty)
        bots.append(bot)
        isEnabled = true
    }
    
    /// Remove all bots
    func removeAllBots() {
        bots.removeAll()
        isEnabled = false
    }
    
    /// Reset all bots for a new round
    func reset() {
        for i in 0..<bots.count {
            bots[i].moveCounter = 0
            bots[i].shootCooldown = 0
            bots[i].targetPlayerIndex = nil
        }
    }
    
    /// Check if a player index is controlled by a bot
    func isBot(playerIndex: Int) -> Bool {
        return bots.contains { $0.playerIndex == playerIndex }
    }
    
    /// Update all bots and process their actions
    /// - Parameters:
    ///   - tanks: All tanks in the game (will be mutated for bot movements)
    ///   - grid: The game grid
    ///   - projectiles: Current projectiles (for bot to add new shots)
    func update(tanks: inout [Tank], grid: [[GridCell]], projectiles: inout [Projectile]) {
        guard isEnabled else { return }
        
        for i in 0..<bots.count {
            let playerIndex = bots[i].playerIndex
            guard playerIndex < tanks.count else { continue }
            
            let tank = tanks[playerIndex]
            guard tank.isAlive else { continue }
            
            // Update bot and get action
            if let action = bots[i].update(
                tank: tank,
                allTanks: tanks,
                grid: grid,
                projectiles: projectiles
            ) {
                switch action {
                case .move(let direction):
                    // Execute move
                    if tanks[playerIndex].move(in: direction, grid: grid) {
                        onBotMove?(playerIndex, tanks[playerIndex].row, tanks[playerIndex].col, direction)
                    }
                    
                case .shoot:
                    // Execute shoot (bot only returns shoot action when facing target)
                    let projectile = tanks[playerIndex].shoot()
                    projectiles.append(projectile)
                    onBotShoot?(playerIndex, projectile)
                }
            }
        }
    }
}
