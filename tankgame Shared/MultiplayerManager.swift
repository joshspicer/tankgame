//
//  MultiplayerManager.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//
//  Core coordinator for multiplayer functionality.
//  Delegate implementations are in separate files:
//  - MultiplayerSessionHandler.swift (MCSessionDelegate)
//  - MultiplayerAdvertiser.swift (MCNearbyServiceAdvertiserDelegate)
//  - MultiplayerBrowser.swift (MCNearbyServiceBrowserDelegate)
//

import Foundation
import MultipeerConnectivity

protocol MultiplayerManagerDelegate: AnyObject {
    func multiplayerManager(_ manager: MultiplayerManager, didFindPeer peerID: MCPeerID)
    func multiplayerManager(_ manager: MultiplayerManager, didLosePeer peerID: MCPeerID)
    func multiplayerManager(_ manager: MultiplayerManager, didConnectToPeer peerID: MCPeerID)
    func multiplayerManager(_ manager: MultiplayerManager, didDisconnectFromPeer peerID: MCPeerID)
    func multiplayerManager(_ manager: MultiplayerManager, didReceiveMessage message: GameMessage, from peerID: MCPeerID)
    func multiplayerManager(_ manager: MultiplayerManager, didEncounterError error: Error)
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
    
    func startHosting() {
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: Self.serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }
    
    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
    }
    
    // MARK: - Browsing
    
    func startBrowsing() {
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: Self.serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
    }
    
    func invitePeer(_ peerID: MCPeerID) {
        browser?.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }
    
    // MARK: - Messaging
    
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
