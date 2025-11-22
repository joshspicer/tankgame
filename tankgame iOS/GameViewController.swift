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
    
    // Player settings
    private var localPlayerSettings: PlayerSettings = PlayerSettings()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load saved settings
        loadPlayerSettings()
        
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
        
        // Setup settings sliders
        lobbyUI.speedSlider.addTarget(self, action: #selector(speedSliderChanged), for: .valueChanged)
        lobbyUI.colorSlider.addTarget(self, action: #selector(colorSliderChanged), for: .valueChanged)
        
        // Initialize settings display
        lobbyUI.updateSettingsDisplay(localPlayerSettings)
        
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
    }
    
    private func handleStartGameTapped() {
        let playerCount = multiplayerCoordinator.playerCount
        
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
        
        let playerAssignments = multiplayerCoordinator.assignPlayerIndices()
        startGame(playerCount: playerCount, localPlayerIndex: 0, playerAssignments: playerAssignments)
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        lobbyUI.peerTableView.reloadData()
        updatePeerListUI()
        updateConnectedPlayersUI()
    }
    
    private func updateConnectedPlayersUI() {
        let playerCount = multiplayerCoordinator.playerCount
        let playerNames = multiplayerCoordinator.getConnectedPlayerNames()
        let namesText = playerNames.enumerated().map { "P\($0.offset + 1): \($0.element)" }.joined(separator: "\n")
        lobbyUI.connectedPlayersLabel.text = "Connected Players (\(playerCount)/4):\n\n\(namesText)"
        
        if multiplayerManager.isHost {
            lobbyUI.startGameButton.isEnabled = playerCount >= 2
            lobbyUI.startGameButton.alpha = playerCount >= 2 ? 1.0 : 0.5
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
        
        // Set local player settings
        gameState?.playerSettings[localPlayerIndex] = localPlayerSettings
        
        multiplayerManager.sendMessage(.roundStart(seed: seed, playerCount: playerCount, hostPlayerIndex: localPlayerIndex, playerAssignments: playerAssignments))
        
        // Send local player settings to all connected peers
        multiplayerManager.sendMessage(.playerSettings(playerIndex: localPlayerIndex, settings: localPlayerSettings))
        
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
    
    // MARK: - Player Settings
    
    private func loadPlayerSettings() {
        if let data = UserDefaults.standard.data(forKey: "tankgame.playerSettings"),
           let settings = try? JSONDecoder().decode(PlayerSettings.self, from: data) {
            localPlayerSettings = settings
        }
    }
    
    private func savePlayerSettings() {
        if let data = try? JSONEncoder().encode(localPlayerSettings) {
            UserDefaults.standard.set(data, forKey: "tankgame.playerSettings")
        }
    }
    
    @objc private func speedSliderChanged(_ slider: UISlider) {
        localPlayerSettings.speed = Double(slider.value)
        savePlayerSettings()
        lobbyUI.updateSettingsDisplay(localPlayerSettings)
        
        // Sync settings to other players if connected
        if let state = gameState {
            state.playerSettings[state.localPlayerIndex] = localPlayerSettings
            multiplayerManager.sendMessage(.playerSettings(playerIndex: state.localPlayerIndex, settings: localPlayerSettings))
        }
    }
    
    @objc private func colorSliderChanged(_ slider: UISlider) {
        localPlayerSettings.colorHue = Double(slider.value)
        savePlayerSettings()
        lobbyUI.updateSettingsDisplay(localPlayerSettings)
        
        // Sync settings to other players if connected
        if let state = gameState {
            state.playerSettings[state.localPlayerIndex] = localPlayerSettings
            multiplayerManager.sendMessage(.playerSettings(playerIndex: state.localPlayerIndex, settings: localPlayerSettings))
        }
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
                
                // Set local player settings
                gameState?.playerSettings[localPlayerIndex] = localPlayerSettings
                
                // Send local player settings to all connected peers
                multiplayerManager.sendMessage(.playerSettings(playerIndex: localPlayerIndex, settings: localPlayerSettings))
                
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
            
        case .playerSettings(let playerIndex, let settings):
            // Update the player settings for the specified player
            if let state = gameState, playerIndex >= 0, playerIndex < state.playerSettings.count {
                state.playerSettings[playerIndex] = settings
                gameScene?.renderTanks()
            }
            
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
