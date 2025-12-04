//
//  MultiplayerManager.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation
import MultipeerConnectivity

/// Message reliability mode for network communication
enum MessageReliability {
    case reliable    // For critical messages (hits, game state)
    case unreliable  // For frequent updates (position, movement)
}

protocol MultiplayerManagerDelegate: AnyObject {
    func multiplayerManager(_ manager: MultiplayerManager, didFindPeer peerID: MCPeerID)
    func multiplayerManager(_ manager: MultiplayerManager, didLosePeer peerID: MCPeerID)
    func multiplayerManager(_ manager: MultiplayerManager, didConnectToPeer peerID: MCPeerID)
    func multiplayerManager(_ manager: MultiplayerManager, didDisconnectFromPeer peerID: MCPeerID)
    func multiplayerManager(_ manager: MultiplayerManager, isConnectingToPeer peerID: MCPeerID)
    func multiplayerManager(_ manager: MultiplayerManager, didReceiveMessage message: GameMessage, from peerID: MCPeerID)
    func multiplayerManager(_ manager: MultiplayerManager, didEncounterError error: Error)
    func multiplayerManager(_ manager: MultiplayerManager, didChangeConnectionState state: ConnectionState)
    func multiplayerManager(_ manager: MultiplayerManager, isAttemptingReconnection attempt: Int, maxAttempts: Int, toPeer peerID: MCPeerID)
}

class MultiplayerManager: NSObject {
    static let serviceType = "tankgame"
    
    weak var delegate: MultiplayerManagerDelegate?
    
    private let myPeerID: MCPeerID
    private(set) var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    
    var isHost: Bool = false
    var maxPlayers: Int = 4 // Can be 2, 3, or 4
    
    // Connection management components
    private let reconnectionManager = ReconnectionManager()
    private let invitationRetryManager = InvitationRetryManager()
    private let connectionHealthMonitor = ConnectionHealthMonitor()
    
    // Track discovered peers for reconnection
    private var discoveredPeers: [MCPeerID] = []
    
