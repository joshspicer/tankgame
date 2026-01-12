//
//  GameViewControllerButtonHandlers.swift
//  tankgame iOS
//
//  Button handling logic extracted from GameViewController
//

import UIKit
import MultipeerConnectivity

/// Handles button tap events for GameViewController
extension GameViewController {
    
    func handleHostTapped() {
        isSinglePlayerMode = false
        multiplayerManager.isHost = true
        [lobbyUI.hostButton, lobbyUI.joinButton, lobbyUI.singlePlayerButton, lobbyUI.instructionsLabel].forEach { $0?.isHidden = true }
        [lobbyUI.cancelButton, lobbyUI.connectedPlayersView, lobbyUI.startGameButton].forEach { $0?.isHidden = false }
        lobbyUI.activityIndicator.startAnimating()
        lobbyUI.statusLabel.text = "Hosting game...\nWaiting for players to join (2-4 players)"
        updateConnectedPlayersUI()
        multiplayerManager.startHosting()
    }
    
    func handleJoinTapped() {
        isSinglePlayerMode = false
        [lobbyUI.hostButton, lobbyUI.joinButton, lobbyUI.singlePlayerButton, lobbyUI.instructionsLabel].forEach { $0?.isHidden = true }
        [lobbyUI.cancelButton, lobbyUI.peerTableView].forEach { $0?.isHidden = false }
        lobbyUI.activityIndicator.startAnimating()
        lobbyUI.statusLabel.text = "Searching for nearby games..."
        updatePeerListUI()
        multiplayerManager.startBrowsing()
    }
    
    func handleSinglePlayerTapped() {
        isSinglePlayerMode = true
        lobbyUI.showSinglePlayerMode()
    }
    
    func handleCancelTapped() {
        isSinglePlayerMode = false
        multiplayerManager.stopHosting()
        multiplayerManager.stopBrowsing()
        multiplayerCoordinator.clearAll()
        lobbyUI.reset()
        lobbyUI.peerTableView.reloadData()
        multiplayerManager.isHost = false
    }
    
    func handleStartGameTapped() {
        if isSinglePlayerMode {
            let totalPlayers = 1 + lobbyUI.botCount
            let botIndices = Array(1...lobbyUI.botCount)
            startGame(playerCount: totalPlayers, localPlayerIndex: 0, botIndices: botIndices)
        } else {
            let playerCount = multiplayerCoordinator.playerCount
            guard playerCount >= 2 else {
                let alert = UIAlertController(title: "Not Enough Players", message: "You need at least 2 players to start the game.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }
            startGame(playerCount: playerCount, localPlayerIndex: 0, playerAssignments: multiplayerCoordinator.assignPlayerIndices())
        }
    }
}
