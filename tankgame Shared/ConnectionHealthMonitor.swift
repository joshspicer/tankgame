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
    
    private var lastResponseTime: [String: Date] = [:]  // Key: peerID.displayName
    private var pingTimer: Timer?
    private var isMonitoring = false
    
    // MARK: - Callbacks
    
    var onSendPing: (([MCPeerID]) -> Void)?  // peers to ping
    var onStaleConnection: ((MCPeerID) -> Void)?  // peer with stale connection
    var onConnectionHealthy: ((MCPeerID) -> Void)?  // peer with healthy connection
    
    // MARK: - Public Methods
    
    /// Start monitoring connection health for the given peers
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
        lastResponseTime.removeAll()
    }
    
    /// Record that we received a response from a peer
    func recordResponse(from peerID: MCPeerID) {
        lastResponseTime[peerID.displayName] = Date()
    }
    
    /// Record initial response time when peer connects
    func peerConnected(_ peerID: MCPeerID) {
        lastResponseTime[peerID.displayName] = Date()
    }
    
    /// Remove peer from health tracking
    func peerDisconnected(_ peerID: MCPeerID) {
        lastResponseTime.removeValue(forKey: peerID.displayName)
    }
    
    /// Check if a peer's connection is considered healthy
    func isConnectionHealthy(for peerID: MCPeerID) -> Bool {
        guard let lastResponse = lastResponseTime[peerID.displayName] else {
            return false
        }
        return Date().timeIntervalSince(lastResponse) < pingTimeout
    }
    
    /// Get the time since last response from a peer
    func timeSinceLastResponse(for peerID: MCPeerID) -> TimeInterval? {
        guard let lastResponse = lastResponseTime[peerID.displayName] else {
            return nil
        }
        return Date().timeIntervalSince(lastResponse)
    }
    
    /// Reset all state
    func reset() {
        stopMonitoring()
        lastResponseTime.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func performHealthCheck() {
        let now = Date()
        var stalePeers: [MCPeerID] = []
        var healthyPeers: [MCPeerID] = []
        
        // Check each tracked peer
        for (peerName, lastResponse) in lastResponseTime {
            // Create a temporary MCPeerID for callback purposes
            // Note: In real usage, we should track actual MCPeerID objects
            let timeSinceResponse = now.timeIntervalSince(lastResponse)
            
            if timeSinceResponse > pingTimeout {
                // Connection is stale
                let stalePeerID = MCPeerID(displayName: peerName)
                stalePeers.append(stalePeerID)
                onStaleConnection?(stalePeerID)
            } else {
                let healthyPeerID = MCPeerID(displayName: peerName)
                healthyPeers.append(healthyPeerID)
            }
        }
        
        // Request ping to all tracked peers
        if !healthyPeers.isEmpty {
            onSendPing?(healthyPeers)
        }
    }
}
