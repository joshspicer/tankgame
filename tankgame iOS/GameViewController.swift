//
//  GameViewController.swift
//  tankgame iOS
//
//  Main view controller that coordinates the game
//

import UIKit
import SpriteKit

/// Main view controller for the tank game
class GameViewController: UIViewController {
    
    // MARK: - Properties
    
    private var gameEngine: GameEngine!
    private var networkManager: NetworkManager!
    private var gameScene: GameScene?
    
    private var localPlayerId: String = ""
    private var isHost = false
    private var updateTimer: Timer?
    
    // UI Elements
    private var lobbyView: UIView!
    private var statusLabel: UILabel!
    private var hostButton: UIButton!
    private var joinButton: UIButton!
    private var startButton: UIButton!
    private var playerListLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize components
        gameEngine = GameEngine() // Uses default gridSize and maxPlayers
        networkManager = NetworkManager()
        networkManager.delegate = self
        localPlayerId = networkManager.myPeerIdString
        
        // Setup UI
        setupLobby()
    }
    
    // MARK: - Setup
    
    private func setupLobby() {
        // Lobby view
        lobbyView = UIView(frame: view.bounds)
        lobbyView.backgroundColor = .systemBackground
        view.addSubview(lobbyView)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Tank Game"
        titleLabel.font = .systemFont(ofSize: 40, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(titleLabel)
        
        // Status label
        statusLabel = UILabel()
        statusLabel.text = "Welcome!"
        statusLabel.font = .systemFont(ofSize: 18)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(statusLabel)
        
        // Player list
        playerListLabel = UILabel()
        playerListLabel.text = ""
        playerListLabel.font = .systemFont(ofSize: 16)
        playerListLabel.textAlignment = .center
        playerListLabel.numberOfLines = 0
        playerListLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(playerListLabel)
        
        // Host button
        hostButton = createButton(title: "Host Game", action: #selector(hostTapped))
        lobbyView.addSubview(hostButton)
        
        // Join button
        joinButton = createButton(title: "Join Game", action: #selector(joinTapped))
        lobbyView.addSubview(joinButton)
        
        // Start button
        startButton = createButton(title: "Start Game", action: #selector(startTapped))
        startButton.isHidden = true
        startButton.backgroundColor = .systemGreen
        lobbyView.addSubview(startButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: lobbyView.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            statusLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -20),
            
            playerListLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            playerListLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 20),
            playerListLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -20),
            
            hostButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            hostButton.centerYAnchor.constraint(equalTo: lobbyView.centerYAnchor, constant: -40),
            hostButton.widthAnchor.constraint(equalToConstant: 200),
            hostButton.heightAnchor.constraint(equalToConstant: 50),
            
            joinButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 20),
            joinButton.widthAnchor.constraint(equalToConstant: 200),
            joinButton.heightAnchor.constraint(equalToConstant: 50),
            
            startButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: lobbyView.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    // MARK: - Actions
    
    @objc private func hostTapped() {
        isHost = true
        networkManager.startHosting()
        statusLabel.text = "Hosting game...\nWaiting for players to join"
        hostButton.isHidden = true
        joinButton.isHidden = true
        startButton.isHidden = false
        updatePlayerList()
    }
    
    @objc private func joinTapped() {
        isHost = false
        networkManager.startBrowsing()
        statusLabel.text = "Looking for games..."
        hostButton.isHidden = true
        joinButton.isHidden = true
        updatePlayerList()
    }
    
    @objc private func startTapped() {
        guard isHost else { return }
        
        // Start game with all connected players
        var playerIds = networkManager.connectedPeers.map { $0.displayName }
        playerIds.insert(localPlayerId, at: 0)
        
        guard playerIds.count >= 2 else {
            statusLabel.text = "Need at least 2 players!"
            return
        }
        
        // Send game start message
        let message = NetworkMessage.gameStart(playerIds: playerIds, hostId: localPlayerId)
        networkManager.sendMessage(message)
        
        // Start local game
        startGame(playerIds: playerIds)
    }
    
    // MARK: - Game Management
    
    private func startGame(playerIds: [String]) {
        // Initialize game engine
        gameEngine.startGame(playerIds: playerIds)
        
        // Setup game scene
        let scene = GameScene(size: CGSize(width: 400, height: 700))
        scene.scaleMode = .aspectFill
        
        // Setup callbacks
        scene.onMove = { [weak self] direction in
            self?.handleMove(direction)
        }
        
        scene.onShoot = { [weak self] in
            self?.handleShoot()
        }
        
        // Render initial state
        scene.renderGrid(gameEngine.grid)
        scene.renderPlayers(gameEngine.getAllPlayers(), localPlayerId: localPlayerId)
        
        // Present scene
        let skView = SKView(frame: view.bounds)
        view.addSubview(skView)
        skView.presentScene(scene)
        
        self.gameScene = scene
        lobbyView.isHidden = true
        
        // Start update loop
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.gameUpdate()
        }
    }
    
    private func gameUpdate() {
        // Update game state
        gameEngine.update()
        
        // Send state to other players if host
        if isHost {
            let message = NetworkMessage.gameState(
                players: gameEngine.getAllPlayers(),
                projectiles: gameEngine.projectiles
            )
            networkManager.sendMessage(message, reliable: false)
        }
        
        // Render
        gameScene?.renderPlayers(gameEngine.getAllPlayers(), localPlayerId: localPlayerId)
        gameScene?.renderProjectiles(gameEngine.projectiles)
        
        // Check game over
        if let winnerId = gameEngine.checkGameOver() {
            handleGameOver(winnerId: winnerId)
        }
    }
    
    private func handleMove(_ direction: Direction) {
        let moved = gameEngine.movePlayer(id: localPlayerId, direction: direction)
        if moved {
            // Send move to other players
            let message = NetworkMessage.playerMove(playerId: localPlayerId, direction: direction)
            networkManager.sendMessage(message, reliable: false)
        }
    }
    
    private func handleShoot() {
        gameEngine.shootProjectile(playerId: localPlayerId)
        
        // Send shoot to other players
        let message = NetworkMessage.playerShoot(playerId: localPlayerId)
        networkManager.sendMessage(message)
    }
    
    private func handleGameOver(winnerId: String?) {
        updateTimer?.invalidate()
        
        let message: String
        if let winnerId = winnerId {
            message = winnerId == localPlayerId ? "You Won! 🎉" : "\(winnerId) Won!"
        } else {
            message = "Draw!"
        }
        
        let alert = UIAlertController(title: "Game Over", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.returnToLobby()
        })
        present(alert, animated: true)
    }
    
    private func returnToLobby() {
        gameScene?.view?.removeFromSuperview()
        gameScene = nil
        lobbyView.isHidden = false
        hostButton.isHidden = false
        joinButton.isHidden = false
        startButton.isHidden = true
        statusLabel.text = "Welcome!"
        networkManager.stop()
    }
    
    private func updatePlayerList() {
        let peers = networkManager.connectedPeers.map { $0.displayName }
        var players = [localPlayerId] + peers
        
        playerListLabel.text = "Players (\(players.count)):\n" + players.joined(separator: "\n")
    }
    
    // MARK: - Orientation
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - NetworkManagerDelegate

extension GameViewController: NetworkManagerDelegate {
    
    func networkManager(_ manager: NetworkManager, didReceiveMessage message: NetworkMessage, from peerId: String) {
        switch message {
        case .playerMove(let playerId, let direction):
            _ = gameEngine.movePlayer(id: playerId, direction: direction)
            
        case .playerShoot(let playerId):
            gameEngine.shootProjectile(playerId: playerId)
            
        case .gameState(let players, let projectiles):
            // Update from host (if not host)
            if !isHost {
                for player in players {
                    // Update player positions from host
                    // TODO: Implement state sync
                }
            }
            
        case .gameStart(let playerIds, _):
            // Start game as client
            if !isHost {
                startGame(playerIds: playerIds)
            }
            
        case .gameOver(let winnerId):
            handleGameOver(winnerId: winnerId)
        }
    }
    
    func networkManager(_ manager: NetworkManager, didConnectPeer peerId: String) {
        statusLabel.text = "Connected to \(peerId)"
        updatePlayerList()
    }
    
    func networkManager(_ manager: NetworkManager, didDisconnectPeer peerId: String) {
        updatePlayerList()
    }
    
    func networkManager(_ manager: NetworkManager, foundPeers: [String]) {
        updatePlayerList()
    }
}
