//
//  GameState.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Manages the state of a game round including tanks, projectiles, grid, and scoring
///
/// The GameState coordinates all entities in a single game round and handles:
/// - Tank positions and states
/// - Projectile movement and collision detection
/// - Win tracking across rounds
/// - Round lifecycle (start, update, end)
final class GameState {
    /// The 8x8 grid of cells (empty or wall)
    var grid: [[GridCell]]
    /// Array of all tanks (index = player index)
    var tanks: [Tank]
    /// Active projectiles currently traveling on the grid
    var projectiles: [Projectile] = []
    /// Win count for each player across multiple rounds
    var wins: [Int]
    /// The local player's index in the tanks array
    var localPlayerIndex: Int
    
    /// Spawn positions for up to 4 players at the corners of the grid
    static let spawnPositions: [(row: Int, col: Int, direction: Direction)] = [
        (0, 0, .down),      // Player 0: top-left
        (7, 7, .up),        // Player 1: bottom-right
        (0, 7, .down),      // Player 2: top-right
        (7, 0, .up)         // Player 3: bottom-left
    ]
    
    /// Initializes a new game state
    /// - Parameters:
    ///   - seed: The seed for deterministic grid generation
    ///   - playerCount: Number of players in the game (2-4)
    ///   - localPlayerIndex: Index identifying which tank belongs to the local player
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
    
    /// Resets the game state for a new round
    /// - Parameter seed: New seed for grid generation (different seed = different wall layout)
    func reset(seed: UInt32) {
        self.grid = GridGenerator.generate(seed: seed)
        self.projectiles = []
        
        // Reset all tanks to their spawn positions
        for i in 0..<tanks.count {
            let spawn = GameState.spawnPositions[i]
            tanks[i] = Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
        }
    }
    
    /// Convenience accessor for the local player's tank
    var localTank: Tank {
        get { tanks[localPlayerIndex] }
        set { tanks[localPlayerIndex] = newValue }
    }
    
    /// Updates all active projectiles by moving them forward and checking for collisions
    ///
    /// This method:
    /// 1. Advances each projectile one cell
    /// 2. Removes projectiles that go out of bounds or hit walls
    /// 3. Removes projectiles that hit tanks (and marks tanks as dead)
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
    
    /// Checks if the current round is over
    /// - Returns: true if one or zero tanks remain alive
    func isRoundOver() -> Bool {
        let aliveTanks = tanks.filter { $0.isAlive }
        return aliveTanks.count <= 1
    }
    
    /// Checks if the local player won the current round
    /// - Returns: true if the local player is alive and all other players are dead
    func localPlayerWon() -> Bool {
        // Local player won if they're the only one alive
        if !tanks[localPlayerIndex].isAlive {
            return false
        }
        
        let aliveTanks = tanks.filter { $0.isAlive }
        return aliveTanks.count == 1
    }
    
    /// Gets the player index of the round winner, if any
    /// - Returns: The player index of the sole survivor, or nil if no clear winner
    func getWinner() -> Int? {
        let aliveTanks = tanks.enumerated().filter { $0.element.isAlive }
        if aliveTanks.count == 1 {
            return aliveTanks.first?.offset
        }
        return nil
    }
}
