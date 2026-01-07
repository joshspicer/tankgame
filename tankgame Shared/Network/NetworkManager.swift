//
//  NetworkManager.swift
//  tankgame Shared
//
//  Network manager protocol
//

import Foundation

/// Protocol for network communication
protocol NetworkManager: AnyObject {
    var delegate: NetworkManagerDelegate? { get set }
    var isHost: Bool { get set }
    var localPlayerId: String { get }
    var connectedPlayerIds: [String] { get }
    
    func startHosting(playerName: String, maxPlayers: Int)
    func startBrowsing(playerName: String)
    func stopHosting()
    func stopBrowsing()
    func disconnect()
    
    func sendMessage(_ message: NetworkMessage, to playerIds: [String]?, reliably: Bool)
    func sendMessageToAll(_ message: NetworkMessage, reliably: Bool)
}

/// Delegate protocol for network events
protocol NetworkManagerDelegate: AnyObject {
    func networkManager(_ manager: NetworkManager, playerJoined playerId: String, playerName: String)
    func networkManager(_ manager: NetworkManager, playerLeft playerId: String)
    func networkManager(_ manager: NetworkManager, didReceiveMessage message: NetworkMessage, from playerId: String)
    func networkManager(_ manager: NetworkManager, didFailWithError error: Error)
}
