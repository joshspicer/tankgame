//
//  CleanGameViewController.swift
//  tankgame iOS
//
//  Clean Architecture - Presentation Layer
//

import UIKit
import SpriteKit

/// Clean game view controller using new architecture
final class CleanGameViewController: UIViewController {
    
    // UI Components
    private var lobbyView: UIView!
    private var hostButton: UIButton!
    private var joinButton: UIButton!
    private var startButton: UIButton!
    private var statusLabel: UILabel!
    private var playersLabel: UILabel!
    
    // Game components
    private var coordinator: GameCoordinator!
    private var networkAdapter: BluetoothNetworkAdapter!
    private var renderer: GameRenderer!
    private var gameScene: CleanGameScene?
    
    // State
    private var localPlayerID: PlayerID!
    private var connectedPlayers: [PlayerEntity] = []
    private var isHost: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize components
        localPlayerID = PlayerID()
        coordinator = GameCoordinator()
        renderer = SpriteKitGameRenderer()
        networkAdapter = BluetoothNetworkAdapter()
        networkAdapter.delegate = self
        coordinator.setNetworkAdapter(networkAdapter)
        
        // Setup UI
        setupLobbyUI()
        
        // Setup coordinator callbacks
        setupCoordinatorCallbacks()
    }
    
    private func setupLobbyUI() {
        view.backgroundColor = .black
        
        // Lobby view
        lobbyView = UIView()
        lobbyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lobbyView)
        
        // Status label
        statusLabel = UILabel()
        statusLabel.text = "Tank Game"
        statusLabel.textColor = .white
        statusLabel.textAlignment = .center
        statusLabel.font = .systemFont(ofSize: 32, weight: .bold)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(statusLabel)
        
        // Players label
        playersLabel = UILabel()
        playersLabel.text = "No players connected"
        playersLabel.textColor = .lightGray
        playersLabel.textAlignment = .center
        playersLabel.font = .systemFont(ofSize: 16)
        playersLabel.numberOfLines = 0
        playersLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(playersLabel)
        
        // Host button
        hostButton = createButton(title: "Host Game", action: #selector(hostTapped))
        lobbyView.addSubview(hostButton)
        
        // Join button
        joinButton = createButton(title: "Join Game", action: #selector(joinTapped))
        lobbyView.addSubview(joinButton)
        
        // Start button
        startButton = createButton(title: "Start Game", action: #selector(startTapped))
        startButton.isHidden = true
        lobbyView.addSubview(startButton)
        
        // Layout
        NSLayoutConstraint.activate([
            lobbyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lobbyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            lobbyView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            statusLabel.topAnchor.constraint(equalTo: lobbyView.topAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor),
            
            playersLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            playersLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor),
            playersLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor),
            
            hostButton.topAnchor.constraint(equalTo: playersLabel.bottomAnchor, constant: 40),
            hostButton.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor),
            hostButton.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor),
            hostButton.heightAnchor.constraint(equalToConstant: 50),
            
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 16),
            joinButton.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor),
            joinButton.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor),
            joinButton.heightAnchor.constraint(equalToConstant: 50),
            
            startButton.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 16),
            startButton.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor),
            startButton.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            lobbyView.bottomAnchor.constraint(equalTo: startButton.bottomAnchor)
        ])
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func setupCoordinatorCallbacks() {
        coordinator.onRoundEnd = { [weak self] winner in
            self?.handleRoundEnd(winner: winner)
        }
        
        coordinator.onGameOver = { [weak self] winner in
            self?.handleGameOver(winner: winner)
        }
    }
    
    // MARK: - Actions
    
    @objc private func hostTapped() {
        isHost = true
        networkAdapter.startHosting(displayName: UIDevice.current.name)
        
        // Add local player
        let localPlayer = PlayerEntity(id: localPlayerID, name: UIDevice.current.name, index: 0)
        connectedPlayers = [localPlayer]
        
        statusLabel.text = "Hosting..."
        hostButton.isHidden = true
        joinButton.isHidden = true
        startButton.isHidden = false
        
        updatePlayersLabel()
    }
    
    @objc private func joinTapped() {
        isHost = false
        networkAdapter.startBrowsing(displayName: UIDevice.current.name)
        
        statusLabel.text = "Looking for games..."
        hostButton.isHidden = true
        joinButton.isHidden = true
    }
    
    @objc private func startTapped() {
        guard isHost, connectedPlayers.count >= 2 else {
            showAlert(title: "Cannot Start", message: "Need at least 2 players to start")
            return
        }
        
        startGame()
    }
    
    private func startGame() {
        // Create session
        let result = coordinator.createSession(players: connectedPlayers, localPlayerID: localPlayerID)
        
        switch result {
        case .success:
            // Start first round
            _ = coordinator.startRound()
            
            // Show game scene
            showGameScene()
            
        case .failure(let error):
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    private func showGameScene() {
        // Hide lobby
        lobbyView.isHidden = true
        
        // Create and show game scene
        let skView = SKView(frame: view.bounds)
        skView.ignoresSiblingOrder = true
        view.addSubview(skView)
        
        let scene = CleanGameScene(
            size: CGSize(width: 600, height: 800),
            coordinator: coordinator,
            renderer: renderer
        )
        gameScene = scene
        skView.presentScene(scene)
    }
    
    private func handleRoundEnd(winner: PlayerEntity?) {
        let message = winner != nil ? "Player \(winner!.name) wins!" : "Draw!"
        showAlert(title: "Round Over", message: message) { [weak self] in
            // Start next round after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                _ = self?.coordinator.startRound()
            }
        }
    }
    
    private func handleGameOver(winner: PlayerEntity) {
        showAlert(title: "Game Over", message: "\(winner.name) wins the game!") { [weak self] in
            self?.returnToLobby()
        }
    }
    
    private func returnToLobby() {
        gameScene?.view?.removeFromSuperview()
        gameScene = nil
        lobbyView.isHidden = false
        
        // Reset state
        connectedPlayers.removeAll()
        hostButton.isHidden = false
        joinButton.isHidden = false
        startButton.isHidden = true
        statusLabel.text = "Tank Game"
        
        // Disconnect network
        networkAdapter.disconnect()
    }
    
    private func updatePlayersLabel() {
        if connectedPlayers.isEmpty {
            playersLabel.text = "No players connected"
        } else {
            let names = connectedPlayers.map { $0.name }.joined(separator: ", ")
            playersLabel.text = "Players: \(names)"
        }
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - NetworkAdapterDelegate
extension CleanGameViewController: NetworkAdapterDelegate {
    
    func networkAdapter(_ adapter: NetworkAdapter, didReceive message: NetworkMessage, from peerID: String) {
        // Handle network messages
        switch message {
        case .playerJoined(let player):
            if !connectedPlayers.contains(where: { $0.id == player.id }) {
                connectedPlayers.append(player)
                updatePlayersLabel()
            }
            
        case .playerLeft(let playerID):
            connectedPlayers.removeAll { $0.id == playerID }
            updatePlayersLabel()
            
        case .playerMove(let playerID, let direction, _):
            // Remote player movement
            coordinator.handleRemoteMove(playerID: playerID, direction: direction)
            
        case .playerFire(let playerID, let timestamp):
            // Remote player fire
            coordinator.handleRemoteFire(playerID: playerID, currentTime: timestamp)
            
        default:
            break
        }
    }
    
    func networkAdapter(_ adapter: NetworkAdapter, peerDidConnect peerID: String, displayName: String) {
        if isHost {
            // Send existing players to new peer
            for player in connectedPlayers {
                let message = NetworkMessage.playerJoined(player)
                try? adapter.send(message, to: [peerID])
            }
            
            // Add new player
            let newPlayer = PlayerEntity(id: PlayerID(), name: displayName, index: connectedPlayers.count)
            connectedPlayers.append(newPlayer)
            
            // Broadcast new player to all
            let message = NetworkMessage.playerJoined(newPlayer)
            try? adapter.broadcast(message)
            
            updatePlayersLabel()
        }
    }
    
    func networkAdapter(_ adapter: NetworkAdapter, peerDidDisconnect peerID: String) {
        // Handle disconnection
        connectedPlayers.removeAll { $0.name == peerID }
        updatePlayersLabel()
    }
    
    func networkAdapter(_ adapter: NetworkAdapter, didFailWithError error: Error) {
        print("Network error: \(error)")
    }
}
