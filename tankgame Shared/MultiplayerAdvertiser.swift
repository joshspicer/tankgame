//
//  MultiplayerAdvertiser.swift
//  tankgame Shared
//
//  MCNearbyServiceAdvertiserDelegate implementation extracted from MultiplayerManager
//

import Foundation
import MultipeerConnectivity

/// Handles MCNearbyServiceAdvertiser delegate callbacks for MultiplayerManager
extension MultiplayerManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Accept invitations if we have room (max 4 players total)
        if session.connectedPeers.count < maxPlayers - 1 {
            invitationHandler(true, session)
        } else {
            invitationHandler(false, nil)
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Error starting advertising: \(error.localizedDescription)")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.multiplayerManager(self, didEncounterError: error)
        }
    }
}
