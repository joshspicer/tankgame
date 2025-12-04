//
//  GameViewControllerUIUpdates.swift
//  tankgame iOS
//
//  UI update logic extracted from GameViewController
//

import UIKit

/// Handles UI updates for GameViewController
extension GameViewController {
    
    func updateUI() {
        lobbyUI.peerTableView.reloadData()
        updatePeerListUI()
        updateConnectedPlayersUI()
    }
    
    func updateConnectedPlayersUI() {
        let playerCount = multiplayerCoordinator.playerCount
        let playerNames = multiplayerCoordinator.getConnectedPlayerNames()
        let namesText = playerNames.enumerated().map { "P\($0.offset + 1): \($0.element)" }.joined(separator: "\n")
        lobbyUI.connectedPlayersLabel.text = "Connected Players (\(playerCount)/4):\n\n\(namesText)"
        
        print("[GameViewController] updateConnectedPlayersUI - playerCount: \(playerCount), isHost: \(multiplayerManager.isHost)")
        print("[GameViewController] Connected peer names: \(playerNames)")
        
        if multiplayerManager.isHost {
            lobbyUI.startGameButton.isEnabled = playerCount >= 2
            lobbyUI.startGameButton.alpha = playerCount >= 2 ? 1.0 : 0.5
            print("[GameViewController] Start Game button enabled: \(playerCount >= 2)")
        }
    }
    
    func updatePeerListUI() {
        if multiplayerCoordinator.discoveredPeers.isEmpty {
            lobbyUI.peerTableView.isHidden = true
            lobbyUI.emptyStateLabel.isHidden = false
        } else {
            lobbyUI.peerTableView.isHidden = false
            lobbyUI.emptyStateLabel.isHidden = true
        }
    }
}
