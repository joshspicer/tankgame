//
//  AIPathfinding.swift
//  tankgame Shared
//
//  Pathfinding utilities for AI bots including flanking and tactical positioning
//

import Foundation

/// Provides pathfinding and tactical positioning utilities for AI bots
struct AIPathfinding {
    
    /// Calculate Manhattan distance between two positions
    static func manhattanDistance(from: (row: Int, col: Int), to: (row: Int, col: Int)) -> Int {
        return abs(from.row - to.row) + abs(from.col - to.col)
    }
    
    /// Find the best direction to reach a target position
    /// - Parameters:
    ///   - from: Current position
    ///   - to: Target position
    ///   - grid: The game grid
    ///   - tanks: All tanks (for obstacle avoidance)
    ///   - currentTankIndex: Index of the current tank
    ///   - preferFlanking: Whether to prefer flanking routes
    /// - Returns: The best direction to move, or nil if stuck
    static func findBestDirection(
        from: (row: Int, col: Int),
        to: (row: Int, col: Int),
        grid: [[GridCell]],
        tanks: [Tank],
        currentTankIndex: Int,
        preferFlanking: Bool = false
    ) -> Direction? {
        var directions: [(direction: Direction, score: Int)] = []
        
        for direction in Direction.cardinalDirections {
            let offset = direction.offset
            let newRow = from.row + offset.row
            let newCol = from.col + offset.col
            
            // Check if move is valid
            guard isValidPosition(row: newRow, col: newCol, grid: grid, tanks: tanks, currentTankIndex: currentTankIndex) else {
                continue
            }
            
            // Calculate score for this direction
            let newDistance = manhattanDistance(from: (newRow, newCol), to: to)
            var score = -newDistance // Negative so lower distance = higher score
            
            if preferFlanking {
                // Prefer diagonal approaches - score moves that don't directly approach
                let rowDiff = to.row - from.row
                let colDiff = to.col - from.col
                
                // If target is primarily in one axis, prefer moving in the other axis
                if abs(rowDiff) > abs(colDiff) {
                    // Target is primarily vertical - prefer horizontal movement
                    if direction == .left || direction == .right {
                        score += 2
                    }
                } else if abs(colDiff) > abs(rowDiff) {
                    // Target is primarily horizontal - prefer vertical movement
                    if direction == .up || direction == .down {
                        score += 2
                    }
                }
            }
            
            directions.append((direction, score))
        }
        
        // Sort by score (highest first) and pick the best
        directions.sort { $0.score > $1.score }
        return directions.first?.direction
    }
    
    /// Find a direction to take cover near a wall
    /// - Parameters:
    ///   - from: Current position
    ///   - grid: The game grid
    ///   - tanks: All tanks
    ///   - currentTankIndex: Index of the current tank
    ///   - threatDirection: Direction the threat is coming from
    /// - Returns: Direction to move toward cover, or nil
    static func findCoverDirection(
        from: (row: Int, col: Int),
        grid: [[GridCell]],
        tanks: [Tank],
        currentTankIndex: Int,
        threatDirection: Direction
    ) -> Direction? {
        // Find directions perpendicular to the threat
        let coverDirections: [Direction]
        switch threatDirection {
        case .up, .down:
            coverDirections = [.left, .right]
        case .left, .right:
            coverDirections = [.up, .down]
        default:
            coverDirections = Direction.cardinalDirections
        }
        
        // Prioritize moves that put a wall between us and the threat
        var bestDirection: Direction?
        var bestScore = Int.min
        
        for direction in coverDirections {
            let offset = direction.offset
            let newRow = from.row + offset.row
            let newCol = from.col + offset.col
            
            guard isValidPosition(row: newRow, col: newCol, grid: grid, tanks: tanks, currentTankIndex: currentTankIndex) else {
                continue
            }
            
            // Score based on proximity to walls (walls provide cover)
            var score = 0
            for wallCheckDir in Direction.cardinalDirections {
                let wallOffset = wallCheckDir.offset
                let checkRow = newRow + wallOffset.row
                let checkCol = newCol + wallOffset.col
                
                if checkRow >= 0 && checkRow < grid.count &&
                   checkCol >= 0 && checkCol < grid[0].count &&
                   grid[checkRow][checkCol] == .wall {
                    score += 1
                }
            }
            
            if score > bestScore {
                bestScore = score
                bestDirection = direction
            }
        }
        
        return bestDirection
    }
    
