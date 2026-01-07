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
    internal(set) var session: MCSession!
    internal var advertiser: MCNearbyServiceAdvertiser?
    internal var browser: MCNearbyServiceBrowser?
    
    var isHost: Bool = false
    var maxPlayers: Int = 4 // Can be 2, 3, or 4
    
    // Connection management components
    internal let reconnectionManager = ReconnectionManager()
    internal let invitationRetryManager = InvitationRetryManager()
    internal let connectionHealthMonitor = ConnectionHealthMonitor()
    
    // Delegate handlers
    private var sessionDelegate: MultiplayerSession!
    private var discoveryDelegate: MultiplayerDiscovery!
    
    // Track discovered peers for reconnection
    internal var discoveredPeers: [MCPeerID] = []
    
    // Connection state
    internal(set) var connectionState: ConnectionState = .disconnected {
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
        
        // Initialize delegate handlers
        self.sessionDelegate = MultiplayerSession(manager: self)
        self.discoveryDelegate = MultiplayerDiscovery(manager: self)
        
        self.session.delegate = self.sessionDelegate
        
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
    
    internal func updateConnectionState() {
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
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: Self.serviceType)
        advertiser?.delegate = discoveryDelegate
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
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: Self.serviceType)
        browser?.delegate = discoveryDelegate
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
    
    internal func attemptReconnection(to peerID: MCPeerID) {
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
