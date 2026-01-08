//
//  NetworkManager.swift
//  tankgame Shared
//
//  Protocol-oriented networking with Bluetooth

import Foundation
import MultipeerConnectivity

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Network protocol - Strategy pattern
protocol NetworkManagerProtocol: AnyObject {
    var delegate: NetworkManagerDelegate? { get set }
    func startHosting()
    func startBrowsing()
    func invite(_ peer: String)
    func send(_ message: NetworkMessage)
    func disconnect()
    var connectedPeers: [String] { get }
}

protocol NetworkManagerDelegate: AnyObject {
    func networkManager(_ manager: NetworkManagerProtocol, didDiscover peer: String)
    func networkManager(_ manager: NetworkManagerProtocol, didConnect peer: String)
    func networkManager(_ manager: NetworkManagerProtocol, didDisconnect peer: String)
    func networkManager(_ manager: NetworkManagerProtocol, didReceive message: NetworkMessage, from peer: String)
}

/// Bluetooth implementation
final class BluetoothNetworkManager: NSObject, NetworkManagerProtocol {

    weak var delegate: NetworkManagerDelegate?

    private let serviceType = "tankgame"
    private let peerID: MCPeerID
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private var discoveredPeers: [String: MCPeerID] = [:]

    override init() {
        // Persistent peer ID
        if let data = UserDefaults.standard.data(forKey: "peerID"),
           let saved = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data) {
            peerID = saved
        } else {
            #if os(iOS) || os(tvOS)
            let deviceName = UIDevice.current.name
            #elseif os(macOS)
            let deviceName = Host.current().localizedName ?? "Mac"
            #else
            let deviceName = "Device"
            #endif
            peerID = MCPeerID(displayName: deviceName)
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: peerID, requiringSecureCoding: true) {
                UserDefaults.standard.set(data, forKey: "peerID")
            }
        }

        super.init()
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
    }

    func startHosting() {
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func startBrowsing() {
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }

    func invite(_ peer: String) {
        guard let peerID = discoveredPeers[peer] else { return }
        browser?.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }

    func send(_ message: NetworkMessage) {
        guard !session.connectedPeers.isEmpty,
              let data = try? JSONEncoder().encode(message) else { return }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }

    func disconnect() {
        session.disconnect()
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        advertiser = nil
        browser = nil
        discoveredPeers.removeAll()
    }

    var connectedPeers: [String] {
        session.connectedPeers.map { $0.displayName }
    }
}

// MARK: - MCSessionDelegate
extension BluetoothNetworkManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.delegate?.networkManager(self, didConnect: peerID.displayName)
            case .notConnected:
                self.delegate?.networkManager(self, didDisconnect: peerID.displayName)
            case .connecting:
                break
            @unknown default:
                break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = try? JSONDecoder().decode(NetworkMessage.self, from: data) else { return }
        DispatchQueue.main.async {
            self.delegate?.networkManager(self, didReceive: message, from: peerID.displayName)
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension BluetoothNetworkManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(session.connectedPeers.count < 5, session)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Advertising error: \(error)")
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension BluetoothNetworkManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        discoveredPeers[peerID.displayName] = peerID
        DispatchQueue.main.async {
            self.delegate?.networkManager(self, didDiscover: peerID.displayName)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        discoveredPeers.removeValue(forKey: peerID.displayName)
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Browsing error: \(error)")
    }
}
