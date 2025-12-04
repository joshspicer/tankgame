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
        // Use displayName for comparison to avoid issues with MCPeerID object identity
        if !discoveredPeers.contains(where: { $0.displayName == peerID.displayName }) {
            print("[MultiplayerCoordinator] Adding discovered peer: \(peerID.displayName)")
            discoveredPeers.append(peerID)
            onPeersUpdated?()
        } else {
            print("[MultiplayerCoordinator] Discovered peer already exists: \(peerID.displayName)")
        }
    }
    
    func removeDiscoveredPeer(_ peerID: MCPeerID) {
        print("[MultiplayerCoordinator] Removing discovered peer: \(peerID.displayName)")
        discoveredPeers.removeAll { $0.displayName == peerID.displayName }
        onPeersUpdated?()
    }
    
    func addConnectedPeer(_ peerID: MCPeerID) {
        // Use displayName for comparison to avoid issues with MCPeerID object identity
        if !connectedPeers.contains(where: { $0.displayName == peerID.displayName }) {
            print("[MultiplayerCoordinator] Adding connected peer: \(peerID.displayName)")
            connectedPeers.append(peerID)
            onPeersUpdated?()
        } else {
            print("[MultiplayerCoordinator] Connected peer already exists: \(peerID.displayName)")
        }
    }
    
    func removeConnectedPeer(_ peerID: MCPeerID) {
        print("[MultiplayerCoordinator] Removing connected peer: \(peerID.displayName)")
        connectedPeers.removeAll { $0.displayName == peerID.displayName }
        
        // Remove from peerToPlayerIndex using displayName comparison
        // since MCPeerID object identity may not match
        if let keyToRemove = peerToPlayerIndex.keys.first(where: { $0.displayName == peerID.displayName }) {
            peerToPlayerIndex.removeValue(forKey: keyToRemove)
        }
        
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
        let hostName = multiplayerManager.session.myPeerID.displayName
        playerAssignments[hostName] = 0
        print("[MultiplayerCoordinator] assignPlayerIndices: Host '\(hostName)' = player 0")
        
        // Assign indices to connected peers
        for (index, peer) in connectedPeers.enumerated() {
            let playerIndex = index + 1
            peerToPlayerIndex[peer] = playerIndex
            playerAssignments[peer.displayName] = playerIndex
            print("[MultiplayerCoordinator] assignPlayerIndices: '\(peer.displayName)' = player \(playerIndex)")
        }
        
        print("[MultiplayerCoordinator] Final player assignments: \(playerAssignments)")
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
