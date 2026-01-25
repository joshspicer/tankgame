//
//  Network.swift
//  Tank Game
//
//  Simple MultipeerConnectivity wrapper for peer-to-peer multiplayer.
//

import Foundation
import MultipeerConnectivity

/// Delegate protocol for network events
protocol NetworkDelegate: AnyObject {
    func network(_ network: Network, peerConnected peerId: String)
    func network(_ network: Network, peerDisconnected peerId: String)
    func network(_ network: Network, received message: GameMessage, from peerId: String)
}

/// Simple MultipeerConnectivity wrapper with peer-to-peer support
final class Network: NSObject {
    static let serviceType = "tankgame"

    weak var delegate: NetworkDelegate?

    private let myPeerID: MCPeerID
    private(set) var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    /// Unique persistent peer ID (UUID string)
    let localPeerId: String

    override init() {
        // Create or retrieve persistent UUID-based peer ID
        if let existingId = UserDefaults.standard.string(forKey: "tankgame.peerId") {
            localPeerId = existingId
        } else {
            localPeerId = UUID().uuidString
            UserDefaults.standard.set(localPeerId, forKey: "tankgame.peerId")
        }

        // Use UUID as display name for MCPeerID
        myPeerID = MCPeerID(displayName: localPeerId)

        super.init()

        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
    }

    // MARK: - Peer-to-Peer Mode

    /// Start both advertising and browsing simultaneously
    func startPeerToPeer() {
        // Start advertising
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: Self.serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()

        // Start browsing
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: Self.serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }

    func stopPeerToPeer() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        browser?.stopBrowsingForPeers()
        browser = nil
    }

    // MARK: - Messaging

    func send(_ message: GameMessage) {
        guard !session.connectedPeers.isEmpty else { return }

        do {
            let data = try JSONEncoder().encode(message)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Send error: \(error)")
        }
    }

    func send(_ message: GameMessage, to peerId: String) {
        guard let peer = session.connectedPeers.first(where: { $0.displayName == peerId }) else { return }

        do {
            let data = try JSONEncoder().encode(message)
            try session.send(data, toPeers: [peer], with: .reliable)
        } catch {
            print("Send to peer error: \(error)")
        }
    }

    // MARK: - Connection

    func disconnect() {
        session.disconnect()
        stopPeerToPeer()
    }

    var isConnected: Bool {
        !session.connectedPeers.isEmpty
    }

    var connectedCount: Int {
        session.connectedPeers.count + 1 // +1 for local
    }

    /// All peer IDs sorted alphabetically (for deterministic ordering)
    var sortedPeerIds: [String] {
        var allIds = [localPeerId] + session.connectedPeers.map(\.displayName)
        allIds.sort()
        return allIds
    }

    /// Check if local peer is the elder (lowest UUID)
    var isElder: Bool {
        sortedPeerIds.first == localPeerId
    }
}

// MARK: - MCSessionDelegate

extension Network: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch state {
            case .connected:
                NSLog("[Network] Connected to: %@... (total peers: %d)", String(peerID.displayName.prefix(8)), session.connectedPeers.count)
                delegate?.network(self, peerConnected: peerID.displayName)
            case .notConnected:
                NSLog("[Network] Disconnected from: %@...", String(peerID.displayName.prefix(8)))
                delegate?.network(self, peerDisconnected: peerID.displayName)
            case .connecting:
                NSLog("[Network] Connecting to: %@...", String(peerID.displayName.prefix(8)))
            @unknown default:
                break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let message = try JSONDecoder().decode(GameMessage.self, from: data)
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                delegate?.network(self, received: message, from: peerID.displayName)
            }
        } catch {
            print("Decode error: \(error)")
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension Network: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Auto-accept all invitations (no player limit)
        invitationHandler(true, session)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Advertise error: \(error)")
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension Network: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        // Skip if already connected
        if session.connectedPeers.contains(where: { $0.displayName == peerID.displayName }) {
            return
        }

        // Deterministic invite: lower UUID invites higher UUID (prevents duplicate connections)
        let theirId = peerID.displayName
        if localPeerId < theirId {
            // We have lower UUID, so we invite them
            NSLog("[Network] Inviting peer: %@...", String(theirId.prefix(8)))
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        }
        // If they have lower UUID, they will invite us
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // Handled by session delegate
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Browse error: \(error)")
    }
}
