//
//  WiFiMultiplayerManager.swift
//  tankgame Shared
//
//  Handles WiFi-based multiplayer using Network framework for direct TCP/IP connections
//

import Foundation
import Network

/// Protocol for WiFi multiplayer events
protocol WiFiMultiplayerManagerDelegate: AnyObject {
    func wifiManager(_ manager: WiFiMultiplayerManager, didUpdateConnectionState state: WiFiMultiplayerManager.ConnectionState)
    func wifiManager(_ manager: WiFiMultiplayerManager, didFindHost hostInfo: WiFiMultiplayerManager.HostInfo)
    func wifiManager(_ manager: WiFiMultiplayerManager, didLoseHost hostInfo: WiFiMultiplayerManager.HostInfo)
    func wifiManager(_ manager: WiFiMultiplayerManager, didConnectToPeer peerName: String)
    func wifiManager(_ manager: WiFiMultiplayerManager, didDisconnectFromPeer peerName: String)
    func wifiManager(_ manager: WiFiMultiplayerManager, didReceiveMessage message: GameMessage, from peerName: String)
    func wifiManager(_ manager: WiFiMultiplayerManager, didEncounterError error: Error)
}

/// Manages WiFi-based multiplayer connections using Network framework
class WiFiMultiplayerManager {
    
    // MARK: - Types
    
    enum ConnectionState {
        case disconnected
        case hosting(roomCode: String)
        case browsing
        case connecting
        case connected
    }
    
    struct HostInfo: Equatable {
        let name: String
        let roomCode: String
        let endpoint: NWEndpoint
        
        static func == (lhs: HostInfo, rhs: HostInfo) -> Bool {
            return lhs.roomCode == rhs.roomCode
        }
    }
    
    enum WiFiError: LocalizedError {
        case invalidRoomCode
        case connectionFailed
        case hostNotFound
        case alreadyHosting
        case alreadyConnected
        case encodingError
        case decodingError
        
        var errorDescription: String? {
            switch self {
            case .invalidRoomCode: return "Invalid room code"
            case .connectionFailed: return "Failed to connect"
            case .hostNotFound: return "Host not found"
            case .alreadyHosting: return "Already hosting a game"
            case .alreadyConnected: return "Already connected"
            case .encodingError: return "Failed to encode message"
            case .decodingError: return "Failed to decode message"
            }
        }
    }
    
    // MARK: - Properties
    
    weak var delegate: WiFiMultiplayerManagerDelegate?
    
