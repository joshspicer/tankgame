//
//  GameState.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

// Network message types
enum GameMessage: Codable {
    case roundStart(seed: UInt32, isInitiator: Bool)
    case playerMove(row: Int, col: Int, direction: Direction)
    case playerShoot(projectile: Projectile)
    case playerHit(playerIndex: Int)
    case readyForNextRound
}

final class GameState {
    var grid: [[GridCell]]
    var localTank: Tank
    var remoteTank: Tank
    var projectiles: [Projectile] = []
    var localWins: Int = 0
    var remoteWins: Int = 0
    var isLocalPlayer1: Bool // true if we're player 1 (top-left spawn)
    
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
    
    func isRoundOver() -> Bool {
        return !localTank.isAlive || !remoteTank.isAlive
    }
    
    func localPlayerWon() -> Bool {
        return !remoteTank.isAlive && localTank.isAlive
    }
}
