//
//  Projectile.swift
//  tankgame Shared
//
//  Projectile entity

import Foundation

struct Projectile: GameEntity, Codable {
    var position: Position
    var direction: Direction
    var isAlive: Bool = true

    mutating func update(in context: GameContext) {
        // Move projectile
        let delta = direction.delta
        position = Position(row: position.row + delta.row, col: position.col + delta.col)

        // Check collision
        if !position.isValid() || context.grid[position.row][position.col] == .wall {
            isAlive = false
        }
    }

    func hits(_ tank: Tank) -> Bool {
        return isAlive && tank.isAlive && position == tank.position
    }
}
