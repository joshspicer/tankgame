//
//  InternetMultiplayerManager.swift
//  tankgame Shared
//
//  Internet multiplayer using WebSockets
//

import Foundation

protocol InternetMultiplayerManagerDelegate: AnyObject {
    func internetMultiplayerManager(_ manager: InternetMultiplayerManager, didConnect: Bool)
    func internetMultiplayerManager(_ manager: InternetMultiplayerManager, didReceiveMessage message: GameMessage)
    func internetMultiplayerManager(_ manager: InternetMultiplayerManager, didDisconnect: Bool)
    func internetMultiplayerManager(_ manager: InternetMultiplayerManager, didEncounterError error: Error)
}

class InternetMultiplayerManager: NSObject {
    weak var delegate: InternetMultiplayerManagerDelegate?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var isConnected = false
    private var passphrase: String?
    
    // MARK: - Connection
    
    func connect(to serverURL: String, passphrase: String) {
        self.passphrase = passphrase
        
        guard let url = URL(string: serverURL) else {
            delegate?.internetMultiplayerManager(self, didEncounterError: NSError(domain: "Invalid URL", code: -1))
            return
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // Start receiving messages
        receiveMessage()
        
        // Send join message
        let joinMessage: [String: Any] = [
            "type": "join",
            "passphrase": passphrase
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: joinMessage)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                sendRawMessage(jsonString)
            }
        } catch {
            delegate?.internetMultiplayerManager(self, didEncounterError: error)
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
    }
    
    // MARK: - Messaging
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleReceivedMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.handleReceivedMessage(text)
                    }
                @unknown default:
                    break
                }
                
                // Continue receiving
                self.receiveMessage()
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.internetMultiplayerManager(self, didEncounterError: error)
                    self.isConnected = false
                    self.delegate?.internetMultiplayerManager(self, didDisconnect: true)
                }
            }
        }
    }
    
    private func handleReceivedMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let messageType = json["type"] as? String ?? ""
                
                switch messageType {
                case "joined":
                    // Successfully joined lobby
                    print("Joined lobby: \(json)")
                    
                case "ready":
                    // Opponent found, game can start
                    DispatchQueue.main.async {
                        self.isConnected = true
                        self.delegate?.internetMultiplayerManager(self, didConnect: true)
                    }
                    
                case "error":
                    let errorMessage = json["message"] as? String ?? "Unknown error"
                    let error = NSError(domain: "ServerError", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    DispatchQueue.main.async {
                        self.delegate?.internetMultiplayerManager(self, didEncounterError: error)
                    }
                    
                case "opponentDisconnected":
                    DispatchQueue.main.async {
                        self.isConnected = false
                        self.delegate?.internetMultiplayerManager(self, didDisconnect: true)
                    }
                    
                default:
                    // Try to decode as GameMessage
                    if let gameMessage = try? JSONDecoder().decode(GameMessage.self, from: data) {
                        DispatchQueue.main.async {
                            self.delegate?.internetMultiplayerManager(self, didReceiveMessage: gameMessage)
                        }
                    }
                }
            }
        } catch {
            print("Error parsing message: \(error)")
        }
    }
    
    private func sendRawMessage(_ message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("Error sending message: \(error)")
            }
        }
    }
    
    func sendMessage(_ message: GameMessage) {
        guard isConnected else { return }
        
        do {
            let data = try JSONEncoder().encode(message)
            if let jsonString = String(data: data, encoding: .utf8) {
                sendRawMessage(jsonString)
            }
        } catch {
            print("Error encoding message: \(error)")
        }
    }
}

// MARK: - URLSessionWebSocketDelegate

extension InternetMultiplayerManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connected")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket disconnected")
        DispatchQueue.main.async {
            self.isConnected = false
            self.delegate?.internetMultiplayerManager(self, didDisconnect: true)
        }
    }
}
