//
//  MultiplayerDiscovery.swift
//  tankgame Shared
//
//  Created by AI Assistant on 1/7/26.
//

import Foundation
import MultipeerConnectivity

/// Handles peer advertising (host) and browsing (client) for multiplayer discovery
class MultiplayerDiscovery: NSObject {
    
    weak var manager: MultiplayerManager?
    
    init(manager: MultiplayerManager) {
        self.manager = manager
        super.init()
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MultiplayerDiscovery: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        guard let manager = self.manager else {
            invitationHandler(false, nil)
            return
        }
        
        // Accept invitations if we have room (max 4 players total)
        if manager.session.connectedPeers.count < manager.maxPlayers - 1 {
            invitationHandler(true, manager.session)
        } else {
            invitationHandler(false, nil)
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        guard let manager = self.manager else { return }
        
        print("Error starting advertising: \(error.localizedDescription)")
        manager.connectionState = .disconnected
        DispatchQueue.main.async {
            manager.delegate?.multiplayerManager(manager, didEncounterError: error)
        }
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultiplayerDiscovery: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard let manager = self.manager else { return }
        
        // Track discovered peers for reconnection
        if !manager.discoveredPeers.contains(where: { $0.displayName == peerID.displayName }) {
            manager.discoveredPeers.append(peerID)
        }
        
        // If we're trying to reconnect to this peer, invite them
        if manager.reconnectionManager.isReconnecting(to: peerID) {
            manager.invitePeer(peerID)
        }
        
        DispatchQueue.main.async {
            manager.delegate?.multiplayerManager(manager, didFindPeer: peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        guard let manager = self.manager else { return }
        
        manager.discoveredPeers.removeAll { $0.displayName == peerID.displayName }
        
        DispatchQueue.main.async {
            manager.delegate?.multiplayerManager(manager, didLosePeer: peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        guard let manager = self.manager else { return }
        
        print("Error starting browsing: \(error.localizedDescription)")
        manager.connectionState = .disconnected
        DispatchQueue.main.async {
            manager.delegate?.multiplayerManager(manager, didEncounterError: error)
        }
    }
}
