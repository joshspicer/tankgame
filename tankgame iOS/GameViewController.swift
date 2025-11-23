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

/// Main view controller that coordinates the game experience
class GameViewController: UIViewController {
    
    // Core managers
    private var multiplayerManager: MultiplayerManager!
    private var multiplayerCoordinator: MultiplayerCoordinator!
    private var permissionManager: PermissionManager!
    
    // UI components
    private var lobbyUI: LobbyUI!
    
    // Game components
    private var gameScene: GameScene?
    private var gameState: GameState?
    private var skView: SKView?
    
    // AI tracking
    private var aiPlayerCount: Int = 0
    private var maxPlayers: Int = 4

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize managers
        multiplayerManager = MultiplayerManager()
        multiplayerManager.delegate = self
        multiplayerCoordinator = MultiplayerCoordinator(multiplayerManager: multiplayerManager)
        permissionManager = PermissionManager(multiplayerManager: multiplayerManager)
        
        // Setup UI
        setupLobby()
        
        // Request permissions on first launch
        permissionManager.requestPermissionsIfNeeded()
    }
    
    private func setupLobby() {
        lobbyUI = LobbyUI()
        lobbyUI.setup(in: view)
        
        // Setup callbacks
        lobbyUI.onHostTapped = { [weak self] in
            self?.handleHostTapped()
        }
        
        lobbyUI.onJoinTapped = { [weak self] in
            self?.handleJoinTapped()
        }
        
        lobbyUI.onCancelTapped = { [weak self] in
            self?.handleCancelTapped()
        }
        
        lobbyUI.onStartGameTapped = { [weak self] in
            self?.handleStartGameTapped()
        }
        
        lobbyUI.onAddAITapped = { [weak self] in
            self?.handleAddAITapped()
        }
        
        // Setup table view
        lobbyUI.peerTableView.delegate = self
        lobbyUI.peerTableView.dataSource = self
        
        // Setup coordinator callbacks
        multiplayerCoordinator.onPeersUpdated = { [weak self] in
            self?.updateUI()
        }
        
        multiplayerCoordinator.onReadyForNextRound = { [weak self] in
            self?.startNextRound()
        }
    }
    
    // MARK: - Button Handlers
    
    private func handleHostTapped() {
        multiplayerManager.isHost = true
        lobbyUI.hostButton.isHidden = true
        lobbyUI.joinButton.isHidden = true
        lobbyUI.instructionsLabel.isHidden = true
        lobbyUI.cancelButton.isHidden = false
        lobbyUI.connectedPlayersView.isHidden = false
        lobbyUI.startGameButton.isHidden = false
        lobbyUI.activityIndicator.startAnimating()
        lobbyUI.statusLabel.text = "Hosting game...\nWaiting for players to join (2-4 players)"
        updateConnectedPlayersUI()
        
        multiplayerManager.startHosting()
    }
    
    private func handleJoinTapped() {
        lobbyUI.hostButton.isHidden = true
        lobbyUI.joinButton.isHidden = true
        lobbyUI.instructionsLabel.isHidden = true
        lobbyUI.cancelButton.isHidden = false
        lobbyUI.activityIndicator.startAnimating()
        lobbyUI.statusLabel.text = "Searching for nearby games..."
        lobbyUI.peerTableView.isHidden = false
        updatePeerListUI()
        
        multiplayerManager.startBrowsing()
    }
    
    private func handleCancelTapped() {
        multiplayerManager.stopHosting()
        multiplayerManager.stopBrowsing()
        multiplayerCoordinator.clearAll()
        lobbyUI.reset()
        lobbyUI.peerTableView.reloadData()
        multiplayerManager.isHost = false
        aiPlayerCount = 0
    }
    
    private func handleStartGameTapped() {
        let totalPlayers = multiplayerCoordinator.playerCount + aiPlayerCount
        
        if totalPlayers < 2 {
            let alert = UIAlertController(
                title: "Not Enough Players",
                message: "You need at least 2 players to start the game. Add an AI player or wait for other players to join.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let playerAssignments = multiplayerCoordinator.assignPlayerIndices()
        startGame(playerCount: totalPlayers, localPlayerIndex: 0, playerAssignments: playerAssignments)
    }
    
    private func handleAddAITapped() {
        let totalPlayers = multiplayerCoordinator.playerCount + aiPlayerCount
        
        if totalPlayers >= maxPlayers {
            let alert = UIAlertController(
                title: "Maximum Players",
                message: "The game already has \(maxPlayers) players (maximum).",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        aiPlayerCount += 1
        updateConnectedPlayersUI()
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        lobbyUI.peerTableView.reloadData()
        updatePeerListUI()
        updateConnectedPlayersUI()
    }
    
    private func updateConnectedPlayersUI() {
        let humanPlayerCount = multiplayerCoordinator.playerCount
        let totalPlayers = humanPlayerCount + aiPlayerCount
        let playerNames = multiplayerCoordinator.getConnectedPlayerNames()
        
        var allPlayers: [String] = []
        for (index, name) in playerNames.enumerated() {
            allPlayers.append("P\(index + 1): \(name)")
        }
        
        // Add AI players
        for i in 0..<aiPlayerCount {
            allPlayers.append("P\(humanPlayerCount + i + 1): 🤖 AI Bot")
        }
        
        let namesText = allPlayers.joined(separator: "\n")
        lobbyUI.connectedPlayersLabel.text = "Connected Players (\(totalPlayers)/\(maxPlayers)):\n\n\(namesText)"
        
        if multiplayerManager.isHost {
            lobbyUI.startGameButton.isEnabled = totalPlayers >= 2
            lobbyUI.startGameButton.alpha = totalPlayers >= 2 ? 1.0 : 0.5
            lobbyUI.addAIButton.isHidden = false
            lobbyUI.addAIButton.isEnabled = totalPlayers < maxPlayers
            lobbyUI.addAIButton.alpha = totalPlayers < maxPlayers ? 1.0 : 0.5
        }
    }
    
    private func updatePeerListUI() {
        if multiplayerCoordinator.discoveredPeers.isEmpty {
            lobbyUI.peerTableView.isHidden = true
            lobbyUI.emptyStateLabel.isHidden = false
        } else {
            lobbyUI.peerTableView.isHidden = false
            lobbyUI.emptyStateLabel.isHidden = true
        }
    }
    
    // MARK: - Game Management
    
    private func startGame(playerCount: Int, localPlayerIndex: Int, playerAssignments: [String: Int]) {
        lobbyUI.lobbyView.isHidden = true
        
        // Create SKView if needed
        if skView == nil {
            let newSKView = SKView(frame: view.bounds)
            newSKView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(newSKView, at: 0)
            skView = newSKView
        }
        
        let seed = UInt32.random(in: 0...UInt32.max)
        gameState = GameState(seed: seed, playerCount: playerCount, localPlayerIndex: localPlayerIndex)
        
        // Enable AI for AI players (they get the last player indices)
        let humanPlayerCount = multiplayerCoordinator.playerCount
        for i in 0..<aiPlayerCount {
            let aiPlayerIndex = humanPlayerCount + i
            gameState?.enableAI(forPlayerIndex: aiPlayerIndex)
        }
        
        multiplayerManager.sendMessage(.roundStart(seed: seed, playerCount: playerCount, hostPlayerIndex: localPlayerIndex, playerAssignments: playerAssignments))
        
        let scene = GameScene.newGameScene()
        scene.startGame(with: gameState!)
        scene.onGameMessage = { [weak self] message in
            self?.handleGameMessage(message)
        }
        
        gameScene = scene
        
        skView?.presentScene(scene)
        skView?.ignoresSiblingOrder = true
        skView?.showsFPS = true
        skView?.showsNodeCount = true
    }
    
    private func handleGameMessage(_ message: GameMessage) {
        guard let state = gameState else { return }
        
        switch message {
        case .playerMove(let playerIndex, let row, let col, let direction):
            multiplayerManager.sendMessage(.playerMove(playerIndex: playerIndex, row: row, col: col, direction: direction))
            
        case .playerShoot(let playerIndex, let projectile):
            multiplayerManager.sendMessage(.playerShoot(playerIndex: playerIndex, projectile: projectile))
            
        case .readyForNextRound(let playerIndex):
            multiplayerCoordinator.markPlayerReady(playerIndex)
            checkAndStartNextRound()
            
        case .restartMatch:
            handleRestartMatch()
            
        case .quitToLobby:
            handleQuitToLobby()
            
        default:
            break
        }
    }
    
    private func checkAndStartNextRound() {
        guard let state = gameState else { return }
        
        if multiplayerCoordinator.isAllPlayersReady(totalPlayers: state.tanks.count) {
            multiplayerCoordinator.resetReadyPlayers()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.startNextRound()
            }
        } else if multiplayerCoordinator.readyPlayers.contains(state.localPlayerIndex) {
            multiplayerManager.sendMessage(.readyForNextRound(playerIndex: state.localPlayerIndex))
        }
    }
    
    private func startNextRound() {
        guard let currentState = gameState else { return }
        
        let seed = UInt32.random(in: 0...UInt32.max)
        gameState?.reset(seed: seed)
        gameScene?.startGame(with: gameState!)
        
        var playerAssignments: [String: Int] = [:]
        playerAssignments[multiplayerManager.session.myPeerID.displayName] = currentState.localPlayerIndex
        for (peer, index) in multiplayerCoordinator.peerToPlayerIndex {
            playerAssignments[peer.displayName] = index
        }
        
        multiplayerManager.sendMessage(.roundStart(seed: seed, playerCount: currentState.tanks.count, hostPlayerIndex: currentState.localPlayerIndex, playerAssignments: playerAssignments))
    }
    
    private func handleRestartMatch() {
        // Only host can restart the match
        guard multiplayerManager.isHost else {
            showAlert(title: "Cannot Restart", message: "Only the host can restart the match.")
            return
        }
        
        // Reset all scores to 0
        gameState?.wins = Array(repeating: 0, count: gameState?.tanks.count ?? 2)
        
        // Send restart message to all players
        multiplayerManager.sendMessage(.restartMatch)
        
        // Start a new round with fresh scores
        startNextRound()
    }
    
    private func handleQuitToLobby() {
        // Send quit message to all players
        multiplayerManager.sendMessage(.quitToLobby)
        
        // Return to lobby
        returnToLobby()
    }
    
    private func returnToLobby() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Clean up game state
            self.gameScene = nil
            self.gameState = nil
            self.skView?.removeFromSuperview()
            self.skView = nil
            
            // Show lobby UI
            self.lobbyUI.lobbyView.isHidden = false
            self.lobbyUI.reset()
            
            // Keep connections but allow new game
            if self.multiplayerManager.isHost {
                self.lobbyUI.hostButton.isHidden = true
                self.lobbyUI.joinButton.isHidden = true
                self.lobbyUI.instructionsLabel.isHidden = true
                self.lobbyUI.cancelButton.isHidden = false
                self.lobbyUI.connectedPlayersView.isHidden = false
                self.lobbyUI.startGameButton.isHidden = false
                self.lobbyUI.statusLabel.text = "Ready to start a new game"
                self.updateConnectedPlayersUI()
            } else {
                self.lobbyUI.statusLabel.text = "Waiting for host to start new game..."
                self.lobbyUI.cancelButton.isHidden = false
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
        multiplayerCoordinator.addDiscoveredPeer(peerID)
        lobbyUI.statusLabel.text = "Found \(multiplayerCoordinator.discoveredPeers.count) game\(multiplayerCoordinator.discoveredPeers.count == 1 ? "" : "s"). Tap to join."
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didLosePeer peerID: MCPeerID) {
        multiplayerCoordinator.removeDiscoveredPeer(peerID)
        if multiplayerCoordinator.discoveredPeers.isEmpty {
            lobbyUI.statusLabel.text = "Searching for nearby games..."
        } else {
            lobbyUI.statusLabel.text = "Found \(multiplayerCoordinator.discoveredPeers.count) game\(multiplayerCoordinator.discoveredPeers.count == 1 ? "" : "s"). Tap to join."
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didConnectToPeer peerID: MCPeerID) {
        multiplayerCoordinator.addConnectedPeer(peerID)
        lobbyUI.activityIndicator.stopAnimating()
        
        if multiplayerManager.isHost {
            lobbyUI.statusLabel.text = "Player joined: \(peerID.displayName)"
        } else {
            lobbyUI.statusLabel.text = "Connected! Waiting for host to start game..."
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didDisconnectFromPeer peerID: MCPeerID) {
        multiplayerCoordinator.removeConnectedPeer(peerID)
        
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
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didReceiveMessage message: GameMessage, from peerID: MCPeerID) {
        switch message {
        case .roundStart(let seed, let playerCount, let hostPlayerIndex, let playerAssignments):
            if gameState == nil {
                let myName = multiplayerManager.session.myPeerID.displayName
                let localPlayerIndex = playerAssignments[myName] ?? 1
                
                gameState = GameState(seed: seed, playerCount: playerCount, localPlayerIndex: localPlayerIndex)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self, let state = self.gameState else { return }
                    
                    self.lobbyUI.lobbyView.isHidden = true
                    
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
                gameState?.reset(seed: seed)
                gameScene?.startGame(with: gameState!)
            }
            
        case .playerMove(let playerIndex, let row, let col, let direction):
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
            multiplayerCoordinator.markPlayerReady(playerIndex)
            checkAndStartNextRound()
            
        case .restartMatch:
            // Reset scores to 0
            gameState?.wins = Array(repeating: 0, count: gameState?.tanks.count ?? 2)
            // Host will send a new roundStart message, so we just wait
            
        case .quitToLobby:
            returnToLobby()
            
        case .playerHit, .startGame, .playerJoined:
            break
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didEncounterError error: Error) {
        if permissionManager.isRequesting {
            return
        }
        
        lobbyUI.activityIndicator.stopAnimating()
        
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
            self?.lobbyUI.reset()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.lobbyUI.reset()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource

extension GameViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return multiplayerCoordinator.discoveredPeers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeerCell", for: indexPath)
        let peer = multiplayerCoordinator.discoveredPeers[indexPath.row]
        cell.textLabel?.text = "📱 \(peer.displayName)"
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peer = multiplayerCoordinator.discoveredPeers[indexPath.row]
        multiplayerManager.invitePeer(peer)
        lobbyUI.statusLabel.text = "Connecting to \(peer.displayName)..."
        lobbyUI.activityIndicator.startAnimating()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
