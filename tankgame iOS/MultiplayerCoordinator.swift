//
//  MultiplayerCoordinator.swift
//  tankgame iOS
//
//  Created by jospicer on 10/28/25.
//

import Foundation
import MultipeerConnectivity

/// Coordinates multiplayer game session and player management
///
/// This class manages the lifecycle of a multiplayer session including:
/// - Tracking discovered and connected peers
/// - Assigning player indices for gameplay
/// - Coordinating round transitions
/// - Managing player ready states
///
/// Session Flow:
/// 1. Host starts advertising, clients start browsing
/// 2. Clients discover host and connect
/// 3. Host assigns player indices when starting game
/// 4. During gameplay, tracks which players are ready for next round
/// 5. When all players ready, coordinator signals to start next round
class MultiplayerCoordinator {
    private let multiplayerManager: MultiplayerManager
    
    // State
    /// Peers that have successfully connected to the session
    private(set) var connectedPeers: [MCPeerID] = []
    
    /// Peers that have been discovered but not yet connected
    private(set) var discoveredPeers: [MCPeerID] = []
    
    /// Maps each connected peer to their assigned player index (0-3)
    private(set) var peerToPlayerIndex: [MCPeerID: Int] = [:]
    
    /// Set of player indices that are ready for the next round
    private(set) var readyPlayers: Set<Int> = []
    
    // Callbacks
    /// Called whenever peer lists change (discovery, connection, or disconnection)
    var onPeersUpdated: (() -> Void)?
    
    /// Called when all players are ready to start the next round
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
