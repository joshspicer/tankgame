//
//  AIThreatDetection.swift
//  tankgame Shared
//
//  Threat detection and avoidance utilities for AI bots
//

import Foundation

/// Provides threat detection and avoidance utilities for AI bots
struct AIThreatDetection {
    
    /// Information about a detected threat
    struct ThreatInfo {
        let direction: Direction       // Direction threat is coming from
        let distance: Int              // Distance to threat
        let turnsToImpact: Int         // Estimated turns until impact
        let severity: ThreatSeverity   // How dangerous the threat is
    }
    
    /// Severity levels for threats
    enum ThreatSeverity: Int, Comparable {
        case low = 0
        case medium = 1
        case high = 2
        case critical = 3
        
        static func < (lhs: ThreatSeverity, rhs: ThreatSeverity) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
    
    /// Detect incoming projectile threats
    /// - Parameters:
    ///   - tank: The tank to check threats for
    ///   - projectiles: All projectiles in the game
    ///   - lookAhead: How many cells ahead to scan
    /// - Returns: Array of detected threats, sorted by severity
    static func detectProjectileThreats(
        tank: Tank,
        projectiles: [Projectile],
        lookAhead: Int
    ) -> [ThreatInfo] {
        var threats: [ThreatInfo] = []
        
        for projectile in projectiles {
            let offset = projectile.direction.offset
            var checkRow = projectile.row
            var checkCol = projectile.col
            
            // Look ahead to see if projectile will hit us
            for step in 0..<lookAhead {
                checkRow += offset.row
                checkCol += offset.col
                
                if checkRow == tank.row && checkCol == tank.col {
                    // This projectile will hit us
                    let distance = step + 1
                    let severity: ThreatSeverity
                    
                    if distance <= 1 {
                        severity = .critical
                    } else if distance <= 2 {
                        severity = .high
                    } else if distance <= 4 {
                        severity = .medium
                    } else {
                        severity = .low
                    }
                    
                    threats.append(ThreatInfo(
                        direction: projectile.direction,
                        distance: distance,
                        turnsToImpact: distance,
                        severity: severity
                    ))
                    break
                }
            }
        }
        
        // Sort by severity (most dangerous first)
        return threats.sorted { $0.severity > $1.severity }
    }
    
    /// Detect enemy tank threats (enemies that could shoot us)
    /// - Parameters:
    ///   - tank: The tank to check threats for
    ///   - allTanks: All tanks in the game
    ///   - tankIndex: Index of the current tank
    ///   - grid: The game grid
    /// - Returns: Array of detected threats
    static func detectEnemyThreats(
        tank: Tank,
        allTanks: [Tank],
        tankIndex: Int,
        grid: [[GridCell]]
    ) -> [ThreatInfo] {
        var threats: [ThreatInfo] = []
        
        for (index, enemy) in allTanks.enumerated() {
            guard index != tankIndex && enemy.isAlive else { continue }
            
            // Check if enemy is facing us and has line of sight
            let los = AITargeting.checkLineOfSight(
                from: (enemy.row, enemy.col),
                target: tank,
                grid: grid,
                maxDistance: 8
            )
            
            if los.hasLineOfSight && los.requiredDirection == enemy.direction {
                // Enemy is facing us with clear line of sight!
                let severity: ThreatSeverity
                if los.distance <= 2 {
                    severity = .critical
                } else if los.distance <= 4 {
                    severity = .high
                } else {
                    severity = .medium
                }
                
                threats.append(ThreatInfo(
                    direction: enemy.direction,
                    distance: los.distance,
                    turnsToImpact: los.distance, // Approximation
                    severity: severity
                ))
            }
        }
        
        return threats.sorted { $0.severity > $1.severity }
    }
    
