//
//  GameState.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Messages exchanged between players during multiplayer gameplay
enum GameMessage: Codable {
    case roundStart(seed: UInt32, isInitiator: Bool)
    case playerMove(row: Int, col: Int, direction: Direction)
    case playerShoot(projectile: Projectile)
    case playerHit(playerIndex: Int)
    case readyForNextRound
}

/// Manages the state of a tank game round including grid, tanks, and projectiles
final class GameState {
    var grid: [[GridCell]]
    var localTank: Tank
    var remoteTank: Tank
    var projectiles: [Projectile] = []
    var localWins: Int = 0
    var remoteWins: Int = 0
    var isLocalPlayer1: Bool // true if we're player 1 (top-left spawn)
    
    /// Initializes a new game state with the given parameters
    /// - Parameters:
    ///   - seed: Random seed for deterministic grid generation
    ///   - isPlayer1: Whether this player spawns at top-left (true) or bottom-right (false)
    init(seed: UInt32, isPlayer1: Bool) {
        self.grid = GridGenerator.generate(seed: seed)
        self.isLocalPlayer1 = isPlayer1
        
        if isPlayer1 {
            // Player 1: top-left
            self.localTank = Tank(row: 0, col: 0, direction: .down)
            // Player 2: bottom-right
            self.remoteTank = Tank(row: 7, col: 7, direction: .up)
        } else {
            // Player 2: bottom-right
            self.localTank = Tank(row: 7, col: 7, direction: .up)
            // Player 1: top-left
            self.remoteTank = Tank(row: 0, col: 0, direction: .down)
        }
    }
    
    /// Resets the game state for a new round with a new grid
    /// - Parameter seed: Random seed for deterministic grid generation
    func reset(seed: UInt32) {
        self.grid = GridGenerator.generate(seed: seed)
        self.projectiles = []
        
        if isLocalPlayer1 {
            self.localTank = Tank(row: 0, col: 0, direction: .down)
            self.remoteTank = Tank(row: 7, col: 7, direction: .up)
        } else {
            self.localTank = Tank(row: 7, col: 7, direction: .up)
            self.remoteTank = Tank(row: 0, col: 0, direction: .down)
        }
    }
    
    /// Updates all projectiles, checking for collisions with walls and tanks
    func updateProjectiles() {
        var activeProjectiles: [Projectile] = []
        
        for var projectile in projectiles {
            projectile.advance()
            
            // Check if out of bounds or hit wall
            if projectile.isOutOfBounds(gridSize: 8) || projectile.hits(grid: grid) {
                continue // Remove this projectile
            }
            
            // Check if hit local tank
            if projectile.hits(tank: localTank) {
                localTank.isAlive = false
                continue
            }
            
            // Check if hit remote tank
            if projectile.hits(tank: remoteTank) {
                remoteTank.isAlive = false
                continue
            }
            
            activeProjectiles.append(projectile)
        }
        
        projectiles = activeProjectiles
    }
    
    /// Checks if the current round has ended (at least one tank destroyed)
    /// - Returns: true if round is over, false otherwise
    func isRoundOver() -> Bool {
        return !localTank.isAlive || !remoteTank.isAlive
    }
    
    /// Determines if the local player won the round
    /// - Returns: true if local player won (remote tank destroyed, local tank alive)
    func localPlayerWon() -> Bool {
        return !remoteTank.isAlive && localTank.isAlive
    }
}
