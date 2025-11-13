//
//  GameState.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

// Network message types
enum GameMessage: Codable {
    case roundStart(seed: UInt32, numberOfPlayers: Int, playerIndex: Int)
    case playerMove(playerIndex: Int, row: Int, col: Int, direction: Direction)
    case playerShoot(playerIndex: Int, projectile: Projectile)
    case playerHit(playerIndex: Int)
    case readyForNextRound
    case playerIndexAssignment(playerIndex: Int) // Sent by host to assign player index to client
}

final class GameState {
    var grid: [[GridCell]]
    var tanks: [Tank] // Array of all tanks (local player is at localPlayerIndex)
    var projectiles: [(projectile: Projectile, ownerIndex: Int)] = []
    var wins: [Int] // Wins for each player
    var localPlayerIndex: Int // Index of the local player in the tanks array
    
    // Spawn positions for up to 4 players (corners)
    static let spawnPositions: [(row: Int, col: Int, direction: Direction)] = [
        (0, 0, .down),      // Player 0: top-left
        (0, 7, .down),      // Player 1: top-right
        (7, 7, .up),        // Player 2: bottom-right
        (7, 0, .up)         // Player 3: bottom-left
    ]
    
    init(seed: UInt32, numberOfPlayers: Int, localPlayerIndex: Int) {
        self.grid = GridGenerator.generate(seed: seed)
        self.localPlayerIndex = localPlayerIndex
        self.wins = Array(repeating: 0, count: numberOfPlayers)
        
        // Initialize tanks at spawn positions
        self.tanks = (0..<numberOfPlayers).map { playerIndex in
            let spawn = GameState.spawnPositions[playerIndex % GameState.spawnPositions.count]
            return Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
        }
    }
    
    func reset(seed: UInt32) {
        self.grid = GridGenerator.generate(seed: seed)
        self.projectiles = []
        
        // Reset all tanks to their spawn positions
        for (index, _) in tanks.enumerated() {
            let spawn = GameState.spawnPositions[index % GameState.spawnPositions.count]
            tanks[index] = Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
        }
    }
    
    func updateProjectiles() {
        var activeProjectiles: [(projectile: Projectile, ownerIndex: Int)] = []
        
        for (var projectile, ownerIndex) in projectiles {
            projectile.advance()
            
            // Check if out of bounds or hit wall
            if projectile.isOutOfBounds(gridSize: 8) || projectile.hits(grid: grid) {
                continue // Remove this projectile
            }
            
            // Check if hit any tank
            var hitTank = false
            for (index, _) in tanks.enumerated() {
                if projectile.hits(tank: tanks[index]) {
                    tanks[index].isAlive = false
                    hitTank = true
                    break
                }
            }
            
            if hitTank {
                continue // Remove this projectile
            }
            
            activeProjectiles.append((projectile, ownerIndex))
        }
        
        projectiles = activeProjectiles
    }
    
    func isRoundOver() -> Bool {
        let aliveTanks = tanks.filter { $0.isAlive }
        return aliveTanks.count <= 1
    }
    
    func localPlayerWon() -> Bool {
        let aliveTanks = tanks.enumerated().filter { $0.element.isAlive }
        return aliveTanks.count == 1 && aliveTanks.first?.offset == localPlayerIndex
    }
    
    var localTank: Tank {
        get { tanks[localPlayerIndex] }
        set { tanks[localPlayerIndex] = newValue }
    }
}
