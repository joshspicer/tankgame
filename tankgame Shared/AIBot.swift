//
//  AIBot.swift
//  tankgame Shared
//
//  AI-controlled tank bot that can play against human players
//

import Foundation

/// AI difficulty levels that affect bot behavior
enum AIBotDifficulty: Int, Codable, CaseIterable {
    case easy = 0
    case medium = 1
    case hard = 2
    
    /// Display name for the difficulty
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    /// Movement interval (ticks between moves) - lower = faster
    var moveInterval: Int {
        switch self {
        case .easy: return 25
        case .medium: return 18
        case .hard: return 12
        }
    }
    
    /// Reaction time (ticks before responding to threats)
    var reactionTime: Int {
        switch self {
        case .easy: return 15
        case .medium: return 8
        case .hard: return 3
        }
    }
    
    /// Shooting accuracy (probability 0-1)
    var shootingAccuracy: Double {
        switch self {
        case .easy: return 0.5
        case .medium: return 0.7
        case .hard: return 0.9
        }
    }
    
    /// Shooting cooldown (ticks between shots)
    var shootCooldown: Int {
        switch self {
        case .easy: return 30
        case .medium: return 20
        case .hard: return 10
        }
    }
}

/// Represents an AI-controlled tank bot
struct AIBot: Codable {
    /// The player index this bot controls
    let playerIndex: Int
    
    /// The difficulty level of this bot
    let difficulty: AIBotDifficulty
    
    /// Counter for movement timing
    var moveCounter: Int = 0
    
    /// Counter for shooting cooldown
    var shootCooldown: Int = 0
    
    /// Current target player index (if any)
    var targetPlayerIndex: Int?
    
    /// Cardinal directions for bot movement
    static let cardinalDirections: [Direction] = [.up, .down, .left, .right]
    
    init(playerIndex: Int, difficulty: AIBotDifficulty = .medium) {
        self.playerIndex = playerIndex
        self.difficulty = difficulty
    }
    
    /// Update the bot's AI logic and return any actions to take
    /// - Parameters:
    ///   - tank: The tank controlled by this bot
    ///   - allTanks: All tanks in the game
    ///   - grid: The game grid
    ///   - projectiles: Active projectiles
    /// - Returns: An AIBotAction if the bot decides to act
    mutating func update(tank: Tank, allTanks: [Tank], grid: [[GridCell]], projectiles: [Projectile]) -> AIBotAction? {
        guard tank.isAlive else { return nil }
        
        // Decrement cooldowns
        moveCounter += 1
        if shootCooldown > 0 {
            shootCooldown -= 1
        }
        
        // Find nearest alive enemy
        let enemies = findEnemies(allTanks: allTanks)
        
        // Check if we can shoot an enemy
        if let shootAction = tryShoot(tank: tank, enemies: enemies, grid: grid) {
            return shootAction
        }
        
        // Check if we need to dodge incoming projectiles
        if let dodgeAction = tryDodge(tank: tank, projectiles: projectiles, grid: grid) {
            return dodgeAction
        }
        
        // Move towards nearest enemy if it's time to move
        if moveCounter >= difficulty.moveInterval {
            moveCounter = 0
            if let moveAction = tryMove(tank: tank, enemies: enemies, grid: grid, allTanks: allTanks) {
                return moveAction
            }
        }
        
        return nil
    }
    
    /// Find all enemy tanks (alive, not us)
    private func findEnemies(allTanks: [Tank]) -> [(index: Int, tank: Tank)] {
        return allTanks.enumerated()
            .filter { $0.offset != playerIndex && $0.element.isAlive }
            .map { (index: $0.offset, tank: $0.element) }
    }
    
    /// Try to shoot at an enemy if in line of sight
    private mutating func tryShoot(tank: Tank, enemies: [(index: Int, tank: Tank)], grid: [[GridCell]]) -> AIBotAction? {
        guard shootCooldown <= 0 else { return nil }
        
        for enemy in enemies {
            if hasLineOfSight(from: tank, to: enemy.tank, grid: grid) {
                // Check if we're facing the right direction
                let directionToEnemy = getDirectionToTarget(from: tank, to: enemy.tank)
                if let direction = directionToEnemy, direction == tank.direction {
                    // Random chance based on accuracy
                    if Double.random(in: 0...1) <= difficulty.shootingAccuracy {
                        shootCooldown = difficulty.shootCooldown
                        return .shoot
                    }
                }
            }
        }
        
        return nil
    }
    
    /// Try to dodge incoming projectiles
    private func tryDodge(tank: Tank, projectiles: [Projectile], grid: [[GridCell]]) -> AIBotAction? {
        for projectile in projectiles {
            // Check if projectile is heading towards us
            if isProjectileThreateningUs(projectile: projectile, tank: tank) {
                // Try to move perpendicular to the projectile's direction
                let dodgeDirections = getDodgeDirections(projectileDirection: projectile.direction)
                for direction in dodgeDirections {
                    if canMove(tank: tank, in: direction, grid: grid) {
                        return .move(direction: direction)
                    }
                }
            }
        }
        return nil
    }
    
