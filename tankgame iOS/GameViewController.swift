//
//  GameViewController.swift
//  tankgame iOS
//
//  Created by jospicer on 10/28/25.
//

import UIKit
import SpriteKit
import GameplayKit
import MultipeerConnectivity
import Network

class GameViewController: UIViewController {
    
    var multiplayerManager: MultiplayerManager!
    var gameScene: GameScene?
    var gameState: GameState?
    var skView: SKView?
    
    // Lobby UI
    var lobbyView: UIView!
    var hostButton: UIButton!
    var joinButton: UIButton!
    var cancelButton: UIButton!
    var startGameButton: UIButton!
    var peerTableView: UITableView!
    var connectedPlayersView: UIView!
    var connectedPlayersLabel: UILabel!
    var statusLabel: UILabel!
    var instructionsLabel: UILabel!
    var emptyStateLabel: UILabel!
    var activityIndicator: UIActivityIndicatorView!
    var discoveredPeers: [MCPeerID] = []
    
    // Multiplayer state
    var connectedPeers: [MCPeerID] = [] // Track connected peers
    var peerToPlayerIndex: [MCPeerID: Int] = [:] // Map peer to player index
    var readyPlayers: Set<Int> = [] // Track which players are ready for next round

    override func viewDidLoad() {
        super.viewDidLoad()
        
        multiplayerManager = MultiplayerManager()
        multiplayerManager.delegate = self
        
        setupLobby()
    }
    
