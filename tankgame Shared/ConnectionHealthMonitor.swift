//
//  ConnectionHealthMonitor.swift
//  tankgame Shared
//
//  Monitors connection health through periodic ping/pong messages
//

import Foundation
import MultipeerConnectivity

/// Monitors the health of multiplayer connections
class ConnectionHealthMonitor {
    
    // MARK: - Configuration
    
    let pingInterval: TimeInterval = 5.0
    let pingTimeout: TimeInterval = 15.0
    
    // MARK: - State
    
    /// Tracks connected peers with their last response time
    private var trackedPeers: [String: (peer: MCPeerID, lastResponse: Date)] = [:]
    private var pingTimer: Timer?
    private var isMonitoring = false
    
    // MARK: - Callbacks
    
    var onStaleConnection: ((MCPeerID) -> Void)?
    
    // MARK: - Public Methods
    
    /// Start monitoring connection health
    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        
        pingTimer = Timer.scheduledTimer(withTimeInterval: pingInterval, repeats: true) { [weak self] _ in
            self?.performHealthCheck()
        }
    }
    
    /// Stop monitoring connection health
    func stopMonitoring() {
        isMonitoring = false
        pingTimer?.invalidate()
        pingTimer = nil
    }
    
    /// Record that we received a response from a peer
    func recordResponse(from peerID: MCPeerID) {
        if var tracked = trackedPeers[peerID.displayName] {
            tracked.lastResponse = Date()
            trackedPeers[peerID.displayName] = tracked
        }
    }
    
    /// Start tracking a peer when they connect
    func peerConnected(_ peerID: MCPeerID) {
        trackedPeers[peerID.displayName] = (peer: peerID, lastResponse: Date())
    }
    
    /// Stop tracking a peer when they disconnect
    func peerDisconnected(_ peerID: MCPeerID) {
        trackedPeers.removeValue(forKey: peerID.displayName)
    }
    
    /// Check if a peer's connection is considered healthy
    func isConnectionHealthy(for peerID: MCPeerID) -> Bool {
        guard let tracked = trackedPeers[peerID.displayName] else {
            return false
        }
        return Date().timeIntervalSince(tracked.lastResponse) < pingTimeout
    }
    
    /// Get the time since last response from a peer
    func timeSinceLastResponse(for peerID: MCPeerID) -> TimeInterval? {
        guard let tracked = trackedPeers[peerID.displayName] else {
            return nil
        }
        return Date().timeIntervalSince(tracked.lastResponse)
    }
    
    /// Reset all state
    func reset() {
        stopMonitoring()
        trackedPeers.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func performHealthCheck() {
        let now = Date()
        
        for (_, tracked) in trackedPeers {
            let timeSinceResponse = now.timeIntervalSince(tracked.lastResponse)
            
            if timeSinceResponse > pingTimeout {
                // Connection appears stale - notify callback with actual MCPeerID
                onStaleConnection?(tracked.peer)
            }
        }
    }
}
