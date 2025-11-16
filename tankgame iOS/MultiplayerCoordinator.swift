//
//  MultiplayerCoordinator.swift
//  tankgame iOS
//
//  Created by jospicer on 10/28/25.
//

import Foundation
import MultipeerConnectivity

/// Coordinates multiplayer game session and player management
class MultiplayerCoordinator {
    private let multiplayerManager: MultiplayerManager
    
    // State
    private(set) var connectedPeers: [MCPeerID] = []
    private(set) var discoveredPeers: [MCPeerID] = []
    private(set) var peerToPlayerIndex: [MCPeerID: Int] = [:]
    private(set) var readyPlayers: Set<Int> = []
    
    // Callbacks
    var onPeersUpdated: (() -> Void)?
    var onReadyForNextRound: (() -> Void)?
    
    init(multiplayerManager: MultiplayerManager) {
        self.multiplayerManager = multiplayerManager
    }
    
    // MARK: - Peer Management
    
    func addDiscoveredPeer(_ peerID: MCPeerID) {
        if !discoveredPeers.contains(peerID) {
            discoveredPeers.append(peerID)
            onPeersUpdated?()
        }
    }
    
    func removeDiscoveredPeer(_ peerID: MCPeerID) {
        discoveredPeers.removeAll { $0 == peerID }
        onPeersUpdated?()
    }
    
    func addConnectedPeer(_ peerID: MCPeerID) {
        if !connectedPeers.contains(peerID) {
            connectedPeers.append(peerID)
            onPeersUpdated?()
        }
    }
    
    func removeConnectedPeer(_ peerID: MCPeerID) {
        connectedPeers.removeAll { $0 == peerID }
        peerToPlayerIndex.removeValue(forKey: peerID)
        onPeersUpdated?()
    }
    
    func clearAll() {
        discoveredPeers.removeAll()
        connectedPeers.removeAll()
        peerToPlayerIndex.removeAll()
        readyPlayers.removeAll()
    }
    
    // MARK: - Game Coordination
    
    /// Assign player indices for game start
    /// - Returns: Dictionary mapping peer names to player indices
    func assignPlayerIndices() -> [String: Int] {
        peerToPlayerIndex.removeAll()
        var playerAssignments: [String: Int] = [:]
        
        // Host is always player 0
        playerAssignments[multiplayerManager.session.myPeerID.displayName] = 0
        
        // Assign indices to connected peers
        for (index, peer) in connectedPeers.enumerated() {
            let playerIndex = index + 1
            peerToPlayerIndex[peer] = playerIndex
            playerAssignments[peer.displayName] = playerIndex
        }
        
        return playerAssignments
    }
    
    /// Get connected player names
    func getConnectedPlayerNames() -> [String] {
        return [multiplayerManager.session.myPeerID.displayName] + connectedPeers.map { $0.displayName }
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
