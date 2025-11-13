//
//  GameState.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

// Network message types
enum GameMessage: Codable {
    case roundStart(seed: UInt32, playerIndex: Int, totalPlayers: Int)
    case playerMove(playerIndex: Int, row: Int, col: Int, direction: Direction)
    case playerShoot(playerIndex: Int, projectile: Projectile)
    case playerHit(playerIndex: Int)
    case readyForNextRound(playerIndex: Int)
    case gameStart(seed: UInt32, playerIndices: [String: Int]) // peerID to playerIndex mapping
}

struct PlayerTank: Codable {
    var tank: Tank
    var playerIndex: Int
    var peerID: String // Display name or unique identifier
    
    init(tank: Tank, playerIndex: Int, peerID: String) {
        self.tank = tank
        self.playerIndex = playerIndex
        self.peerID = peerID
    }
}

final class GameState {
    var grid: [[GridCell]]
    var tanks: [PlayerTank] = [] // All player tanks
    var localPlayerIndex: Int // Index of local player in tanks array
    var projectiles: [Projectile] = []
    var wins: [Int: Int] = [:] // playerIndex -> win count
    var totalPlayers: Int
    
    init(seed: UInt32, localPlayerIndex: Int, totalPlayers: Int, peerIDs: [String]) {
        self.grid = GridGenerator.generate(seed: seed)
        self.localPlayerIndex = localPlayerIndex
        self.totalPlayers = totalPlayers
        
        // Initialize spawn positions based on number of players
        let spawnPositions = Self.getSpawnPositions(for: totalPlayers)
        
        for (index, peerID) in peerIDs.enumerated() {
            let spawn = spawnPositions[index]
            let tank = Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
            let playerTank = PlayerTank(tank: tank, playerIndex: index, peerID: peerID)
            tanks.append(playerTank)
            wins[index] = 0
        }
    }
    
    static func getSpawnPositions(for playerCount: Int) -> [(row: Int, col: Int, direction: Direction)] {
        // Spawn positions for different player counts
        switch playerCount {
        case 2:
            return [
                (row: 0, col: 0, direction: .down),     // Top-left
                (row: 7, col: 7, direction: .up)         // Bottom-right
            ]
        case 3:
            return [
                (row: 0, col: 0, direction: .down),     // Top-left
                (row: 0, col: 7, direction: .down),     // Top-right
                (row: 7, col: 3, direction: .up)         // Bottom-center
            ]
        case 4:
            return [
                (row: 0, col: 0, direction: .down),     // Top-left
                (row: 0, col: 7, direction: .down),     // Top-right
                (row: 7, col: 0, direction: .up),        // Bottom-left
                (row: 7, col: 7, direction: .up)         // Bottom-right
            ]
        default:
            // Default to 2 players
            return [
                (row: 0, col: 0, direction: .down),
                (row: 7, col: 7, direction: .up)
            ]
        }
    }
    
    func reset(seed: UInt32) {
        self.grid = GridGenerator.generate(seed: seed)
        self.projectiles = []
        
        let spawnPositions = Self.getSpawnPositions(for: totalPlayers)
        for i in 0..<tanks.count {
            let spawn = spawnPositions[i]
            tanks[i].tank = Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
        }
    }
    
    var localTank: Tank {
        get {
            return tanks[localPlayerIndex].tank
        }
        set {
            tanks[localPlayerIndex].tank = newValue
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
            
            // Check if hit any tank
            var hitTank = false
            for i in 0..<tanks.count {
                if projectile.hits(tank: tanks[i].tank) {
                    tanks[i].tank.isAlive = false
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
    
    func isRoundOver() -> Bool {
        let aliveTanks = tanks.filter { $0.tank.isAlive }
        return aliveTanks.count <= 1
    }
    
    func localPlayerWon() -> Bool {
        guard localTank.isAlive else { return false }
        let aliveTanks = tanks.filter { $0.tank.isAlive }
        return aliveTanks.count == 1 && aliveTanks[0].playerIndex == localPlayerIndex
    }
    
    func getWinnerIndex() -> Int? {
        let aliveTanks = tanks.filter { $0.tank.isAlive }
        return aliveTanks.count == 1 ? aliveTanks[0].playerIndex : nil
    }
}
