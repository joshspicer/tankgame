//
//  AIController.swift
//  tankgame Shared
//
//  AI logic for computer-controlled tanks
//

import Foundation

enum AIDifficulty {
    case easy
    case medium
    case hard
    
    var reactionTime: TimeInterval {
        switch self {
        case .easy: return 0.5
        case .medium: return 0.3
        case .hard: return 0.15
        }
    }
    
    var shootAccuracy: Double {
        switch self {
        case .easy: return 0.3
        case .medium: return 0.6
        case .hard: return 0.9
        }
    }
}

class AIController {
    private var difficulty: AIDifficulty
    private var lastActionTime: TimeInterval = 0
    private var targetRow: Int?
    private var targetCol: Int?
    
    init(difficulty: AIDifficulty = .medium) {
        self.difficulty = difficulty
    }
    
    /// Update AI behavior for a specific tank
    func update(tankIndex: Int, gameState: GameState, currentTime: TimeInterval) -> AIAction? {
        guard tankIndex < gameState.tanks.count else { return nil }
        let tank = gameState.tanks[tankIndex]
        
        // Don't act if tank is dead
        guard tank.isAlive else { return nil }
        
        // Check if enough time has passed since last action
        guard currentTime - lastActionTime >= difficulty.reactionTime else { return nil }
        
        // Decide on action based on current situation
        let action = decideAction(for: tank, gameState: gameState, currentTime: currentTime)
        
        if action != nil {
            lastActionTime = currentTime
        }
        
        return action
    }
    
    private func decideAction(for tank: Tank, gameState: GameState, currentTime: TimeInterval) -> AIAction? {
        // Priority 1: Avoid incoming projectiles
        if let avoidDirection = getAvoidanceDirection(for: tank, gameState: gameState) {
            return .move(direction: avoidDirection)
        }
        
        // Priority 2: Try to shoot at enemy tanks
        if let shootDirection = getShootDirection(for: tank, gameState: gameState) {
            if shouldShoot() && tank.canShoot(currentTime: currentTime) {
                return .shoot(direction: shootDirection)
            }
        }
        
        // Priority 3: Move toward power-ups
        if let powerUpDirection = getPowerUpDirection(for: tank, gameState: gameState) {
            return .move(direction: powerUpDirection)
        }
        
        // Priority 4: Move toward enemy tanks
        if let huntDirection = getHuntDirection(for: tank, gameState: gameState) {
            return .move(direction: huntDirection)
        }
        
        // Priority 5: Random exploration
        if Double.random(in: 0...1) < 0.3 {
            return .move(direction: Direction.allCases.randomElement()!)
        }
        
        return nil
    }
    
    /// Check if AI should shoot based on accuracy
    private func shouldShoot() -> Bool {
        return Double.random(in: 0...1) < difficulty.shootAccuracy
    }
    
    /// Get direction to avoid incoming projectiles
    private func getAvoidanceDirection(for tank: Tank, gameState: GameState) -> Direction? {
        // Check if any projectile is heading toward the tank
        for projectile in gameState.projectiles {
            if isProjectileHeadingToward(projectile: projectile, tank: tank) {
                // Try to move perpendicular to projectile direction
                let perpendicularDirections = getPerpendicularDirections(to: projectile.direction)
                for direction in perpendicularDirections {
                    if canMove(tank: tank, in: direction, grid: gameState.grid) {
                        return direction
                    }
                }
            }
        }
        return nil
    }
    
    /// Check if projectile is heading toward tank
    private func isProjectileHeadingToward(projectile: Projectile, tank: Tank) -> Bool {
        switch projectile.direction {
        case .up:
            return projectile.col == tank.col && projectile.row > tank.row && projectile.row - tank.row <= 3
        case .down:
            return projectile.col == tank.col && projectile.row < tank.row && tank.row - projectile.row <= 3
        case .left:
            return projectile.row == tank.row && projectile.col > tank.col && projectile.col - tank.col <= 3
        case .right:
            return projectile.row == tank.row && projectile.col < tank.col && tank.col - projectile.col <= 3
        }
    }
    
    /// Get directions perpendicular to given direction
    private func getPerpendicularDirections(to direction: Direction) -> [Direction] {
        switch direction {
        case .up, .down:
            return [.left, .right]
        case .left, .right:
            return [.up, .down]
        }
    }
    
