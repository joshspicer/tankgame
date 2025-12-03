//
//  InvitationRetryManager.swift
//  tankgame Shared
//
//  Manages retry logic for peer invitations
//

import Foundation
import MultipeerConnectivity

/// Manages retry logic for peer invitations that fail or timeout
class InvitationRetryManager {
    
    // MARK: - Configuration
    
    let maxInvitationAttempts = 3
    let invitationTimeout: TimeInterval = 30.0
    let retryCheckDelay: TimeInterval = 2.0  // Extra delay after timeout to check result
    
    // MARK: - State
    
    private var invitationAttempts: [String: InvitationAttempt] = [:]
    private var retryWorkItems: [String: DispatchWorkItem] = [:]
    
    // MARK: - Callbacks
    
    var onInvitationAttempt: ((MCPeerID, Int, Int) -> Void)?  // peer, attempt, maxAttempts
    var onInvitationFailed: ((MCPeerID, Error?) -> Void)?  // peer, error
    var onInvitationSucceeded: ((MCPeerID) -> Void)?  // peer
    
    // MARK: - Invitation Attempt
    
    private struct InvitationAttempt {
        let peerID: MCPeerID
        var attempts: Int = 0
        var lastAttempt: Date?
        var isPending: Bool = false
    }
    
    // MARK: - Public Methods
    
    /// Start tracking an invitation to a peer
    /// - Parameters:
    ///   - peerID: The peer being invited
    ///   - checkConnection: Closure to check if connection was established
    ///   - retryAction: Closure to retry the invitation
    func trackInvitation(
        to peerID: MCPeerID,
        checkConnection: @escaping (MCPeerID) -> Bool,
        retryAction: @escaping (MCPeerID) -> Void
    ) {
        let key = peerID.displayName
        
        // Initialize or update attempt tracking
        var attempt = invitationAttempts[key] ?? InvitationAttempt(peerID: peerID)
        attempt.attempts += 1
        attempt.lastAttempt = Date()
        attempt.isPending = true
        invitationAttempts[key] = attempt
        
        // Notify callback
        onInvitationAttempt?(peerID, attempt.attempts, maxInvitationAttempts)
        
        // Cancel any existing retry work item
        retryWorkItems[key]?.cancel()
        
        // Schedule retry check after timeout
        let totalDelay = invitationTimeout + retryCheckDelay
        let workItem = DispatchWorkItem { [weak self] in
            self?.checkInvitationResult(
                for: peerID,
                checkConnection: checkConnection,
                retryAction: retryAction
            )
        }
        
        retryWorkItems[key] = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay, execute: workItem)
    }
    
    /// Mark invitation as successful (peer connected)
    func invitationSucceeded(for peerID: MCPeerID) {
        let key = peerID.displayName
        
        // Cancel pending retry
        retryWorkItems[key]?.cancel()
        retryWorkItems.removeValue(forKey: key)
        
        // Clear attempt tracking
        invitationAttempts.removeValue(forKey: key)
        
        // Notify callback
        onInvitationSucceeded?(peerID)
    }
    
    /// Cancel all pending invitations
    func cancelAllInvitations() {
        for (_, workItem) in retryWorkItems {
            workItem.cancel()
        }
        retryWorkItems.removeAll()
        invitationAttempts.removeAll()
    }
    
    /// Cancel invitation for a specific peer
    func cancelInvitation(for peerID: MCPeerID) {
        let key = peerID.displayName
        
        retryWorkItems[key]?.cancel()
        retryWorkItems.removeValue(forKey: key)
        invitationAttempts.removeValue(forKey: key)
    }
    
    /// Check if there's a pending invitation for a peer
    func hasPendingInvitation(for peerID: MCPeerID) -> Bool {
        return invitationAttempts[peerID.displayName]?.isPending ?? false
    }
    
    /// Get the current attempt number for a peer
    func currentAttempt(for peerID: MCPeerID) -> Int {
        return invitationAttempts[peerID.displayName]?.attempts ?? 0
    }
    
    /// Reset all state
    func reset() {
        cancelAllInvitations()
    }
    
    // MARK: - Private Methods
    
    private func checkInvitationResult(
        for peerID: MCPeerID,
        checkConnection: @escaping (MCPeerID) -> Bool,
        retryAction: @escaping (MCPeerID) -> Void
    ) {
        let key = peerID.displayName
        
        guard var attempt = invitationAttempts[key], attempt.isPending else {
            return
        }
        
        // Check if connection was established
        if checkConnection(peerID) {
            // Success!
            invitationSucceeded(for: peerID)
            return
        }
        
        // Connection not established - check if we should retry
        attempt.isPending = false
        invitationAttempts[key] = attempt
        
        if attempt.attempts < maxInvitationAttempts {
            // Retry the invitation
            retryAction(peerID)
        } else {
            // Max attempts reached
            let error = NSError(
                domain: "InvitationRetryManager",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Failed to connect to \(peerID.displayName) after \(maxInvitationAttempts) attempts"
                ]
            )
            
            // Clear tracking
            invitationAttempts.removeValue(forKey: key)
            
            // Notify failure
            onInvitationFailed?(peerID, error)
        }
    }
}