    func setupLobby() {
        // Create lobby view
        lobbyView = UIView(frame: view.bounds)
        lobbyView.backgroundColor = .systemBackground
        view.addSubview(lobbyView)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "🎮 Tank Game"
        titleLabel.font = .systemFont(ofSize: 36, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(titleLabel)
        
        // Status label
        statusLabel = UILabel()
        statusLabel.text = "Choose an option to start"
        statusLabel.font = .systemFont(ofSize: 18, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.textColor = .secondaryLabel
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(statusLabel)
        
        // Instructions label
        instructionsLabel = UILabel()
        instructionsLabel.text = "Battle with 2-4 players on the same network!\nMove with the joystick, tap FIRE to shoot."
        instructionsLabel.font = .systemFont(ofSize: 14)
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textColor = .secondaryLabel
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(instructionsLabel)
        
        // Host button
        hostButton = UIButton(type: .system)
        hostButton.setTitle("🎯 Host Game", for: .normal)
        hostButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        hostButton.backgroundColor = .systemBlue
        hostButton.setTitleColor(.white, for: .normal)
        hostButton.layer.cornerRadius = 16
        hostButton.layer.shadowColor = UIColor.black.cgColor
        hostButton.layer.shadowOpacity = 0.2
        hostButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        hostButton.layer.shadowRadius = 4
        hostButton.translatesAutoresizingMaskIntoConstraints = false
        hostButton.addTarget(self, action: #selector(hostTapped), for: .touchUpInside)
        lobbyView.addSubview(hostButton)
        
        // Join button
        joinButton = UIButton(type: .system)
        joinButton.setTitle("🔍 Join Game", for: .normal)
        joinButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        joinButton.backgroundColor = .systemGreen
        joinButton.setTitleColor(.white, for: .normal)
        joinButton.layer.cornerRadius = 16
        joinButton.layer.shadowColor = UIColor.black.cgColor
        joinButton.layer.shadowOpacity = 0.2
        joinButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        joinButton.layer.shadowRadius = 4
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        joinButton.addTarget(self, action: #selector(joinTapped), for: .touchUpInside)
        lobbyView.addSubview(joinButton)
        
        // Cancel button
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.isHidden = true
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        lobbyView.addSubview(cancelButton)
        
        // Start Game button (for host)
        startGameButton = UIButton(type: .system)
        startGameButton.setTitle("🚀 Start Game", for: .normal)
        startGameButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        startGameButton.backgroundColor = .systemGreen
        startGameButton.setTitleColor(.white, for: .normal)
        startGameButton.layer.cornerRadius = 16
        startGameButton.isHidden = true
        startGameButton.translatesAutoresizingMaskIntoConstraints = false
        startGameButton.addTarget(self, action: #selector(startGameTapped), for: .touchUpInside)
        lobbyView.addSubview(startGameButton)
        
        // Connected players view
        connectedPlayersView = UIView()
        connectedPlayersView.backgroundColor = .secondarySystemBackground
        connectedPlayersView.layer.cornerRadius = 12
        connectedPlayersView.isHidden = true
        connectedPlayersView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(connectedPlayersView)
        
        connectedPlayersLabel = UILabel()
        connectedPlayersLabel.text = "Connected: 1/4"
        connectedPlayersLabel.font = .systemFont(ofSize: 16, weight: .medium)
        connectedPlayersLabel.textAlignment = .center
        connectedPlayersLabel.numberOfLines = 0
        connectedPlayersLabel.translatesAutoresizingMaskIntoConstraints = false
        connectedPlayersView.addSubview(connectedPlayersLabel)
        
        // Activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .systemBlue
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(activityIndicator)
        
        // Peer table view
        peerTableView = UITableView()
        peerTableView.isHidden = true
        peerTableView.delegate = self
        peerTableView.dataSource = self
        peerTableView.layer.cornerRadius = 12
        peerTableView.layer.borderWidth = 1
        peerTableView.layer.borderColor = UIColor.separator.cgColor
        peerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PeerCell")
        peerTableView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(peerTableView)
        
        // Empty state label
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "No nearby games found.\nMake sure the other device is hosting."
        emptyStateLabel.font = .systemFont(ofSize: 14)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(emptyStateLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: lobbyView.safeAreaLayoutGuide.topAnchor, constant: 80),
            titleLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            statusLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            instructionsLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
            instructionsLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            instructionsLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            hostButton.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 50),
            hostButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            hostButton.widthAnchor.constraint(equalToConstant: 240),
            hostButton.heightAnchor.constraint(equalToConstant: 56),
            
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 20),
            joinButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            joinButton.widthAnchor.constraint(equalToConstant: 240),
            joinButton.heightAnchor.constraint(equalToConstant: 56),
            
            cancelButton.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 20),
            cancelButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            connectedPlayersView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            connectedPlayersView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            connectedPlayersView.widthAnchor.constraint(equalToConstant: 280),
            connectedPlayersView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            connectedPlayersLabel.topAnchor.constraint(equalTo: connectedPlayersView.topAnchor, constant: 16),
            connectedPlayersLabel.leadingAnchor.constraint(equalTo: connectedPlayersView.leadingAnchor, constant: 16),
            connectedPlayersLabel.trailingAnchor.constraint(equalTo: connectedPlayersView.trailingAnchor, constant: -16),
            connectedPlayersLabel.bottomAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: -16),
            
            startGameButton.topAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: 20),
            startGameButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            startGameButton.widthAnchor.constraint(equalToConstant: 240),
            startGameButton.heightAnchor.constraint(equalToConstant: 56),
            
            activityIndicator.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            
            peerTableView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            peerTableView.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            peerTableView.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            peerTableView.heightAnchor.constraint(equalToConstant: 200),
            
            emptyStateLabel.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 40),
            emptyStateLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            emptyStateLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30)
        ])
    }
    
    @objc func hostTapped() {
        // Update UI first
        multiplayerManager.isHost = true
        hostButton.isHidden = true
        joinButton.isHidden = true
        instructionsLabel.isHidden = true
        cancelButton.isHidden = false
        connectedPlayersView.isHidden = false
        startGameButton.isHidden = false
        activityIndicator.startAnimating()
        statusLabel.text = "Hosting game...\nWaiting for players to join (2-4 players)"
        updateConnectedPlayersUI()
        
        // Start hosting - this will trigger the permission dialog if not already granted
        multiplayerManager.startHosting()
    }
    
    @objc func joinTapped() {
        // Update UI first
        hostButton.isHidden = true
        joinButton.isHidden = true
        instructionsLabel.isHidden = true
        cancelButton.isHidden = false
        activityIndicator.startAnimating()
        statusLabel.text = "Searching for nearby games..."
        peerTableView.isHidden = false
        updatePeerListUI()
        
        // Start browsing - this will trigger the permission dialog if not already granted
        multiplayerManager.startBrowsing()
    }
    
    @objc func cancelTapped() {
        // Stop any active connections
        multiplayerManager.stopHosting()
        multiplayerManager.stopBrowsing()
        discoveredPeers.removeAll()
        connectedPeers.removeAll()
        peerToPlayerIndex.removeAll()
        
        // Reset UI
        resetLobbyUI()
    }
    
    @objc func startGameTapped() {
        // Host can start game with 2-4 players
        let playerCount = connectedPeers.count + 1 // +1 for host
        
        if playerCount < 2 {
            let alert = UIAlertController(
                title: "Not Enough Players",
                message: "You need at least 2 players to start the game.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Assign player indices: host is always player 0
        peerToPlayerIndex.removeAll()
        var playerAssignments: [String: Int] = [:]
        playerAssignments[multiplayerManager.session.myPeerID.displayName] = 0
        
        for (index, peer) in connectedPeers.enumerated() {
            let playerIndex = index + 1
            peerToPlayerIndex[peer] = playerIndex
            playerAssignments[peer.displayName] = playerIndex
        }
        
        // Start the game
        startGame(playerCount: playerCount, localPlayerIndex: 0, playerAssignments: playerAssignments)
    }
    
    func updateConnectedPlayersUI() {
        let playerCount = connectedPeers.count + 1
        let playerNames = [multiplayerManager.session.myPeerID.displayName] + connectedPeers.map { $0.displayName }
        let namesText = playerNames.enumerated().map { "P\($0.offset + 1): \($0.element)" }.joined(separator: "\n")
        connectedPlayersLabel.text = "Connected Players (\(playerCount)/4):\n\n\(namesText)"
        
        // Enable start button only if we have 2+ players and are host
        if multiplayerManager.isHost {
            startGameButton.isEnabled = playerCount >= 2
            startGameButton.alpha = playerCount >= 2 ? 1.0 : 0.5
        }
    }
    
    func resetLobbyUI() {
        hostButton.isHidden = false
        joinButton.isHidden = false
        instructionsLabel.isHidden = false
        cancelButton.isHidden = true
        startGameButton.isHidden = true
        connectedPlayersView.isHidden = true
        peerTableView.isHidden = true
        emptyStateLabel.isHidden = true
        activityIndicator.stopAnimating()
        statusLabel.text = "Choose an option to start"
        peerTableView.reloadData()
        multiplayerManager.isHost = false
    }
    
    func updatePeerListUI() {
        if discoveredPeers.isEmpty {
            peerTableView.isHidden = true
            emptyStateLabel.isHidden = false
        } else {
            peerTableView.isHidden = false
            emptyStateLabel.isHidden = true
        }
    }
    
    // MARK: - Permission Handling
    
    func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Local Network Access Required",
            message: "Tank Game needs Local Network access to find and connect with nearby players.\n\nTo enable:\n1. Open Settings app\n2. Go to Privacy & Security → Local Network\n3. Find Tank Game and turn it ON\n4. Return here and try again",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func startGame(playerCount: Int, localPlayerIndex: Int, playerAssignments: [String: Int]) {
        // Hide lobby
        lobbyView.isHidden = true
        
        // Create SKView if needed
        if skView == nil {
            let newSKView = SKView(frame: view.bounds)
            newSKView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(newSKView, at: 0)
            skView = newSKView
        }
        
        // Generate initial seed (coin flip for fairness)
        let seed = UInt32.random(in: 0...UInt32.max)
        
        // Create game state
        gameState = GameState(seed: seed, playerCount: playerCount, localPlayerIndex: localPlayerIndex)
        
        // Send round start message to all peers
        multiplayerManager.sendMessage(.roundStart(seed: seed, playerCount: playerCount, hostPlayerIndex: localPlayerIndex, playerAssignments: playerAssignments))
        
        // Setup game scene
        let scene = GameScene.newGameScene()
        scene.startGame(with: gameState!)
        scene.onGameMessage = { [weak self] message in
            self?.handleGameMessage(message)
        }
        
        gameScene = scene
        
        // Present the scene
        skView?.presentScene(scene)
        skView?.ignoresSiblingOrder = true
        skView?.showsFPS = true
        skView?.showsNodeCount = true
    }
    
    func handleGameMessage(_ message: GameMessage) {
        guard let state = gameState else { return }
        
        switch message {
        case .playerMove(let playerIndex, let row, let col, let direction):
            multiplayerManager.sendMessage(.playerMove(playerIndex: playerIndex, row: row, col: col, direction: direction))
            
        case .playerShoot(let playerIndex, let projectile):
            multiplayerManager.sendMessage(.playerShoot(playerIndex: playerIndex, projectile: projectile))
            
        case .readyForNextRound(let playerIndex):
            readyPlayers.insert(playerIndex)
            checkAndStartNextRound()
            
        default:
            break
        }
    }
    
    func checkAndStartNextRound() {
        guard let state = gameState else { return }
        
        // Check if all players are ready
        let totalPlayers = state.tanks.count
        if readyPlayers.count == totalPlayers {
            // All players ready, start next round
            readyPlayers.removeAll()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.startNextRound()
            }
        } else if readyPlayers.contains(state.localPlayerIndex) {
            // Send ready message to other players
            multiplayerManager.sendMessage(.readyForNextRound(playerIndex: state.localPlayerIndex))
        }
    }
    
    func startNextRound() {
        guard let currentState = gameState else { return }
        
        // Generate new seed (fair coin flip)
        let seed = UInt32.random(in: 0...UInt32.max)
        
        // Reset game state
        gameState?.reset(seed: seed)
        gameScene?.startGame(with: gameState!)
        
        // Build player assignments map
        var playerAssignments: [String: Int] = [:]
        playerAssignments[multiplayerManager.session.myPeerID.displayName] = currentState.localPlayerIndex
        for (peer, index) in peerToPlayerIndex {
            playerAssignments[peer.displayName] = index
        }
        
        // Send new round message
        multiplayerManager.sendMessage(.roundStart(seed: seed, playerCount: currentState.tanks.count, hostPlayerIndex: currentState.localPlayerIndex, playerAssignments: playerAssignments))
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - MultiplayerManagerDelegate

extension GameViewController: MultiplayerManagerDelegate {
    func multiplayerManager(_ manager: MultiplayerManager, didFindPeer peerID: MCPeerID) {
        if !discoveredPeers.contains(peerID) {
            discoveredPeers.append(peerID)
            peerTableView.reloadData()
            updatePeerListUI()
            statusLabel.text = "Found \(discoveredPeers.count) game\(discoveredPeers.count == 1 ? "" : "s"). Tap to join."
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didLosePeer peerID: MCPeerID) {
        discoveredPeers.removeAll { $0 == peerID }
        peerTableView.reloadData()
        updatePeerListUI()
        if discoveredPeers.isEmpty {
            statusLabel.text = "Searching for nearby games..."
        } else {
            statusLabel.text = "Found \(discoveredPeers.count) game\(discoveredPeers.count == 1 ? "" : "s"). Tap to join."
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didConnectToPeer peerID: MCPeerID) {
        // Add to connected peers list
        if !connectedPeers.contains(peerID) {
            connectedPeers.append(peerID)
        }
        
        activityIndicator.stopAnimating()
        
        if multiplayerManager.isHost {
            // Host: show updated player count
            statusLabel.text = "Player joined: \(peerID.displayName)"
            updateConnectedPlayersUI()
        } else {
            // Client: wait for host to start game
            statusLabel.text = "Connected! Waiting for host to start game..."
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didDisconnectFromPeer peerID: MCPeerID) {
        // Remove from connected peers
        connectedPeers.removeAll { $0 == peerID }
        peerToPlayerIndex.removeValue(forKey: peerID)
        
        if gameState != nil {
            // During game - return to lobby
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view.subviews.forEach { $0.removeFromSuperview() }
                self.viewDidLoad()
                let alert = UIAlertController(
                    title: "Disconnected",
                    message: "Lost connection to \(peerID.displayName)",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    self?.resetLobbyUI()
                })
                self.present(alert, animated: true)
            }
        } else {
            // In lobby - just update UI
            updateConnectedPlayersUI()
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didReceiveMessage message: GameMessage, from peerID: MCPeerID) {
        switch message {
        case .roundStart(let seed, let playerCount, let hostPlayerIndex, let playerAssignments):
            // Host initiated game start or round restart
            if gameState == nil {
                // Initial game start - get our player index from assignments
                let myName = multiplayerManager.session.myPeerID.displayName
                let localPlayerIndex = playerAssignments[myName] ?? 1 // Default to 1 if not found
                
                gameState = GameState(seed: seed, playerCount: playerCount, localPlayerIndex: localPlayerIndex)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self, let state = self.gameState else { return }
                    
                    // Hide lobby
                    self.lobbyView.isHidden = true
                    
                    // Create SKView if needed
                    if self.skView == nil {
                        let newSKView = SKView(frame: self.view.bounds)
                        newSKView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        self.view.insertSubview(newSKView, at: 0)
                        self.skView = newSKView
                    }
                    
                    let scene = GameScene.newGameScene()
                    scene.startGame(with: state)
                    scene.onGameMessage = { [weak self] msg in
                        self?.handleGameMessage(msg)
                    }
                    self.gameScene = scene
                    
                    self.skView?.presentScene(scene)
                    self.skView?.ignoresSiblingOrder = true
                    self.skView?.showsFPS = true
                    self.skView?.showsNodeCount = true
                }
            } else {
                // Round restart
                gameState?.reset(seed: seed)
                gameScene?.startGame(with: gameState!)
            }
            
        case .playerMove(let playerIndex, let row, let col, let direction):
            // Update the specified player's tank
            if let state = gameState, playerIndex < state.tanks.count {
                state.tanks[playerIndex].row = row
                state.tanks[playerIndex].col = col
                state.tanks[playerIndex].direction = direction
                gameScene?.renderTanks()
            }
            
        case .playerShoot(let playerIndex, let projectile):
            gameState?.projectiles.append(projectile)
            gameScene?.renderProjectiles()
            
        case .readyForNextRound(let playerIndex):
            readyPlayers.insert(playerIndex)
            checkAndStartNextRound()
            
        case .playerHit:
            break // Not used in current implementation
            
        case .startGame:
            // Host sent start game signal (could be used for future functionality)
            break
            
        case .playerJoined:
            // Could be used to notify about new players joining
            break
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didEncounterError error: Error) {
        // Reset UI
        activityIndicator.stopAnimating()
        
        // Show error alert with actionable guidance
        let alert = UIAlertController(
            title: "Unable to Start Multiplayer",
            message: "Could not start multiplayer session. This is likely because:\n\n• Local Network permission was denied\n• Bluetooth permission was denied\n\nTo fix:\n1. Open Settings app\n2. Go to Privacy & Security → Local Network\n3. Find Tank Game and turn it ON\n4. Also check Bluetooth permissions\n5. Return here and try again\n\nTechnical error: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
            self?.resetLobbyUI()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.resetLobbyUI()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource

extension GameViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredPeers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeerCell", for: indexPath)
        let peer = discoveredPeers[indexPath.row]
        cell.textLabel?.text = "📱 \(peer.displayName)"
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peer = discoveredPeers[indexPath.row]
        multiplayerManager.invitePeer(peer)
        statusLabel.text = "Connecting to \(peer.displayName)..."
        activityIndicator.startAnimating()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

