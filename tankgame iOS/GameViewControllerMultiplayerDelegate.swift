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
        updateSearchStatusText()
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didLosePeer peerID: MCPeerID) {
        multiplayerCoordinator.removeDiscoveredPeer(peerID)
        updateSearchStatusText()
    }
    
    private func updateSearchStatusText() {
        let count = multiplayerCoordinator.discoveredPeers.count
        lobbyUI.statusLabel.text = count == 0 ? "Searching for nearby games..." : "Found \(count) game\(count == 1 ? "" : "s"). Tap to join."
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didConnectToPeer peerID: MCPeerID) {
        multiplayerCoordinator.addConnectedPeer(peerID)
        lobbyUI.activityIndicator.stopAnimating()
        
        if multiplayerManager.isHost {
            lobbyUI.statusLabel.text = "Player joined: \(peerID.displayName)"
        } else {
            lobbyUI.statusLabel.text = "Connected! Waiting for host to start game..."
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didDisconnectFromPeer peerID: MCPeerID) {
        multiplayerCoordinator.removeConnectedPeer(peerID)
        
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
        guard !permissionManager.isRequesting else { return }
        lobbyUI.activityIndicator.stopAnimating()
        
        let alert = UIAlertController(title: "Unable to Start Multiplayer", message: "Could not start multiplayer session. This is likely because:\n\n• Local Network permission was denied\n• Bluetooth permission was denied\n\nTo fix:\n1. Open Settings app\n2. Go to Privacy & Security → Local Network\n3. Find Tank Game and turn it ON\n4. Also check Bluetooth permissions\n5. Return here and try again\n\nTechnical error: \(error.localizedDescription)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in self?.lobbyUI.reset() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in self?.lobbyUI.reset() })
        present(alert, animated: true)
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didChangeConnectionState state: ConnectionState) {
        lobbyUI.statusLabel.text = state.description
        
        switch state {
        case .disconnected:
            lobbyUI.activityIndicator.stopAnimating()
            if gameState != nil {
                DispatchQueue.main.async { [weak self] in
                    self?.returnToLobbyWithDisconnectAlert()
                }
            }
        case .browsing, .advertising, .connecting, .reconnecting:
            lobbyUI.activityIndicator.startAnimating()
        case .connected:
            lobbyUI.activityIndicator.stopAnimating()
            updateConnectedPlayersUI()
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
