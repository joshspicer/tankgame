//
//  MultiplayerSession.swift
//  tankgame Shared
//
//  Created by AI Assistant on 1/7/26.
//

import Foundation
import MultipeerConnectivity

/// Handles MCSession delegate callbacks for multiplayer connections
class MultiplayerSession: NSObject, MCSessionDelegate {
    
    weak var manager: MultiplayerManager?
    
    init(manager: MultiplayerManager) {
        self.manager = manager
        super.init()
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let manager = self.manager else { return }
            
            switch state {
            case .connected:
                // Mark peer as known for future reconnection
                manager.reconnectionManager.markPeerAsKnown(peerID)
                
                // Cancel any pending reconnection attempts
                manager.reconnectionManager.cancelReconnection(for: peerID)
                
                // Mark invitation as successful
                manager.invitationRetryManager.invitationSucceeded(for: peerID)
                
                // Track connection health
                manager.connectionHealthMonitor.peerConnected(peerID)
                
                // Update connection state
                manager.updateConnectionState()
                
                manager.delegate?.multiplayerManager(manager, didConnectToPeer: peerID)
                
            case .notConnected:
                // Stop tracking health for this peer
                manager.connectionHealthMonitor.peerDisconnected(peerID)
                
                // Attempt reconnection if enabled and appropriate
                if manager.autoReconnectEnabled && manager.reconnectionManager.shouldAttemptReconnection(for: peerID) {
                    manager.reconnectionManager.scheduleReconnection(for: peerID) { [weak manager] in
                        manager?.attemptReconnection(to: peerID)
                    }
                }
                
                // Update connection state
                manager.updateConnectionState()
                
                manager.delegate?.multiplayerManager(manager, didDisconnectFromPeer: peerID)
                
            case .connecting:
                manager.connectionState = .connecting(peerName: peerID.displayName)
                manager.delegate?.multiplayerManager(manager, isConnectingToPeer: peerID)
                
            @unknown default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let manager = self.manager else { return }
        
        // Record response for health monitoring
        manager.connectionHealthMonitor.recordResponse(from: peerID)
        
        do {
            let message = try JSONDecoder().decode(GameMessage.self, from: data)
            DispatchQueue.main.async {
                manager.delegate?.multiplayerManager(manager, didReceiveMessage: message, from: peerID)
            }
        } catch {
            print("Error decoding message: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Not used
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Not used
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Not used
    }
}
