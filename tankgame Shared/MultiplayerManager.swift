//
//  MultiplayerManager.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation
import MultipeerConnectivity

protocol MultiplayerManagerDelegate: AnyObject {
    func multiplayerManager(_ manager: MultiplayerManager, didFindPeer peerID: MCPeerID)
    func multiplayerManager(_ manager: MultiplayerManager, didLosePeer peerID: MCPeerID)
    func multiplayerManager(_ manager: MultiplayerManager, didConnectToPeer peerID: MCPeerID)
    func multiplayerManager(_ manager: MultiplayerManager, didDisconnectFromPeer peerID: MCPeerID)
    func multiplayerManager(_ manager: MultiplayerManager, didReceiveMessage message: GameMessage)
    func multiplayerManager(_ manager: MultiplayerManager, didEncounterError error: Error)
}

class MultiplayerManager: NSObject {
    static let serviceType = "tankgame"
    
    weak var delegate: MultiplayerManagerDelegate?
    
    private let myPeerID: MCPeerID
    private(set) var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    
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
    
    func sendPositionUpdate(row: Int, col: Int, direction: Direction) {
        sendMessage(.playerMove(row: row, col: col, direction: direction))
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
    
    // MARK: - Debug Info
    
    var isAdvertising: Bool {
        return advertiser != nil
    }
    
    var isBrowsing: Bool {
        return browser != nil
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
                self.delegate?.multiplayerManager(self, didReceiveMessage: message)
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
        // Auto-accept invitations (simple approach for 2-player game)
        invitationHandler(true, session)
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
