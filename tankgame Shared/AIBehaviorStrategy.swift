//
//  AIBehaviorStrategy.swift
//  tankgame Shared
//
//  Defines AI difficulty levels and behavior strategies for bot tanks
//

import Foundation

/// AI difficulty levels that control bot behavior parameters
enum AIDifficulty: Int, CaseIterable {
    case easy = 0
    case medium = 1
    case hard = 2
    case expert = 3
    
    /// Display name for the difficulty level
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .expert: return "Expert"
        }
    }
    
    /// Movement interval in update ticks (lower = faster)
    var moveInterval: Int {
        switch self {
        case .easy: return 18
        case .medium: return 12
        case .hard: return 10
        case .expert: return 8
        }
    }
    
    /// Shooting interval in update ticks (lower = faster)
    var shootInterval: Int {
        switch self {
        case .easy: return 35
        case .medium: return 25
        case .hard: return 18
        case .expert: return 14
        }
    }
    
    /// Probability of making optimal movement decisions (0-1)
    var smartMoveChance: Double {
        switch self {
        case .easy: return 0.3
        case .medium: return 0.6
        case .hard: return 0.8
        case .expert: return 0.95
        }
    }
    
    /// Probability of shooting when a valid target is in sight (0-1)
    var accurateShootChance: Double {
        switch self {
        case .easy: return 0.5
        case .medium: return 0.7
        case .hard: return 0.85
        case .expert: return 0.95
        }
    }
    
    /// How far ahead to look for projectile danger (in cells)
    var dangerLookahead: Int {
        switch self {
        case .easy: return 2
        case .medium: return 4
        case .hard: return 5
        case .expert: return 6
        }
    }
    
    /// Probability of random shooting when no target (0-1)
    var randomShootChance: Double {
        switch self {
        case .easy: return 0.1
        case .medium: return 0.15
        case .hard: return 0.08
        case .expert: return 0.05
        }
    }
    
    /// Whether to use advanced tactical behaviors
    var useAdvancedTactics: Bool {
        switch self {
        case .easy, .medium: return false
        case .hard, .expert: return true
        }
    }
    
    /// Distance to maintain from enemies when using cover tactics
    var preferredCombatDistance: Int {
        switch self {
        case .easy: return 2
        case .medium: return 3
        case .hard: return 4
        case .expert: return 4
        }
    }
}

/// Represents the current tactical situation for a bot
struct TacticalSituation {
    /// Direction of incoming danger, if any
    var dangerDirection: Direction?
    
    /// Distance to the nearest threat
    var threatLevel: Int
    
    /// Best direction to attack from
    var attackDirection: Direction?
    
    /// Whether the bot has line of sight to a target
    var hasLineOfSight: Bool
    
    /// Number of enemies within close range
    var nearbyEnemyCount: Int
    
    /// Recommended action based on situation
    var recommendedAction: TacticalAction
    
    init() {
        self.dangerDirection = nil
        self.threatLevel = 0
        self.attackDirection = nil
        self.hasLineOfSight = false
        self.nearbyEnemyCount = 0
        self.recommendedAction = .wander
    }
}

/// Tactical actions the bot can take
enum TacticalAction {
    case attack      // Move towards enemy and shoot
    case dodge       // Evade incoming projectile
    case flank       // Move to get a better angle on enemy
    case seekCover   // Move behind obstacles
    case retreat     // Move away from multiple enemies
    case wander      // Random exploration
    case hold        // Stay in position (good firing position)
}

/// Strategy helper for AI decision making
struct AIBehaviorStrategy {
    
