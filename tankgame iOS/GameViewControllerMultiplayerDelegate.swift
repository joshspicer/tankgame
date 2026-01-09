//
//  GameViewControllerMultiplayerDelegate.swift
//  tankgame iOS
//
//  MultiplayerManagerDelegate implementation extracted from GameViewController
//

import UIKit
import MultipeerConnectivity

/// Handles multiplayer delegate callbacks for GameViewController
extension GameViewController: MultiplayerManagerDelegate {
    func multiplayerManager(_ manager: MultiplayerManager, didFindPeer peerID: MCPeerID) {
        multiplayerCoordinator.addDiscoveredPeer(peerID)
        lobbyUI.statusLabel.text = "Found \(multiplayerCoordinator.discoveredPeers.count) game\(multiplayerCoordinator.discoveredPeers.count == 1 ? "" : "s"). Tap to join."
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didLosePeer peerID: MCPeerID) {
        multiplayerCoordinator.removeDiscoveredPeer(peerID)
        if multiplayerCoordinator.discoveredPeers.isEmpty {
            lobbyUI.statusLabel.text = "Searching for nearby games..."
        } else {
            lobbyUI.statusLabel.text = "Found \(multiplayerCoordinator.discoveredPeers.count) game\(multiplayerCoordinator.discoveredPeers.count == 1 ? "" : "s"). Tap to join."
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didConnectToPeer peerID: MCPeerID) {
        multiplayerCoordinator.addConnectedPeer(peerID)
        lobbyUI.activityIndicator.stopAnimating()
        
        if multiplayerManager.isHost {
            lobbyUI.statusLabel.text = "Player joined: \(peerID.displayName)"
        } else {
            lobbyUI.statusLabel.text = "Connected! Waiting for host to start game..."
        }
        
        if #available(iOS 16.0, *) {
            nearbyConnectivityManager?.handlePeerConnected(peerID)
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didDisconnectFromPeer peerID: MCPeerID) {
        multiplayerCoordinator.removeConnectedPeer(peerID)
        
        if #available(iOS 16.0, *) {
            nearbyConnectivityManager?.handlePeerDisconnected(peerID)
        }
        
        // During game - show reconnection status if auto-reconnect is active
        // The actual return-to-lobby is handled by didChangeConnectionState when state becomes .disconnected
        if gameState != nil && multiplayerManager.connectionState.isReconnecting {
            lobbyUI.statusLabel.text = "Reconnecting to \(peerID.displayName)..."
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, isConnectingToPeer peerID: MCPeerID) {
        lobbyUI.statusLabel.text = "Connecting to \(peerID.displayName)..."
        lobbyUI.activityIndicator.startAnimating()
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didReceiveMessage message: GameMessage, from peerID: MCPeerID) {
        handleReceivedMessage(message, from: peerID)
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didEncounterError error: Error) {
        if permissionManager.isRequesting {
            return
        }
        
        lobbyUI.activityIndicator.stopAnimating()
        
        let alert = UIAlertController(
            title: "Unable to Start Multiplayer",
            message: "Could not start multiplayer session. This is likely because:\n\n• Local Network permission was denied\n• Bluetooth permission was denied\n\nTo fix:\n1. Open Settings app\n2. Go to Privacy & Security → Local Network\n3. Find Tank Game and turn it ON\n4. Also check Bluetooth permissions\n5. Return here and try again\n\nTechnical error: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
            self?.lobbyUI.reset()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.lobbyUI.reset()
        })
        
        present(alert, animated: true)
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didChangeConnectionState state: ConnectionState) {
        // Update UI based on connection state
        lobbyUI.statusLabel.text = state.description
        
        switch state {
        case .disconnected:
            lobbyUI.activityIndicator.stopAnimating()
            
            // If game was in progress and we're now disconnected (e.g., reconnection failed),
            // return to lobby with an alert
            if gameState != nil {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.returnToLobbyWithDisconnectAlert()
                }
            }
            
        case .browsing, .advertising:
            lobbyUI.activityIndicator.startAnimating()
        case .connecting:
            lobbyUI.activityIndicator.startAnimating()
        case .connected:
            lobbyUI.activityIndicator.stopAnimating()
            updateConnectedPlayersUI()
        case .reconnecting:
            lobbyUI.activityIndicator.startAnimating()
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, isAttemptingReconnection attempt: Int, maxAttempts: Int, toPeer peerID: MCPeerID) {
        lobbyUI.statusLabel.text = "Reconnecting to \(peerID.displayName) (attempt \(attempt)/\(maxAttempts))..."
        lobbyUI.activityIndicator.startAnimating()
    }
    
    // MARK: - Helper Methods
    
    private func returnToLobbyWithDisconnectAlert() {
        view.subviews.forEach { $0.removeFromSuperview() }
        viewDidLoad()
        
        let alert = UIAlertController(
            title: "Connection Lost",
            message: "Unable to reconnect. Returning to lobby.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
