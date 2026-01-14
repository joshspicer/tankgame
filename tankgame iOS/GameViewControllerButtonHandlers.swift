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
        lobbyUI.hostButton.isHidden = true
        lobbyUI.joinButton.isHidden = true
        lobbyUI.singlePlayerButton.isHidden = true
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
        isSinglePlayerMode = false
        lobbyUI.hostButton.isHidden = true
        lobbyUI.joinButton.isHidden = true
        lobbyUI.singlePlayerButton.isHidden = true
        lobbyUI.instructionsLabel.isHidden = true
        lobbyUI.cancelButton.isHidden = false
        lobbyUI.activityIndicator.startAnimating()
        lobbyUI.statusLabel.text = "Searching for nearby games..."
        lobbyUI.peerTableView.isHidden = false
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
            initiateSinglePlayerGame()
        } else {
            initiateMultiplayerGame()
        }
    }
}
