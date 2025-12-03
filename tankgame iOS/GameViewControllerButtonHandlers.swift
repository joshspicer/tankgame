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
        lobbyUI.hostButton.isHidden = true
        lobbyUI.joinButton.isHidden = true
        lobbyUI.instructionsLabel.isHidden = true
        lobbyUI.cancelButton.isHidden = false
        lobbyUI.connectedPlayersView.isHidden = false
        lobbyUI.startGameButton.isHidden = false
        lobbyUI.activityIndicator.startAnimating()
        
        if connectionMode == .wifi {
            // WiFi hosting
            wifiMultiplayerManager?.isHost = true
            lobbyUI.statusLabel.text = "Hosting WiFi game...\nShare the room code with friends!"
            wifiMultiplayerManager?.startHosting()
            updateWiFiConnectedPlayersUI()
        } else {
            // Bluetooth hosting
            multiplayerManager.isHost = true
            lobbyUI.statusLabel.text = "Hosting game...\nWaiting for players to join (2-4 players)"
            multiplayerManager.startHosting()
            updateConnectedPlayersUI()
        }
    }
    
    func handleJoinTapped() {
        lobbyUI.hostButton.isHidden = true
        lobbyUI.joinButton.isHidden = true
        lobbyUI.instructionsLabel.isHidden = true
        lobbyUI.cancelButton.isHidden = false
        lobbyUI.activityIndicator.startAnimating()
        
        if connectionMode == .wifi {
            // WiFi joining
            lobbyUI.statusLabel.text = "Searching for WiFi games..."
            wifiLobbyUI?.showJoinByCodeUI()
            wifiLobbyUI?.showWiFiHostsList(hasHosts: !(wifiCoordinator?.discoveredHosts.isEmpty ?? true))
            wifiMultiplayerManager?.startBrowsing()
        } else {
            // Bluetooth joining
            lobbyUI.statusLabel.text = "Searching for nearby games..."
            lobbyUI.peerTableView.isHidden = false
            updatePeerListUI()
            multiplayerManager.startBrowsing()
        }
    }
    
    func handleCancelTapped() {
        // Stop Bluetooth
        multiplayerManager.stopHosting()
        multiplayerManager.stopBrowsing()
        multiplayerCoordinator.clearAll()
        multiplayerManager.isHost = false
        
        // Stop WiFi
        wifiMultiplayerManager?.disconnect()
        wifiCoordinator?.clearAll()
        
        // Reset UI
        lobbyUI.reset()
        wifiLobbyUI?.reset()
        lobbyUI.peerTableView.reloadData()
        wifiLobbyUI?.wifiHostsTableView.reloadData()
    }
    
    func handleStartGameTapped() {
        let playerCount: Int
        let playerAssignments: [String: Int]
        
        if connectionMode == .wifi {
            playerCount = wifiCoordinator?.playerCount ?? 1
            
            if playerCount < 2 {
                showNotEnoughPlayersAlert()
                return
            }
            
            let localName = UIDevice.current.name
            playerAssignments = wifiCoordinator?.assignPlayerIndices(localPlayerName: localName) ?? [:]
            startWiFiGame(playerCount: playerCount, localPlayerIndex: 0, playerAssignments: playerAssignments)
        } else {
            playerCount = multiplayerCoordinator.playerCount
            
            if playerCount < 2 {
                showNotEnoughPlayersAlert()
                return
            }
            
            playerAssignments = multiplayerCoordinator.assignPlayerIndices()
            startGame(playerCount: playerCount, localPlayerIndex: 0, playerAssignments: playerAssignments)
        }
    }
    
    func handleModeChanged(_ mode: WiFiLobbyUI.ConnectionMode) {
        connectionMode = mode
        
        // Reset any active connections when mode changes
        handleCancelTapped()
        
        // Update instructions based on mode
        if mode == .wifi {
            lobbyUI.instructionsLabel.text = "Battle with 2-4 players over WiFi!\nMove with the joystick, tap FIRE to shoot."
        } else {
            lobbyUI.instructionsLabel.text = "Battle with 2-4 players on the same network!\nMove with the joystick, tap FIRE to shoot."
        }
    }
    
    func handleJoinByCode(_ code: String) {
        guard RoomCodeGenerator.isValid(code) else {
            let alert = UIAlertController(
                title: "Invalid Room Code",
                message: "Please enter a valid 6-character room code.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Find a host with matching room code
        if let hostInfo = wifiCoordinator?.discoveredHosts.first(where: { $0.roomCode == code }) {
            wifiMultiplayerManager?.joinHost(hostInfo)
        } else {
            let alert = UIAlertController(
                title: "Host Not Found",
                message: "No host found with room code \(code). Make sure the host is hosting and on the same network.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    private func showNotEnoughPlayersAlert() {
        let alert = UIAlertController(
            title: "Not Enough Players",
            message: "You need at least 2 players to start the game.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