    // Connection state
    private(set) var connectionState: ConnectionState = .disconnected {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.multiplayerManager(self, didChangeConnectionState: self.connectionState)
            }
        }
    }
    
    /// Auto-reconnection enabled flag
    var autoReconnectEnabled: Bool = true
    
    override init() {
        // Generate or retrieve persistent peer ID
        let peerID: MCPeerID
        if let data = UserDefaults.standard.data(forKey: "tankgame.peerID"),
           let decoded = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data) {
            peerID = decoded
        } else {
            peerID = MCPeerID(displayName: UIDevice.current.name)
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: peerID, requiringSecureCoding: true) {
                UserDefaults.standard.set(data, forKey: "tankgame.peerID")
            }
        }
        self.myPeerID = peerID
        
        super.init()
        
        self.session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        self.session.delegate = self
        
        setupConnectionManagers()
    }
    
    private func setupConnectionManagers() {
        // Setup reconnection manager callbacks
        reconnectionManager.onReconnectionAttempt = { [weak self] peerID, attempt, maxAttempts in
            guard let self = self else { return }
            self.connectionState = .reconnecting(attempt: attempt, maxAttempts: maxAttempts)
            self.delegate?.multiplayerManager(self, isAttemptingReconnection: attempt, maxAttempts: maxAttempts, toPeer: peerID)
        }
        
        reconnectionManager.onReconnectionFailed = { [weak self] peerID in
            guard let self = self else { return }
            self.connectionState = .disconnected
        }
        
        reconnectionManager.onReconnectionSucceeded = { [weak self] peerID in
            guard let self = self else { return }
            self.updateConnectionState()
        }
        
        // Setup invitation retry manager callbacks
        invitationRetryManager.onInvitationFailed = { [weak self] peerID, error in
            guard let self = self else { return }
            if let error = error {
                self.delegate?.multiplayerManager(self, didEncounterError: error)
            }
        }
        
        invitationRetryManager.onInvitationSucceeded = { [weak self] peerID in
            guard let self = self else { return }
            self.reconnectionManager.markPeerAsKnown(peerID)
        }
        
        // Setup health monitor callbacks
        connectionHealthMonitor.onStaleConnection = { [weak self] peerID in
            guard let self = self else { return }
            // Log stale connection for debugging
            print("Connection to \(peerID.displayName) appears stale")
        }
    }
    
    private func updateConnectionState() {
        let peerCount = session.connectedPeers.count
        if peerCount > 0 {
            connectionState = .connected(peerCount: peerCount + 1) // +1 for local player
        } else if advertiser != nil {
            connectionState = .advertising
        } else if browser != nil {
            connectionState = .browsing
        } else {
            connectionState = .disconnected
        }
    }
    
    // MARK: - Hosting
    
    func startHosting() {
        print("Starting to host game as: \(myPeerID.displayName)")
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: Self.serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        connectionState = .advertising
        connectionHealthMonitor.startMonitoring()
    }
    
    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        updateConnectionState()
    }
    
    // MARK: - Browsing
    
    func startBrowsing() {
        print("Starting to browse for games as: \(myPeerID.displayName)")
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: Self.serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        connectionState = .browsing
        connectionHealthMonitor.startMonitoring()
    }
    
    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
        discoveredPeers.removeAll()
        updateConnectionState()
    }
    
    func invitePeer(_ peerID: MCPeerID) {
        // Guard against inviting already connected peers
        if session.connectedPeers.contains(where: { $0.displayName == peerID.displayName }) {
            print("Peer \(peerID.displayName) is already connected, skipping invitation")
            return
        }
        
        // Guard against duplicate pending invitations
        if invitationRetryManager.hasPendingInvitation(for: peerID) {
            print("Invitation to \(peerID.displayName) is already pending, skipping duplicate")
            return
        }
        
        print("Inviting peer: \(peerID.displayName) to session")
        connectionState = .connecting(peerName: peerID.displayName)
        browser?.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        
        // Track invitation for retry
        invitationRetryManager.trackInvitation(
            to: peerID,
            checkConnection: { [weak self] peer in
                self?.session.connectedPeers.contains(where: { $0.displayName == peer.displayName }) ?? false
            },
            retryAction: { [weak self] peer in
                self?.invitePeer(peer)
            }
        )
    }
    
    // MARK: - Messaging
    
    func sendMessage(_ message: GameMessage, reliability: MessageReliability = .reliable) {
        guard !session.connectedPeers.isEmpty else { return }
        
        do {
            let data = try JSONEncoder().encode(message)
            let mode: MCSessionSendDataMode = reliability == .reliable ? .reliable : .unreliable
            try session.send(data, toPeers: session.connectedPeers, with: mode)
        } catch {
            print("Error sending message: \(error.localizedDescription)")
            delegate?.multiplayerManager(self, didEncounterError: error)
        }
    }
    
    // MARK: - Disconnection
    
    func disconnect() {
        session.disconnect()
        stopHosting()
        stopBrowsing()
        reconnectionManager.cancelAllReconnections()
        invitationRetryManager.cancelAllInvitations()
        connectionHealthMonitor.stopMonitoring()
        connectionState = .disconnected
    }
    
    /// Reset all connection state for a fresh start
    func reset() {
        disconnect()
        reconnectionManager.reset()
        invitationRetryManager.reset()
        connectionHealthMonitor.reset()
        discoveredPeers.removeAll()
    }
    
    var isConnected: Bool {
        return !session.connectedPeers.isEmpty
    }
    
    var connectedPeerName: String? {
        return session.connectedPeers.first?.displayName
    }
    
    var connectedPeersCount: Int {
        return session.connectedPeers.count + 1 // +1 for local player
    }
    
    var allPlayerNames: [String] {
        return [myPeerID.displayName] + session.connectedPeers.map { $0.displayName }
    }
}

// MARK: - MCSessionDelegate

