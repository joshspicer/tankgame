//
//  AIBotTank.swift
//  tankgame Shared
//
//  AI controller for bot tanks - enables single player mode and AI opponents in multiplayer
//

import Foundation

/// Difficulty level for AI bots - affects reaction time, accuracy, and strategic behavior
enum AIBotDifficulty: Int, CaseIterable {
    case easy = 0
    case medium = 1
    case hard = 2
    
    /// Movement interval (lower = faster reactions)
    var moveInterval: Int {
        switch self {
        case .easy: return 18
        case .medium: return 12
        case .hard: return 8
        }
    }
    
    /// Shooting interval (lower = faster shooting)
    var shootInterval: Int {
        switch self {
        case .easy: return 35
        case .medium: return 25
        case .hard: return 18
        }
    }
    
    /// How far ahead to look for danger (in cells)
    var dangerLookahead: Int {
        switch self {
        case .easy: return 3
        case .medium: return 4
        case .hard: return 6
        }
    }
    
    /// Chance of random wandering vs strategic movement (0.0-1.0)
    var randomnessChance: Double {
        switch self {
        case .easy: return 0.5
        case .medium: return 0.3
        case .hard: return 0.15
        }
    }
    
    /// Chance of random shooting when no target is visible (0.0-1.0)
    var randomShootChance: Double {
        switch self {
        case .easy: return 0.3
        case .medium: return 0.2
        case .hard: return 0.1
        }
    }
    
    /// Whether to use flanking strategies
    var useFlankingBehavior: Bool {
        switch self {
        case .easy: return false
        case .medium: return true
        case .hard: return true
        }
    }
    
    /// Whether to seek cover near walls
    var useCoverBehavior: Bool {
        switch self {
        case .easy: return false
        case .medium: return false
        case .hard: return true
        }
    }
    
    /// Whether to consider lizards as threats
    var avoidLizards: Bool {
        switch self {
        case .easy: return false
        case .medium: return true
        case .hard: return true
        }
    }
}

/// Represents a potential threat to the bot
struct ThreatInfo {
    let direction: Direction
    let distance: Int
    let isProjectile: Bool
}

/// AI controller that manages bot tank behavior including movement and shooting
struct AIBotTank {
    
    /// The tank index this AI controls
    let tankIndex: Int
    
    /// Difficulty level for this bot
    let difficulty: AIBotDifficulty
    
    /// Movement decision interval in update ticks
    private var moveCounter: Int = 0
    
    /// Shooting decision interval in update ticks
    private var shootCounter: Int = 0
    
    /// Whether the bot should attempt to shoot this update
    var shouldShoot: Bool = false
    
    /// Counter for flanking behavior - tracks how long we've been pursuing same direction
    private var pursuitCounter: Int = 0
    private var lastPursuitDirection: Direction?
    
    /// Preferred flanking direction (alternates to create varied behavior)
    private var preferredFlankSide: Bool = Bool.random()
    
