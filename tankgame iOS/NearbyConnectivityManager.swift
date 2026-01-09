//
//  NearbyConnectivityManager.swift
//  tankgame iOS
//
//  Adds ultra-precise local connectivity using Nearby Interaction (UWB)
//

import Foundation
import MultipeerConnectivity
import NearbyInteraction

@available(iOS 16.0, *)
class NearbyConnectivityManager: NSObject {
    
    // MARK: - Properties
    
    private let localPeerName: String
    private let sendMessage: (GameMessage, MessageReliability) -> Void
    
    private var sessions: [String: NISession] = [:]
    private var peerTokens: [String: NIDiscoveryToken] = [:]
    
    /// Called whenever the nearby status changes (UI-friendly text)
    var onStatusChanged: ((String) -> Void)?
    
    // MARK: - Init
    
    init(localPeerName: String,
         sendMessage: @escaping (GameMessage, MessageReliability) -> Void) {
        self.localPeerName = localPeerName
        self.sendMessage = sendMessage
        super.init()
    }
    
    static var isSupported: Bool {
        NISession.isSupported
    }
    
    // MARK: - Public API
    
    func handlePeerConnected(_ peerID: MCPeerID) {
        guard Self.isSupported else { return }
        let peerName = peerID.displayName
        let session = session(for: peerName)
        sendLocalTokenIfNeeded(from: session)
        onStatusChanged?("Exchanging precision token with \(peerName)…")
    }
    
    func handlePeerDisconnected(_ peerID: MCPeerID) {
        let peerName = peerID.displayName
        if let session = sessions.removeValue(forKey: peerName) {
            session.invalidate()
        }
        peerTokens.removeValue(forKey: peerName)
        onStatusChanged?("Precision link ended with \(peerName)")
    }
    
    func handleTokenMessage(from peerName: String, tokenData: Data) {
        guard Self.isSupported else { return }
        guard let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: tokenData) else {
            return
        }
        
        peerTokens[peerName] = token
        let session = session(for: peerName)
        let config = NINearbyPeerConfiguration(peerToken: token)
        session.run(config)
        onStatusChanged?("Precision link active with \(peerName)")
    }
    
    // MARK: - Helpers
    
    private func sendLocalTokenIfNeeded(from session: NISession) {
        guard let token = session.discoveryToken else { return }
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) else { return }
        let message = GameMessage.nearbyInteractionToken(peerName: localPeerName, tokenData: data)
        sendMessage(message, .reliable)
    }
    
    private func session(for peerName: String) -> NISession {
        if let existing = sessions[peerName] {
            return existing
        }
        let session = NISession()
        session.delegate = self
        sessions[peerName] = session
        return session
    }
    
    private func peerName(for session: NISession) -> String? {
        return sessions.first { $0.value === session }?.key
    }
}

// MARK: - NISessionDelegate

@available(iOS 16.0, *)
extension NearbyConnectivityManager: NISessionDelegate {
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let peerName = peerName(for: session) else { return }
        guard let object = nearbyObjects.first else { return }
        
        if let distance = object.distance {
            let formatted = String(format: "%.2f m", distance)
            onStatusChanged?("Nearby \(peerName): \(formatted)")
        } else {
            onStatusChanged?("Nearby \(peerName): estimating…")
        }
    }
    
    func sessionWasSuspended(_ session: NISession) {
        guard let peerName = peerName(for: session) else { return }
        onStatusChanged?("Precision link paused with \(peerName)")
    }
    
    func session(_ session: NISession, didInvalidateWith error: Error) {
        guard let peerName = peerName(for: session) else { return }
        sessions.removeValue(forKey: peerName)
        onStatusChanged?("Precision link reset for \(peerName): \(error.localizedDescription)")
        
        if let token = peerTokens[peerName] {
            let newSession = session(for: peerName)
            let config = NINearbyPeerConfiguration(peerToken: token)
            newSession.run(config)
        }
    }
}
