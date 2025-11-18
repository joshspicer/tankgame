//
//  GameState.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Manages the state of a game round including tanks, projectiles, and grid
final class GameState {
    // MARK: - Properties
    
    /// The game grid containing walls and empty spaces
    var grid: [[GridCell]]
    
    /// Array of all tanks (index corresponds to player index)
    var tanks: [Tank]
    
    /// Active projectiles in the game
    var projectiles: [Projectile] = []
    
    /// Win count for each player (index corresponds to player index)
    var wins: [Int]
    
    /// Index of the local player in the tanks array
    var localPlayerIndex: Int
    
    // MARK: - Constants
    
    /// Spawn positions for up to 4 players at the corners of the grid
    static let spawnPositions: [(row: Int, col: Int, direction: Direction)] = [
        (0, 0, .down),      // Player 0: top-left
        (7, 7, .up),        // Player 1: bottom-right
        (0, 7, .down),      // Player 2: top-right
        (7, 0, .up)         // Player 3: bottom-left
    ]
    
    // MARK: - Initialization
    
    /// Creates a new game state
    /// - Parameters:
    ///   - seed: Random seed for grid generation
    ///   - playerCount: Number of players (2-4)
    ///   - localPlayerIndex: Index of the local player
    init(seed: UInt32, playerCount: Int, localPlayerIndex: Int) {
        self.grid = GridGenerator.generate(seed: seed)
        self.localPlayerIndex = localPlayerIndex
        
        // Initialize tanks for all players
        var initialTanks: [Tank] = []
        for i in 0..<playerCount {
            let spawn = GameState.spawnPositions[i]
            initialTanks.append(Tank(row: spawn.row, col: spawn.col, direction: spawn.direction))
        }
        self.tanks = initialTanks
        
        // Initialize wins array
        self.wins = Array(repeating: 0, count: playerCount)
    }
    
    // MARK: - Round Management
    
    /// Resets the game state for a new round
    /// - Parameter seed: Random seed for the new grid
    func reset(seed: UInt32) {
        self.grid = GridGenerator.generate(seed: seed)
        self.projectiles = []
        
        // Reset all tanks to their spawn positions
        for i in 0..<tanks.count {
            let spawn = GameState.spawnPositions[i]
            tanks[i] = Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
        }
    }
    
    // MARK: - Computed Properties
    
    /// Convenience accessor for the local player's tank
    var localTank: Tank {
        get { tanks[localPlayerIndex] }
        set { tanks[localPlayerIndex] = newValue }
    }
    
    // MARK: - Game Logic
    
    /// Updates all projectiles and checks for collisions
    /// Removes projectiles that go out of bounds, hit walls, or hit tanks
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
                if projectile.hits(tank: tanks[i]) {
                    tanks[i].isAlive = false
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
    
    // MARK: - Round State Queries
    
    /// Checks if the current round is over
    /// A round is over when 1 or fewer tanks remain alive
    /// - Returns: true if the round has ended
    func isRoundOver() -> Bool {
        let aliveTanks = tanks.filter { $0.isAlive }
        return aliveTanks.count <= 1
    }
    
    /// Checks if the local player won the round
    /// - Returns: true if the local player is the sole survivor
    func localPlayerWon() -> Bool {
        // Local player won if they're the only one alive
        if !tanks[localPlayerIndex].isAlive {
            return false
        }
        
        let aliveTanks = tanks.filter { $0.isAlive }
        return aliveTanks.count == 1
    }
    
    /// Gets the player index of the round winner
    /// - Returns: Player index if there's exactly one survivor, nil otherwise
    func getWinner() -> Int? {
        let aliveTanks = tanks.enumerated().filter { $0.element.isAlive }
        if aliveTanks.count == 1 {
            return aliveTanks.first?.offset
        }
        return nil
    }
}
