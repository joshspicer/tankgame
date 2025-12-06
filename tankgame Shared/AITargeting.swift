//
//  AITargeting.swift
//  tankgame Shared
//
//  Targeting and shooting logic for AI bots including predictive aiming
//

import Foundation

/// Provides targeting and shooting utilities for AI bots
struct AITargeting {
    
    /// Result of a line-of-sight check
    struct LineOfSightResult {
        let hasLineOfSight: Bool
        let distance: Int
        let requiredDirection: Direction?
    }
    
    /// Check if there's a clear line of sight to a target
    /// - Parameters:
    ///   - from: Shooter position
    ///   - target: Target tank
    ///   - grid: The game grid
    ///   - maxDistance: Maximum distance to check
    /// - Returns: LineOfSightResult with details about the line of sight
    static func checkLineOfSight(
        from: (row: Int, col: Int),
        target: Tank,
        grid: [[GridCell]],
        maxDistance: Int
    ) -> LineOfSightResult {
        // Check all four cardinal directions
        for direction in Direction.cardinalDirections {
            let offset = direction.offset
            var checkRow = from.row + offset.row
            var checkCol = from.col + offset.col
            var distance = 1
            
            while distance <= maxDistance {
                // Check bounds
                guard checkRow >= 0, checkRow < grid.count,
                      checkCol >= 0, checkCol < grid[0].count else {
                    break
                }
                
                // Check if hit wall
                if grid[checkRow][checkCol] == .wall {
                    break
                }
                
                // Check if found target
                if checkRow == target.row && checkCol == target.col {
                    return LineOfSightResult(
                        hasLineOfSight: true,
                        distance: distance,
                        requiredDirection: direction
                    )
                }
                
                checkRow += offset.row
                checkCol += offset.col
                distance += 1
            }
        }
        
        return LineOfSightResult(hasLineOfSight: false, distance: Int.max, requiredDirection: nil)
    }
    
    /// Determine if the bot should shoot based on current alignment and configuration
    /// - Parameters:
    ///   - tank: The bot's tank
    ///   - allTanks: All tanks in the game
    ///   - grid: The game grid
    ///   - config: The bot's configuration
    ///   - tankIndex: The bot's tank index
    /// - Returns: true if the bot should shoot
    static func shouldShoot(
        tank: Tank,
        allTanks: [Tank],
        grid: [[GridCell]],
        config: AIBotConfig,
        tankIndex: Int
    ) -> Bool {
        // Check if currently aligned with an enemy
        if isAlignedWithEnemy(tank: tank, allTanks: allTanks, grid: grid, tankIndex: tankIndex, maxDistance: config.lookAheadDistance) {
            // Apply aim accuracy - higher difficulty = more likely to shoot when aligned
            return Double.random(in: 0...1) < config.aimAccuracy
        }
        
        // Random shooting for suppression (less likely at higher difficulties)
        let suppressionChance = config.aimAccuracy * 0.15 // 15% of aim accuracy for random shots
        return Double.random(in: 0...1) < suppressionChance
    }
    
