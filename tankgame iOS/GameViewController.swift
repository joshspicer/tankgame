//
//  GameViewController.swift
//  Tank Game iOS
//
//  Main view controller with lobby UI and game presentation.
//

import UIKit
import SpriteKit
import MultipeerConnectivity

class GameViewController: UIViewController {
    
    // MARK: - Properties
    
    private var network: Network!
    private var gameScene: GameScene?
    private var game: Game?
    private var skView: SKView?
    
    // Lobby state
    private var discoveredPeers: [MCPeerID] = []
    private var isHost = false
    private var playerAssignments: [String: Int] = [:]
    private var readyPlayers: Set<Int> = []
    
    // UI Elements
    private var menuBackgroundView: MenuBackgroundView!
    private var titleLabel: UILabel!
    private var statusLabel: UILabel!
    private var hostButton: UIButton!
    private var joinButton: UIButton!
    private var startButton: UIButton!
    private var cancelButton: UIButton!
    private var peerTableView: UITableView!
    private var lobbyContainer: UIView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        
        network = Network()
        network.delegate = self
        
        setupLobbyUI()
    }
    
    // MARK: - Lobby UI Setup
    
    private func setupLobbyUI() {
        lobbyContainer = UIView()
        lobbyContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lobbyContainer)
        
        NSLayoutConstraint.activate([
            lobbyContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            lobbyContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lobbyContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lobbyContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Animated background
        menuBackgroundView = MenuBackgroundView()
        menuBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        lobbyContainer.addSubview(menuBackgroundView)
        
        NSLayoutConstraint.activate([
            menuBackgroundView.topAnchor.constraint(equalTo: lobbyContainer.topAnchor),
            menuBackgroundView.leadingAnchor.constraint(equalTo: lobbyContainer.leadingAnchor),
            menuBackgroundView.trailingAnchor.constraint(equalTo: lobbyContainer.trailingAnchor),
            menuBackgroundView.bottomAnchor.constraint(equalTo: lobbyContainer.bottomAnchor)
        ])
        
        // Title
        titleLabel = UILabel()
        titleLabel.text = "TANK BATTLE"
        titleLabel.font = .systemFont(ofSize: 36, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subtle 8-bit style shadow effect
        titleLabel.layer.shadowColor = UIColor.white.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        titleLabel.layer.shadowOpacity = 0.3
        titleLabel.layer.shadowRadius = 0
        
        lobbyContainer.addSubview(titleLabel)
        
        // Status
        statusLabel = UILabel()
        statusLabel.text = "Choose an option to start"
        statusLabel.font = .systemFont(ofSize: 16)
        statusLabel.textColor = .lightGray
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyContainer.addSubview(statusLabel)
        
        // Buttons
        hostButton = makeButton(systemName: "antenna.radiowaves.left.and.right", color: UIColor(white: 0.35, alpha: 1))
        hostButton.addTarget(self, action: #selector(hostTapped), for: .touchUpInside)

        joinButton = makeButton(systemName: "person.badge.plus", color: UIColor(white: 0.35, alpha: 1))
        joinButton.addTarget(self, action: #selector(joinTapped), for: .touchUpInside)

        startButton = makeButton(systemName: "play.fill", color: UIColor(white: 0.35, alpha: 1))
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        startButton.isHidden = true

        cancelButton = makeButton(systemName: "xmark", color: UIColor(white: 0.28, alpha: 1))
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.isHidden = true
        
        // Peer table
        peerTableView = UITableView()
        peerTableView.backgroundColor = UIColor(white: 0.15, alpha: 0.9)
        peerTableView.delegate = self
        peerTableView.dataSource = self
        peerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PeerCell")
        peerTableView.layer.cornerRadius = 4
        peerTableView.layer.borderWidth = 1
        peerTableView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        peerTableView.isHidden = true
        peerTableView.translatesAutoresizingMaskIntoConstraints = false
        lobbyContainer.addSubview(peerTableView)
        
        // Layout
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: lobbyContainer.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: lobbyContainer.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            statusLabel.centerXAnchor.constraint(equalTo: lobbyContainer.centerXAnchor),
            
            hostButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 40),
            hostButton.centerXAnchor.constraint(equalTo: lobbyContainer.centerXAnchor),
            hostButton.widthAnchor.constraint(equalToConstant: 200),
            hostButton.heightAnchor.constraint(equalToConstant: 50),
            
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 16),
            joinButton.centerXAnchor.constraint(equalTo: lobbyContainer.centerXAnchor),
            joinButton.widthAnchor.constraint(equalToConstant: 200),
            joinButton.heightAnchor.constraint(equalToConstant: 50),
            
            peerTableView.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 24),
            peerTableView.leadingAnchor.constraint(equalTo: lobbyContainer.leadingAnchor, constant: 40),
            peerTableView.trailingAnchor.constraint(equalTo: lobbyContainer.trailingAnchor, constant: -40),
            peerTableView.heightAnchor.constraint(equalToConstant: 200),
            
            startButton.topAnchor.constraint(equalTo: peerTableView.bottomAnchor, constant: 24),
            startButton.centerXAnchor.constraint(equalTo: lobbyContainer.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            cancelButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: lobbyContainer.centerXAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 200),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    private func makeButton(systemName: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)

        // Create a larger icon without text
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let image = UIImage(systemName: systemName, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white

        button.backgroundColor = color
        button.layer.cornerRadius = 4

        // Minimal border for retro aesthetic
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor

        button.translatesAutoresizingMaskIntoConstraints = false
        lobbyContainer.addSubview(button)
        return button
    }
    
    // MARK: - Button Actions
    
    @objc private func hostTapped() {
        isHost = true
        network.startHosting()
        statusLabel.text = "Waiting for players..."
        hostButton.isHidden = true
        joinButton.isHidden = true
        peerTableView.isHidden = false
        startButton.isHidden = false
        cancelButton.isHidden = false
        startButton.isEnabled = false
        startButton.alpha = 0.5
    }
    
    @objc private func joinTapped() {
        isHost = false
        network.startBrowsing()
        statusLabel.text = "Looking for games..."
        hostButton.isHidden = true
        joinButton.isHidden = true
        peerTableView.isHidden = false
        cancelButton.isHidden = false
    }
    
    @objc private func startTapped() {
        guard isHost else { return }
        
        // Create player assignments
        let allPlayers = network.allPlayerNames
        playerAssignments = [:]
        for (i, name) in allPlayers.enumerated() {
            playerAssignments[name] = i
        }
        
        let seed = UInt32.random(in: 0...UInt32.max)
        let playerCount = allPlayers.count
        let localIndex = playerAssignments[network.myName] ?? 0
        
        // Send round start to all clients
        network.send(.roundStart(seed: seed, playerCount: playerCount, playerAssignments: playerAssignments))
        
        // Start the game
        startGame(seed: seed, playerCount: playerCount, localIndex: localIndex)
    }
    
    @objc private func cancelTapped() {
        network.disconnect()
        resetLobby()
    }
    
    private func resetLobby() {
        discoveredPeers.removeAll()
        peerTableView.reloadData()
        
        statusLabel.text = "Choose an option to start"
        hostButton.isHidden = false
        joinButton.isHidden = false
        peerTableView.isHidden = true
        startButton.isHidden = true
        cancelButton.isHidden = true
    }
    
    // MARK: - Game Presentation
    
    private func startGame(seed: UInt32, playerCount: Int, localIndex: Int) {
        game = Game(seed: seed, playerCount: playerCount, localPlayerIndex: localIndex)
        readyPlayers.removeAll()
        
        // Create SpriteKit view
        let skView = SKView(frame: view.bounds)
        skView.ignoresSiblingOrder = true
        self.skView = skView
        
        let scene = GameScene.newScene()
        scene.gameDelegate = self
        scene.game = game
        self.gameScene = scene
        
        // Transition to game
        lobbyContainer.isHidden = true
        view.insertSubview(skView, at: 0)
        skView.presentScene(scene)
    }
    
    private func returnToLobby() {
        skView?.removeFromSuperview()
        skView = nil
        gameScene = nil
        game = nil
        lobbyContainer.isHidden = false
        resetLobby()
    }
    
    // MARK: - View Configuration
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        UIDevice.current.userInterfaceIdiom == .phone ? .portrait : .all
    }
    
    override var prefersStatusBarHidden: Bool { true }
}

