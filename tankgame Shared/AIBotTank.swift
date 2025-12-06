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
    
    /// The difficulty level for this bot
    let difficulty: AIBotDifficulty
    
    /// Movement decision interval in update ticks
    private var moveCounter: Int = 0
    
    /// Shooting decision interval in update ticks
    private var shootCounter: Int = 0
    
    /// Whether the bot should attempt to shoot this update
    var shouldShoot: Bool = false
    
    /// Counter for flanking behavior (hard mode)
    private var flankingCounter: Int = 0
    private var currentFlankDirection: Direction?
    
    /// Maximum number of update cycles before resetting flanking direction
    private static let flankingResetThreshold: Int = 5
    
    init(tankIndex: Int, difficulty: AIBotDifficulty = AISettings.shared.difficulty) {
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
        
        // Update shooting logic
        shootCounter += 1
        if shootCounter >= difficulty.shootInterval {
            shootCounter = 0
            shouldShoot = shouldAttemptShoot(tank: tank, allTanks: allTanks, grid: grid, projectiles: projectiles)
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
        // Priority 1: Dodge incoming projectiles
        let dangerDirection = detectDanger(tank: tank, projectiles: projectiles)
        if let dodge = dangerDirection {
            return dodgeDirection(from: dodge, tank: tank, grid: grid, allTanks: allTanks)
        }
        
        // Find the nearest enemy tank
        guard let target = findNearestEnemy(tank: tank, allTanks: allTanks) else {
            // No enemy found, wander randomly
            return wanderRandomly(tank: tank, grid: grid, allTanks: allTanks)
        }
        
        // Priority 2: For hard mode, use flanking maneuvers
        if difficulty.usesFlankingManeuvers {
            if let flankMove = attemptFlankingManeuver(tank: tank, target: target, grid: grid, allTanks: allTanks) {
                return flankMove
            }
        }
        
        // Priority 3: For advanced targeting, try to get into firing position
        if difficulty.usesAdvancedTargeting {
            if let positionMove = moveToFiringPosition(tank: tank, target: target, grid: grid, allTanks: allTanks) {
                return positionMove
            }
        }
        
        // Priority 4: Pursue the target with difficulty-based randomness
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
            
            // Look ahead based on difficulty (more steps = better awareness)
            for _ in 0..<difficulty.dangerLookAhead {
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
        
        // Add randomness based on difficulty (higher difficulty = less random)
        if Double.random(in: 0...1) < difficulty.randomMoveProbability {
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
    private func shouldAttemptShoot(tank: Tank, allTanks: [Tank], grid: [[GridCell]], projectiles: [Projectile]) -> Bool {
        // Check if there's an enemy in the line of fire
        if hasEnemyInLineOfFire(tank: tank, allTanks: allTanks, grid: grid) {
            return true
        }
        
        // For advanced targeting, also check if we're close to having a shot
        if difficulty.usesAdvancedTargeting {
            if isNearFiringPosition(tank: tank, allTanks: allTanks, grid: grid) {
                // Don't randomly shoot when we're close to a good position
                return false
            }
        }
        
        // Random shooting based on difficulty (lower probability = smarter)
        return Double.random(in: 0...1) < difficulty.randomShootProbability
    }
    
    /// Check if there's an enemy directly in the line of fire
    private func hasEnemyInLineOfFire(tank: Tank, allTanks: [Tank], grid: [[GridCell]]) -> Bool {
        let offset = tank.direction.offset
        var checkRow = tank.row + offset.row
        var checkCol = tank.col + offset.col
        
        // Look along the firing line up to targeting range
        var distance = 0
        while distance < difficulty.targetingRange &&
              checkRow >= 0 && checkRow < grid.count &&
              checkCol >= 0 && checkCol < grid[0].count {
            
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
            distance += 1
        }
        
        return false
    }
    
    /// Check if the tank is near a good firing position (one move away from having a shot)
    private func isNearFiringPosition(tank: Tank, allTanks: [Tank], grid: [[GridCell]]) -> Bool {
        // Check each cardinal direction to see if turning that way would give us a shot
        for direction in Direction.cardinalDirections {
            if wouldHaveShot(tank: tank, facing: direction, allTanks: allTanks, grid: grid) {
                return true
            }
        }
        return false
    }
    
    /// Check if the tank would have a shot if it were facing a certain direction
    private func wouldHaveShot(tank: Tank, facing: Direction, allTanks: [Tank], grid: [[GridCell]]) -> Bool {
        let offset = facing.offset
        var checkRow = tank.row + offset.row
        var checkCol = tank.col + offset.col
        
        var distance = 0
        while distance < difficulty.targetingRange &&
              checkRow >= 0 && checkRow < grid.count &&
              checkCol >= 0 && checkCol < grid[0].count {
            
            if grid[checkRow][checkCol] == .wall {
                break
            }
            
            for (index, otherTank) in allTanks.enumerated() {
                guard index != tankIndex && otherTank.isAlive else { continue }
                if otherTank.row == checkRow && otherTank.col == checkCol {
                    return true
                }
            }
            
            checkRow += offset.row
            checkCol += offset.col
            distance += 1
        }
        
        return false
    }
    
    /// Move to get into a firing position against the target
    private func moveToFiringPosition(tank: Tank, target: Tank, grid: [[GridCell]], allTanks: [Tank]) -> Direction? {
        // Check if we can get a shot by moving to align with the target
        
        // If target is on same row, try to get into horizontal firing position
        if target.row == tank.row {
            // Already aligned, don't need to move for position
            return nil
        }
        
        // If target is on same column, try to get into vertical firing position
        if target.col == tank.col {
            // Already aligned, don't need to move for position
            return nil
        }
        
        // Try to move to same row as target
        let rowDiff = target.row - tank.row
        let colDiff = target.col - tank.col
        
        // Prioritize the shorter distance alignment
        if abs(rowDiff) < abs(colDiff) {
            // Move vertically to align rows
            let direction: Direction = rowDiff < 0 ? .up : .down
            if canMove(tank: tank, direction: direction, grid: grid, allTanks: allTanks) {
                return direction
            }
        } else {
            // Move horizontally to align columns
            let direction: Direction = colDiff < 0 ? .left : .right
            if canMove(tank: tank, direction: direction, grid: grid, allTanks: allTanks) {
                return direction
            }
        }
        
        return nil
    }
    
    /// Attempt a flanking maneuver to approach the target from the side.
    /// This makes the bot harder to hit by approaching perpendicular to the target's facing direction.
    /// The flanking direction is maintained for several updates to create consistent movement patterns.
    /// - Parameters:
    ///   - tank: The bot's tank
    ///   - target: The enemy tank being targeted
    ///   - grid: The game grid
    ///   - allTanks: All tanks in the game
    /// - Returns: The direction to move for flanking, or nil if flanking isn't possible
    private mutating func attemptFlankingManeuver(tank: Tank, target: Tank, grid: [[GridCell]], allTanks: [Tank]) -> Direction? {
        flankingCounter += 1
        
        // Reset flanking direction periodically to adapt to target movement
        if flankingCounter > AIBotTank.flankingResetThreshold {
            flankingCounter = 0
            currentFlankDirection = nil
        }
        
        // If we don't have a flanking direction, decide one based on target's facing
        if currentFlankDirection == nil {
            let targetFacing = target.direction
            
            // Move perpendicular to the target's facing direction to approach from the side
            let perpendicularDirs: [Direction]
            switch targetFacing {
            case .up, .down:
                perpendicularDirs = [.left, .right]
            case .left, .right:
                perpendicularDirs = [.up, .down]
            case .upRight, .downRight, .downLeft, .upLeft:
                // For diagonal directions, use all cardinal directions as options
                perpendicularDirs = Direction.cardinalDirections
            }
            
            currentFlankDirection = perpendicularDirs.randomElement()
        }
        
        // Try to move in the flanking direction
        if let flankDir = currentFlankDirection,
           canMove(tank: tank, direction: flankDir, grid: grid, allTanks: allTanks) {
            return flankDir
        }
        
        // If flanking direction blocked, clear it to try a different approach next time
        currentFlankDirection = nil
        return nil
    }
}
