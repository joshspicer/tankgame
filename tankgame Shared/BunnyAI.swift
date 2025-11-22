//
//  BunnyAI.swift
//  tankgame Shared
//
//  AI controller for bunny rabbit opponent
//

import Foundation

/// Simple AI that behaves like a bunny rabbit - hops around randomly
class BunnyAI {
    private var lastMoveTime: TimeInterval = 0
    private var lastShootTime: TimeInterval = 0
    private let moveInterval: TimeInterval = 0.5 // Hop every 0.5 seconds
    private let shootInterval: TimeInterval = 2.0 // Shoot every 2 seconds
    
    /// Update the AI and return actions to take
    func update(currentTime: TimeInterval, tank: Tank, gameState: GameState) -> AIAction? {
        // Don't act if tank is dead
        guard tank.isAlive else { return nil }
        
        // Check if it's time to move (hop)
        if currentTime - lastMoveTime >= moveInterval {
            lastMoveTime = currentTime
            
            // Randomly choose a direction to hop
            let directions: [Direction] = [.up, .down, .left, .right]
            if let randomDirection = directions.randomElement() {
                return .move(randomDirection)
            }
        }
        
        // Check if it's time to shoot
        if currentTime - lastShootTime >= shootInterval {
            lastShootTime = currentTime  // Update time regardless of outcome
            // 50% chance to shoot when interval elapses
            if Bool.random() {
                return .shoot
            }
        }
        
        return nil
    }
}

/// Actions that AI can take
enum AIAction {
    case move(Direction)
    case shoot
}
