//
//  ReconnectionManager.swift
//  tankgame Shared
//
//  Manages auto-reconnection logic for multiplayer connections
//

import Foundation
import MultipeerConnectivity

/// Manages automatic reconnection attempts when connections are lost
class ReconnectionManager {
    
    // MARK: - Configuration
    
    let maxReconnectionAttempts = 5
    let baseReconnectionDelay: TimeInterval = 1.0
    let maxReconnectionDelay: TimeInterval = 30.0
    
    // MARK: - State
    
    private var reconnectionInfos: [String: ReconnectionInfo] = [:]
    private var reconnectionWorkItems: [String: DispatchWorkItem] = [:]
    private var knownPeers: Set<String> = []
    
    // MARK: - Callbacks
    
    var onReconnectionAttempt: ((String, Int, Int) -> Void)?  // peerName, attempt, maxAttempts
    var onReconnectionFailed: ((String) -> Void)?  // peerName
    var onReconnectionSucceeded: ((String) -> Void)?  // peerName
    
    // MARK: - Reconnection Info
    
    private struct ReconnectionInfo {
        let peerID: MCPeerID
        var attempts: Int = 0
        var lastAttempt: Date?
        var isReconnecting: Bool = false
    }
    
    // MARK: - Public Methods
    
    /// Mark a peer as known (successfully connected before)
    func markPeerAsKnown(_ peerID: MCPeerID) {
        knownPeers.insert(peerID.displayName)
    }
    
    /// Check if we should attempt reconnection for this peer
    func shouldAttemptReconnection(for peerID: MCPeerID) -> Bool {
        // Only reconnect to peers we've successfully connected to before
        guard knownPeers.contains(peerID.displayName) else { return false }
        
        // Check if we've exceeded max attempts
        if let info = reconnectionInfos[peerID.displayName] {
            return info.attempts < maxReconnectionAttempts
        }
        
        return true
    }
    
    /// Schedule a reconnection attempt for the given peer
    /// - Parameters:
    ///   - peerID: The peer to reconnect to
    ///   - action: The action to perform when attempting reconnection
    func scheduleReconnection(for peerID: MCPeerID, action: @escaping () -> Void) {
        let key = peerID.displayName
        
        // Initialize or update reconnection info
        var info = reconnectionInfos[key] ?? ReconnectionInfo(peerID: peerID)
        info.attempts += 1
        info.lastAttempt = Date()
        info.isReconnecting = true
        reconnectionInfos[key] = info
        
        // Calculate delay with exponential backoff
        let delay = min(
            baseReconnectionDelay * pow(2.0, Double(info.attempts - 1)),
            maxReconnectionDelay
        )
        
        // Notify callback
        onReconnectionAttempt?(peerID.displayName, info.attempts, maxReconnectionAttempts)
        
        // Cancel any existing work item
        reconnectionWorkItems[key]?.cancel()
        
        // Schedule reconnection attempt
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            guard let currentInfo = self.reconnectionInfos[key], currentInfo.isReconnecting else { return }
            
            action()
        }
        
        reconnectionWorkItems[key] = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
    
    /// Cancel reconnection attempts for a specific peer
    func cancelReconnection(for peerID: MCPeerID) {
        let key = peerID.displayName
        
        // Cancel pending work item
        reconnectionWorkItems[key]?.cancel()
        reconnectionWorkItems.removeValue(forKey: key)
        
        // Check if we were reconnecting and notify success
        if let info = reconnectionInfos[key], info.isReconnecting {
            onReconnectionSucceeded?(key)
        }
        
        // Reset reconnection info
        reconnectionInfos.removeValue(forKey: key)
    }
    
    /// Cancel all pending reconnection attempts
    func cancelAllReconnections() {
        for (_, workItem) in reconnectionWorkItems {
            workItem.cancel()
        }
        reconnectionWorkItems.removeAll()
        reconnectionInfos.removeAll()
    }
    
    /// Check if currently attempting reconnection to a peer
    func isReconnecting(to peerID: MCPeerID) -> Bool {
        return reconnectionInfos[peerID.displayName]?.isReconnecting ?? false
    }
    
    /// Get the current reconnection attempt number for a peer
    func currentAttempt(for peerID: MCPeerID) -> Int {
        return reconnectionInfos[peerID.displayName]?.attempts ?? 0
    }
    
    /// Mark reconnection as failed after max attempts
    func markReconnectionFailed(for peerID: MCPeerID) {
        let key = peerID.displayName
        
        reconnectionWorkItems[key]?.cancel()
        reconnectionWorkItems.removeValue(forKey: key)
        reconnectionInfos.removeValue(forKey: key)
        
        onReconnectionFailed?(key)
    }
    
    /// Reset all state
    func reset() {
        cancelAllReconnections()
        knownPeers.removeAll()
    }
}
