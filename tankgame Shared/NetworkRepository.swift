//
//  NetworkRepository.swift
//  tankgame Shared
//
//  Complete rewrite - Clean networking layer
//

import Foundation
import MultipeerConnectivity

protocol NetworkRepositoryDelegate: AnyObject {
    func networkRepository(_ repo: NetworkRepository, didFindPeer peer: Player)
    func networkRepository(_ repo: NetworkRepository, didLosePeer peer: Player)
    func networkRepository(_ repo: NetworkRepository, didConnectPeer peer: Player)
    func networkRepository(_ repo: NetworkRepository, didDisconnectPeer peer: Player)
    func networkRepository(_ repo: NetworkRepository, didReceiveMessage message: GameMessage)
}

final class NetworkRepository: NSObject {
    weak var delegate: NetworkRepositoryDelegate?

    private let serviceType = "tankgame"
    private let myPeerID: MCPeerID
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    var isHost = false
    var localPlayer: Player { Player(id: myPeerID.displayName, name: myPeerID.displayName) }
    var connectedPlayers: [Player] {
        session.connectedPeers.map { Player(id: $0.displayName, name: $0.displayName) }
    }

    override init() {
        // Use device name as peer ID
        self.myPeerID = MCPeerID(displayName: UIDevice.current.name)
        super.init()

        self.session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        self.session.delegate = self
    }

    // MARK: - Hosting

    func startHosting() {
        isHost = true
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
    }

    // MARK: - Browsing

    func startBrowsing() {
        isHost = false
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }

    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
    }

    func invitePeer(_ player: Player) {
        guard let peer = session.connectedPeers.first(where: { $0.displayName == player.id }) ??
                         findDiscoveredPeer(player.id) else {
            return
        }
        browser?.invitePeer(peer, to: session, withContext: nil, timeout: 30)
    }

    private var discoveredPeers: [MCPeerID] = []

    private func findDiscoveredPeer(_ id: String) -> MCPeerID? {
        return discoveredPeers.first { $0.displayName == id }
    }

    // MARK: - Messaging

    func send(message: GameMessage) {
        guard !session.connectedPeers.isEmpty else { return }

        do {
            let data = try JSONEncoder().encode(message)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Failed to send message: \(error)")
        }
    }

    // MARK: - Disconnection

    func disconnect() {
        session.disconnect()
        stopHosting()
        stopBrowsing()
    }
}

// MARK: - MCSessionDelegate

extension NetworkRepository: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let player = Player(id: peerID.displayName, name: peerID.displayName)

            switch state {
            case .connected:
                self.delegate?.networkRepository(self, didConnectPeer: player)
            case .notConnected:
                self.delegate?.networkRepository(self, didDisconnectPeer: player)
            case .connecting:
                break
            @unknown default:
                break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = try? JSONDecoder().decode(GameMessage.self, from: data) else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.networkRepository(self, didReceiveMessage: message)
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension NetworkRepository: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Auto-accept if we have room (max 6 players)
        if session.connectedPeers.count < 5 {
            invitationHandler(true, session)
        } else {
            invitationHandler(false, nil)
        }
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Failed to advertise: \(error)")
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension NetworkRepository: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if !discoveredPeers.contains(where: { $0.displayName == peerID.displayName }) {
            discoveredPeers.append(peerID)
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let player = Player(id: peerID.displayName, name: peerID.displayName)
            self.delegate?.networkRepository(self, didFindPeer: player)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        discoveredPeers.removeAll { $0.displayName == peerID.displayName }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let player = Player(id: peerID.displayName, name: peerID.displayName)
            self.delegate?.networkRepository(self, didLosePeer: player)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Failed to browse: \(error)")
    }
}
