//
//  WiFiMultiplayerCoordinator.swift
//  tankgame iOS
//
//  Coordinates WiFi multiplayer game session and player management
//

import Foundation

/// Coordinates WiFi multiplayer game session and player management
class WiFiMultiplayerCoordinator {
    private let wifiManager: WiFiMultiplayerManager
    
    // State
    private(set) var connectedPeers: [String] = []
    private(set) var discoveredHosts: [WiFiMultiplayerManager.HostInfo] = []
    private(set) var peerToPlayerIndex: [String: Int] = [:]
    private(set) var readyPlayers: Set<Int> = []
    
    // Callbacks
    var onPeersUpdated: (() -> Void)?
    var onReadyForNextRound: (() -> Void)?
    
    init(wifiManager: WiFiMultiplayerManager) {
        self.wifiManager = wifiManager
    }
    
    // MARK: - Host Discovery
    
    func addDiscoveredHost(_ hostInfo: WiFiMultiplayerManager.HostInfo) {
        if !discoveredHosts.contains(hostInfo) {
            discoveredHosts.append(hostInfo)
            onPeersUpdated?()
        }
    }
    
    func removeDiscoveredHost(_ hostInfo: WiFiMultiplayerManager.HostInfo) {
        discoveredHosts.removeAll { $0 == hostInfo }
        onPeersUpdated?()
    }
    
    // MARK: - Peer Management
    
    func addConnectedPeer(_ peerName: String) {
        if !connectedPeers.contains(peerName) {
            connectedPeers.append(peerName)
            onPeersUpdated?()
        }
    }
    
    func removeConnectedPeer(_ peerName: String) {
        connectedPeers.removeAll { $0 == peerName }
        peerToPlayerIndex.removeValue(forKey: peerName)
        onPeersUpdated?()
    }
    
    func clearAll() {
        discoveredHosts.removeAll()
        connectedPeers.removeAll()
        peerToPlayerIndex.removeAll()
        readyPlayers.removeAll()
    }
    
    // MARK: - Game Coordination
    
    /// Assign player indices for game start
    /// - Returns: Dictionary mapping peer names to player indices
    func assignPlayerIndices(localPlayerName: String) -> [String: Int] {
        peerToPlayerIndex.removeAll()
        var playerAssignments: [String: Int] = [:]
        
        // Host is always player 0
        playerAssignments[localPlayerName] = 0
        
        // Assign indices to connected peers
        for (index, peerName) in connectedPeers.enumerated() {
            let playerIndex = index + 1
            peerToPlayerIndex[peerName] = playerIndex
            playerAssignments[peerName] = playerIndex
        }
        
        return playerAssignments
    }
    
    /// Get connected player names
    func getConnectedPlayerNames(localPlayerName: String) -> [String] {
        return [localPlayerName] + connectedPeers
    }
    
    /// Get player count (including local player)
    var playerCount: Int {
        return connectedPeers.count + 1
    }
    
    // MARK: - Round Management
    
    func markPlayerReady(_ playerIndex: Int) {
        readyPlayers.insert(playerIndex)
    }
    
    func isAllPlayersReady(totalPlayers: Int) -> Bool {
        return readyPlayers.count == totalPlayers
    }
    
    func resetReadyPlayers() {
        readyPlayers.removeAll()
    }
}
