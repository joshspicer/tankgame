//
//  NetworkManager.swift
//  tankgame Shared
//
//  Minimal async/await MultipeerConnectivity wrapper

import Foundation
import MultipeerConnectivity
import Combine

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

actor NetworkManager: NSObject {
    #if os(iOS) || os(tvOS)
    private let peer = MCPeerID(displayName: UIDevice.current.name)
    #elseif os(macOS)
    private let peer = MCPeerID(displayName: Host.current().localizedName ?? "Mac")
    #endif
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    
    let messagePublisher = PassthroughSubject<(GameMessage, MCPeerID), Never>()
    let peerPublisher = PassthroughSubject<[MCPeerID], Never>()
    
    override init() {
        super.init()
        session = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
    }
    
    func startHosting() {
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "tankgame")
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }
    
    func startBrowsing() {
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "tankgame")
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }
    
    func invite(_ peer: MCPeerID) {
        browser?.invitePeer(peer, to: session, withContext: nil, timeout: 30)
    }
    
    func send(_ message: GameMessage) {
        guard !session.connectedPeers.isEmpty else { return }
        try? session.send(JSONEncoder().encode(message), toPeers: session.connectedPeers, with: .reliable)
    }
    
    func disconnect() {
        session.disconnect()
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        advertiser = nil
        browser = nil
    }
    
    var connectedPeers: [MCPeerID] { session.connectedPeers }
    var allPlayers: [String] { [peer.displayName] + connectedPeers.map(\.displayName) }
}

// MARK: - MCSessionDelegate
extension NetworkManager: MCSessionDelegate {
    nonisolated func session(_ session: MCSession, peer: MCPeerID, didChange state: MCSessionState) {
        Task { await peerPublisher.send(session.connectedPeers) }
    }
    
    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peer: MCPeerID) {
        guard let message = try? JSONDecoder().decode(GameMessage.self, from: data) else { return }
        Task { await messagePublisher.send((message, peer)) }
    }
    
    nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension NetworkManager: MCNearbyServiceAdvertiserDelegate {
    nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        Task {
            let session = await session
            invitationHandler(true, session)
        }
    }
    
    nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Advertising error: \(error)")
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension NetworkManager: MCNearbyServiceBrowserDelegate {
    nonisolated func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        Task { await peerPublisher.send([peerID]) }
    }
    
    nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
    nonisolated func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Browsing error: \(error)")
    }
}
