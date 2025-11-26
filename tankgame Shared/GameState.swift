//
//  GameState.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation

/// Manages the state of a game round including tanks, projectiles, dinosaurs, and grid
final class GameState {
    var grid: [[GridCell]]
    var tanks: [Tank] // Array of all tanks (index = player index)
    var projectiles: [Projectile] = []
    var dinosaurs: [Dinosaur] = [] // AI-controlled dinosaurs as hazards
    var wins: [Int] // Wins for each player
    var localPlayerIndex: Int // Index of the local player in tanks array
    
    // Random number generator for dinosaur AI
    var dinosaurRng: SeededRandomNumberGenerator
    
    // Spawn positions for up to 4 players
    static let spawnPositions: [(row: Int, col: Int, direction: Direction)] = [
        (0, 0, .down),      // Player 0: top-left
        (7, 7, .up),        // Player 1: bottom-right
        (0, 7, .down),      // Player 2: top-right
        (7, 0, .up)         // Player 3: bottom-left
    ]
    
    // Dinosaur spawn position (center of the grid)
    static let dinosaurSpawnPosition = (row: 3, col: 4, direction: Direction.down)
    
    init(seed: UInt32, playerCount: Int, localPlayerIndex: Int) {
        self.grid = GridGenerator.generate(seed: seed)
        self.localPlayerIndex = localPlayerIndex
        self.dinosaurRng = SeededRandomNumberGenerator(seed: seed &+ 12345)
        
        // Initialize tanks for all players
        var initialTanks: [Tank] = []
        for i in 0..<playerCount {
            let spawn = GameState.spawnPositions[i]
            initialTanks.append(Tank(row: spawn.row, col: spawn.col, direction: spawn.direction))
        }
        self.tanks = initialTanks
        
        // Initialize wins array
        self.wins = Array(repeating: 0, count: playerCount)
        
        // Spawn one dinosaur in the center area
        spawnDinosaur()
    }
    
    /// Spawn a dinosaur at the designated spawn position
    private func spawnDinosaur() {
        let spawn = GameState.dinosaurSpawnPosition
        // Only spawn if the cell is empty
        if grid[spawn.row][spawn.col] == .empty {
            dinosaurs.append(Dinosaur(row: spawn.row, col: spawn.col, direction: spawn.direction))
        }
    }
    
    func reset(seed: UInt32) {
        self.grid = GridGenerator.generate(seed: seed)
        self.projectiles = []
        self.dinosaurs = []
        self.dinosaurRng = SeededRandomNumberGenerator(seed: seed &+ 12345)
        
        // Reset all tanks to their spawn positions
        for i in 0..<tanks.count {
            let spawn = GameState.spawnPositions[i]
            tanks[i] = Tank(row: spawn.row, col: spawn.col, direction: spawn.direction)
        }
        
        // Respawn dinosaur
        spawnDinosaur()
    }
    
    var localTank: Tank {
        get { tanks[localPlayerIndex] }
        set { tanks[localPlayerIndex] = newValue }
    }
    
    func updateProjectiles() -> [Int] {
        var activeProjectiles: [Projectile] = []
        var hitDinosaurIndices: [Int] = []
        
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
            
            // Check if hit any dinosaur
            var hitDinosaur = false
            for i in 0..<dinosaurs.count {
                if dinosaurs[i].isAlive && projectile.row == dinosaurs[i].row && projectile.col == dinosaurs[i].col {
                    dinosaurs[i].isAlive = false
                    hitDinosaurIndices.append(i)
                    hitDinosaur = true
                    break
                }
            }
            
            if hitDinosaur {
                continue
            }
            
            activeProjectiles.append(projectile)
        }
        
        projectiles = activeProjectiles
        return hitDinosaurIndices
    }
    
    /// Update dinosaur AI movement - called periodically
    func updateDinosaurs() {
        for i in 0..<dinosaurs.count where dinosaurs[i].isAlive {
            // Random chance to change direction
            if dinosaurRng.nextDouble() < 0.3 {
                dinosaurs[i].direction = Dinosaur.randomDirection(using: &dinosaurRng)
            }
            
            // Try to move in current direction
            if !dinosaurs[i].move(in: dinosaurs[i].direction, grid: grid, tanks: tanks) {
                // If blocked, try a random direction
                let newDirection = Dinosaur.randomDirection(using: &dinosaurRng)
                _ = dinosaurs[i].move(in: newDirection, grid: grid, tanks: tanks)
            }
        }
    }
    
    /// Check if any dinosaur collides with any tank and return affected tank indices
    func checkDinosaurTankCollisions() -> [Int] {
        var hitTankIndices: [Int] = []
        
        for dinosaur in dinosaurs where dinosaur.isAlive {
            for i in 0..<tanks.count {
                if dinosaur.collidesWith(tank: tanks[i]) {
                    tanks[i].isAlive = false
                    hitTankIndices.append(i)
                }
            }
        }
        
        return hitTankIndices
    }
    
    func isRoundOver() -> Bool {
        let aliveTanks = tanks.filter { $0.isAlive }
        return aliveTanks.count <= 1
    }
    
    func localPlayerWon() -> Bool {
        // Local player won if they're the only one alive
        if !tanks[localPlayerIndex].isAlive {
            return false
        }
        
        let aliveTanks = tanks.filter { $0.isAlive }
        return aliveTanks.count == 1
    }
    
    func getWinner() -> Int? {
        let aliveTanks = tanks.enumerated().filter { $0.element.isAlive }
        if aliveTanks.count == 1 {
            return aliveTanks.first?.offset
        }
        return nil
    }
}
