//
//  AIController.swift
//  tankgame Shared
//
//  Manages AI opponents in the game
//

import Foundation

/// Manages all AI-controlled tanks
class AIController {
    private var aiPlayers: [Int: BunnyAI] = [:] // Map of tank index to AI instance
    
    /// Register a tank to be controlled by AI
    func registerAI(for tankIndex: Int) {
        aiPlayers[tankIndex] = BunnyAI()
    }
    
    /// Check if a tank is AI-controlled
    func isAIControlled(_ tankIndex: Int) -> Bool {
        return aiPlayers[tankIndex] != nil
    }
    
    /// Update all AI players and return their actions
    func update(currentTime: TimeInterval, gameState: GameState) -> [(tankIndex: Int, action: AIAction)] {
        var actions: [(Int, AIAction)] = []
        
        for (tankIndex, ai) in aiPlayers {
            guard tankIndex < gameState.tanks.count else { continue }
            let tank = gameState.tanks[tankIndex]
            
            if let action = ai.update(currentTime: currentTime, tank: tank, gameState: gameState) {
                actions.append((tankIndex, action))
            }
        }
        
        return actions
    }
}
