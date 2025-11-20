//
//  AIAgent.swift
//  tankgame Shared
//
//  AI agent that can play the tank game autonomously
//

import Foundation

/// AI agent that controls a tank autonomously
class AIAgent {
    private let playerIndex: Int
    private var lastActionTime: TimeInterval = 0
    private let actionDelay: TimeInterval = 0.5 // Time between actions in seconds
    private var currentTarget: (row: Int, col: Int)?
    private var lastShootTime: TimeInterval = 0
    private let shootCooldown: TimeInterval = 1.0
    
    init(playerIndex: Int) {
        self.playerIndex = playerIndex
    }
    
    /// Update AI decision-making
    /// - Parameters:
    ///   - gameState: Current game state
    ///   - currentTime: Current time for action throttling
    /// - Returns: Action to take (move or shoot)
    func update(gameState: GameState, currentTime: TimeInterval) -> AIAction? {
        guard playerIndex < gameState.tanks.count else { return nil }
        let tank = gameState.tanks[playerIndex]
        
        // Don't act if tank is dead
        guard tank.isAlive else { return nil }
        
        // Throttle actions
        guard currentTime - lastActionTime >= actionDelay else { return nil }
        
        // Decide on action
        if shouldShoot(tank: tank, gameState: gameState, currentTime: currentTime) {
            lastActionTime = currentTime
            lastShootTime = currentTime
            return .shoot
        }
        
        if let direction = decideMovement(tank: tank, gameState: gameState) {
            lastActionTime = currentTime
            return .move(direction)
        }
        
        return nil
    }
    
    // MARK: - Decision Making
    
    private func shouldShoot(tank: Tank, gameState: GameState, currentTime: TimeInterval) -> Bool {
        // Check cooldown
        guard currentTime - lastShootTime >= shootCooldown else { return false }
        
        // Check if there's an enemy in line of sight
        return hasEnemyInLineOfSight(tank: tank, gameState: gameState)
    }
    
    private func hasEnemyInLineOfSight(tank: Tank, gameState: GameState) -> Bool {
        let offset = tank.direction.offset
        var checkRow = tank.row + offset.row
        var checkCol = tank.col + offset.col
        
        // Scan in the direction the tank is facing
        while checkRow >= 0 && checkRow < gameState.grid.count &&
              checkCol >= 0 && checkCol < gameState.grid[0].count {
            
            // Check if we hit a wall
            if gameState.grid[checkRow][checkCol] == .wall {
                return false
            }
            
            // Check if there's an enemy tank at this position
            for (index, enemyTank) in gameState.tanks.enumerated() {
                if index != playerIndex && enemyTank.isAlive &&
                   enemyTank.row == checkRow && enemyTank.col == checkCol {
                    return true
                }
            }
            
            checkRow += offset.row
            checkCol += offset.col
        }
        
        return false
    }
    
    private func decideMovement(tank: Tank, gameState: GameState) -> Direction? {
        // Find nearest enemy
        guard let nearestEnemy = findNearestEnemy(tank: tank, gameState: gameState) else {
            // No enemies, explore randomly
            return randomValidDirection(tank: tank, gameState: gameState)
        }
        
        // Calculate direction towards enemy
        let rowDiff = nearestEnemy.row - tank.row
        let colDiff = nearestEnemy.col - tank.col
        
        // Prioritize movement based on larger distance
        var preferredDirections: [Direction] = []
        
        if abs(rowDiff) > abs(colDiff) {
            if rowDiff > 0 {
                preferredDirections.append(.down)
            } else if rowDiff < 0 {
                preferredDirections.append(.up)
            }
            if colDiff > 0 {
                preferredDirections.append(.right)
            } else if colDiff < 0 {
                preferredDirections.append(.left)
            }
        } else {
            if colDiff > 0 {
                preferredDirections.append(.right)
            } else if colDiff < 0 {
                preferredDirections.append(.left)
            }
            if rowDiff > 0 {
                preferredDirections.append(.down)
            } else if rowDiff < 0 {
                preferredDirections.append(.up)
            }
        }
        
        // Try preferred directions
        for direction in preferredDirections {
            if canMove(tank: tank, direction: direction, gameState: gameState) {
                return direction
            }
        }
        
        // If preferred directions blocked, try any valid direction
        return randomValidDirection(tank: tank, gameState: gameState)
    }
    
    private func findNearestEnemy(tank: Tank, gameState: GameState) -> Tank? {
        var nearest: Tank?
        var minDistance = Int.max
        
        for (index, enemyTank) in gameState.tanks.enumerated() {
            guard index != playerIndex && enemyTank.isAlive else { continue }
            
            let distance = abs(enemyTank.row - tank.row) + abs(enemyTank.col - tank.col)
            if distance < minDistance {
                minDistance = distance
                nearest = enemyTank
            }
        }
        
        return nearest
    }
    
    private func randomValidDirection(tank: Tank, gameState: GameState) -> Direction? {
        let allDirections: [Direction] = [.up, .down, .left, .right]
        let validDirections = allDirections.filter { canMove(tank: tank, direction: $0, gameState: gameState) }
        return validDirections.randomElement()
    }
    
    private func canMove(tank: Tank, direction: Direction, gameState: GameState) -> Bool {
        let offset = direction.offset
        let newRow = tank.row + offset.row
        let newCol = tank.col + offset.col
        
        // Check bounds
        guard newRow >= 0, newRow < gameState.grid.count,
              newCol >= 0, newCol < gameState.grid[0].count else {
            return false
        }
        
        // Check if cell is empty
        return gameState.grid[newRow][newCol] == .empty
    }
}

/// Actions that an AI agent can take
enum AIAction {
    case move(Direction)
    case shoot
}
