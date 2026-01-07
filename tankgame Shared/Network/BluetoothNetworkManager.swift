//
//  BluetoothNetworkManager.swift
//  tankgame Shared
//
//  Bluetooth implementation using MultipeerConnectivity
//

import Foundation
import MultipeerConnectivity

/// Network manager using MultipeerConnectivity (Bluetooth/WiFi)
final class BluetoothNetworkManager: NSObject, NetworkManager {
    weak var delegate: NetworkManagerDelegate?
    
    var isHost: Bool = false
    private(set) var localPlayerId: String
    var connectedPlayerIds: [String] {
        return session.connectedPeers.map { $0.displayName }
    }
    
    private let serviceType = "tankgame-v2"
    private let myPeerID: MCPeerID
    private var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    
    private var peerIdToPlayerId: [MCPeerID: String] = [:]
    private var maxPlayers: Int = 4
    
    override init() {
        // Create or retrieve persistent peer ID
        let peerID: MCPeerID
        if let data = UserDefaults.standard.data(forKey: "tankgame.peerId.v2"),
           let decoded = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data) {
            peerID = decoded
        } else {
            peerID = MCPeerID(displayName: UUID().uuidString)
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: peerID, requiringSecureCoding: true) {
                UserDefaults.standard.set(data, forKey: "tankgame.peerId.v2")
            }
        }
        
        self.myPeerID = peerID
        self.localPlayerId = peerID.displayName
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        
        super.init()
        
        self.session.delegate = self
    }
    
    // MARK: - Connection Management
    
    func startHosting(playerName: String, maxPlayers: Int) {
        isHost = true
        self.maxPlayers = maxPlayers
        
        stopBrowsing()
        
        let discoveryInfo = ["playerName": playerName, "isHost": "true"]
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: discoveryInfo, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }
    
    func startBrowsing(playerName: String) {
        isHost = false
        
        stopHosting()
        
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }
    
    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
    }
    
    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
    }
    
    func disconnect() {
        session.disconnect()
        stopHosting()
        stopBrowsing()
        peerIdToPlayerId.removeAll()
    }
    
    // MARK: - Message Sending
    
    func sendMessage(_ message: NetworkMessage, to playerIds: [String]?, reliably: Bool) {
        do {
            let data = try JSONEncoder().encode(message)
            let mode: MCSessionSendDataMode = reliably ? .reliable : .unreliable
            
            let targetPeers: [MCPeerID]
            if let playerIds = playerIds {
                targetPeers = session.connectedPeers.filter { playerIds.contains($0.displayName) }
            } else {
                targetPeers = session.connectedPeers
            }
            
            guard !targetPeers.isEmpty else { return }
            
            try session.send(data, toPeers: targetPeers, with: mode)
        } catch {
            delegate?.networkManager(self, didFailWithError: error)
        }
    }
    
    func sendMessageToAll(_ message: NetworkMessage, reliably: Bool) {
        sendMessage(message, to: nil, reliably: reliably)
    }
}

// MARK: - MCSessionDelegate

extension BluetoothNetworkManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch state {
            case .connected:
                let playerId = peerID.displayName
                self.peerIdToPlayerId[peerID] = playerId
                self.delegate?.networkManager(self, playerJoined: playerId, playerName: playerId)
                
            case .notConnected:
                if let playerId = self.peerIdToPlayerId[peerID] {
                    self.delegate?.networkManager(self, playerLeft: playerId)
                    self.peerIdToPlayerId.removeValue(forKey: peerID)
                }
                
            case .connecting:
                break
                
            @unknown default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let message = try JSONDecoder().decode(NetworkMessage.self, from: data)
            let playerId = peerID.displayName
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.networkManager(self, didReceiveMessage: message, from: playerId)
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.networkManager(self, didFailWithError: error)
            }
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

extension BluetoothNetworkManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Auto-accept invitations if we have room
        if session.connectedPeers.count < maxPlayers - 1 {
            invitationHandler(true, session)
        } else {
            invitationHandler(false, nil)
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.networkManager(self, didFailWithError: error)
        }
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension BluetoothNetworkManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // Only connect to hosts
        guard info?["isHost"] == "true" else { return }
        
        // Invite the host
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // Peer discovery lost
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.networkManager(self, didFailWithError: error)
        }
    }
}