    /// Get direction to shoot at enemy tanks
    private func getShootDirection(for tank: Tank, gameState: GameState) -> Direction? {
        // Find closest enemy tank
        var closestEnemy: Tank?
        var minDistance = Int.max
        
        for otherTank in gameState.tanks {
            if otherTank.isAlive && (otherTank.row != tank.row || otherTank.col != tank.col) {
                let distance = abs(otherTank.row - tank.row) + abs(otherTank.col - tank.col)
                if distance < minDistance {
                    minDistance = distance
                    closestEnemy = otherTank
                }
            }
        }
        
        guard let enemy = closestEnemy else { return nil }
        
        // Check if enemy is in line of sight
        if enemy.row == tank.row {
            // Enemy is in same row
            if enemy.col > tank.col && isPathClear(from: tank, to: enemy, gameState: gameState) {
                return .right
            } else if enemy.col < tank.col && isPathClear(from: tank, to: enemy, gameState: gameState) {
                return .left
            }
        } else if enemy.col == tank.col {
            // Enemy is in same column
            if enemy.row > tank.row && isPathClear(from: tank, to: enemy, gameState: gameState) {
                return .down
            } else if enemy.row < tank.row && isPathClear(from: tank, to: enemy, gameState: gameState) {
                return .up
            }
        }
        
        return nil
    }
    
    /// Check if path between two tanks is clear (no walls)
    private func isPathClear(from: Tank, to: Tank, gameState: GameState) -> Bool {
        if from.row == to.row {
            let minCol = min(from.col, to.col)
            let maxCol = max(from.col, to.col)
            for col in (minCol + 1)..<maxCol {
                if gameState.grid[from.row][col] == .wall {
                    return false
                }
            }
        } else if from.col == to.col {
            let minRow = min(from.row, to.row)
            let maxRow = max(from.row, to.row)
            for row in (minRow + 1)..<maxRow {
                if gameState.grid[row][from.col] == .wall {
                    return false
                }
            }
        }
        return true
    }
    
    /// Get direction to move toward power-ups
    private func getPowerUpDirection(for tank: Tank, gameState: GameState) -> Direction? {
        guard !gameState.powerUps.isEmpty else { return nil }
        
        // Find closest power-up
        var closestPowerUp: PowerUp?
        var minDistance = Int.max
        
        for powerUp in gameState.powerUps where powerUp.isActive {
            let distance = abs(powerUp.row - tank.row) + abs(powerUp.col - tank.col)
            if distance < minDistance {
                minDistance = distance
                closestPowerUp = powerUp
            }
        }
        
        guard let powerUp = closestPowerUp else { return nil }
        
        // Move toward power-up using simple pathfinding
        return getDirectionToward(from: tank, toRow: powerUp.row, toCol: powerUp.col, grid: gameState.grid)
    }
    
    /// Get direction to move toward enemy tanks
    private func getHuntDirection(for tank: Tank, gameState: GameState) -> Direction? {
        // Find closest enemy tank
        var closestEnemy: Tank?
        var minDistance = Int.max
        
        for otherTank in gameState.tanks {
            if otherTank.isAlive && (otherTank.row != tank.row || otherTank.col != tank.col) {
                let distance = abs(otherTank.row - tank.row) + abs(otherTank.col - tank.col)
                if distance < minDistance {
                    minDistance = distance
                    closestEnemy = otherTank
                }
            }
        }
        
        guard let enemy = closestEnemy else { return nil }
        
        return getDirectionToward(from: tank, toRow: enemy.row, toCol: enemy.col, grid: gameState.grid)
    }
    
    /// Get direction to move toward a target position
    private func getDirectionToward(from tank: Tank, toRow: Int, toCol: Int, grid: [[GridCell]]) -> Direction? {
        var possibleDirections: [(Direction, Int)] = []
        
        // Calculate distance for each direction
        for direction in Direction.allCases {
            if canMove(tank: tank, in: direction, grid: grid) {
                let offset = direction.offset
                let newRow = tank.row + offset.row
                let newCol = tank.col + offset.col
                let distance = abs(toRow - newRow) + abs(toCol - newCol)
                possibleDirections.append((direction, distance))
            }
        }
        
        // Sort by distance and return closest
        possibleDirections.sort { $0.1 < $1.1 }
        return possibleDirections.first?.0
    }
    
    /// Check if tank can move in a direction
    private func canMove(tank: Tank, in direction: Direction, grid: [[GridCell]]) -> Bool {
        let offset = direction.offset
        let newRow = tank.row + offset.row
        let newCol = tank.col + offset.col
        
        guard newRow >= 0, newRow < grid.count,
              newCol >= 0, newCol < grid[0].count else {
            return false
        }
        
        return grid[newRow][newCol] == .empty
    }
}

enum AIAction {
    case move(direction: Direction)
    case shoot(direction: Direction)
}
