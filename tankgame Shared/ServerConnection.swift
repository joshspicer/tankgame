//
//  ServerConnection.swift
//  Tank Game
//
//  WebSocket client for connecting to the Modal game server.
//

import Foundation

/// Delegate protocol for server connection events
protocol ServerConnectionDelegate: AnyObject {
    func serverDidConnect(_ connection: ServerConnection)
    func serverDidDisconnect(_ connection: ServerConnection)
    func server(_ connection: ServerConnection, didReceive message: ServerMessage)
    func server(_ connection: ServerConnection, didEncounterError error: Error)
}

/// WebSocket connection to the Modal game server
final class ServerConnection: NSObject {

    weak var delegate: ServerConnectionDelegate?

    /// The player ID assigned by the server upon joining
    private(set) var playerId: String?

    /// Whether we are currently connected
    private(set) var isConnected: Bool = false

    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession!
    private let serverURL: URL
    private let displayName: String

    /// Reconnect state
    private var reconnectAttempts: Int = 0
    private let maxReconnectAttempts: Int = 10
    private var reconnectTimer: Timer?
    private var shouldReconnect: Bool = true

    init(serverURL: URL = ServerConfig.serverURL, displayName: String = "Player") {
        self.serverURL = serverURL
        self.displayName = displayName
        super.init()
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }

    // MARK: - Connection

    /// Connect to the game server
    func connect() {
        guard webSocketTask == nil else { return }
        shouldReconnect = true
        reconnectAttempts = 0

        NSLog("[ServerConnection] Connecting to %@", serverURL.absoluteString)
        webSocketTask = session.webSocketTask(with: serverURL)
        webSocketTask?.resume()
    }

    /// Disconnect from the server
    func disconnect() {
        shouldReconnect = false
        reconnectTimer?.invalidate()
        reconnectTimer = nil

        if isConnected {
            sendMessage(.leave)
        }

        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
        playerId = nil
    }

    // MARK: - Sending

    /// Send a client message to the server
    func sendMessage(_ message: ClientMessage) {
        guard let task = webSocketTask else { return }

        do {
            let data = try JSONEncoder().encode(message)
            guard let text = String(data: data, encoding: .utf8) else { return }
            task.send(.string(text)) { [weak self] error in
                if let error = error {
                    NSLog("[ServerConnection] Send error: %@", error.localizedDescription)
                    self?.handleConnectionLost()
                }
            }
        } catch {
            NSLog("[ServerConnection] Encode error: %@", error.localizedDescription)
        }
    }

    /// Convenience: send a move input
    func sendMove(direction: Direction) {
        sendMessage(.move(direction: direction.rawValue))
    }

    /// Convenience: send a shoot input
    func sendShoot() {
        sendMessage(.shoot)
    }

    // MARK: - Receiving

    private func receiveLoop() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleServerMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.handleServerMessage(text)
                    }
                @unknown default:
                    break
                }
                // Continue receiving
                self.receiveLoop()

            case .failure(let error):
                NSLog("[ServerConnection] Receive error: %@", error.localizedDescription)
                self.handleConnectionLost()
            }
        }
    }

    private func handleServerMessage(_ raw: String) {
        let message = ServerMessage.parse(raw)

        // Handle welcome specially to capture playerId
        if case .welcome(let pid, _) = message {
            self.playerId = pid
            NSLog("[ServerConnection] Assigned player ID: %@", String(pid.prefix(8)))
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.server(self, didReceive: message)
        }
    }

    // MARK: - Reconnection

    private func handleConnectionLost() {
        let wasConnected = isConnected
        webSocketTask = nil
        isConnected = false
        playerId = nil

        if wasConnected {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.serverDidDisconnect(self)
            }
        }

        attemptReconnect()
    }

    private func attemptReconnect() {
        guard shouldReconnect, reconnectAttempts < maxReconnectAttempts else {
            NSLog("[ServerConnection] Giving up reconnection after %d attempts", reconnectAttempts)
            return
        }

        reconnectAttempts += 1
        let delay = min(pow(2.0, Double(reconnectAttempts - 1)), 30.0)
        NSLog("[ServerConnection] Reconnecting in %.1f seconds (attempt %d/%d)", delay, reconnectAttempts, maxReconnectAttempts)

        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            guard let self = self, self.shouldReconnect else { return }
            self.webSocketTask = self.session.webSocketTask(with: self.serverURL)
            self.webSocketTask?.resume()
        }
    }

    private func onConnectionEstablished() {
        isConnected = true
        reconnectAttempts = 0

        NSLog("[ServerConnection] Connected, sending join")
        sendMessage(.join(displayName: displayName))
        receiveLoop()

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.serverDidConnect(self)
        }
    }
}

// MARK: - URLSessionWebSocketDelegate

extension ServerConnection: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        NSLog("[ServerConnection] WebSocket opened")
        onConnectionEstablished()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        NSLog("[ServerConnection] WebSocket closed (code: %d)", closeCode.rawValue)
        handleConnectionLost()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            NSLog("[ServerConnection] Connection error: %@", error.localizedDescription)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.server(self, didEncounterError: error)
            }
            handleConnectionLost()
        }
    }
}
