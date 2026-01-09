//
//  TURNConfiguration.swift
//  tankgame Shared
//
//  Configuration for TURN (Traversal Using Relays around NAT) servers
//  Enables connection through firewalls and NATs when direct peer-to-peer fails
//

import Foundation

/// TURN server configuration
struct TURNServer: Codable, Equatable {
    let urls: [String]          // TURN server URLs (e.g., "turn:turnserver.example.com:3478")
    let username: String?       // TURN server username (optional for open servers)
    let credential: String?     // TURN server credential/password (optional for open servers)

    init(urls: [String], username: String? = nil, credential: String? = nil) {
        self.urls = urls
        self.username = username
        self.credential = credential
    }

    /// Create a TURN server configuration with a single URL
    static func single(url: String, username: String? = nil, credential: String? = nil) -> TURNServer {
        return TURNServer(urls: [url], username: username, credential: credential)
    }
}

/// ICE (Interactive Connectivity Establishment) server configuration
/// Includes both STUN and TURN servers
struct ICEServerConfiguration: Codable {
    let stunServers: [String]       // STUN servers for NAT traversal discovery
    let turnServers: [TURNServer]   // TURN servers for relayed connections

    init(stunServers: [String] = [], turnServers: [TURNServer] = []) {
        self.stunServers = stunServers
        self.turnServers = turnServers
    }

    /// Default configuration with common public STUN servers
    static var `default`: ICEServerConfiguration {
        return ICEServerConfiguration(
            stunServers: [
                "stun:stun.l.google.com:19302",
                "stun:stun1.l.google.com:19302"
            ],
            turnServers: []
        )
    }

    /// Configuration with custom TURN server
    static func withTURN(turnServer: TURNServer, includeSTUN: Bool = true) -> ICEServerConfiguration {
        let stunServers = includeSTUN ? [
            "stun:stun.l.google.com:19302",
            "stun:stun1.l.google.com:19302"
        ] : []

        return ICEServerConfiguration(
            stunServers: stunServers,
            turnServers: [turnServer]
        )
    }

    /// Check if TURN is configured
    var hasTURNServers: Bool {
        return !turnServers.isEmpty
    }

    /// Check if STUN is configured
    var hasSTUNServers: Bool {
        return !stunServers.isEmpty
    }
}

/// TURN connection settings
struct TURNSettings {
    /// Enable TURN fallback when direct connection fails
    var enableTURNFallback: Bool = true

    /// Timeout for direct connection attempts before falling back to TURN (in seconds)
    var directConnectionTimeout: TimeInterval = 10.0

    /// ICE server configuration
    var iceConfiguration: ICEServerConfiguration = .default

    /// Priority for connection types (0 = disabled, higher = preferred)
    var connectionTypePriority: ConnectionTypePriority = .default

    /// Default settings with TURN disabled
    static var disabled: TURNSettings {
        var settings = TURNSettings()
        settings.enableTURNFallback = false
        return settings
    }

    /// Settings with TURN enabled using default public STUN servers
    static var enabled: TURNSettings {
        var settings = TURNSettings()
        settings.enableTURNFallback = true
        return settings
    }

    /// Settings with custom TURN server
    static func custom(turnServer: TURNServer, timeout: TimeInterval = 10.0) -> TURNSettings {
        var settings = TURNSettings()
        settings.enableTURNFallback = true
        settings.directConnectionTimeout = timeout
        settings.iceConfiguration = .withTURN(turnServer: turnServer)
        return settings
    }
}

/// Priority settings for different connection types
struct ConnectionTypePriority {
    var host: Int = 126         // Direct LAN connection
    var serverReflexive: Int = 100  // STUN-based connection
    var peerReflexive: Int = 110    // Peer-discovered connection
    var relay: Int = 0          // TURN relay connection (lowest priority, fallback only)

    static var `default`: ConnectionTypePriority {
        return ConnectionTypePriority()
    }

    /// Aggressive TURN usage - prefers relay for stability
    static var aggressiveTURN: ConnectionTypePriority {
        return ConnectionTypePriority(
            host: 126,
            serverReflexive: 100,
            peerReflexive: 110,
            relay: 120  // Higher priority for relay
        )
    }
}
