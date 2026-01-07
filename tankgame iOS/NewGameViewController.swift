//
//  NewGameViewController.swift
//  tankgame iOS
//
//  Main view controller for the new tank game
//

import UIKit
import SpriteKit

/// Main view controller that manages lobby and game flow
final class NewGameViewController: UIViewController {
    
    // UI Components
    private var containerView: UIView!
    private var titleLabel: UILabel!
    private var hostButton: UIButton!
    private var joinButton: UIButton!
    private var startGameButton: UIButton!
    private var playersLabel: UILabel!
    private var statusLabel: UILabel!
    
    // Game components
    private var networkManager: NetworkManager!
    private var gameCoordinator: GameCoordinator?
    private var gameScene: TankGameScene?
    
    // State
    private var connectedPlayers: [PlayerInfo] = []
    private var localPlayer: PlayerInfo?
    private var isInGame = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNetworking()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Title
        titleLabel = UILabel()
        titleLabel.text = "Tank Game"
        titleLabel.font = .systemFont(ofSize: 36, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Host button
        hostButton = UIButton(type: .system)
        hostButton.setTitle("Host Game (2-6 players)", for: .normal)
        hostButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        hostButton.addTarget(self, action: #selector(hostButtonTapped), for: .touchUpInside)
        hostButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostButton)
        
        // Join button
        joinButton = UIButton(type: .system)
        joinButton.setTitle("Join Game", for: .normal)
        joinButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(joinButton)
        
        // Start game button (hidden initially)
        startGameButton = UIButton(type: .system)
        startGameButton.setTitle("Start Game", for: .normal)
        startGameButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        startGameButton.backgroundColor = .systemGreen
        startGameButton.setTitleColor(.white, for: .normal)
        startGameButton.layer.cornerRadius = 12
        startGameButton.addTarget(self, action: #selector(startGameButtonTapped), for: .touchUpInside)
        startGameButton.translatesAutoresizingMaskIntoConstraints = false
        startGameButton.isHidden = true
        view.addSubview(startGameButton)
        
        // Players label
        playersLabel = UILabel()
        playersLabel.text = "Waiting for players..."
        playersLabel.font = .systemFont(ofSize: 18)
        playersLabel.textAlignment = .center
        playersLabel.numberOfLines = 0
        playersLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playersLabel)
        
        // Status label
        statusLabel = UILabel()
        statusLabel.text = ""
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textAlignment = .center
        statusLabel.textColor = .secondaryLabel
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        // Layout
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            hostButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hostButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            hostButton.widthAnchor.constraint(equalToConstant: 280),
            hostButton.heightAnchor.constraint(equalToConstant: 50),
            
            joinButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 20),
            joinButton.widthAnchor.constraint(equalToConstant: 280),
            joinButton.heightAnchor.constraint(equalToConstant: 50),
            
            playersLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playersLabel.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 40),
            playersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            playersLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            startGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startGameButton.topAnchor.constraint(equalTo: playersLabel.bottomAnchor, constant: 30),
            startGameButton.widthAnchor.constraint(equalToConstant: 200),
            startGameButton.heightAnchor.constraint(equalToConstant: 60),
            
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupNetworking() {
        networkManager = BluetoothNetworkManager()
        networkManager.delegate = self
    }
    
    // MARK: - Actions
    
    @objc private func hostButtonTapped() {
        let localPlayerId = networkManager.localPlayerId
        let localPlayerName = UIDevice.current.name
        
        // Create local player as host (index 0)
        localPlayer = PlayerInfo(id: localPlayerId, name: localPlayerName, index: 0)
        connectedPlayers = [localPlayer!]
        
        networkManager.startHosting(playerName: localPlayerName, maxPlayers: 6)
        
        updateUI()
        statusLabel.text = "Hosting game. Waiting for players..."
        
        // Show start button for host
        startGameButton.isHidden = false
    }
    
    @objc private func joinButtonTapped() {
        let localPlayerId = networkManager.localPlayerId
        let localPlayerName = UIDevice.current.name
        
        networkManager.startBrowsing(playerName: localPlayerName)
        
        statusLabel.text = "Searching for games..."
        hostButton.isEnabled = false
        joinButton.isEnabled = false
    }
    
    @objc private func startGameButtonTapped() {
        guard networkManager.isHost else { return }
        guard connectedPlayers.count >= 2 else {
            statusLabel.text = "Need at least 2 players to start"
            return
        }
        
        startGame()
    }
    
    // MARK: - Game Flow
    
    private func startGame() {
        guard let localPlayer = localPlayer else { return }
        
        // Hide lobby UI
        hostButton.isHidden = true
        joinButton.isHidden = true
        startGameButton.isHidden = true
        playersLabel.isHidden = true
        titleLabel.isHidden = true
        
        // Create game components
        let engine = TankGameEngine(players: connectedPlayers)
        let coordinator = GameCoordinator(engine: engine, networkManager: networkManager)
        self.gameCoordinator = coordinator
        
        // Setup game scene
        let scene = TankGameScene(size: view.bounds.size)
        scene.scaleMode = .resizeFill
        scene.gameCoordinator = coordinator
        self.gameScene = scene
        
        // Create SKView
        let skView = SKView(frame: view.bounds)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        view.addSubview(skView)
        view.sendSubviewToBack(skView)
        
        // Present scene
        skView.presentScene(scene)
        
        // Start coordinator
        coordinator.startGame(asHost: networkManager.isHost, playerInfo: localPlayer)
        
        // If host, start first round
        if networkManager.isHost {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let seed = UInt32.random(in: 0...UInt32.max)
                coordinator.startRound(seed: seed)
            }
        }
        
        isInGame = true
        statusLabel.text = "Game started!"
    }
    
    private func updateUI() {
        let playerNames = connectedPlayers.map { $0.name }.joined(separator: "\n")
        playersLabel.text = "Players (\(connectedPlayers.count)):\n\(playerNames)"
    }
}

// MARK: - NetworkManagerDelegate

extension NewGameViewController: NetworkManagerDelegate {
    func networkManager(_ manager: NetworkManager, playerJoined playerId: String, playerName: String) {
        // Assign player index
        let playerIndex = connectedPlayers.count
        let player = PlayerInfo(id: playerId, name: playerName, index: playerIndex)
        connectedPlayers.append(player)
        
        updateUI()
        statusLabel.text = "\(playerName) joined!"
    }
    
    func networkManager(_ manager: NetworkManager, playerLeft playerId: String) {
        connectedPlayers.removeAll { $0.id == playerId }
        updateUI()
        statusLabel.text = "A player left"
    }
    
    func networkManager(_ manager: NetworkManager, didReceiveMessage message: NetworkMessage, from playerId: String) {
        gameCoordinator?.handleNetworkMessage(message, from: playerId)
        
        // Handle special cases
        switch message {
        case .gameStarting(let players, _):
            // Non-host received game start
            if !manager.isHost {
                self.connectedPlayers = players
                if let localId = manager.localPlayerId,
                   let localPlayer = players.first(where: { $0.id == localId }) {
                    self.localPlayer = localPlayer
                    DispatchQueue.main.async {
                        self.startGame()
                    }
                }
            }
        default:
            break
        }
    }
    
    func networkManager(_ manager: NetworkManager, didFailWithError error: Error) {
        statusLabel.text = "Error: \(error.localizedDescription)"
    }
}
