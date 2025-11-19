//
//  MultiplayerManager.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation
import MultipeerConnectivity

/// Delegate protocol for multiplayer manager events
protocol MultiplayerManagerDelegate: AnyObject {
    /// Called when a new peer is discovered
    func multiplayerManager(_ manager: MultiplayerManager, didFindPeer peerID: MCPeerID)
    
    /// Called when a peer is no longer discoverable
    func multiplayerManager(_ manager: MultiplayerManager, didLosePeer peerID: MCPeerID)
    
    /// Called when successfully connected to a peer
    func multiplayerManager(_ manager: MultiplayerManager, didConnectToPeer peerID: MCPeerID)
    
    /// Called when disconnected from a peer
    func multiplayerManager(_ manager: MultiplayerManager, didDisconnectFromPeer peerID: MCPeerID)
    
    /// Called when a game message is received from a peer
    func multiplayerManager(_ manager: MultiplayerManager, didReceiveMessage message: GameMessage, from peerID: MCPeerID)
    
    /// Called when an error occurs
    func multiplayerManager(_ manager: MultiplayerManager, didEncounterError error: Error)
}

/// Manages low-level MultipeerConnectivity for game networking
/// Handles peer discovery, connections, and message passing
final class MultiplayerManager: NSObject {
    
    // MARK: - Constants
    
    /// Service type identifier for peer discovery
    static let serviceType = "tankgame"
    
    // MARK: - Properties
    
    /// Delegate to receive multiplayer events
    weak var delegate: MultiplayerManagerDelegate?
    
    /// This device's peer ID
    private let myPeerID: MCPeerID
    
    /// Active multipeer session
    private(set) var session: MCSession!
    
    /// Service advertiser for hosting
    private var advertiser: MCNearbyServiceAdvertiser?
    
    /// Service browser for joining
    private var browser: MCNearbyServiceBrowser?
    
    /// Whether this device is hosting the game
    var isHost: Bool = false
    
    /// Maximum number of players allowed (2-4)
    var maxPlayers: Int = 4
    
    // MARK: - Initialization
    
    /// Creates a new multiplayer manager with a persistent peer ID
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
    }
    
    // MARK: - Hosting
    
    /// Starts advertising as a host for other players to discover
    func startHosting() {
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: Self.serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }
    
    /// Stops advertising as a host
    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
    }
    
    // MARK: - Browsing
    
    /// Starts browsing for available hosts
    func startBrowsing() {
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: Self.serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }
    
    /// Stops browsing for hosts
    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
    }
    
    /// Invites a discovered peer to join the session
    /// - Parameter peerID: The peer to invite
    func invitePeer(_ peerID: MCPeerID) {
        browser?.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }
    
    // MARK: - Messaging
    
    /// Sends a game message to all connected peers
    /// - Parameter message: The game message to send
    func sendMessage(_ message: GameMessage) {
        guard !session.connectedPeers.isEmpty else { return }
        
        do {
            let data = try JSONEncoder().encode(message)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Disconnection
    
    func disconnect() {
        session.disconnect()
        stopHosting()
        stopBrowsing()
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
                self.delegate?.multiplayerManager(self, didConnectToPeer: peerID)
            case .notConnected:
                self.delegate?.multiplayerManager(self, didDisconnectFromPeer: peerID)
            case .connecting:
                break
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.multiplayerManager(self, didEncounterError: error)
        }
    }
}
