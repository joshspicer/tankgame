//
//  AIBotTank.swift
//  tankgame Shared
//
//  AI controller for bot tanks - enables single player mode and AI opponents in multiplayer
//  Supports multiple difficulty levels with varying behaviors
//

import Foundation

/// AI controller that manages bot tank behavior including movement and shooting
struct AIBotTank {
    
    /// The tank index this AI controls
    let tankIndex: Int
    
    /// The difficulty level for this bot
    let difficulty: AIBotDifficulty
    
    /// Configuration based on difficulty
    var config: AIBotConfig { difficulty.config }
    
    /// Movement decision interval in update ticks
    private var moveCounter: Int = 0
    
    /// Shooting decision interval in update ticks
    private var shootCounter: Int = 0
    
    /// Whether the bot should attempt to shoot this update
    var shouldShoot: Bool = false
    
    /// Current tactical state
    private var currentState: TacticalState = .pursuing
    
    /// Tactical states for the AI
    enum TacticalState {
        case pursuing       // Chasing an enemy
        case flanking       // Attempting to flank an enemy
        case retreating     // Running away from threats
        case seekingCover   // Looking for defensive position
        case wandering      // No target, exploring
    }
    
    init(tankIndex: Int, difficulty: AIBotDifficulty = .medium) {
        self.tankIndex = tankIndex
        self.difficulty = difficulty
        // Randomize initial counters to avoid synchronized bot behavior
        let moveInterval = difficulty.config.moveInterval
        let shootInterval = difficulty.config.shootInterval
        self.moveCounter = Int.random(in: 0..<moveInterval)
        self.shootCounter = Int.random(in: 0..<shootInterval)
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
        if shootCounter >= config.shootInterval {
            shootCounter = 0
            shouldShoot = AITargeting.shouldShoot(
                tank: tank,
                allTanks: allTanks,
                grid: grid,
                config: config,
                tankIndex: tankIndex
            )
        } else {
            shouldShoot = false
        }
        
        // Update movement logic
        moveCounter += 1
        guard moveCounter >= config.moveInterval else { return nil }
        moveCounter = 0
        
        return decideMovement(tank: tank, grid: grid, allTanks: allTanks, projectiles: projectiles)
    }
    
    /// Decide which direction to move based on tactical state
    private mutating func decideMovement(tank: Tank, grid: [[GridCell]], allTanks: [Tank], projectiles: [Projectile]) -> Direction? {
        // Detect threats
        let projectileThreats = AIThreatDetection.detectProjectileThreats(
            tank: tank,
            projectiles: projectiles,
            lookAhead: config.dodgeReactionTime
        )
        
        let threatLevel = AIThreatDetection.assessOverallThreatLevel(
            tank: tank,
            allTanks: allTanks,
            projectiles: projectiles,
            tankIndex: tankIndex,
            grid: grid
        )
        
        // Priority 1: Dodge incoming projectiles
        if let mostDangerousThreat = projectileThreats.first, mostDangerousThreat.severity >= .medium {
            if let dodgeDir = AIThreatDetection.findDodgeDirection(
                tank: tank,
                threats: projectileThreats,
                grid: grid,
                allTanks: allTanks,
                tankIndex: tankIndex
            ) {
                currentState = .seekingCover
                return dodgeDir
            }
        }
        
        // Priority 2: Retreat if advisable and enabled
        if config.retreatEnabled && AIThreatDetection.shouldRetreat(
            tank: tank,
            allTanks: allTanks,
            tankIndex: tankIndex,
            threatLevel: threatLevel
        ) {
            currentState = .retreating
            let enemies = allTanks.enumerated()
                .filter { $0.offset != tankIndex && $0.element.isAlive }
                .map { $0.element }
            
            if let retreatDir = AIPathfinding.findRetreatDirection(
                from: (tank.row, tank.col),
                enemies: enemies,
                grid: grid,
                tanks: allTanks,
                currentTankIndex: tankIndex
            ) {
                return retreatDir
            }
        }
        
        // Priority 3: Seek cover if under threat and enabled
        if config.coverSeekingEnabled && threatLevel >= .high {
            let enemyThreats = AIThreatDetection.detectEnemyThreats(
                tank: tank,
                allTanks: allTanks,
                tankIndex: tankIndex,
                grid: grid
            )
            
            if let topThreat = enemyThreats.first {
                if let coverDir = AIPathfinding.findCoverDirection(
                    from: (tank.row, tank.col),
                    grid: grid,
                    tanks: allTanks,
                    currentTankIndex: tankIndex,
                    threatDirection: topThreat.direction
                ) {
                    currentState = .seekingCover
                    return coverDir
                }
            }
        }
        
        // Find the best target
        guard let target = AITargeting.findBestTarget(
            tank: tank,
            allTanks: allTanks,
            tankIndex: tankIndex,
            grid: grid
        ) else {
            // No enemy found, wander randomly
            currentState = .wandering
            return wanderRandomly(tank: tank, grid: grid, allTanks: allTanks)
        }
        
        // Priority 4: Try flanking if enabled
        if config.flankingEnabled && Double.random(in: 0...1) < 0.4 {
            if let flankDir = AIPathfinding.findFlankingDirection(
                from: (tank.row, tank.col),
                target: target,
                grid: grid,
                tanks: allTanks,
                currentTankIndex: tankIndex
            ) {
                currentState = .flanking
                return flankDir
            }
        }
        
        // Priority 5: Direct pursuit
        currentState = .pursuing
        return pursueTarget(tank: tank, target: target, grid: grid, allTanks: allTanks)
    }
    
    /// Pursue a target tank with difficulty-appropriate randomness
    private func pursueTarget(tank: Tank, target: Tank, grid: [[GridCell]], allTanks: [Tank]) -> Direction? {
        // Apply pursuit randomness based on difficulty
        if Double.random(in: 0...1) < config.pursuitRandomness {
            return wanderRandomly(tank: tank, grid: grid, allTanks: allTanks)
        }
        
        // Check if we can get a shot lined up
        if let shootDir = AITargeting.findBestShootingDirection(
            tank: tank,
            target: target,
            grid: grid,
            predictive: config.predictiveAiming
        ) {
            // If we're already facing the right direction, consider holding position
            if tank.direction == shootDir {
                // Use configurable hold position chance based on difficulty
                if Double.random(in: 0...1) < config.holdPositionChance {
                    return nil
                }
            }
        }
        
        // Use pathfinding to pursue target
        if let direction = AIPathfinding.findBestDirection(
            from: (tank.row, tank.col),
            to: (target.row, target.col),
            grid: grid,
            tanks: allTanks,
            currentTankIndex: tankIndex,
            preferFlanking: config.flankingEnabled
        ) {
            return direction
        }
        
        // Fall back to basic pursuit logic if pathfinding fails
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
        
        preferredDirections.shuffle()
        
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
}
