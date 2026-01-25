//
//  Network.swift
//  Tank Game
//
//  MultipeerConnectivity wrapper using MultiPlayKit library.
//

import Foundation
import MultiPlayKit

/// Delegate protocol for network events
protocol NetworkDelegate: AnyObject {
    func network(_ network: Network, peerConnected peerId: String)
    func network(_ network: Network, peerDisconnected peerId: String)
    func network(_ network: Network, received message: GameMessage, from peerId: String)
}

/// MultipeerConnectivity wrapper using MultiPlayKit
final class Network: NSObject {
    static let serviceType = "tankgame"

    weak var delegate: NetworkDelegate?

    private let session: PeerSession
    private let transport = MessageTransport()

    /// Unique persistent peer ID (UUID string)
    var localPeerId: String {
        session.localIdentity.id
    }

    override init() {
        let config = SessionConfiguration(
            serviceType: Self.serviceType,
            identityKey: "tankgame.peerId",
            encryptionRequired: true,
            invitationTimeout: 30,
            autoAcceptInvitations: true
        )
        session = PeerSession(configuration: config)

        super.init()

        session.delegate = self
    }

    // MARK: - Peer-to-Peer Mode

    /// Start both advertising and browsing simultaneously
    func startPeerToPeer() {
        session.start()
    }

    func stopPeerToPeer() {
        session.stop()
    }

    // MARK: - Messaging

    func send(_ message: GameMessage) {
        session.broadcast(message, reliable: true)
    }

    func send(_ message: GameMessage, to peerId: String) {
        session.send(message, to: peerId, reliable: true)
    }

    // MARK: - Connection

    func disconnect() {
        session.disconnect()
    }

    var isConnected: Bool {
        session.isConnected
    }

    var connectedCount: Int {
        session.peerCount
    }

    /// All peer IDs sorted alphabetically (for deterministic ordering)
    var sortedPeerIds: [String] {
        session.sortedPeerIds
    }

    /// Check if local peer is the elder (lowest UUID)
    var isElder: Bool {
        session.isElder
    }
}

// MARK: - PeerSessionDelegate

extension Network: PeerSessionDelegate {
    func peerSession(_ session: PeerSession, peerConnected peerId: String) {
        delegate?.network(self, peerConnected: peerId)
    }

    func peerSession(_ session: PeerSession, peerDisconnected peerId: String) {
        delegate?.network(self, peerDisconnected: peerId)
    }

    func peerSession(_ session: PeerSession, receivedMessage data: Data, ofType messageType: String, from peerId: String) {
        do {
            let message = try transport.decodePayload(GameMessage.self, from: data)
            delegate?.network(self, received: message, from: peerId)
        } catch {
            print("[Network] Decode error: \(error)")
        }
    }

    func peerSession(_ session: PeerSession, receivedFullSync data: Data, from peerId: String) {
        // Handle full sync as WorldState message
        do {
            let worldState = try JSONDecoder().decode(WorldState.self, from: data)
            delegate?.network(self, received: .worldState(worldState), from: peerId)
        } catch {
            print("[Network] WorldState decode error: \(error)")
        }
    }

    func peerSession(_ session: PeerSession, receivedStateUpdate data: Data, from peerId: String) {
        // Not used for TankGame - uses custom sync messages
    }

    func peerSession(_ session: PeerSession, elderStatusChanged isElder: Bool) {
        // Elder changes handled via existing peer connect/disconnect logic
    }

    func peerSession(_ session: PeerSession, peerRequestedSync peerId: String) {
        // New peer requested sync - handled by GameViewController
    }
}