    /// Find a direction to flank an enemy target
    /// - Parameters:
    ///   - from: Current position
    ///   - target: Target tank
    ///   - grid: The game grid
    ///   - tanks: All tanks
    ///   - currentTankIndex: Index of the current tank
    /// - Returns: Direction for flanking maneuver, or nil
    static func findFlankingDirection(
        from: (row: Int, col: Int),
        target: Tank,
        grid: [[GridCell]],
        tanks: [Tank],
        currentTankIndex: Int
    ) -> Direction? {
        // Try to get to a position perpendicular to the target's facing direction
        let targetFacing = target.direction
        
        // Determine flanking positions (perpendicular to target's facing)
        var flankPositions: [(row: Int, col: Int)] = []
        
        switch targetFacing {
        case .up, .down:
            // Flank from left or right
            flankPositions = [
                (target.row, target.col - 2),
                (target.row, target.col + 2)
            ]
        case .left, .right:
            // Flank from above or below
            flankPositions = [
                (target.row - 2, target.col),
                (target.row + 2, target.col)
            ]
        default:
            // For diagonal facing, use cardinal flanking
            flankPositions = [
                (target.row - 2, target.col),
                (target.row + 2, target.col),
                (target.row, target.col - 2),
                (target.row, target.col + 2)
            ]
        }
        
        // Find the closest flank position and move toward it
        var closestPosition: (row: Int, col: Int)?
        var closestDistance = Int.max
        
        for pos in flankPositions {
            // Skip invalid positions
            if pos.row < 0 || pos.row >= grid.count || pos.col < 0 || pos.col >= grid[0].count {
                continue
            }
            if grid[pos.row][pos.col] != .empty {
                continue
            }
            
            let distance = manhattanDistance(from: from, to: pos)
            if distance < closestDistance {
                closestDistance = distance
                closestPosition = pos
            }
        }
        
        guard let targetPos = closestPosition else {
            return nil
        }
        
        return findBestDirection(
            from: from,
            to: targetPos,
            grid: grid,
            tanks: tanks,
            currentTankIndex: currentTankIndex,
            preferFlanking: false
        )
    }
    
    /// Check if a position is valid for movement
    static func isValidPosition(row: Int, col: Int, grid: [[GridCell]], tanks: [Tank], currentTankIndex: Int) -> Bool {
        // Check bounds
        guard row >= 0, row < grid.count, col >= 0, col < grid[0].count else {
            return false
        }
        
        // Check if cell is empty
        guard grid[row][col] == .empty else {
            return false
        }
        
        // Check if another tank is there
        for (index, tank) in tanks.enumerated() {
            guard index != currentTankIndex && tank.isAlive else { continue }
            if tank.row == row && tank.col == col {
                return false
            }
        }
        
        return true
    }
    
    /// Find the best retreat direction (away from enemies)
    static func findRetreatDirection(
        from: (row: Int, col: Int),
        enemies: [Tank],
        grid: [[GridCell]],
        tanks: [Tank],
        currentTankIndex: Int
    ) -> Direction? {
        // Calculate average enemy position
        let aliveEnemies = enemies.filter { $0.isAlive }
        guard !aliveEnemies.isEmpty else { return nil }
        
        let avgRow = aliveEnemies.map { $0.row }.reduce(0, +) / aliveEnemies.count
        let avgCol = aliveEnemies.map { $0.col }.reduce(0, +) / aliveEnemies.count
        
        // Find direction that maximizes distance from average enemy position
        var bestDirection: Direction?
        var bestDistance = Int.min
        
        for direction in Direction.cardinalDirections {
            let offset = direction.offset
            let newRow = from.row + offset.row
            let newCol = from.col + offset.col
            
            guard isValidPosition(row: newRow, col: newCol, grid: grid, tanks: tanks, currentTankIndex: currentTankIndex) else {
                continue
            }
            
            let distance = manhattanDistance(from: (newRow, newCol), to: (avgRow, avgCol))
            if distance > bestDistance {
                bestDistance = distance
                bestDirection = direction
            }
        }
        
        return bestDirection
    }
}
