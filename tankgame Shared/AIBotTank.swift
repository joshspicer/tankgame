//
//  AIBotTank.swift
//  tankgame Shared
//
//  AI controller for bot tanks - enables single player mode and AI opponents in multiplayer
//

import Foundation

/// AI controller that manages bot tank behavior including movement and shooting
struct AIBotTank {
    
    /// The tank index this AI controls
    let tankIndex: Int
    
    /// Movement decision interval in update ticks
    private var moveCounter: Int = 0
    static let moveInterval: Int = 12
    
    /// Shooting decision interval in update ticks
    private var shootCounter: Int = 0
    static let shootInterval: Int = 25
    
    /// Whether the bot should attempt to shoot this update
    var shouldShoot: Bool = false
    
    init(tankIndex: Int) {
        self.tankIndex = tankIndex
        // Randomize initial counters to avoid synchronized bot behavior
        self.moveCounter = Int.random(in: 0..<AIBotTank.moveInterval)
        self.shootCounter = Int.random(in: 0..<AIBotTank.shootInterval)
    }
    
    /// Update the AI bot behavior
    /// - Parameters:
    ///   - tank: The tank this AI controls
    ///   - grid: The game grid
    ///   - allTanks: All tanks in the game (for targeting)
    ///   - projectiles: Current projectiles (for avoidance)
    /// - Returns: The direction the bot wants to move, or nil if not moving this update
    mutating func update(tank: Tank, grid: [[GridCell]], allTanks: [Tank], projectiles: [Projectile]) -> Direction? {
        guard tank.isAlive else { return nil }
        
        // Update shooting logic
        shootCounter += 1
        if shootCounter >= AIBotTank.shootInterval {
            shootCounter = 0
            shouldShoot = shouldAttemptShoot(tank: tank, allTanks: allTanks, grid: grid)
        } else {
            shouldShoot = false
        }
        
        // Update movement logic
        moveCounter += 1
        guard moveCounter >= AIBotTank.moveInterval else { return nil }
        moveCounter = 0
        
        return decideMovement(tank: tank, grid: grid, allTanks: allTanks, projectiles: projectiles)
    }
    
    /// Decide which direction to move
    private func decideMovement(tank: Tank, grid: [[GridCell]], allTanks: [Tank], projectiles: [Projectile]) -> Direction? {
        // Find the nearest enemy tank
        guard let target = findNearestEnemy(tank: tank, allTanks: allTanks) else {
            // No enemy found, wander randomly
            return wanderRandomly(tank: tank, grid: grid, allTanks: allTanks)
        }
        
        // Decide whether to pursue, dodge, or attack
        let dangerDirection = detectDanger(tank: tank, projectiles: projectiles)
        
        if let dodge = dangerDirection {
            // Dodge incoming projectile
            return dodgeDirection(from: dodge, tank: tank, grid: grid, allTanks: allTanks)
        }
        
        // Pursue the target with some randomness
        return pursueTarget(tank: tank, target: target, grid: grid, allTanks: allTanks)
    }
    
    /// Find the nearest enemy tank
    private func findNearestEnemy(tank: Tank, allTanks: [Tank]) -> Tank? {
        var nearestTank: Tank?
        var nearestDistance = Int.max
        
        for (index, otherTank) in allTanks.enumerated() {
            guard index != tankIndex && otherTank.isAlive else { continue }
            
            let distance = abs(tank.row - otherTank.row) + abs(tank.col - otherTank.col)
            if distance < nearestDistance {
                nearestDistance = distance
                nearestTank = otherTank
            }
        }
        
        return nearestTank
    }
    
    /// Detect if there's an incoming projectile danger
    private func detectDanger(tank: Tank, projectiles: [Projectile]) -> Direction? {
        for projectile in projectiles {
            // Check if projectile is heading toward the tank
            let projOffset = projectile.direction.offset
            var checkRow = projectile.row
            var checkCol = projectile.col
            
            // Look ahead a few steps
            for _ in 0..<4 {
                checkRow += projOffset.row
                checkCol += projOffset.col
                
                if checkRow == tank.row && checkCol == tank.col {
                    return projectile.direction
                }
            }
        }
        return nil
    }
    