    /// Check if the tank is currently aligned with an enemy (can shoot directly)
    static func isAlignedWithEnemy(
        tank: Tank,
        allTanks: [Tank],
        grid: [[GridCell]],
        tankIndex: Int,
        maxDistance: Int
    ) -> Bool {
        let offset = tank.direction.offset
        var checkRow = tank.row + offset.row
        var checkCol = tank.col + offset.col
        var distance = 0
        
        while distance < maxDistance {
            // Check bounds
            guard checkRow >= 0, checkRow < grid.count,
                  checkCol >= 0, checkCol < grid[0].count else {
                break
            }
            
            // Check if hit wall
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
    
    /// Find the best direction to face for shooting at a target
    /// - Parameters:
    ///   - tank: The bot's tank
    ///   - target: Target tank
    ///   - grid: The game grid
    ///   - predictive: Whether to use predictive aiming
    /// - Returns: The best direction to face, or nil if no good shot
    static func findBestShootingDirection(
        tank: Tank,
        target: Tank,
        grid: [[GridCell]],
        predictive: Bool = false
    ) -> Direction? {
        var targetRow = target.row
        var targetCol = target.col
        
        // Predictive aiming - aim where the target might be
        if predictive {
            let predictedPos = predictTargetPosition(target: target, ticksAhead: 2)
            targetRow = predictedPos.row
            targetCol = predictedPos.col
        }
        
        // Check if we can hit the target from current position in any direction
        for direction in Direction.cardinalDirections {
            let offset = direction.offset
            
            // Check if target is in this direction
            if offset.row != 0 && offset.col == 0 {
                // Vertical direction
                if tank.col == targetCol {
                    if (direction == .up && targetRow < tank.row) ||
                       (direction == .down && targetRow > tank.row) {
                        // Check for walls in between
                        if !hasObstacleBetween(from: tank, to: (row: targetRow, col: targetCol), direction: direction, grid: grid) {
                            return direction
                        }
                    }
                }
            } else if offset.col != 0 && offset.row == 0 {
                // Horizontal direction
                if tank.row == targetRow {
                    if (direction == .left && targetCol < tank.col) ||
                       (direction == .right && targetCol > tank.col) {
                        // Check for walls in between
                        if !hasObstacleBetween(from: tank, to: (row: targetRow, col: targetCol), direction: direction, grid: grid) {
                            return direction
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    /// Predict where a target will be in the future
    static func predictTargetPosition(target: Tank, ticksAhead: Int) -> (row: Int, col: Int) {
        let offset = target.direction.offset
        // Assume target continues in current direction
        let predictedRow = target.row + (offset.row * ticksAhead)
        let predictedCol = target.col + (offset.col * ticksAhead)
        return (predictedRow, predictedCol)
    }
    
    /// Check if there's an obstacle between two positions in a given direction
    static func hasObstacleBetween(
        from: Tank,
        to: (row: Int, col: Int),
        direction: Direction,
        grid: [[GridCell]]
    ) -> Bool {
        let offset = direction.offset
        var checkRow = from.row + offset.row
        var checkCol = from.col + offset.col
        
        while checkRow != to.row || checkCol != to.col {
            // Check bounds
            guard checkRow >= 0, checkRow < grid.count,
                  checkCol >= 0, checkCol < grid[0].count else {
                return true // Out of bounds is effectively an obstacle
            }
            
            if grid[checkRow][checkCol] == .wall {
                return true
            }
            
            checkRow += offset.row
            checkCol += offset.col
            
            // Safety check to avoid infinite loop
            if abs(checkRow - from.row) > grid.count || abs(checkCol - from.col) > grid[0].count {
                break
            }
        }
        
        return false
    }
    
    /// Find the best target among all enemies
    /// - Parameters:
    ///   - tank: The bot's tank
    ///   - allTanks: All tanks
    ///   - tankIndex: The bot's tank index
    ///   - grid: The game grid
    /// - Returns: The best target tank, or nil
    static func findBestTarget(
        tank: Tank,
        allTanks: [Tank],
        tankIndex: Int,
        grid: [[GridCell]]
    ) -> Tank? {
        var bestTarget: Tank?
        var bestScore = Int.min
        
        for (index, otherTank) in allTanks.enumerated() {
            guard index != tankIndex && otherTank.isAlive else { continue }
            
            var score = 0
            
            // Prefer closer targets
            let distance = AIPathfinding.manhattanDistance(
                from: (tank.row, tank.col),
                to: (otherTank.row, otherTank.col)
            )
            score -= distance
            
            // Bonus for targets in line of sight
            let los = checkLineOfSight(
                from: (tank.row, tank.col),
                target: otherTank,
                grid: grid,
                maxDistance: 8
            )
            if los.hasLineOfSight {
                score += 10
            }
            
            // Bonus for targets not facing us (easier to hit)
            let targetFacing = otherTank.direction
            let relativeDirection = getRelativeDirection(from: tank, to: otherTank)
            if let rel = relativeDirection, targetFacing != rel.opposite {
                score += 3 // Target is not looking at us
            }
            
            if score > bestScore {
                bestScore = score
                bestTarget = otherTank
            }
        }
        
        return bestTarget
    }
    
    /// Get the relative cardinal direction from one tank to another
    static func getRelativeDirection(from: Tank, to: Tank) -> Direction? {
        let rowDiff = to.row - from.row
        let colDiff = to.col - from.col
        
        if abs(rowDiff) > abs(colDiff) {
            return rowDiff < 0 ? .up : .down
        } else if abs(colDiff) > 0 {
            return colDiff < 0 ? .left : .right
        }
        return nil
    }
}

// Extension to add opposite direction
extension Direction {
    var opposite: Direction {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        case .upRight: return .downLeft
        case .downRight: return .upLeft
        case .downLeft: return .upRight
        case .upLeft: return .downRight
        }
    }
}
