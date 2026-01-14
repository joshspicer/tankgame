//
//  GameViewControllerSinglePlayerHandler.swift
//  tankgame iOS
//
//  Single player game initialization logic extracted from GameViewController
//

import UIKit

/// Handles single player game initialization for GameViewController
extension GameViewController {

    func initiateSinglePlayerGame() {
        let botCount = lobbyUI.botCount
        let totalPlayers = 1 + botCount // Player + bots

        // Bot indices start from 1 (player is 0)
        var botIndices: [Int] = []
        for i in 1...botCount {
            botIndices.append(i)
        }

        startGameWithBots(playerCount: totalPlayers, localPlayerIndex: 0, botIndices: botIndices)
    }
}