// MARK: - NetworkDelegate

extension GameViewController: NetworkDelegate {
    func network(_ network: Network, foundPeer peer: MCPeerID) {
        if !discoveredPeers.contains(where: { $0.displayName == peer.displayName }) {
            discoveredPeers.append(peer)
            peerTableView.reloadData()
        }
    }
    
    func network(_ network: Network, lostPeer peer: MCPeerID) {
        discoveredPeers.removeAll { $0.displayName == peer.displayName }
        peerTableView.reloadData()
    }
    
    func network(_ network: Network, connectedTo peer: MCPeerID) {
        statusLabel.text = "Connected: \(network.connectedCount) players"
        startButton.isEnabled = network.connectedCount >= 2
        startButton.alpha = startButton.isEnabled ? 1.0 : 0.5
        peerTableView.reloadData()
    }
    
    func network(_ network: Network, disconnectedFrom peer: MCPeerID) {
        statusLabel.text = network.isConnected ? "Connected: \(network.connectedCount) players" : "Disconnected"
        startButton.isEnabled = network.connectedCount >= 2
        startButton.alpha = startButton.isEnabled ? 1.0 : 0.5
    }
    
    func network(_ network: Network, received message: GameMessage, from peer: MCPeerID) {
        switch message {
        case .roundStart(let seed, let playerCount, let assignments):
            playerAssignments = assignments
            let localIndex = assignments[network.myName] ?? 0
            
            // If already in game, reset instead of starting fresh
            if let game = game, let scene = gameScene {
                game.reset(seed: seed)
                scene.reset(with: game)
            } else {
                startGame(seed: seed, playerCount: playerCount, localIndex: localIndex)
            }
            
        case .move(let playerIndex, let row, let col, let direction):
            guard let game = game, playerIndex < game.tanks.count else { return }
            game.tanks[playerIndex].row = row
            game.tanks[playerIndex].col = col
            game.tanks[playerIndex].direction = direction
            gameScene?.renderTanksSmooth()
            
        case .shoot(let playerIndex, var projectile):
            guard let game = game else { return }
            projectile.ownerIndex = playerIndex
            game.projectiles.append(projectile)
            gameScene?.renderProjectiles()
            
        case .hit(let playerIndex):
            guard let game = game, playerIndex < game.tanks.count else { return }
            game.tanks[playerIndex].isAlive = false
            gameScene?.renderTanksSmooth()
            
        case .ready(let playerIndex):
            readyPlayers.insert(playerIndex)
            if isHost && readyPlayers.count >= network.connectedCount {
                // All ready, start next round
                let seed = UInt32.random(in: 0...UInt32.max)
                network.send(.roundStart(seed: seed, playerCount: game?.playerCount ?? 2, playerAssignments: playerAssignments))
                game?.reset(seed: seed)
                gameScene?.reset(with: game!)
                readyPlayers.removeAll()
            }
        }
    }
}