extension MultiplayerManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        let stateString: String
        switch state {
        case .connected: stateString = "connected"
        case .connecting: stateString = "connecting"
        case .notConnected: stateString = "notConnected"
        @unknown default: stateString = "unknown"
        }
        print("Session state changed for peer \(peerID.displayName): \(stateString)")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch state {
            case .connected:
                print("Successfully connected to peer: \(peerID.displayName)")
                
                // Mark peer as known for future reconnection
                self.reconnectionManager.markPeerAsKnown(peerID)
                
                // Cancel any pending reconnection attempts
                self.reconnectionManager.cancelReconnection(for: peerID)
                
                // Mark invitation as successful
                self.invitationRetryManager.invitationSucceeded(for: peerID)
                
                // Track connection health
                self.connectionHealthMonitor.peerConnected(peerID)
                
                // Update connection state
                self.updateConnectionState()
                
                self.delegate?.multiplayerManager(self, didConnectToPeer: peerID)
                
            case .notConnected:
                print("Disconnected from peer: \(peerID.displayName)")
                
                // Stop tracking health for this peer
                self.connectionHealthMonitor.peerDisconnected(peerID)
                
                // Attempt reconnection if enabled and appropriate
                if self.autoReconnectEnabled && self.reconnectionManager.shouldAttemptReconnection(for: peerID) {
                    self.reconnectionManager.scheduleReconnection(for: peerID) { [weak self] in
                        self?.attemptReconnection(to: peerID)
                    }
                }
                
                // Update connection state
                self.updateConnectionState()
                
                self.delegate?.multiplayerManager(self, didDisconnectFromPeer: peerID)
                
            case .connecting:
                print("Connecting to peer: \(peerID.displayName)")
                self.connectionState = .connecting(peerName: peerID.displayName)
                self.delegate?.multiplayerManager(self, isConnectingToPeer: peerID)
                
            @unknown default:
                print("Unknown state for peer: \(peerID.displayName)")
                break
            }
        }
    }
    
    private func attemptReconnection(to peerID: MCPeerID) {
        if isHost {
            // If we're the host, restart advertising to allow peer to reconnect
            if advertiser == nil {
                startHosting()
            }
        } else {
            // If we're a client, restart browsing and look for the peer
            if browser == nil {
                startBrowsing()
            }
            
            // If the peer is already discovered, invite them
            if let foundPeer = discoveredPeers.first(where: { $0.displayName == peerID.displayName }) {
                invitePeer(foundPeer)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Record response for health monitoring
        connectionHealthMonitor.recordResponse(from: peerID)
        
        do {
            let message = try JSONDecoder().decode(GameMessage.self, from: data)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.multiplayerManager(self, didReceiveMessage: message, from: peerID)
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
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        // Accept all certificates for peer-to-peer gaming
        // This is required when encryptionPreference is .required
        print("Received certificate from peer: \(peerID.displayName), accepting connection")
        certificateHandler(true)
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MultiplayerManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let currentPeerCount = session.connectedPeers.count
        print("Received invitation from peer: \(peerID.displayName), current peers: \(currentPeerCount), max: \(maxPlayers)")
        
        // Check if this peer is already connected
        if session.connectedPeers.contains(where: { $0.displayName == peerID.displayName }) {
            print("Rejecting invitation from \(peerID.displayName) - peer already connected")
            invitationHandler(false, nil)
            return
        }
        
        // Accept invitations if we have room (max 4 players total)
        if currentPeerCount < maxPlayers - 1 {
            print("Accepting invitation from \(peerID.displayName)")
            invitationHandler(true, session)
        } else {
            print("Rejecting invitation from \(peerID.displayName) - session full")
            invitationHandler(false, nil)
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Error starting advertising: \(error.localizedDescription)")
        connectionState = .disconnected
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.multiplayerManager(self, didEncounterError: error)
        }
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultiplayerManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer: \(peerID.displayName)")
        
        // Track discovered peers for reconnection
        if !discoveredPeers.contains(where: { $0.displayName == peerID.displayName }) {
            discoveredPeers.append(peerID)
        }
        
        // If we're trying to reconnect to this peer, invite them
        if reconnectionManager.isReconnecting(to: peerID) {
            invitePeer(peerID)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.multiplayerManager(self, didFindPeer: peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
        discoveredPeers.removeAll { $0.displayName == peerID.displayName }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.multiplayerManager(self, didLosePeer: peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Error starting browsing: \(error.localizedDescription)")
        connectionState = .disconnected
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.multiplayerManager(self, didEncounterError: error)
        }
    }
}
