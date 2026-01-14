//
//  RetryManager.swift
//  tankgame Shared
//
//  Unified retry manager for multiplayer connections
//

import Foundation
import MultipeerConnectivity

/// Generic retry manager that handles both reconnection and invitation retry logic
class RetryManager {
    
    // MARK: - Configuration
    
    struct Configuration {
        let maxAttempts: Int
        let baseDelay: TimeInterval
        let maxDelay: TimeInterval
        let useExponentialBackoff: Bool
        
        static let reconnection = Configuration(
            maxAttempts: 5,
            baseDelay: 1.0,
            maxDelay: 30.0,
            useExponentialBackoff: true
        )
        
        static let invitation = Configuration(
            maxAttempts: 3,
            baseDelay: 32.0, // invitationTimeout + retryCheckDelay
            maxDelay: 32.0,
            useExponentialBackoff: false
        )
    }
    
    // MARK: - State
    
    private struct RetryInfo {
        let peerID: MCPeerID
        var attempts: Int = 0
        var lastAttempt: Date?
        var isActive: Bool = false
    }
    
    private var retryInfos: [String: RetryInfo] = [:]
    private var workItems: [String: DispatchWorkItem] = [:]
    private var knownPeers: Set<String> = []
    
    private let config: Configuration
    
    // MARK: - Callbacks
    
    var onRetryAttempt: ((MCPeerID, Int, Int) -> Void)?
    var onRetryFailed: ((MCPeerID) -> Void)?
    var onRetrySucceeded: ((MCPeerID) -> Void)?
    
    // MARK: - Initialization
    
    init(configuration: Configuration) {
        self.config = configuration
    }
    
    // MARK: - Public Methods
    
    /// Mark a peer as known (for reconnection eligibility)
    func markPeerAsKnown(_ peerID: MCPeerID) {
        knownPeers.insert(peerID.displayName)
    }
    
    /// Check if retry should be attempted for this peer
    func shouldAttemptRetry(for peerID: MCPeerID, requireKnownPeer: Bool = false) -> Bool {
        if requireKnownPeer && !knownPeers.contains(peerID.displayName) {
            return false
        }
        
        if let info = retryInfos[peerID.displayName] {
            return info.attempts < config.maxAttempts
        }
        
        return true
    }
    
    /// Schedule a retry attempt
    func scheduleRetry(for peerID: MCPeerID, action: @escaping () -> Void) {
        let key = peerID.displayName
        
        // Update retry info
        var info = retryInfos[key] ?? RetryInfo(peerID: peerID)
        info.attempts += 1
        info.lastAttempt = Date()
        info.isActive = true
        retryInfos[key] = info
        
        // Calculate delay
        let delay = calculateDelay(for: info.attempts)
        
        // Notify callback
        onRetryAttempt?(peerID, info.attempts, config.maxAttempts)
        
        // Cancel existing work item
        workItems[key]?.cancel()
        
        // Schedule retry
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self,
                  let currentInfo = self.retryInfos[key],
                  currentInfo.isActive else { return }
            action()
        }
        
        workItems[key] = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
    
    /// Cancel retry for a specific peer (marks as succeeded)
    func cancelRetry(for peerID: MCPeerID) {
        let key = peerID.displayName
        
        workItems[key]?.cancel()
        workItems.removeValue(forKey: key)
        
        if let info = retryInfos[key], info.isActive {
            onRetrySucceeded?(info.peerID)
        }
        
        retryInfos.removeValue(forKey: key)
    }
    
    /// Cancel all pending retries
    func cancelAllRetries() {
        workItems.values.forEach { $0.cancel() }
        workItems.removeAll()
        retryInfos.removeAll()
    }
    
    /// Check if currently retrying for a peer
    func isRetrying(for peerID: MCPeerID) -> Bool {
        return retryInfos[peerID.displayName]?.isActive ?? false
    }
    
    /// Get current attempt number
    func currentAttempt(for peerID: MCPeerID) -> Int {
        return retryInfos[peerID.displayName]?.attempts ?? 0
    }
    
    /// Mark retry as failed
    func markRetryFailed(for peerID: MCPeerID) {
        let key = peerID.displayName
        
        workItems[key]?.cancel()
        workItems.removeValue(forKey: key)
        
        let actualPeer = retryInfos[key]?.peerID ?? peerID
        retryInfos.removeValue(forKey: key)
        
        onRetryFailed?(actualPeer)
    }
    
    /// Reset all state
    func reset() {
        cancelAllRetries()
        knownPeers.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func calculateDelay(for attempt: Int) -> TimeInterval {
        if config.useExponentialBackoff {
            return min(
                config.baseDelay * pow(2.0, Double(attempt - 1)),
                config.maxDelay
            )
        } else {
            return config.baseDelay
        }
    }
}