    private(set) var connectionState: ConnectionState = .disconnected {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.wifiManager(self, didUpdateConnectionState: self.connectionState)
            }
        }
    }
    
    var isHost: Bool = false
    var maxPlayers: Int = 4
    
    private var listener: NWListener?
    private var browser: NWBrowser?
    private var connections: [NWConnection] = []
    private var hostConnection: NWConnection?
    private var roomCode: String?
    private var displayName: String
    
    private let queue = DispatchQueue(label: "com.tankgame.wifi", qos: .userInteractive)
    private let serviceType = "_tankgame._tcp"
    
    // Track connected peer names
    private var connectedPeerNames: [NWConnection: String] = [:]
    private var discoveredHosts: [String: HostInfo] = [:]
    
    // MARK: - Initialization
    
    init() {
        #if os(iOS)
        self.displayName = UIDevice.current.name
        #else
        self.displayName = Host.current().localizedName ?? "Player"
        #endif
    }
    
    // MARK: - Hosting
    
    func startHosting() {
        guard case .disconnected = connectionState else {
            delegate?.wifiManager(self, didEncounterError: WiFiError.alreadyHosting)
            return
        }
        
        isHost = true
        roomCode = RoomCodeGenerator.generateCode()
        
        do {
            // Create TCP listener with Bonjour advertising
            let parameters = NWParameters.tcp
            parameters.includePeerToPeer = true
            
            // Add TXT record with room code and host name
            let txtRecord = NWTXTRecord([
                "roomCode": roomCode!,
                "hostName": displayName
            ])
            
            listener = try NWListener(using: parameters)
            listener?.service = NWListener.Service(type: serviceType, txtRecord: txtRecord)
            
            listener?.stateUpdateHandler = { [weak self] state in
                self?.handleListenerState(state)
            }
            
            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleNewConnection(connection)
            }
            
            listener?.start(queue: queue)
            connectionState = .hosting(roomCode: roomCode!)
            
        } catch {
            delegate?.wifiManager(self, didEncounterError: error)
        }
    }
    
    func stopHosting() {
        listener?.cancel()
        listener = nil
        roomCode = nil
        isHost = false
        
        // Close all client connections
        for connection in connections {
            connection.cancel()
        }
        connections.removeAll()
        connectedPeerNames.removeAll()
        
        if case .hosting = connectionState {
            connectionState = .disconnected
        }
    }
    
    // MARK: - Browsing
    
    func startBrowsing() {
        guard case .disconnected = connectionState else { return }
        
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        
        browser = NWBrowser(for: .bonjour(type: serviceType, domain: nil), using: parameters)
        
        browser?.stateUpdateHandler = { [weak self] state in
            self?.handleBrowserState(state)
        }
        
        browser?.browseResultsChangedHandler = { [weak self] results, changes in
            self?.handleBrowseResults(results, changes: changes)
        }
        
        browser?.start(queue: queue)
        connectionState = .browsing
    }
    
    func stopBrowsing() {
        browser?.cancel()
        browser = nil
        discoveredHosts.removeAll()
        
        if case .browsing = connectionState {
            connectionState = .disconnected
        }
    }
    
    // MARK: - Joining
    
    func joinHost(_ hostInfo: HostInfo) {
        guard case .browsing = connectionState else { return }
        
        connectionState = .connecting
        stopBrowsing()
        
        let parameters = NWParameters.tcp
        parameters.includePeerToPeer = true
        
        hostConnection = NWConnection(to: hostInfo.endpoint, using: parameters)
        
        hostConnection?.stateUpdateHandler = { [weak self] state in
            self?.handleHostConnectionState(state, hostName: hostInfo.name)
        }
        
        hostConnection?.start(queue: queue)
    }
    
    // MARK: - Messaging
    
    func sendMessage(_ message: GameMessage) {
        do {
            let data = try JSONEncoder().encode(message)
            let lengthData = withUnsafeBytes(of: UInt32(data.count).bigEndian) { Data($0) }
            let frameData = lengthData + data
            
            if isHost {
                // Host sends to all connected clients
                for connection in connections {
                    connection.send(content: frameData, completion: .contentProcessed { [weak self] error in
                        if let error = error {
                            print("WiFi send error: \(error)")
                            self?.delegate?.wifiManager(self!, didEncounterError: error)
                        }
                    })
                }
            } else if let hostConn = hostConnection {
                // Client sends to host
                hostConn.send(content: frameData, completion: .contentProcessed { [weak self] error in
                    if let error = error {
                        print("WiFi send error: \(error)")
                        self?.delegate?.wifiManager(self!, didEncounterError: error)
                    }
                })
            }
        } catch {
            delegate?.wifiManager(self, didEncounterError: WiFiError.encodingError)
        }
    }
    
    // MARK: - Disconnection
    
    func disconnect() {
        stopHosting()
        stopBrowsing()
        
        hostConnection?.cancel()
        hostConnection = nil
        
        for connection in connections {
            connection.cancel()
        }
        connections.removeAll()
        connectedPeerNames.removeAll()
        discoveredHosts.removeAll()
        
        connectionState = .disconnected
    }
    
    var isConnected: Bool {
        if case .connected = connectionState { return true }
        if case .hosting = connectionState { return !connections.isEmpty }
        return false
    }
    
    var connectedPeersCount: Int {
        if isHost {
            return connections.count + 1 // +1 for host
        } else {
            return hostConnection != nil ? 2 : 1
        }
    }
    
    var allPlayerNames: [String] {
        if isHost {
            return [displayName] + connectedPeerNames.values
        } else {
            return [displayName]
        }
    }
    
    var currentRoomCode: String? {
        return roomCode
    }
    
    var foundHosts: [HostInfo] {
        return Array(discoveredHosts.values)
    }
    
    // MARK: - Private Handlers
    
    private func handleListenerState(_ state: NWListener.State) {
        switch state {
        case .ready:
            print("WiFi: Listener ready")
        case .failed(let error):
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.wifiManager(self, didEncounterError: error)
            }
            stopHosting()
        case .cancelled:
            break
        default:
            break
        }
    }
    
    private func handleNewConnection(_ connection: NWConnection) {
        guard connections.count < maxPlayers - 1 else {
            connection.cancel()
            return
        }
        
        connections.append(connection)
        
        connection.stateUpdateHandler = { [weak self] state in
            self?.handleClientConnectionState(state, connection: connection)
        }
        
        connection.start(queue: queue)
        startReceiving(on: connection)
    }
    
    private func handleClientConnectionState(_ state: NWConnection.State, connection: NWConnection) {
        switch state {
        case .ready:
            // Connection ready - client will send their name
            print("WiFi: Client connected")
        case .failed(let error):
            print("WiFi: Client connection failed: \(error)")
            removeConnection(connection)
        case .cancelled:
            removeConnection(connection)
        default:
            break
        }
    }
    
    private func handleHostConnectionState(_ state: NWConnection.State, hostName: String) {
        switch state {
        case .ready:
            connectionState = .connected
            startReceiving(on: hostConnection!)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.wifiManager(self, didConnectToPeer: hostName)
            }
        case .failed(let error):
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.wifiManager(self, didEncounterError: error)
            }
            disconnect()
        case .cancelled:
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.wifiManager(self, didDisconnectFromPeer: hostName)
            }
        default:
            break
        }
    }
    
    private func handleBrowserState(_ state: NWBrowser.State) {
        switch state {
        case .ready:
            print("WiFi: Browser ready")
        case .failed(let error):
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.wifiManager(self, didEncounterError: error)
            }
        default:
            break
        }
    }
    
    private func handleBrowseResults(_ results: Set<NWBrowser.Result>, changes: Set<NWBrowser.Result.Change>) {
        for change in changes {
            switch change {
            case .added(let result):
                if case .service(let name, let type, _, _) = result.endpoint {
                    // Extract TXT record data
                    var roomCode = ""
                    var hostName = name
                    
                    if case .bonjour(let txtRecord) = result.metadata {
                        roomCode = txtRecord.dictionary["roomCode"] ?? ""
                        hostName = txtRecord.dictionary["hostName"] ?? name
                    }
                    
                    let hostInfo = HostInfo(name: hostName, roomCode: roomCode, endpoint: result.endpoint)
                    discoveredHosts[roomCode] = hostInfo
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.wifiManager(self, didFindHost: hostInfo)
                    }
                }
            case .removed(let result):
                if case .service(_, _, _, _) = result.endpoint {
                    if case .bonjour(let txtRecord) = result.metadata {
                        let roomCode = txtRecord.dictionary["roomCode"] ?? ""
                        if let hostInfo = discoveredHosts.removeValue(forKey: roomCode) {
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                self.delegate?.wifiManager(self, didLoseHost: hostInfo)
                            }
                        }
                    }
                }
            default:
                break
            }
        }
    }
    
    private func startReceiving(on connection: NWConnection) {
        // Read the 4-byte length prefix first
        connection.receive(minimumIncompleteLength: 4, maximumLength: 4) { [weak self] content, _, isComplete, error in
            guard let self = self else { return }
            
            if let error = error {
                print("WiFi receive error: \(error)")
                return
            }
            
            guard let lengthData = content, lengthData.count == 4 else {
                if !isComplete {
                    self.startReceiving(on: connection)
                }
                return
            }
            
            let length = lengthData.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
            
            // Now read the actual message
            connection.receive(minimumIncompleteLength: Int(length), maximumLength: Int(length)) { [weak self] messageData, _, isComplete, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("WiFi receive error: \(error)")
                    return
                }
                
                if let data = messageData {
                    self.handleReceivedData(data, from: connection)
                }
                
                if !isComplete {
                    self.startReceiving(on: connection)
                }
            }
        }
    }
    
    private func handleReceivedData(_ data: Data, from connection: NWConnection) {
        do {
            let message = try JSONDecoder().decode(GameMessage.self, from: data)
            
            // Extract peer name from connection or use a default
            let peerName = connectedPeerNames[connection] ?? "Player"
            
            // If host, forward message to other clients
            if isHost {
                for otherConnection in connections where otherConnection !== connection {
                    let lengthData = withUnsafeBytes(of: UInt32(data.count).bigEndian) { Data($0) }
                    let frameData = lengthData + data
                    otherConnection.send(content: frameData, completion: .contentProcessed { _ in })
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.wifiManager(self, didReceiveMessage: message, from: peerName)
            }
        } catch {
            print("WiFi decode error: \(error)")
        }
    }
    
    private func removeConnection(_ connection: NWConnection) {
        if let index = connections.firstIndex(where: { $0 === connection }) {
            connections.remove(at: index)
            if let peerName = connectedPeerNames.removeValue(forKey: connection) {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.wifiManager(self, didDisconnectFromPeer: peerName)
                }
            }
        }
    }
}

// MARK: - TXT Record Extension

extension NWTXTRecord {
    var dictionary: [String: String] {
        var dict: [String: String] = [:]
        for (key, value) in self {
            if let stringValue = value {
                dict[key] = String(data: stringValue, encoding: .utf8)
            }
        }
        return dict
    }
}