    /// Try to move towards an enemy or explore
    private func tryMove(tank: Tank, enemies: [(index: Int, tank: Tank)], grid: [[GridCell]], allTanks: [Tank]) -> AIBotAction? {
        // Find nearest enemy
        guard let nearestEnemy = enemies.min(by: { distance(from: tank, to: $0.tank) < distance(from: tank, to: $1.tank) }) else {
            return randomMove(tank: tank, grid: grid, allTanks: allTanks)
        }
        
        // Get direction towards enemy
        if let directionToEnemy = getDirectionToTarget(from: tank, to: nearestEnemy.tank) {
            // Check if we can move in that direction
            if canMove(tank: tank, in: directionToEnemy, grid: grid) {
                return .move(direction: directionToEnemy)
            }
            
            // Try alternative directions
            let alternatives = getAlternativeDirections(primary: directionToEnemy)
            for alt in alternatives {
                if canMove(tank: tank, in: alt, grid: grid) {
                    return .move(direction: alt)
                }
            }
        }
        
        return randomMove(tank: tank, grid: grid, allTanks: allTanks)
    }
    
    /// Perform a random valid move
    private func randomMove(tank: Tank, grid: [[GridCell]], allTanks: [Tank]) -> AIBotAction? {
        let shuffled = AIBot.cardinalDirections.shuffled()
        for direction in shuffled {
            if canMove(tank: tank, in: direction, grid: grid) {
                return .move(direction: direction)
            }
        }
        return nil
    }
    
    /// Check if we can move in a direction
    private func canMove(tank: Tank, in direction: Direction, grid: [[GridCell]]) -> Bool {
        let offset = direction.offset
        let newRow = tank.row + offset.row
        let newCol = tank.col + offset.col
        
        // Check bounds
        guard newRow >= 0, newRow < grid.count,
              newCol >= 0, newCol < grid[0].count else {
            return false
        }
        
        // Check if cell is empty
        return grid[newRow][newCol] == .empty
    }
    
    /// Check if there's line of sight between two tanks
    private func hasLineOfSight(from: Tank, to: Tank, grid: [[GridCell]]) -> Bool {
        // Must be in same row or column
        if from.row == to.row {
            // Same row - check horizontal
            let minCol = min(from.col, to.col)
            let maxCol = max(from.col, to.col)
            for col in minCol...maxCol {
                if grid[from.row][col] == .wall {
                    return false
                }
            }
            return true
        } else if from.col == to.col {
            // Same column - check vertical
            let minRow = min(from.row, to.row)
            let maxRow = max(from.row, to.row)
            for row in minRow...maxRow {
                if grid[row][from.col] == .wall {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    /// Get the cardinal direction to reach a target
    private func getDirectionToTarget(from: Tank, to: Tank) -> Direction? {
        let rowDiff = to.row - from.row
        let colDiff = to.col - from.col
        
        // Prefer the axis with larger distance
        if abs(rowDiff) > abs(colDiff) {
            return rowDiff > 0 ? .down : .up
        } else if abs(colDiff) > abs(rowDiff) {
            return colDiff > 0 ? .right : .left
        } else if rowDiff != 0 {
            return rowDiff > 0 ? .down : .up
        } else if colDiff != 0 {
            return colDiff > 0 ? .right : .left
        }
        return nil
    }
    
    /// Calculate Manhattan distance between tanks
    private func distance(from: Tank, to: Tank) -> Int {
        return abs(from.row - to.row) + abs(from.col - to.col)
    }
    
    /// Check if a projectile is threatening our position
    private func isProjectileThreateningUs(projectile: Projectile, tank: Tank) -> Bool {
        let offset = projectile.direction.offset
        var checkRow = projectile.row
        var checkCol = projectile.col
        
        // Check next few positions in projectile's path
        for _ in 0..<5 {
            if checkRow == tank.row && checkCol == tank.col {
                return true
            }
            checkRow += offset.row
            checkCol += offset.col
        }
        return false
    }
    
    /// Get perpendicular directions to dodge a projectile
    private func getDodgeDirections(projectileDirection: Direction) -> [Direction] {
        switch projectileDirection {
        case .up, .down:
            return [.left, .right].shuffled()
        case .left, .right:
            return [.up, .down].shuffled()
        case .upRight, .downLeft:
            // Diagonal from upper-right to lower-left - dodge perpendicular
            return [.up, .left, .down, .right].shuffled()
        case .upLeft, .downRight:
            // Diagonal from upper-left to lower-right - dodge perpendicular
            return [.up, .right, .down, .left].shuffled()
        }
    }
    
    /// Get alternative directions when primary is blocked
    private func getAlternativeDirections(primary: Direction) -> [Direction] {
        switch primary {
        case .up:
            return [.left, .right, .down].shuffled()
        case .down:
            return [.left, .right, .up].shuffled()
        case .left:
            return [.up, .down, .right].shuffled()
        case .right:
            return [.up, .down, .left].shuffled()
        case .upRight:
            return [.up, .right, .down, .left].shuffled()
        case .upLeft:
            return [.up, .left, .down, .right].shuffled()
        case .downRight:
            return [.down, .right, .up, .left].shuffled()
        case .downLeft:
            return [.down, .left, .up, .right].shuffled()
        }
    }
}

/// Actions that an AI bot can take
enum AIBotAction {
    case move(direction: Direction)
    case shoot
}
