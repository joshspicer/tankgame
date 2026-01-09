//
//  NetworkTransport.swift
//  tankgame Shared
//
//  Network transport abstraction layer
//  Supports both MultipeerConnectivity and WebRTC with TURN
//

import Foundation
import MultipeerConnectivity

/// Transport types for network connections
enum TransportType: String, Codable {
    case multipeerConnectivity  // Bluetooth/WiFi Direct using MCSession
    case webRTC                 // WebRTC with TURN/STUN support
}

/// Network transport protocol - abstraction over different connection methods
protocol NetworkTransport: AnyObject {
    /// Transport type
    var transportType: TransportType { get }

    /// Peer ID (unique identifier for this peer)
    var peerID: String { get }

    /// Connected peers
    var connectedPeers: [String] { get }

    /// Check if connected to any peers
    var isConnected: Bool { get }

    /// Delegate for transport events
    var delegate: NetworkTransportDelegate? { get set }

    /// Start hosting/advertising
    func startHosting()

    /// Stop hosting/advertising
    func stopHosting()

    /// Start browsing for peers
    func startBrowsing()

    /// Stop browsing for peers
    func stopBrowsing()

    /// Invite a peer to connect
    /// - Parameter peerID: Identifier of the peer to invite
    func invitePeer(_ peerID: String)

    /// Send data to connected peers
    /// - Parameters:
    ///   - data: Data to send
    ///   - reliability: Whether to use reliable transport
    func sendData(_ data: Data, reliability: MessageReliability) throws

    /// Disconnect from all peers
    func disconnect()
}

/// Delegate protocol for network transport events
protocol NetworkTransportDelegate: AnyObject {
    /// Called when a peer is discovered
    func transport(_ transport: NetworkTransport, didFindPeer peerID: String, displayName: String)

    /// Called when a peer is lost
    func transport(_ transport: NetworkTransport, didLosePeer peerID: String)

    /// Called when connected to a peer
    func transport(_ transport: NetworkTransport, didConnectToPeer peerID: String, displayName: String)

    /// Called when disconnected from a peer
    func transport(_ transport: NetworkTransport, didDisconnectFromPeer peerID: String)

    /// Called when connecting to a peer
    func transport(_ transport: NetworkTransport, isConnectingToPeer peerID: String, displayName: String)

    /// Called when data is received
    func transport(_ transport: NetworkTransport, didReceiveData data: Data, fromPeer peerID: String)

    /// Called when an error occurs
    func transport(_ transport: NetworkTransport, didEncounterError error: Error)

    /// Called when connection state changes
    func transport(_ transport: NetworkTransport, didChangeState state: ConnectionState)
}

/// Errors for network transport
enum NetworkTransportError: LocalizedError {
    case notConnected
    case encodingFailed
    case sendFailed(underlying: Error)
    case notSupported
    case invalidPeerID

    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "Not connected to any peers"
        case .encodingFailed:
            return "Failed to encode message"
        case .sendFailed(let error):
            return "Failed to send message: \(error.localizedDescription)"
        case .notSupported:
            return "Operation not supported by this transport"
        case .invalidPeerID:
            return "Invalid peer ID"
        }
    }
}
