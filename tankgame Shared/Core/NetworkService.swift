//
//  NetworkService.swift
//  tankgame Shared
//
//  Simplified networking with Combine publishers

import Foundation
import MultipeerConnectivity
import Combine

/// Handles all multiplayer networking using MultipeerConnectivity
final class NetworkService: NSObject {

    // MARK: - Publishers
    let peersChanged = PassthroughSubject<[MCPeerID], Never>()
    let gameDidStart = PassthroughSubject<GameStartInfo, Never>()
    let messageReceived = PassthroughSubject<GameCommand, Never>()

    // MARK: - Properties
    private let serviceType = "tankgame"
    private let myPeerID: MCPeerID
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private(set) var isHost = false

    var connectedPeers: [MCPeerID] { session.connectedPeers }
    var playerCount: Int { connectedPeers.count + 1 }

    override init() {
        // Create persistent peer ID
        if let data = UserDefaults.standard.data(forKey: "tankgame.peerID"),
           let decoded = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data) {
            myPeerID = decoded
        } else {
            myPeerID = MCPeerID(displayName: UIDevice.current.name)
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: myPeerID, requiringSecureCoding: true) {
                UserDefaults.standard.set(data, forKey: "tankgame.peerID")
            }
        }

        super.init()
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
    }

    // MARK: - Host/Browse
    func startHosting() {
        isHost = true
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func startBrowsing() {
        isHost = false
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }

    func invitePeer(_ peerID: MCPeerID) {
        browser?.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }

    func disconnect() {
        session.disconnect()
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        advertiser = nil
        browser = nil
    }

    // MARK: - Game Control
    func startGame() {
        guard isHost else { return }
        let seed = arc4random()
        let assignments = createPlayerAssignments()
        let info = GameStartInfo(seed: seed, playerCount: playerCount, assignments: assignments)
        send(.startGame(info))
        gameDidStart.send(info)
    }

    private func createPlayerAssignments() -> [String: Int] {
        var assignments: [String: Int] = [myPeerID.displayName: 0]
        for (index, peer) in connectedPeers.enumerated() {
            assignments[peer.displayName] = index + 1
        }
        return assignments
    }

    // MARK: - Messaging
    func send(_ command: GameCommand) {
        guard !connectedPeers.isEmpty else { return }
        guard let data = try? JSONEncoder().encode(command) else { return }
        try? session.send(data, toPeers: connectedPeers, with: .reliable)
    }
}

// MARK: - MCSessionDelegate
extension NetworkService: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.peersChanged.send(self.connectedPeers)
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let command = try? JSONDecoder().decode(GameCommand.self, from: data) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.messageReceived.send(command)
            if case .startGame(let info) = command {
                self?.gameDidStart.send(info)
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension NetworkService: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Accept if we have room (max 6 players)
        invitationHandler(session.connectedPeers.count < 5, session)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Advertising error: \(error)")
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension NetworkService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async { [weak self] in
            self?.peersChanged.send([peerID])
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Browsing error: \(error)")
    }
}

// MARK: - Supporting Types
struct GameStartInfo: Codable {
    let seed: UInt32
    let playerCount: Int
    let assignments: [String: Int] // peerName -> playerIndex
}

enum GameCommand: Codable {
    case startGame(GameStartInfo)
    case move(playerIndex: Int, position: Position, direction: Direction)
    case shoot(playerIndex: Int, projectile: Projectile)
}

struct Position: Codable {
    let row: Int
    let col: Int
}
