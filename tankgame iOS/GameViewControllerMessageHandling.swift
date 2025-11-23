//
//  GameViewControllerMessageHandling.swift
//  tankgame iOS
//
//  Network message handling extracted from GameViewController
//

import Foundation

/// Handles game messages for GameViewController
extension GameViewController {
    
    func handleGameMessage(_ message: GameMessage) {
        guard let state = gameState else { return }
        
        switch message {
        case .playerMove(let playerIndex, let row, let col, let direction):
            multiplayerManager.sendMessage(.playerMove(playerIndex: playerIndex, row: row, col: col, direction: direction))
            
        case .playerShoot(let playerIndex, let projectile):
            multiplayerManager.sendMessage(.playerShoot(playerIndex: playerIndex, projectile: projectile))
            
        case .readyForNextRound(let playerIndex):
            multiplayerCoordinator.markPlayerReady(playerIndex)
            checkAndStartNextRound()
            
        default:
            break
        }
    }
}