    /// Evaluate the tactical situation for a tank
    /// - Parameters:
    ///   - tank: The tank to evaluate for
    ///   - allTanks: All tanks in the game
    ///   - projectiles: Current projectiles
    ///   - grid: The game grid
    ///   - tankIndex: Index of the tank being evaluated
    ///   - difficulty: The AI difficulty level
    /// - Returns: A TacticalSituation describing the current state
    static func evaluateSituation(
        tank: Tank,
        allTanks: [Tank],
        projectiles: [Projectile],
        grid: [[GridCell]],
        tankIndex: Int,
        difficulty: AIDifficulty
    ) -> TacticalSituation {
        var situation = TacticalSituation()
        
        // Check for incoming danger
        situation.dangerDirection = detectIncomingDanger(
            tank: tank,
            projectiles: projectiles,
            lookahead: difficulty.dangerLookahead
        )
        
        // Count nearby enemies and calculate threat
        var nearbyCount = 0
        var minDistance = Int.max
        var nearestEnemy: Tank?
        
        for (index, otherTank) in allTanks.enumerated() {
            guard index != tankIndex && otherTank.isAlive else { continue }
            
            let distance = manhattanDistance(from: tank, to: otherTank)
            if distance < minDistance {
                minDistance = distance
                nearestEnemy = otherTank
            }
            
            if distance <= 4 {
                nearbyCount += 1
            }
        }
        
        situation.nearbyEnemyCount = nearbyCount
        situation.threatLevel = max(0, 5 - minDistance)
        
        // Check line of sight
        if let enemy = nearestEnemy {
            situation.hasLineOfSight = hasLineOfSight(from: tank, to: enemy, grid: grid)
            situation.attackDirection = directionTo(from: tank, to: enemy)
        }
        
        // Determine recommended action
        situation.recommendedAction = determineAction(
            situation: situation,
            difficulty: difficulty
        )
        
        return situation
    }
    
    /// Calculate Manhattan distance between two tanks
    static func manhattanDistance(from tank1: Tank, to tank2: Tank) -> Int {
        return abs(tank1.row - tank2.row) + abs(tank1.col - tank2.col)
    }
    
    /// Detect if there's an incoming projectile heading toward the tank
    private static func detectIncomingDanger(
        tank: Tank,
        projectiles: [Projectile],
        lookahead: Int
    ) -> Direction? {
        for projectile in projectiles {
            let offset = projectile.direction.offset
            var checkRow = projectile.row
            var checkCol = projectile.col
            
            for _ in 0..<lookahead {
                checkRow += offset.row
                checkCol += offset.col
                
                if checkRow == tank.row && checkCol == tank.col {
                    return projectile.direction
                }
                
                // Also check adjacent cells for near misses
                if abs(checkRow - tank.row) <= 1 && abs(checkCol - tank.col) <= 1 &&
                   (checkRow == tank.row || checkCol == tank.col) {
                    return projectile.direction
                }
            }
        }
        return nil
    }
    
    /// Check if there's a clear line of sight between two tanks
    private static func hasLineOfSight(from tank: Tank, to target: Tank, grid: [[GridCell]]) -> Bool {
        // Check horizontal line
        if tank.row == target.row {
            let minCol = min(tank.col, target.col)
            let maxCol = max(tank.col, target.col)
            for col in (minCol + 1)..<maxCol {
                if grid[tank.row][col] == .wall {
                    return false
                }
            }
            return true
        }
        
        // Check vertical line
        if tank.col == target.col {
            let minRow = min(tank.row, target.row)
            let maxRow = max(tank.row, target.row)
            for row in (minRow + 1)..<maxRow {
                if grid[row][tank.col] == .wall {
                    return false
                }
            }
            return true
        }
        
        return false
    }
    
    /// Get the direction from one tank to another
    private static func directionTo(from tank: Tank, to target: Tank) -> Direction? {
        if tank.row == target.row {
            return target.col > tank.col ? .right : .left
        }
        if tank.col == target.col {
            return target.row > tank.row ? .down : .up
        }
        return nil
    }
    
    /// Determine the best action based on situation and difficulty
    private static func determineAction(
        situation: TacticalSituation,
        difficulty: AIDifficulty
    ) -> TacticalAction {
        // Priority 1: Dodge incoming projectiles
        if situation.dangerDirection != nil {
            return .dodge
        }
        
        // Priority 2: If surrounded, retreat (for advanced tactics)
        if difficulty.useAdvancedTactics && situation.nearbyEnemyCount >= 2 {
            return .retreat
        }
        
        // Priority 3: Attack if we have line of sight
        if situation.hasLineOfSight {
            // For advanced tactics, consider holding position if we have advantage
            if difficulty.useAdvancedTactics && situation.threatLevel <= 2 {
                return .hold
            }
            return .attack
        }
        
        // Priority 4: Flank if we're close but no line of sight (advanced tactics)
        if difficulty.useAdvancedTactics && situation.threatLevel >= 2 {
            return .flank
        }
        
        // Priority 5: Seek cover if threatened but no good shot (advanced)
        if difficulty.useAdvancedTactics && situation.threatLevel >= 3 && !situation.hasLineOfSight {
            return .seekCover
        }
        
        // Default: Attack or wander
        if situation.threatLevel > 0 {
            return .attack
        }
        
        return .wander
    }
    
