//
//  NetworkAdapter.swift
//  tankgame Shared
//
//  Clean Architecture - Infrastructure Layer
//

import Foundation
import MultipeerConnectivity

/// Protocol for network communication
protocol NetworkAdapter: AnyObject {
    var delegate: NetworkAdapterDelegate? { get set }
    var isHost: Bool { get }
    var connectedPeerCount: Int { get }
    
    func startHosting(displayName: String)
    func startBrowsing(displayName: String)
    func stopHosting()
    func stopBrowsing()
    func disconnect()
    
    func send(_ message: NetworkMessage, to peers: [String]?) throws
    func broadcast(_ message: NetworkMessage) throws
}

/// Delegate for network adapter events
protocol NetworkAdapterDelegate: AnyObject {
    func networkAdapter(_ adapter: NetworkAdapter, didReceive message: NetworkMessage, from peerID: String)
    func networkAdapter(_ adapter: NetworkAdapter, peerDidConnect peerID: String, displayName: String)
    func networkAdapter(_ adapter: NetworkAdapter, peerDidDisconnect peerID: String)
    func networkAdapter(_ adapter: NetworkAdapter, didFailWithError error: Error)
}

/// MultipeerConnectivity-based network adapter
final class BluetoothNetworkAdapter: NSObject, NetworkAdapter {
    
    weak var delegate: NetworkAdapterDelegate?
    
    private let serviceType = "tankgame-mp"
    private var peerID: MCPeerID!
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private let serializer: MessageSerializer
    
    var isHost: Bool {
        return advertiser != nil
    }
    
    var connectedPeerCount: Int {
        return session?.connectedPeers.count ?? 0
    }
    
    init(serializer: MessageSerializer = JSONMessageSerializer()) {
        self.serializer = serializer
        super.init()
    }
    
    func startHosting(displayName: String) {
        setupSession(displayName: displayName)
        
        advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: nil,
            serviceType: serviceType
        )
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }
    
    func startBrowsing(displayName: String) {
        setupSession(displayName: displayName)
        
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
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
        stopHosting()
        stopBrowsing()
        session?.disconnect()
        session = nil
    }
    
    func send(_ message: NetworkMessage, to peers: [String]?) throws {
        guard let session = session else { return }
        
        let data = try serializer.serialize(message)
        
        let targetPeers: [MCPeerID]
        if let peerNames = peers {
            targetPeers = session.connectedPeers.filter { peerNames.contains($0.displayName) }
        } else {
            targetPeers = session.connectedPeers
        }
        
        guard !targetPeers.isEmpty else { return }
        
        try session.send(data, toPeers: targetPeers, with: .reliable)
    }
    
    func broadcast(_ message: NetworkMessage) throws {
        try send(message, to: nil)
    }
    
    private func setupSession(displayName: String) {
        peerID = MCPeerID(displayName: displayName)
        session = MCSession(
            peer: peerID,
            securityIdentity: nil,
            encryptionPreference: .none
        )
        session.delegate = self
    }
}

// MARK: - MCSessionDelegate
extension BluetoothNetworkAdapter: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            delegate?.networkAdapter(self, peerDidConnect: peerID.displayName, displayName: peerID.displayName)
        case .notConnected:
            delegate?.networkAdapter(self, peerDidDisconnect: peerID.displayName)
        case .connecting:
            break
        @unknown default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let message = try serializer.deserialize(data)
            delegate?.networkAdapter(self, didReceive: message, from: peerID.displayName)
        } catch {
            delegate?.networkAdapter(self, didFailWithError: error)
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
extension BluetoothNetworkAdapter: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Auto-accept invitations when hosting
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension BluetoothNetworkAdapter: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // Auto-invite when browsing
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // Peer lost
    }
}
