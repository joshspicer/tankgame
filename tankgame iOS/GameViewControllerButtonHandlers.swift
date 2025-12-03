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
        multiplayerManager.isHost = true
        lobbyUI.hostButton.isHidden = true
        lobbyUI.joinButton.isHidden = true
        lobbyUI.storeButton.isHidden = true
        lobbyUI.instructionsLabel.isHidden = true
        lobbyUI.cancelButton.isHidden = false
        lobbyUI.connectedPlayersView.isHidden = false
        lobbyUI.startGameButton.isHidden = false
        lobbyUI.activityIndicator.startAnimating()
        lobbyUI.statusLabel.text = "Hosting game...\nWaiting for players to join (2-4 players)"
        updateConnectedPlayersUI()
        
        multiplayerManager.startHosting()
    }
    
    func handleJoinTapped() {
        lobbyUI.hostButton.isHidden = true
        lobbyUI.joinButton.isHidden = true
        lobbyUI.storeButton.isHidden = true
        lobbyUI.instructionsLabel.isHidden = true
        lobbyUI.cancelButton.isHidden = false
        lobbyUI.activityIndicator.startAnimating()
        lobbyUI.statusLabel.text = "Searching for nearby games..."
        lobbyUI.peerTableView.isHidden = false
        updatePeerListUI()
        
        multiplayerManager.startBrowsing()
    }
    
    func handleStoreTapped() {
        storeUI.show()
    }
    
    func handleCancelTapped() {
        multiplayerManager.stopHosting()
        multiplayerManager.stopBrowsing()
        multiplayerCoordinator.clearAll()
        lobbyUI.reset()
        lobbyUI.peerTableView.reloadData()
        multiplayerManager.isHost = false
    }
    
    func handleStartGameTapped() {
        let playerCount = multiplayerCoordinator.playerCount
        
        if playerCount < 2 {
            let alert = UIAlertController(
                title: "Not Enough Players",
                message: "You need at least 2 players to start the game.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let playerAssignments = multiplayerCoordinator.assignPlayerIndices()
        startGame(playerCount: playerCount, localPlayerIndex: 0, playerAssignments: playerAssignments)
    }
}
