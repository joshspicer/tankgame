//
//  GameViewControllerWiFiDelegate.swift
//  tankgame iOS
//
//  WiFiMultiplayerManagerDelegate implementation for GameViewController
//

import UIKit

/// Handles WiFi multiplayer delegate callbacks for GameViewController
extension GameViewController: WiFiMultiplayerManagerDelegate {
    
    func wifiManager(_ manager: WiFiMultiplayerManager, didUpdateConnectionState state: WiFiMultiplayerManager.ConnectionState) {
        switch state {
        case .disconnected:
            lobbyUI.activityIndicator.stopAnimating()
        case .hosting(let roomCode):
            wifiLobbyUI?.showRoomCode(roomCode)
            lobbyUI.statusLabel.text = "Hosting WiFi game...\nShare the room code with friends!"
        case .browsing:
            lobbyUI.statusLabel.text = "Searching for WiFi games..."
        case .connecting:
            lobbyUI.statusLabel.text = "Connecting..."
        case .connected:
            lobbyUI.activityIndicator.stopAnimating()
        }
    }
    
    func wifiManager(_ manager: WiFiMultiplayerManager, didFindHost hostInfo: WiFiMultiplayerManager.HostInfo) {
        wifiCoordinator?.addDiscoveredHost(hostInfo)
        wifiLobbyUI?.showWiFiHostsList(hasHosts: true)
        wifiLobbyUI?.wifiHostsTableView.reloadData()
        lobbyUI.statusLabel.text = "Found \(wifiCoordinator?.discoveredHosts.count ?? 0) WiFi game\((wifiCoordinator?.discoveredHosts.count ?? 0) == 1 ? "" : "s"). Tap to join."
    }
    
    func wifiManager(_ manager: WiFiMultiplayerManager, didLoseHost hostInfo: WiFiMultiplayerManager.HostInfo) {
        wifiCoordinator?.removeDiscoveredHost(hostInfo)
        let hasHosts = !(wifiCoordinator?.discoveredHosts.isEmpty ?? true)
        wifiLobbyUI?.showWiFiHostsList(hasHosts: hasHosts)
        wifiLobbyUI?.wifiHostsTableView.reloadData()
        
        if wifiCoordinator?.discoveredHosts.isEmpty ?? true {
            lobbyUI.statusLabel.text = "Searching for WiFi games..."
        } else {
            lobbyUI.statusLabel.text = "Found \(wifiCoordinator?.discoveredHosts.count ?? 0) WiFi game\((wifiCoordinator?.discoveredHosts.count ?? 0) == 1 ? "" : "s"). Tap to join."
        }
    }
    
    func wifiManager(_ manager: WiFiMultiplayerManager, didConnectToPeer peerName: String) {
        wifiCoordinator?.addConnectedPeer(peerName)
        lobbyUI.activityIndicator.stopAnimating()
        
        if wifiMultiplayerManager?.isHost == true {
            lobbyUI.statusLabel.text = "Player joined: \(peerName)"
            updateWiFiConnectedPlayersUI()
        } else {
            lobbyUI.statusLabel.text = "Connected to \(peerName)! Waiting for host to start..."
        }
    }
    
    func wifiManager(_ manager: WiFiMultiplayerManager, didDisconnectFromPeer peerName: String) {
        wifiCoordinator?.removeConnectedPeer(peerName)
        
        if gameState != nil {
            // During game - return to lobby
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view.subviews.forEach { $0.removeFromSuperview() }
                self.viewDidLoad()
                let alert = UIAlertController(
                    title: "Disconnected",
                    message: "Lost connection to \(peerName)",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    func wifiManager(_ manager: WiFiMultiplayerManager, didReceiveMessage message: GameMessage, from peerName: String) {
        handleReceivedWiFiMessage(message, from: peerName)
    }
    
    func wifiManager(_ manager: WiFiMultiplayerManager, didEncounterError error: Error) {
        lobbyUI.activityIndicator.stopAnimating()
        
        let alert = UIAlertController(
            title: "WiFi Connection Error",
            message: "Could not establish WiFi connection.\n\nError: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
            self?.handleCancelTapped()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.handleCancelTapped()
        })
        
        present(alert, animated: true)
    }
}