// MARK: - GameSceneDelegate

extension GameViewController: GameSceneDelegate {
    func gameScene(_ scene: GameScene, playerMoved direction: Direction) {
        guard let game = game else { return }
        let tank = game.localTank
        network.send(.move(playerIndex: game.localPlayerIndex, row: tank.row, col: tank.col, direction: tank.direction))
    }
    
    func gameScene(_ scene: GameScene, playerShot projectile: Projectile) {
        guard let game = game else { return }
        game.projectiles.append(projectile)
        scene.renderProjectiles()
        network.send(.shoot(playerIndex: game.localPlayerIndex, projectile: projectile))
    }
    
    func gameScene(_ scene: GameScene, playerHit index: Int) {
        network.send(.hit(playerIndex: index))
    }
    
    func gameSceneRoundEnded(_ scene: GameScene, winner: Int?) {
        // Wait for tap to signal ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self, let game = self.game else { return }
            
            if self.isHost {
                // Host: start next round after delay
                let seed = UInt32.random(in: 0...UInt32.max)
                self.network.send(.roundStart(seed: seed, playerCount: game.playerCount, playerAssignments: self.playerAssignments))
                game.reset(seed: seed)
                scene.reset(with: game)
            } else {
                // Client: send ready
                self.network.send(.ready(playerIndex: game.localPlayerIndex))
                scene.showStatus("Waiting...", duration: 10)
            }
        }
    }
}

// MARK: - UITableViewDataSource & Delegate

extension GameViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isHost ? network.connectedCount : discoveredPeers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeerCell", for: indexPath)
        cell.backgroundColor = UIColor(white: 0.2, alpha: 1)
        cell.textLabel?.textColor = .white
        
        if isHost {
            let names = network.allPlayerNames
            if indexPath.row < names.count {
                let name = names[indexPath.row]
                cell.textLabel?.text = indexPath.row == 0 ? "\(name) (You)" : name
            }
        } else {
            if indexPath.row < discoveredPeers.count {
                cell.textLabel?.text = discoveredPeers[indexPath.row].displayName
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Join a host
        if !isHost && indexPath.row < discoveredPeers.count {
            let peer = discoveredPeers[indexPath.row]
            network.invite(peer)
            statusLabel.text = "Connecting to \(peer.displayName)..."
        }
    }
}