    /// Find the best dodge direction to avoid threats
    /// - Parameters:
    ///   - tank: The tank trying to dodge
    ///   - threats: Detected threats
    ///   - grid: The game grid
    ///   - allTanks: All tanks
    ///   - tankIndex: Index of current tank
    /// - Returns: Best direction to dodge, or nil
    static func findDodgeDirection(
        tank: Tank,
        threats: [ThreatInfo],
        grid: [[GridCell]],
        allTanks: [Tank],
        tankIndex: Int
    ) -> Direction? {
        guard let mostDangerousThreat = threats.first else { return nil }
        
        // Get perpendicular directions to dodge
        let perpendicularDirections: [Direction]
        switch mostDangerousThreat.direction {
        case .up, .down:
            perpendicularDirections = [.left, .right]
        case .left, .right:
            perpendicularDirections = [.up, .down]
        default:
            perpendicularDirections = Direction.cardinalDirections
        }
        
        // Shuffle to add unpredictability
        let shuffled = perpendicularDirections.shuffled()
        
        for direction in shuffled {
            let offset = direction.offset
            let newRow = tank.row + offset.row
            let newCol = tank.col + offset.col
            
            if AIPathfinding.isValidPosition(row: newRow, col: newCol, grid: grid, tanks: allTanks, currentTankIndex: tankIndex) {
                return direction
            }
        }
        
        // If perpendicular dodge not possible, try moving away
        let awayDirection = mostDangerousThreat.direction.opposite
        let awayOffset = awayDirection.offset
        let awayRow = tank.row + awayOffset.row
        let awayCol = tank.col + awayOffset.col
        
        if AIPathfinding.isValidPosition(row: awayRow, col: awayCol, grid: grid, tanks: allTanks, currentTankIndex: tankIndex) {
            return awayDirection
        }
        
        return nil
    }
    
    /// Assess overall threat level for the current situation
    /// - Parameters:
    ///   - tank: The tank to assess for
    ///   - allTanks: All tanks
    ///   - projectiles: All projectiles
    ///   - tankIndex: Index of current tank
    ///   - grid: The game grid
    /// - Returns: Overall threat severity
    static func assessOverallThreatLevel(
        tank: Tank,
        allTanks: [Tank],
        projectiles: [Projectile],
        tankIndex: Int,
        grid: [[GridCell]]
    ) -> ThreatSeverity {
        let projectileThreats = detectProjectileThreats(tank: tank, projectiles: projectiles, lookAhead: 6)
        let enemyThreats = detectEnemyThreats(tank: tank, allTanks: allTanks, tankIndex: tankIndex, grid: grid)
        
        // Count alive enemies using helper
        let aliveEnemyCount = countAliveEnemies(allTanks: allTanks, tankIndex: tankIndex)
        
        // Critical if we have immediate projectile threat
        if let topThreat = projectileThreats.first, topThreat.severity == .critical {
            return .critical
        }
        
        // High if enemy is aiming at us
        if let topEnemyThreat = enemyThreats.first, topEnemyThreat.severity >= .high {
            return .high
        }
        
        // Medium if outnumbered or moderate threats
        if aliveEnemyCount > 1 || !projectileThreats.isEmpty {
            return .medium
        }
        
        return .low
    }
    
    /// Count the number of alive enemies
    /// - Parameters:
    ///   - allTanks: All tanks in the game
    ///   - tankIndex: Index of the current tank
    /// - Returns: Number of alive enemy tanks
    static func countAliveEnemies(allTanks: [Tank], tankIndex: Int) -> Int {
        return allTanks.enumerated().filter { $0.offset != tankIndex && $0.element.isAlive }.count
    }
    
    /// Check if retreat is advisable
    /// - Parameters:
    ///   - tank: The tank to check for
    ///   - allTanks: All tanks
    ///   - tankIndex: Index of current tank
    ///   - threatLevel: Current threat level
    /// - Returns: true if retreat is advisable
    static func shouldRetreat(
        tank: Tank,
        allTanks: [Tank],
        tankIndex: Int,
        threatLevel: ThreatSeverity
    ) -> Bool {
        // Count alive enemies using helper
        let aliveEnemyCount = countAliveEnemies(allTanks: allTanks, tankIndex: tankIndex)
        
        // Retreat if heavily outnumbered and under threat
        if aliveEnemyCount >= 2 && threatLevel >= .high {
            return true
        }
        
        // Small chance to retreat even in 1v1 if under high threat
        if threatLevel == .critical {
            return Double.random(in: 0...1) < 0.5
        }
        
        return false
    }
}
