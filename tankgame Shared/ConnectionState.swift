//
//  ConnectionState.swift
//  tankgame Shared
//
//  Connection state enum for better tracking of multiplayer connection status
//

import Foundation

/// Represents the current state of the multiplayer connection
enum ConnectionState: Equatable {
    case disconnected
    case browsing
    case advertising
    case connecting(peerName: String)
    case connected(peerCount: Int)
    
    var description: String {
        switch self {
        case .disconnected:
            return "Disconnected"
        case .browsing:
            return "Searching for games..."
        case .advertising:
            return "Hosting game..."
        case .connecting(let peerName):
            return "Connecting to \(peerName)..."
        case .connected(let peerCount):
            return "Connected (\(peerCount) player\(peerCount == 1 ? "" : "s"))"
        }
    }
    
    var isConnected: Bool {
        if case .connected = self {
            return true
        }
        return false
    }
    
    var isConnecting: Bool {
        if case .connecting = self {
            return true
        }
        return false
    }
}