    init(tankIndex: Int, difficulty: AIBotDifficulty = .medium) {
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
    ///   - lizards: Current lizards (for avoidance on hard difficulty)
    /// - Returns: The direction the bot wants to move, or nil if not moving this update
    mutating func update(tank: Tank, grid: [[GridCell]], allTanks: [Tank], projectiles: [Projectile], lizards: [Lizard] = []) -> Direction? {
        guard tank.isAlive else { return nil }
        
        // Update shooting logic
        shootCounter += 1
        if shootCounter >= difficulty.shootInterval {
            shootCounter = 0
            shouldShoot = shouldAttemptShoot(tank: tank, allTanks: allTanks, grid: grid, lizards: lizards)
        } else {
            shouldShoot = false
        }
        
        // Update movement logic
        moveCounter += 1
        guard moveCounter >= difficulty.moveInterval else { return nil }
        moveCounter = 0
        
        return decideMovement(tank: tank, grid: grid, allTanks: allTanks, projectiles: projectiles, lizards: lizards)
    }
    
    /// Decide which direction to move
    private mutating func decideMovement(tank: Tank, grid: [[GridCell]], allTanks: [Tank], projectiles: [Projectile], lizards: [Lizard]) -> Direction? {
        // Collect all threats (projectiles and lizards)
        let threats = detectAllThreats(tank: tank, projectiles: projectiles, lizards: lizards)
        
        // Priority 1: Dodge immediate danger
        if !threats.isEmpty {
            if let dodgeDir = dodgeThreats(threats: threats, tank: tank, grid: grid, allTanks: allTanks) {
                return dodgeDir
            }
        }
        
        // Find the best target
        guard let target = findBestTarget(tank: tank, allTanks: allTanks, grid: grid) else {
            // No enemy found, wander or seek cover
            if difficulty.useCoverBehavior {
                return seekCover(tank: tank, grid: grid, allTanks: allTanks) ?? wanderRandomly(tank: tank, grid: grid, allTanks: allTanks)
            }
            return wanderRandomly(tank: tank, grid: grid, allTanks: allTanks)
        }
        
        // Decide between flanking, pursuing, or positioning
        if difficulty.useFlankingBehavior && shouldFlank(tank: tank, target: target, grid: grid) {
            return flankTarget(tank: tank, target: target, grid: grid, allTanks: allTanks)
        }
        
        // Check if we should seek a better shooting position
        if difficulty.useCoverBehavior && hasLineOfSight(from: tank, to: target, grid: grid) {
            // We can see them - maybe hold position or get better angle
            if Double.random(in: 0...1) < 0.4 {
                return nil // Hold position and shoot
            }
        }
        
        // Pursue the target with some randomness based on difficulty
        return pursueTarget(tank: tank, target: target, grid: grid, allTanks: allTanks)
    }
    
    // MARK: - Enhanced Targeting
    
    /// Find the best target considering multiple factors
    private func findBestTarget(tank: Tank, allTanks: [Tank], grid: [[GridCell]]) -> Tank? {
        var bestTarget: Tank?
        var bestScore = Int.min
        
        for (index, otherTank) in allTanks.enumerated() {
            guard index != tankIndex && otherTank.isAlive else { continue }
            
            let distance = abs(tank.row - otherTank.row) + abs(tank.col - otherTank.col)
            var score = 100 - distance  // Base score inversely proportional to distance
            
            // Bonus for targets in line of sight
            if hasLineOfSight(from: tank, to: otherTank, grid: grid) {
                score += 30
            }
            
            // Bonus for targets that are aligned (easier to hit)
            if tank.row == otherTank.row || tank.col == otherTank.col {
                score += 20
            }
            
            // Slight preference for targets in current facing direction
            let dirToTarget = directionTo(from: tank, to: otherTank)
            if dirToTarget == tank.direction {
                score += 15
            }
            
            if score > bestScore {
                bestScore = score
                bestTarget = otherTank
            }
        }
        
        return bestTarget
    }
    
    /// Determine the general direction from one tank to another
    private func directionTo(from: Tank, to: Tank) -> Direction {
        let rowDiff = to.row - from.row
        let colDiff = to.col - from.col
        
        if abs(rowDiff) > abs(colDiff) {
            return rowDiff < 0 ? .up : .down
        } else {
            return colDiff < 0 ? .left : .right
        }
    }
    
    /// Check if there's a clear line of sight between two tanks
    private func hasLineOfSight(from: Tank, to: Tank, grid: [[GridCell]]) -> Bool {
        // Only check cardinal directions (horizontal/vertical lines)
        if from.row != to.row && from.col != to.col {
            return false
        }
        
        let rowStep = (to.row - from.row).signum()
        let colStep = (to.col - from.col).signum()
        
        var checkRow = from.row + rowStep
        var checkCol = from.col + colStep
        
        while checkRow != to.row || checkCol != to.col {
            if checkRow < 0 || checkRow >= grid.count || checkCol < 0 || checkCol >= grid[0].count {
                return false
            }
            if grid[checkRow][checkCol] == .wall {
                return false
            }
            checkRow += rowStep
            checkCol += colStep
        }
        
        return true
    }
    
    // MARK: - Enhanced Threat Detection
    
    /// Detect all threats including projectiles and optionally lizards
    private func detectAllThreats(tank: Tank, projectiles: [Projectile], lizards: [Lizard]) -> [ThreatInfo] {
        var threats: [ThreatInfo] = []
        
        // Check projectiles
        for projectile in projectiles {
            if let threat = detectProjectileThreat(tank: tank, projectile: projectile) {
                threats.append(threat)
            }
        }
        
        // Check lizards if enabled
        if difficulty.avoidLizards {
            for lizard in lizards where lizard.isAlive {
                if let threat = detectLizardThreat(tank: tank, lizard: lizard) {
                    threats.append(threat)
                }
            }
        }
        
        return threats
    }
    
    /// Detect if a specific projectile is a threat
    private func detectProjectileThreat(tank: Tank, projectile: Projectile) -> ThreatInfo? {
        let projOffset = projectile.direction.offset
        var checkRow = projectile.row
        var checkCol = projectile.col
        
        for step in 0..<difficulty.dangerLookahead {
            checkRow += projOffset.row
            checkCol += projOffset.col
            
            if checkRow == tank.row && checkCol == tank.col {
                return ThreatInfo(direction: projectile.direction, distance: step + 1, isProjectile: true)
            }
        }
        return nil
    }
    
    /// Detect if a lizard is a nearby threat
    private func detectLizardThreat(tank: Tank, lizard: Lizard) -> ThreatInfo? {
        let distance = abs(tank.row - lizard.row) + abs(tank.col - lizard.col)
        if distance <= 2 {
            let dir = directionTo(from: Tank(row: lizard.row, col: lizard.col), to: tank)
            return ThreatInfo(direction: dir, distance: distance, isProjectile: false)
        }
        return nil
    }
    
    /// Dodge multiple threats by finding the safest direction
    private func dodgeThreats(threats: [ThreatInfo], tank: Tank, grid: [[GridCell]], allTanks: [Tank]) -> Direction? {
        // Find all dangerous directions
        var dangerousDirections: Set<Direction> = []
        for threat in threats {
            dangerousDirections.insert(threat.direction)
            dangerousDirections.insert(threat.direction.opposite)
        }
        
        // Find safe perpendicular directions
        var safeDirections: [Direction] = []
        for dir in Direction.cardinalDirections {
            if !dangerousDirections.contains(dir) && canMove(tank: tank, direction: dir, grid: grid, allTanks: allTanks) {
                safeDirections.append(dir)
            }
        }
        
        // Return a random safe direction
        if let safeDir = safeDirections.randomElement() {
            return safeDir
        }
        
        // If no safe direction, try any movable direction
        return wanderRandomly(tank: tank, grid: grid, allTanks: allTanks)
    }
    
    // MARK: - Flanking Behavior
    
    /// Determine if the bot should attempt to flank the target
    private mutating func shouldFlank(tank: Tank, target: Tank, grid: [[GridCell]]) -> Bool {
        // Track if we've been pursuing the same direction too long
        let currentDir = directionTo(from: tank, to: target)
        if currentDir == lastPursuitDirection {
            pursuitCounter += 1
        } else {
            pursuitCounter = 0
            lastPursuitDirection = currentDir
        }
        
        // Flank if we've been pursuing for a while without success
        // Or randomly based on difficulty
        let shouldFlankDueToStuck = pursuitCounter > 5
        let randomFlank = Double.random(in: 0...1) < 0.25
        
        return shouldFlankDueToStuck || randomFlank
    }
    
    /// Attempt to flank the target by moving perpendicular
    private mutating func flankTarget(tank: Tank, target: Tank, grid: [[GridCell]], allTanks: [Tank]) -> Direction? {
        let directDir = directionTo(from: tank, to: target)
        
        // Get perpendicular directions
        let perpendicularDirs: [Direction]
        switch directDir {
        case .up, .down:
            perpendicularDirs = preferredFlankSide ? [.right, .left] : [.left, .right]
        case .left, .right:
            perpendicularDirs = preferredFlankSide ? [.down, .up] : [.up, .down]
        default:
            perpendicularDirs = Direction.cardinalDirections.shuffled()
        }
        
        // Alternate flanking side for next time
        preferredFlankSide.toggle()
        
        // Try perpendicular directions first
        for dir in perpendicularDirs {
            if canMove(tank: tank, direction: dir, grid: grid, allTanks: allTanks) {
                pursuitCounter = 0 // Reset stuck counter
                return dir
            }
        }
        
        // Fall back to direct pursuit
        return pursueTarget(tank: tank, target: target, grid: grid, allTanks: allTanks)
    }
    
    // MARK: - Cover-Seeking Behavior
    
    /// Find a position near a wall for cover
    private func seekCover(tank: Tank, grid: [[GridCell]], allTanks: [Tank]) -> Direction? {
        // Check which directions have walls nearby (good for cover)
        var coverDirections: [Direction] = []
        
        for dir in Direction.cardinalDirections {
            let offset = dir.offset
            let checkRow = tank.row + offset.row
            let checkCol = tank.col + offset.col
            
            // Skip if out of bounds
            guard checkRow >= 0, checkRow < grid.count,
                  checkCol >= 0, checkCol < grid[0].count else {
                continue
            }
            
            // If there's a wall adjacent to where we'd move, that's good cover
            if hasAdjacentWall(row: checkRow, col: checkCol, grid: grid) &&
               canMove(tank: tank, direction: dir, grid: grid, allTanks: allTanks) {
                coverDirections.append(dir)
            }
        }
        
        return coverDirections.randomElement()
    }
    
    /// Check if a position has an adjacent wall
    private func hasAdjacentWall(row: Int, col: Int, grid: [[GridCell]]) -> Bool {
        for dir in Direction.cardinalDirections {
            let checkRow = row + dir.offset.row
            let checkCol = col + dir.offset.col
            
            if checkRow >= 0 && checkRow < grid.count &&
               checkCol >= 0 && checkCol < grid[0].count &&
               grid[checkRow][checkCol] == .wall {
                return true
            }
        }
        return false
    }
    
    // MARK: - Movement and Pursuit
    
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
        
        // Add randomness based on difficulty
        if Double.random(in: 0...1) < difficulty.randomnessChance {
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
    
    // MARK: - Enhanced Shooting Logic
    
    /// Determine if the bot should attempt to shoot
    private func shouldAttemptShoot(tank: Tank, allTanks: [Tank], grid: [[GridCell]], lizards: [Lizard]) -> Bool {
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
            
            // Check if there's a lizard here (bonus targets)
            for lizard in lizards where lizard.isAlive {
                if lizard.row == checkRow && lizard.col == checkCol {
                    // 60% chance to shoot at lizards
                    return Double.random(in: 0...1) < 0.6
                }
            }
            
            checkRow += offset.row
            checkCol += offset.col
        }
        
        // Random shooting based on difficulty
        return Double.random(in: 0...1) < difficulty.randomShootChance
    }
}