    /// Get a direction to dodge incoming danger
    private func dodgeDirection(from dangerDirection: Direction, tank: Tank, grid: [[GridCell]], allTanks: [Tank]) -> Direction? {
        // Try to move perpendicular to the danger
        let perpendicular: [Direction]
        switch dangerDirection {
        case .up, .down:
            perpendicular = [.left, .right]
        case .left, .right:
            perpendicular = [.up, .down]
        default:
            perpendicular = Direction.cardinalDirections
        }
        
        for direction in perpendicular.shuffled() {
            if canMove(tank: tank, direction: direction, grid: grid, allTanks: allTanks) {
                return direction
            }
        }
        
        return nil
    }
    
    /// Pursue a target tank
    private func pursueTarget(tank: Tank, target: Tank, grid: [[GridCell]], allTanks: [Tank]) -> Direction? {
        var preferredDirections: [Direction] = []
        
        // Calculate direction to target
        if target.row < tank.row {
            preferredDirections.append(.up)
        } else if target.row > tank.row {
            preferredDirections.append(.down)
        }
        
        if target.col < tank.col {
            preferredDirections.append(.left)
        } else if target.col > tank.col {
            preferredDirections.append(.right)
        }
        
        // Add some randomness (30% chance to pick a random direction instead)
        if Double.random(in: 0...1) < 0.3 {
            preferredDirections = Direction.cardinalDirections.shuffled()
        } else {
            preferredDirections.shuffle()
        }
        
        // Try preferred directions first
        for direction in preferredDirections {
            if canMove(tank: tank, direction: direction, grid: grid, allTanks: allTanks) {
                return direction
            }
        }
        
        // Fall back to any valid direction
        return wanderRandomly(tank: tank, grid: grid, allTanks: allTanks)
    }
    
    /// Wander in a random valid direction
    private func wanderRandomly(tank: Tank, grid: [[GridCell]], allTanks: [Tank]) -> Direction? {
        let shuffled = Direction.cardinalDirections.shuffled()
        for direction in shuffled {
            if canMove(tank: tank, direction: direction, grid: grid, allTanks: allTanks) {
                return direction
            }
        }
        return nil
    }
    
    /// Check if the tank can move in the given direction
    private func canMove(tank: Tank, direction: Direction, grid: [[GridCell]], allTanks: [Tank]) -> Bool {
        let offset = direction.offset
        let newRow = tank.row + offset.row
        let newCol = tank.col + offset.col
        
        // Check bounds
        guard newRow >= 0, newRow < grid.count,
              newCol >= 0, newCol < grid[0].count else {
            return false
        }
        
        // Check if cell is passable (empty or goo)
        guard grid[newRow][newCol] == .empty || grid[newRow][newCol] == .goo else {
            return false
        }
        
        // Check if another tank is there
        for (index, otherTank) in allTanks.enumerated() {
            guard index != tankIndex && otherTank.isAlive else { continue }
            if otherTank.row == newRow && otherTank.col == newCol {
                return false
            }
        }
        
        return true
    }
    
    /// Determine if the bot should attempt to shoot
    private func shouldAttemptShoot(tank: Tank, allTanks: [Tank], grid: [[GridCell]]) -> Bool {
        // Check if there's an enemy in the line of fire
        let offset = tank.direction.offset
        var checkRow = tank.row + offset.row
        var checkCol = tank.col + offset.col
        
        // Look along the firing line
        while checkRow >= 0 && checkRow < grid.count && checkCol >= 0 && checkCol < grid[0].count {
            // Stop if we hit a wall
            if grid[checkRow][checkCol] == .wall {
                break
            }
            
            // Check if there's an enemy tank here
            for (index, otherTank) in allTanks.enumerated() {
                guard index != tankIndex && otherTank.isAlive else { continue }
                if otherTank.row == checkRow && otherTank.col == checkCol {
                    return true
                }
            }
            
            checkRow += offset.row
            checkCol += offset.col
        }
        
        // Also shoot randomly sometimes (20% chance)
        return Double.random(in: 0...1) < 0.2
    }
}
