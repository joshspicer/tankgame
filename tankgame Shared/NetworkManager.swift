//
//  NetworkManager.swift
//  tankgame Shared
//
//  Network abstraction for multiplayer
//

import Foundation
import MultipeerConnectivity

/// Delegate for network events
protocol NetworkManagerDelegate: AnyObject {
    func networkManager(_ manager: NetworkManager, didReceiveMessage: NetworkMessage, from peerId: String)
    func networkManager(_ manager: NetworkManager, didConnectPeer peerId: String)
    func networkManager(_ manager: NetworkManager, didDisconnectPeer peerId: String)
    func networkManager(_ manager: NetworkManager, foundPeers: [String])
}

/// Manages multiplayer networking using MultipeerConnectivity
class NetworkManager: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: NetworkManagerDelegate?
    
    private let serviceType = "tankgame-v2"
    private let myPeerId: MCPeerID
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    
    private(set) var isHost = false
    private(set) var connectedPeers: [MCPeerID] = []
    
    // MARK: - Initialization
    
    override init() {
        // Create persistent peer ID
        let deviceName = UIDevice.current.name
        self.myPeerId = MCPeerID(displayName: deviceName)
        
        super.init()
        
        // Setup session
        self.session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        self.session.delegate = self
    }
    
    // MARK: - Public Methods
    
    /// Start hosting a game
    func startHosting() {
        isHost = true
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }
    
    /// Start browsing for games
    func startBrowsing() {
        isHost = false
        browser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }
    
    /// Stop networking
    func stop() {
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        session.disconnect()
        connectedPeers.removeAll()
    }
    
    /// Send message to all connected peers
    func sendMessage(_ message: NetworkMessage, reliable: Bool = true) {
        guard let data = message.encode() else { return }
        
        let sendMode: MCSessionSendDataMode = reliable ? .reliable : .unreliable
        
        do {
            try session.send(data, toPeers: connectedPeers, with: sendMode)
        } catch {
            print("Error sending message: \(error)")
        }
    }
    
    /// Get current peer ID as string
    var myPeerIdString: String {
        return myPeerId.displayName
    }
}

// MARK: - MCSessionDelegate

extension NetworkManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch state {
            case .connected:
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
                self.delegate?.networkManager(self, didConnectPeer: peerID.displayName)
                
            case .notConnected:
                self.connectedPeers.removeAll { $0 == peerID }
                self.delegate?.networkManager(self, didDisconnectPeer: peerID.displayName)
                
            case .connecting:
                break
                
            @unknown default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = NetworkMessage.decode(from: data) else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.networkManager(self, didReceiveMessage: message, from: peerID.displayName)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension NetworkManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Auto-accept invitations when hosting
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension NetworkManager: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // Auto-invite when browsing
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let allPeers = self.connectedPeers.map { $0.displayName }
            self.delegate?.networkManager(self, foundPeers: allPeers)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let allPeers = self.connectedPeers.map { $0.displayName }
            self.delegate?.networkManager(self, foundPeers: allPeers)
        }
    }
}
