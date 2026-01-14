//
//  GameViewControllerMultiplayerHandler.swift
//  tankgame iOS
//
//  Multiplayer game initialization logic extracted from GameViewController
//

import UIKit

/// Handles multiplayer game initialization for GameViewController
extension GameViewController {

    func initiateMultiplayerGame() {
        let playerCount = multiplayerCoordinator.playerCount

        if playerCount < 2 {
            presentNotEnoughPlayersAlert()
            return
        }

        let playerAssignments = multiplayerCoordinator.assignPlayerIndices()
        startGame(playerCount: playerCount, localPlayerIndex: 0, playerAssignments: playerAssignments)
    }
}
