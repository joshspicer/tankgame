//
//  GameEvent.swift
//  tankgame Shared
//
//  Events that occur during gameplay
//

import Foundation

/// Events that can occur during the game
enum GameEvent {
    case tankMoved(playerIndex: Int, from: Position, to: Position)
    case tankRotated(playerIndex: Int, direction: Direction)
    case projectileFired(playerIndex: Int, projectile: ProjectileEntity)
    case projectileMoved(projectileId: String, to: Position)
    case projectileHitWall(projectileId: String, position: Position)
    case projectileHitTank(projectileId: String, tankPlayerIndex: Int)
    case tankDestroyed(playerIndex: Int)
    case wallDestroyed(position: Position)
    case roundStarted(roundNumber: Int)
    case roundEnded(winnerIndex: Int?)
    case gameEnded(finalScores: [Int])
}
