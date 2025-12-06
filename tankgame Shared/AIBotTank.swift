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
    
    /// AI difficulty level for this bot
    let difficulty: AIDifficulty
    
    /// Movement decision interval in update ticks (based on difficulty)
    private var moveCounter: Int = 0
    
    /// Shooting decision interval in update ticks (based on difficulty)
    private var shootCounter: Int = 0
    
    /// Whether the bot should attempt to shoot this update
    var shouldShoot: Bool = false
    
    /// Current tactical situation (evaluated each update)
    private var currentSituation: TacticalSituation = TacticalSituation()
    
    /// Cached target for consistent behavior between updates
    private var lastTargetIndex: Int? = nil
    
    /// Counter for how long we've been pursuing same target
    private var targetPursuitCounter: Int = 0
    
    init(tankIndex: Int, difficulty: AIDifficulty = .medium) {
        self.tankIndex = tankIndex
        self.difficulty = difficulty
        // Randomize initial counters to avoid synchronized bot behavior
        self.moveCounter = Int.random(in: 0..<difficulty.moveInterval)
        self.shootCounter = Int.random(in: 0..<difficulty.shootInterval)
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
        
        // Evaluate current tactical situation
        currentSituation = AIBehaviorStrategy.evaluateSituation(
            tank: tank,
            allTanks: allTanks,
            projectiles: projectiles,
            grid: grid,
            tankIndex: tankIndex,
            difficulty: difficulty
        )
        
        // Update shooting logic
        shootCounter += 1
        if shootCounter >= difficulty.shootInterval {
            shootCounter = 0
            shouldShoot = shouldAttemptShoot(tank: tank, allTanks: allTanks, grid: grid)
        } else {
            shouldShoot = false
        }
        
        // Update movement logic
        moveCounter += 1
        guard moveCounter >= difficulty.moveInterval else { return nil }
        moveCounter = 0
        
        return decideMovement(tank: tank, grid: grid, allTanks: allTanks, projectiles: projectiles)
    }
    
    /// Decide which direction to move
    private mutating func decideMovement(tank: Tank, grid: [[GridCell]], allTanks: [Tank], projectiles: [Projectile]) -> Direction? {
        // Find the nearest enemy tank
        let targetInfo = findNearestEnemy(tank: tank, allTanks: allTanks)
        guard let target = targetInfo.tank else {
            // No enemy found, wander randomly
            lastTargetIndex = nil
            return wanderRandomly(tank: tank, grid: grid, allTanks: allTanks)
        }
        
        // Track target persistence
        if lastTargetIndex == targetInfo.index {
            targetPursuitCounter += 1
        } else {
            lastTargetIndex = targetInfo.index
            targetPursuitCounter = 0
        }
        
        // Use tactical situation to determine behavior
        switch currentSituation.recommendedAction {
        case .dodge:
            if let dangerDir = currentSituation.dangerDirection {
                return dodgeDirection(from: dangerDir, tank: tank, grid: grid, allTanks: allTanks)
            }
            
        case .retreat:
            if let retreatDir = AIBehaviorStrategy.findRetreatDirection(
                tank: tank, allTanks: allTanks, grid: grid, tankIndex: tankIndex) {
                return retreatDir
            }
            
        case .flank:
            if let flankDir = AIBehaviorStrategy.findFlankingDirection(
                tank: tank, target: target, grid: grid, allTanks: allTanks, tankIndex: tankIndex) {
                return flankDir
            }
            
        case .seekCover:
            if let coverDir = AIBehaviorStrategy.findCoverDirection(
                tank: tank, grid: grid, allTanks: allTanks, tankIndex: tankIndex) {
                return coverDir
            }
            
        case .hold:
            // Stay in position - good firing angle
            // Small chance to adjust position for unpredictability
            if Double.random(in: 0...1) < 0.1 {
                return wanderRandomly(tank: tank, grid: grid, allTanks: allTanks)
            }
            return nil
            
        case .attack, .wander:
            // Continue to pursue/attack logic below
            break
        }
        
        // Pursue the target with intelligence based on difficulty
        return pursueTarget(tank: tank, target: target, grid: grid, allTanks: allTanks)
    }
    
    /// Find the nearest enemy tank
    private func findNearestEnemy(tank: Tank, allTanks: [Tank]) -> (tank: Tank?, index: Int?) {
        var nearestTank: Tank?
        var nearestIndex: Int?
        var nearestDistance = Int.max
        
        for (index, otherTank) in allTanks.enumerated() {
            guard index != tankIndex && otherTank.isAlive else { continue }
            
            let distance = AIBehaviorStrategy.manhattanDistance(from: tank, to: otherTank)
            if distance < nearestDistance {
                nearestDistance = distance
                nearestTank = otherTank
                nearestIndex = index
            }
        }
        
        return (nearestTank, nearestIndex)
    }
    
    /// Detect if there's an incoming projectile danger
    private func detectDanger(tank: Tank, projectiles: [Projectile]) -> Direction? {
        return AIBehaviorStrategy.detectIncomingDanger(
            tankRow: tank.row,
            tankCol: tank.col,
            projectiles: projectiles,
            lookahead: difficulty.dangerLookahead,
            checkNearMiss: difficulty.useAdvancedTactics
        )
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
        
        // Smart vs random movement based on difficulty
        let randomChance = 1.0 - difficulty.smartMoveChance
        if Double.random(in: 0...1) < randomChance {
            preferredDirections = Direction.cardinalDirections.shuffled()
        } else {
            // For advanced tactics, try to line up for a shot
            if difficulty.useAdvancedTactics {
                // Prioritize getting aligned (same row or column) with target
                if tank.row != target.row && tank.col != target.col {
                    // Not aligned - prefer direction that gets us aligned
                    let rowDist = abs(tank.row - target.row)
                    let colDist = abs(tank.col - target.col)
                    
                    // Move in the axis with shorter distance to align faster
                    if rowDist < colDist {
                        if target.row < tank.row {
                            preferredDirections.insert(.up, at: 0)
                        } else {
                            preferredDirections.insert(.down, at: 0)
                        }
                    } else {
                        if target.col < tank.col {
                            preferredDirections.insert(.left, at: 0)
                        } else {
                            preferredDirections.insert(.right, at: 0)
                        }
                    }
                }
            } else {
                preferredDirections.shuffle()
            }
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
        
        // Check if cell is empty
        guard grid[newRow][newCol] == .empty else {
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
        let hasTarget = checkLineOfFire(tank: tank, allTanks: allTanks, grid: grid)
        
        if hasTarget {
            // Apply accuracy based on difficulty
            return Double.random(in: 0...1) < difficulty.accurateShootChance
        }
        
        // For advanced difficulties, also check if we can shoot to cut off enemy movement
        if difficulty.useAdvancedTactics {
            if canPredictEnemyMovement(tank: tank, allTanks: allTanks, grid: grid) {
                return Double.random(in: 0...1) < difficulty.accurateShootChance * 0.7
            }
        }
        
        // Also shoot randomly sometimes based on difficulty
        return Double.random(in: 0...1) < difficulty.randomShootChance
    }
    
    /// Check if there's an enemy in the direct line of fire
    private func checkLineOfFire(tank: Tank, allTanks: [Tank], grid: [[GridCell]]) -> Bool {
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
        
        return false
    }
    
    /// Check if we can predict where an enemy will move (for leading shots)
    private func canPredictEnemyMovement(tank: Tank, allTanks: [Tank], grid: [[GridCell]]) -> Bool {
        let offset = tank.direction.offset
        var checkRow = tank.row + offset.row
        var checkCol = tank.col + offset.col
        
        // Check cells along the firing line
        while checkRow >= 0 && checkRow < grid.count && checkCol >= 0 && checkCol < grid[0].count {
            if grid[checkRow][checkCol] == .wall {
                break
            }
            
            // Check if enemy is adjacent to this cell (might move into it)
            for (index, otherTank) in allTanks.enumerated() {
                guard index != tankIndex && otherTank.isAlive else { continue }
                
                // Check if enemy is one step away from this cell
                let rowDiff = abs(otherTank.row - checkRow)
                let colDiff = abs(otherTank.col - checkCol)
                
                if (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1) {
                    return true
                }
            }
            
            checkRow += offset.row
            checkCol += offset.col
        }
        
        return false
    }
}
