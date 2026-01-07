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
}

/// Simple Bluetooth multiplayer manager using MultipeerConnectivity
class MultiplayerManager: NSObject {
    static let serviceType = "tankgame"
    
    weak var delegate: MultiplayerManagerDelegate?
    
    private let myPeerID: MCPeerID
    private(set) var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    
    var isHost: Bool = false
    var maxPlayers: Int = 4 // Can be 2, 3, or 4
    
    // Connection state
    private(set) var connectionState: ConnectionState = .disconnected {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.multiplayerManager(self, didChangeConnectionState: self.connectionState)
            }
        }
    }
    
    override init() {
        // Use device name as peer ID
        self.myPeerID = MCPeerID(displayName: UIDevice.current.name)
        
        super.init()
        
        self.session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        self.session.delegate = self
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
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: Self.serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        connectionState = .advertising
    }
    
    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        updateConnectionState()
    }
    
    // MARK: - Browsing
    
    func startBrowsing() {
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: Self.serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        connectionState = .browsing
    }
    
    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
        updateConnectionState()
    }
    
    func invitePeer(_ peerID: MCPeerID) {
        connectionState = .connecting(peerName: peerID.displayName)
        browser?.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
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
        connectionState = .disconnected
    }
    
    func reset() {
        disconnect()
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch state {
            case .connected:
                self.updateConnectionState()
                self.delegate?.multiplayerManager(self, didConnectToPeer: peerID)
                
            case .notConnected:
                self.updateConnectionState()
                self.delegate?.multiplayerManager(self, didDisconnectFromPeer: peerID)
                
            case .connecting:
                self.connectionState = .connecting(peerName: peerID.displayName)
                self.delegate?.multiplayerManager(self, isConnectingToPeer: peerID)
                
            @unknown default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
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
}

// MARK: - MCNearbyServiceAdvertiserDelegate

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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.multiplayerManager(self, didFindPeer: peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
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
