//
//  MultiplayerCoordinator.swift
//  tankgame iOS
//
//  Created by jospicer on 10/28/25.
//

import Foundation
import MultipeerConnectivity

/// Coordinates multiplayer game session and player management
/// Handles player tracking, index assignment, and ready states
final class MultiplayerCoordinator {
    
    // MARK: - Properties
    
    /// Reference to the low-level multiplayer manager
    private let multiplayerManager: MultiplayerManager
    
    /// List of peers currently connected to the session
    private(set) var connectedPeers: [MCPeerID] = []
    
    /// List of peers discovered but not yet connected
    private(set) var discoveredPeers: [MCPeerID] = []
    
    /// Mapping of peers to their assigned player indices
    private(set) var peerToPlayerIndex: [MCPeerID: Int] = [:]
    
    /// Set of player indices that are ready for the next round
    private(set) var readyPlayers: Set<Int> = []
    
    // MARK: - Callbacks
    
    /// Called when peer lists are updated
    var onPeersUpdated: (() -> Void)?
    
    /// Called when all players are ready for the next round
    var onReadyForNextRound: (() -> Void)?
    
    // MARK: - Initialization
    
    /// Creates a new multiplayer coordinator
    /// - Parameter multiplayerManager: The multiplayer manager to coordinate
    init(multiplayerManager: MultiplayerManager) {
        self.multiplayerManager = multiplayerManager
    }
    
    // MARK: - Peer Management
    
    /// Adds a newly discovered peer to the list
    /// - Parameter peerID: The discovered peer
    func addDiscoveredPeer(_ peerID: MCPeerID) {
        if !discoveredPeers.contains(peerID) {
            discoveredPeers.append(peerID)
            onPeersUpdated?()
        }
    }
    
    /// Removes a peer that is no longer discoverable
    /// - Parameter peerID: The peer to remove
    func removeDiscoveredPeer(_ peerID: MCPeerID) {
        discoveredPeers.removeAll { $0 == peerID }
        onPeersUpdated?()
    }
    
    /// Adds a peer that successfully connected
    /// - Parameter peerID: The connected peer
    func addConnectedPeer(_ peerID: MCPeerID) {
        if !connectedPeers.contains(peerID) {
            connectedPeers.append(peerID)
            onPeersUpdated?()
        }
    }
    
    /// Removes a peer that disconnected
    /// - Parameter peerID: The disconnected peer
    func removeConnectedPeer(_ peerID: MCPeerID) {
        connectedPeers.removeAll { $0 == peerID }
        peerToPlayerIndex.removeValue(forKey: peerID)
        onPeersUpdated?()
    }
    
    /// Clears all peer and player state
    func clearAll() {
        discoveredPeers.removeAll()
        connectedPeers.removeAll()
        peerToPlayerIndex.removeAll()
        readyPlayers.removeAll()
    }
    
    // MARK: - Game Coordination
    
    /// Assigns player indices for game start
    /// The host is always player 0, connected peers get indices 1-3
    /// - Returns: Dictionary mapping peer display names to player indices
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
    
    /// Gets the display names of all connected players
    /// - Returns: Array of player names (host first, then connected peers)
    func getConnectedPlayerNames() -> [String] {
        return [multiplayerManager.session.myPeerID.displayName] + connectedPeers.map { $0.displayName }
    }
    
    /// Gets the total player count including local player
    var playerCount: Int {
        return connectedPeers.count + 1
    }
    
    // MARK: - Round Management
    
    /// Marks a player as ready for the next round
    /// - Parameter playerIndex: Index of the ready player
    func markPlayerReady(_ playerIndex: Int) {
        readyPlayers.insert(playerIndex)
    }
    
    /// Checks if all players are ready for the next round
    /// - Parameter totalPlayers: Expected number of players
    /// - Returns: true if all players have marked themselves ready
    func isAllPlayersReady(totalPlayers: Int) -> Bool {
        return readyPlayers.count == totalPlayers
    }
    
    /// Resets the ready state for a new round
    func resetReadyPlayers() {
        readyPlayers.removeAll()
    }
}
