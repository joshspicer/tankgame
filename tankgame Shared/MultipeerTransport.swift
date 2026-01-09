//
//  MultipeerTransport.swift
//  tankgame Shared
//
//  Network transport adapter for MultipeerConnectivity
//  Wraps MCSession to conform to NetworkTransport protocol
//

import Foundation
import MultipeerConnectivity

/// MultipeerConnectivity transport adapter
class MultipeerTransport: NSObject, NetworkTransport {
    // MARK: - NetworkTransport Properties

    var transportType: TransportType { return .multipeerConnectivity }

    var peerID: String { return myPeerID.displayName }

    var connectedPeers: [String] {
        return session.connectedPeers.map { $0.displayName }
    }

    var isConnected: Bool {
        return !session.connectedPeers.isEmpty
    }

    weak var delegate: NetworkTransportDelegate?

    // MARK: - MultipeerConnectivity Properties

    static let serviceType = "tankgame"

    private let myPeerID: MCPeerID
    private let session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    private var discoveredPeers: [MCPeerID] = []
    private var peerDisplayNames: [String: String] = [:] // MCPeerID display name -> display name

    var maxPlayers: Int = 4

    // MARK: - Initialization

    override init() {
        // Generate or retrieve persistent peer ID
        let peerID: MCPeerID
        if let data = UserDefaults.standard.data(forKey: "tankgame.peerID"),
           let decoded = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data) {
            peerID = decoded
        } else {
            peerID = MCPeerID(displayName: UIDevice.current.name)
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: peerID, requiringSecureCoding: true) {
                UserDefaults.standard.set(data, forKey: "tankgame.peerID")
            }
        }
        self.myPeerID = peerID
        self.session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)

        super.init()

        self.session.delegate = self
    }

    // MARK: - NetworkTransport Methods

    func startHosting() {
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: Self.serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        delegate?.transport(self, didChangeState: .advertising)
    }

    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
    }

    func startBrowsing() {
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: Self.serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        delegate?.transport(self, didChangeState: .browsing)
    }

    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
        discoveredPeers.removeAll()
    }

    func invitePeer(_ peerID: String) {
        guard let mcPeerID = discoveredPeers.first(where: { $0.displayName == peerID }) else {
            delegate?.transport(self, didEncounterError: NetworkTransportError.invalidPeerID)
            return
        }

        let displayName = peerDisplayNames[peerID] ?? peerID
        delegate?.transport(self, didChangeState: .connecting(peerName: displayName))
        browser?.invitePeer(mcPeerID, to: session, withContext: nil, timeout: 30)
    }

    func sendData(_ data: Data, reliability: MessageReliability) throws {
        guard !session.connectedPeers.isEmpty else {
            throw NetworkTransportError.notConnected
        }

        do {
            let mode: MCSessionSendDataMode = reliability == .reliable ? .reliable : .unreliable
            try session.send(data, toPeers: session.connectedPeers, with: mode)
        } catch {
            throw NetworkTransportError.sendFailed(underlying: error)
        }
    }

    func disconnect() {
        session.disconnect()
        stopHosting()
        stopBrowsing()
        delegate?.transport(self, didChangeState: .disconnected)
    }

    // MARK: - Helper Methods

    private func updateConnectionState() {
        let peerCount = session.connectedPeers.count
        if peerCount > 0 {
            delegate?.transport(self, didChangeState: .connected(peerCount: peerCount + 1))
        } else if advertiser != nil {
            delegate?.transport(self, didChangeState: .advertising)
        } else if browser != nil {
            delegate?.transport(self, didChangeState: .browsing)
        } else {
            delegate?.transport(self, didChangeState: .disconnected)
        }
    }
}

// MARK: - MCSessionDelegate

extension MultipeerTransport: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let displayName = self.peerDisplayNames[peerID.displayName] ?? peerID.displayName

            switch state {
            case .connected:
                self.updateConnectionState()
                self.delegate?.transport(self, didConnectToPeer: peerID.displayName, displayName: displayName)

            case .notConnected:
                self.updateConnectionState()
                self.delegate?.transport(self, didDisconnectFromPeer: peerID.displayName)

            case .connecting:
                self.delegate?.transport(self, isConnectingToPeer: peerID.displayName, displayName: displayName)

            @unknown default:
                break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.transport(self, didReceiveData: data, fromPeer: peerID.displayName)
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

extension MultipeerTransport: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Accept invitations if we have room
        if session.connectedPeers.count < maxPlayers - 1 {
            peerDisplayNames[peerID.displayName] = peerID.displayName
            invitationHandler(true, session)
        } else {
            invitationHandler(false, nil)
        }
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Error starting advertising: \(error.localizedDescription)")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.transport(self, didChangeState: .disconnected)
            self.delegate?.transport(self, didEncounterError: error)
        }
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultipeerTransport: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if !discoveredPeers.contains(where: { $0.displayName == peerID.displayName }) {
            discoveredPeers.append(peerID)
        }
        peerDisplayNames[peerID.displayName] = peerID.displayName

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.transport(self, didFindPeer: peerID.displayName, displayName: peerID.displayName)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        discoveredPeers.removeAll { $0.displayName == peerID.displayName }
        peerDisplayNames.removeValue(forKey: peerID.displayName)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.transport(self, didLosePeer: peerID.displayName)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Error starting browsing: \(error.localizedDescription)")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.transport(self, didChangeState: .disconnected)
            self.delegate?.transport(self, didEncounterError: error)
        }
    }
}