    /// Find the best direction to flank a target
    /// - Parameters:
    ///   - tank: Current tank position
    ///   - target: Target to flank
    ///   - grid: Game grid
    ///   - allTanks: All tanks for collision checking
    ///   - tankIndex: Index of current tank
    /// - Returns: Best flanking direction if available
    static func findFlankingDirection(
        tank: Tank,
        target: Tank,
        grid: [[GridCell]],
        allTanks: [Tank],
        tankIndex: Int
    ) -> Direction? {
        // Try to move perpendicular to get a better angle
        var perpDirections: [Direction]
        
        if abs(tank.row - target.row) > abs(tank.col - target.col) {
            // Mostly vertical alignment, move horizontally to flank
            perpDirections = [.left, .right]
        } else {
            // Mostly horizontal alignment, move vertically to flank
            perpDirections = [.up, .down]
        }
        
        // Shuffle for unpredictability
        perpDirections.shuffle()
        
        for direction in perpDirections {
            if canMove(tank: tank, direction: direction, grid: grid, allTanks: allTanks, tankIndex: tankIndex) {
                return direction
            }
        }
        
        return nil
    }
    
    /// Find a direction toward cover (walls)
    /// - Parameters:
    ///   - tank: Current tank position
    ///   - grid: Game grid
    ///   - allTanks: All tanks for collision checking
    ///   - tankIndex: Index of current tank
    /// - Returns: Direction toward cover if available
    static func findCoverDirection(
        tank: Tank,
        grid: [[GridCell]],
        allTanks: [Tank],
        tankIndex: Int
    ) -> Direction? {
        var bestDirection: Direction?
        var bestScore = -1
        
        for direction in Direction.cardinalDirections.shuffled() {
            guard canMove(tank: tank, direction: direction, grid: grid, allTanks: allTanks, tankIndex: tankIndex) else {
                continue
            }
            
            // Score based on nearby walls (cover)
            let offset = direction.offset
            let newRow = tank.row + offset.row
            let newCol = tank.col + offset.col
            
            var coverScore = 0
            
            // Check adjacent cells for walls (cover)
            for checkDir in Direction.cardinalDirections {
                let checkOffset = checkDir.offset
                let checkRow = newRow + checkOffset.row
                let checkCol = newCol + checkOffset.col
                
                if checkRow >= 0 && checkRow < grid.count &&
                   checkCol >= 0 && checkCol < grid[0].count &&
                   grid[checkRow][checkCol] == .wall {
                    coverScore += 1
                }
            }
            
            if coverScore > bestScore {
                bestScore = coverScore
                bestDirection = direction
            }
        }
        
        return bestDirection
    }
    
    /// Find the best direction to retreat from enemies
    static func findRetreatDirection(
        tank: Tank,
        allTanks: [Tank],
        grid: [[GridCell]],
        tankIndex: Int
    ) -> Direction? {
        // Calculate the center of mass of enemies
        var enemyCenterRow = 0
        var enemyCenterCol = 0
        var enemyCount = 0
        
        for (index, otherTank) in allTanks.enumerated() {
            guard index != tankIndex && otherTank.isAlive else { continue }
            enemyCenterRow += otherTank.row
            enemyCenterCol += otherTank.col
            enemyCount += 1
        }
        
        guard enemyCount > 0 else { return nil }
        
        enemyCenterRow /= enemyCount
        enemyCenterCol /= enemyCount
        
        // Move away from center of enemies
        var retreatDirections: [Direction] = []
        
        if enemyCenterRow < tank.row {
            retreatDirections.append(.down)
        } else if enemyCenterRow > tank.row {
            retreatDirections.append(.up)
        }
        
        if enemyCenterCol < tank.col {
            retreatDirections.append(.right)
        } else if enemyCenterCol > tank.col {
            retreatDirections.append(.left)
        }
        
        // Try retreat directions first
        for direction in retreatDirections.shuffled() {
            if canMove(tank: tank, direction: direction, grid: grid, allTanks: allTanks, tankIndex: tankIndex) {
                return direction
            }
        }
        
        // Fall back to any valid direction
        return nil
    }
    
    /// Check if a tank can move in the given direction
    private static func canMove(
        tank: Tank,
        direction: Direction,
        grid: [[GridCell]],
        allTanks: [Tank],
        tankIndex: Int
    ) -> Bool {
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
