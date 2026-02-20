//
//  AIPlayer.swift
//  Tank Game
//
//  AI player behavior with adaptive difficulty.
//

import Foundation

/// AI difficulty level that increases when defeated
enum AIDifficulty: Int, Codable {
    case easy = 0
    case medium = 1
    case hard = 2
    case expert = 3

    /// Move probability (0.0 to 1.0) for this difficulty
    var moveFrequency: Double {
        switch self {
        case .easy: return 0.3
        case .medium: return 0.5
        case .hard: return 0.7
        case .expert: return 0.9
        }
    }

    /// Shoot probability (0.0 to 1.0) for this difficulty
    var shootFrequency: Double {
        switch self {
        case .easy: return 0.2
        case .medium: return 0.4
        case .hard: return 0.6
        case .expert: return 0.8
        }
    }

    /// How many cells ahead the AI can "see" targets
    var targetingRange: Int {
        switch self {
        case .easy: return 3
        case .medium: return 5
        case .hard: return 8
        case .expert: return 12
        }
    }

    /// Next difficulty level when defeated
    func levelUp() -> AIDifficulty {
        guard let next = AIDifficulty(rawValue: rawValue + 1) else {
            return self // Stay at max level
        }
        return next
    }

    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .expert: return "Expert"
        }
    }
}

/// AI player state and behavior
class AIPlayer: Codable {
    let id: String
    var difficulty: AIDifficulty
    var nextActionTime: TimeInterval

    init(id: String, difficulty: AIDifficulty = .easy) {
        self.id = id
        self.difficulty = difficulty
        self.nextActionTime = 0
    }

    /// Increase difficulty when this AI is defeated
    func levelUp() {
        difficulty = difficulty.levelUp()
    }

    /// Decide next action for this AI player
    func decideAction(
        tank: Tank,
        game: Game,
        currentTime: TimeInterval
    ) -> AIAction? {
        guard tank.isAlive else { return nil }
        guard currentTime >= nextActionTime else { return nil }

        // Schedule next decision
        let baseInterval = 0.3
        let jitter = Double.random(in: 0...0.2)
        nextActionTime = currentTime + baseInterval + jitter

        // First check if we should shoot
        if shouldShoot(tank: tank, game: game) {
            return .shoot
        }

        // Then decide movement
        if let direction = decideMovement(tank: tank, game: game) {
            return .move(direction)
        }

        return nil
    }

    /// Determine if AI should shoot
    private func shouldShoot(tank: Tank, game: Game) -> Bool {
        // Random chance based on difficulty
        guard Double.random(in: 0...1) < difficulty.shootFrequency else {
            return false
        }

        // Check if there's a target in line of sight
        return hasTargetInSight(tank: tank, game: game)
    }

    /// Check if there's an enemy tank in line of sight
    private func hasTargetInSight(tank: Tank, game: Game) -> Bool {
        let range = difficulty.targetingRange
        let dir = tank.direction

        for distance in 1...range {
            let checkRow = tank.row + dir.offset.row * distance
            let checkCol = tank.col + dir.offset.col * distance

            // Out of bounds
            guard checkRow >= 0, checkRow < game.gridSize,
                  checkCol >= 0, checkCol < game.gridSize else {
                break
            }

            // Hit a wall
            if game.map.grid[checkRow][checkCol] {
                break
            }

            // Check for enemy tank
            for (peerId, data) in game.players {
                if peerId == id { continue }
                if data.tank.isAlive && data.tank.row == checkRow && data.tank.col == checkCol {
                    return true
                }
            }
        }

        return false
    }

    /// Decide movement direction using simple AI logic
    private func decideMovement(tank: Tank, game: Game) -> Direction? {
        // Random chance to move based on difficulty
        guard Double.random(in: 0...1) < difficulty.moveFrequency else {
            return nil
        }

        // Find nearest enemy
        if let targetDirection = findNearestEnemy(tank: tank, game: game) {
            // Try to move toward enemy
            if canMove(tank: tank, direction: targetDirection, game: game) {
                return targetDirection
            }
        }

        // If can't move toward enemy, try random valid direction
        let directions = Direction.allCases.shuffled()
        for dir in directions {
            if canMove(tank: tank, direction: dir, game: game) {
                return dir
            }
        }

        return nil
    }

    /// Find direction toward nearest enemy
    private func findNearestEnemy(tank: Tank, game: Game) -> Direction? {
        var nearestDistance = Int.max
        var nearestDirection: Direction?

        for (peerId, data) in game.players {
            if peerId == id { continue }
            guard data.tank.isAlive else { continue }

            let rowDiff = data.tank.row - tank.row
            let colDiff = data.tank.col - tank.col
            let distance = abs(rowDiff) + abs(colDiff)

            if distance < nearestDistance {
                nearestDistance = distance

                // Prefer horizontal or vertical movement based on distance
                if abs(rowDiff) > abs(colDiff) {
                    nearestDirection = rowDiff > 0 ? .down : .up
                } else {
                    nearestDirection = colDiff > 0 ? .right : .left
                }
            }
        }

        return nearestDirection
    }

    /// Check if tank can move in direction
    private func canMove(tank: Tank, direction: Direction, game: Game) -> Bool {
        let newRow = tank.row + direction.offset.row
        let newCol = tank.col + direction.offset.col

        guard newRow >= 0, newRow < game.gridSize,
              newCol >= 0, newCol < game.gridSize else {
            return false
        }

        return !game.map.grid[newRow][newCol]
    }
}

/// Actions an AI can take
enum AIAction {
    case move(Direction)
    case shoot
}
