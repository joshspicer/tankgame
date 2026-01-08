//
//  Tank.swift
//  tankgame Shared
//
//  Tank entity with minimal code

import Foundation

struct Tank: GameEntity, Codable {
    var position: Position
    var direction: Direction
    var isAlive: Bool = true
    let playerIndex: Int

    init(position: Position, direction: Direction, playerIndex: Int) {
        self.position = position
        self.direction = direction
        self.playerIndex = playerIndex
    }

    mutating func update(in context: GameContext) {
        // Tank movement handled by player input, not auto-update
    }

    mutating func move(in grid: [[Cell]]) -> Bool {
        let delta = direction.delta
        let newPos = Position(row: position.row + delta.row, col: position.col + delta.col)

        guard newPos.isValid(), grid[newPos.row][newPos.col] == .empty else {
            return false
        }

        position = newPos
        return true
    }

    func createProjectile() -> Projectile {
        let delta = direction.delta
        return Projectile(
            position: Position(row: position.row + delta.row, col: position.col + delta.col),
            direction: direction
        )
    }
}
