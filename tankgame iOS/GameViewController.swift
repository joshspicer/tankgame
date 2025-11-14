//
//  GameViewController.swift
//  tankgame iOS
//
//  Created by jospicer on 10/28/25.
//

import UIKit
import SpriteKit
import MultipeerConnectivity

class GameViewController: UIViewController {
    
    var multiplayerManager: MultiplayerManager?
    var gameScene: GameScene?
    var gameState: GameState?
    var skView: SKView?
    
    // Lobby UI
    var lobbyView: UIView?
    var hostButton: UIButton?
    var joinButton: UIButton?
    var cancelButton: UIButton?
    var peerTableView: UITableView?
    var statusLabel: UILabel?
    var instructionsLabel: UILabel?
    var emptyStateLabel: UILabel?
    var activityIndicator: UIActivityIndicatorView?
    var discoveredPeers: [MCPeerID] = []
    
    // Game state
    var isWaitingForNextRound = false
    var readyForNextRound = false
    var remoteReadyForNextRound = false
    
    // Permission tracking
    var permissionCheckInProgress = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let manager = MultiplayerManager()
        manager.delegate = self
        multiplayerManager = manager
        
        setupLobby()
    }
    
    func setupLobby() {
        // Create lobby view
        let newLobbyView = UIView(frame: view.bounds)
        newLobbyView.backgroundColor = .systemBackground
        view.addSubview(newLobbyView)
        lobbyView = newLobbyView
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "🎮 Tank Game"
        titleLabel.font = .systemFont(ofSize: 36, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        newLobbyView.addSubview(titleLabel)
        
        // Status label
        let newStatusLabel = UILabel()
        newStatusLabel.text = "Choose an option to start"
        newStatusLabel.font = .systemFont(ofSize: 18, weight: .medium)
        newStatusLabel.textAlignment = .center
        newStatusLabel.numberOfLines = 0
        newStatusLabel.textColor = .secondaryLabel
        newStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        newLobbyView.addSubview(newStatusLabel)
        statusLabel = newStatusLabel
        
        // Instructions label
        let newInstructionsLabel = UILabel()
        newInstructionsLabel.text = "Battle with a friend on the same network!\nMove with the joystick, tap FIRE to shoot."
        newInstructionsLabel.font = .systemFont(ofSize: 14)
        newInstructionsLabel.textAlignment = .center
        newInstructionsLabel.numberOfLines = 0
        newInstructionsLabel.textColor = .secondaryLabel
        newInstructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        newLobbyView.addSubview(newInstructionsLabel)
        instructionsLabel = newInstructionsLabel
        
        // Host button
        let newHostButton = UIButton(type: .system)
        newHostButton.setTitle("🎯 Host Game", for: .normal)
        newHostButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        newHostButton.backgroundColor = .systemBlue
        newHostButton.setTitleColor(.white, for: .normal)
        newHostButton.layer.cornerRadius = 16
        newHostButton.layer.shadowColor = UIColor.black.cgColor
        newHostButton.layer.shadowOpacity = 0.2
        newHostButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        newHostButton.layer.shadowRadius = 4
        newHostButton.translatesAutoresizingMaskIntoConstraints = false
        newHostButton.addTarget(self, action: #selector(hostTapped), for: .touchUpInside)
        newLobbyView.addSubview(newHostButton)
        hostButton = newHostButton
        
        // Join button
        let newJoinButton = UIButton(type: .system)
        newJoinButton.setTitle("🔍 Join Game", for: .normal)
        newJoinButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        newJoinButton.backgroundColor = .systemGreen
        newJoinButton.setTitleColor(.white, for: .normal)
        newJoinButton.layer.cornerRadius = 16
        newJoinButton.layer.shadowColor = UIColor.black.cgColor
        newJoinButton.layer.shadowOpacity = 0.2
        newJoinButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        newJoinButton.layer.shadowRadius = 4
        newJoinButton.translatesAutoresizingMaskIntoConstraints = false
        newJoinButton.addTarget(self, action: #selector(joinTapped), for: .touchUpInside)
        newLobbyView.addSubview(newJoinButton)
        joinButton = newJoinButton
        
        // Cancel button
        let newCancelButton = UIButton(type: .system)
        newCancelButton.setTitle("Cancel", for: .normal)
        newCancelButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        newCancelButton.setTitleColor(.systemRed, for: .normal)
        newCancelButton.isHidden = true
        newCancelButton.translatesAutoresizingMaskIntoConstraints = false
        newCancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        newLobbyView.addSubview(newCancelButton)
        cancelButton = newCancelButton
        
        // Activity indicator
        let newActivityIndicator = UIActivityIndicatorView(style: .large)
        newActivityIndicator.color = .systemBlue
        newActivityIndicator.hidesWhenStopped = true
        newActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        newLobbyView.addSubview(newActivityIndicator)
        activityIndicator = newActivityIndicator
        
        // Peer table view
        let newPeerTableView = UITableView()
        newPeerTableView.isHidden = true
        newPeerTableView.delegate = self
        newPeerTableView.dataSource = self
        newPeerTableView.layer.cornerRadius = 12
        newPeerTableView.layer.borderWidth = 1
        newPeerTableView.layer.borderColor = UIColor.separator.cgColor
        newPeerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PeerCell")
        newPeerTableView.translatesAutoresizingMaskIntoConstraints = false
        newLobbyView.addSubview(newPeerTableView)
        peerTableView = newPeerTableView
        
        // Empty state label
        let newEmptyStateLabel = UILabel()
        newEmptyStateLabel.text = "No nearby games found.\nMake sure the other device is hosting."
        newEmptyStateLabel.font = .systemFont(ofSize: 14)
        newEmptyStateLabel.textAlignment = .center
        newEmptyStateLabel.numberOfLines = 0
        newEmptyStateLabel.textColor = .secondaryLabel
        newEmptyStateLabel.isHidden = true
        newEmptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        newLobbyView.addSubview(newEmptyStateLabel)
        emptyStateLabel = newEmptyStateLabel
        
        // Layout constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: newLobbyView.safeAreaLayoutGuide.topAnchor, constant: 80),
            titleLabel.centerXAnchor.constraint(equalTo: newLobbyView.centerXAnchor),
            
            newStatusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            newStatusLabel.leadingAnchor.constraint(equalTo: newLobbyView.leadingAnchor, constant: 30),
            newStatusLabel.trailingAnchor.constraint(equalTo: newLobbyView.trailingAnchor, constant: -30),
            
            newInstructionsLabel.topAnchor.constraint(equalTo: newStatusLabel.bottomAnchor, constant: 12),
            newInstructionsLabel.leadingAnchor.constraint(equalTo: newLobbyView.leadingAnchor, constant: 30),
            newInstructionsLabel.trailingAnchor.constraint(equalTo: newLobbyView.trailingAnchor, constant: -30),
            
            newHostButton.topAnchor.constraint(equalTo: newInstructionsLabel.bottomAnchor, constant: 50),
            newHostButton.centerXAnchor.constraint(equalTo: newLobbyView.centerXAnchor),
            newHostButton.widthAnchor.constraint(equalToConstant: 240),
            newHostButton.heightAnchor.constraint(equalToConstant: 56),
            
            newJoinButton.topAnchor.constraint(equalTo: newHostButton.bottomAnchor, constant: 20),
            newJoinButton.centerXAnchor.constraint(equalTo: newLobbyView.centerXAnchor),
            newJoinButton.widthAnchor.constraint(equalToConstant: 240),
            newJoinButton.heightAnchor.constraint(equalToConstant: 56),
            
            newCancelButton.topAnchor.constraint(equalTo: newJoinButton.bottomAnchor, constant: 20),
            newCancelButton.centerXAnchor.constraint(equalTo: newLobbyView.centerXAnchor),
            
            newActivityIndicator.centerXAnchor.constraint(equalTo: newLobbyView.centerXAnchor),
            newActivityIndicator.topAnchor.constraint(equalTo: newStatusLabel.bottomAnchor, constant: 20),
            
            newPeerTableView.topAnchor.constraint(equalTo: newCancelButton.bottomAnchor, constant: 20),
            newPeerTableView.leadingAnchor.constraint(equalTo: newLobbyView.leadingAnchor, constant: 30),
            newPeerTableView.trailingAnchor.constraint(equalTo: newLobbyView.trailingAnchor, constant: -30),
            newPeerTableView.heightAnchor.constraint(equalToConstant: 200),
            
            newEmptyStateLabel.topAnchor.constraint(equalTo: newCancelButton.bottomAnchor, constant: 40),
            newEmptyStateLabel.leadingAnchor.constraint(equalTo: newLobbyView.leadingAnchor, constant: 30),
            newEmptyStateLabel.trailingAnchor.constraint(equalTo: newLobbyView.trailingAnchor, constant: -30)
        ])
    }
    
    @objc func hostTapped() {
        checkAndRequestPermissions { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                self.hostButton?.isHidden = true
                self.joinButton?.isHidden = true
                self.instructionsLabel?.isHidden = true
                self.cancelButton?.isHidden = false
                self.activityIndicator?.startAnimating()
                self.statusLabel?.text = "Hosting game...\nWaiting for a player to join"
                self.multiplayerManager?.startHosting()
            } else {
                self.showPermissionDeniedAlert()
            }
        }
    }
    
    @objc func joinTapped() {
        checkAndRequestPermissions { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                self.hostButton?.isHidden = true
                self.joinButton?.isHidden = true
                self.instructionsLabel?.isHidden = true
                self.cancelButton?.isHidden = false
                self.activityIndicator?.startAnimating()
                self.statusLabel?.text = "Searching for nearby games..."
                self.peerTableView?.isHidden = false
                self.updatePeerListUI()
                self.multiplayerManager?.startBrowsing()
            } else {
                self.showPermissionDeniedAlert()
            }
        }
    }
    
    @objc func cancelTapped() {
        // Stop any active connections
        multiplayerManager?.stopHosting()
        multiplayerManager?.stopBrowsing()
        discoveredPeers.removeAll()
        
        // Reset UI
        resetLobbyUI()
    }
    
    func resetLobbyUI() {
        hostButton?.isHidden = false
        joinButton?.isHidden = false
        instructionsLabel?.isHidden = false
        cancelButton?.isHidden = true
        peerTableView?.isHidden = true
        emptyStateLabel?.isHidden = true
        activityIndicator?.stopAnimating()
        statusLabel?.text = "Choose an option to start"
        peerTableView?.reloadData()
    }
    
    func updatePeerListUI() {
        if discoveredPeers.isEmpty {
            peerTableView?.isHidden = true
            emptyStateLabel?.isHidden = false
        } else {
            peerTableView?.isHidden = false
            emptyStateLabel?.isHidden = true
        }
    }
    
    // MARK: - Permission Handling
    
    func checkAndRequestPermissions(completion: @escaping (Bool) -> Void) {
        // Prevent multiple simultaneous permission checks
        guard !permissionCheckInProgress else {
            completion(false)
            return
        }
        
        permissionCheckInProgress = true
        statusLabel?.text = "Checking permissions..."
        
        // Create a temporary browser to trigger the permission prompt
        // This is necessary because iOS doesn't provide a direct API to check
        // local network permission status
        let tempPeerID = MCPeerID(displayName: "PermissionCheck")
        let tempBrowser = MCNearbyServiceBrowser(peer: tempPeerID, serviceType: MultiplayerManager.serviceType)
        
        // Start browsing briefly to trigger permission prompt
        tempBrowser.startBrowsingForPeers()
        
        // Give iOS time to show the permission dialog and for user to respond
        DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.permissionCheckDelay) { [weak self] in
            tempBrowser.stopBrowsingForPeers()
            self?.permissionCheckInProgress = false
            
            // After triggering the permission prompt, we assume permission is granted
            // If it's not, the actual multiplayer operations will fail and we'll handle it there
            completion(true)
        }
    }
    
    func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Permissions Required",
            message: "Tank Game needs Local Network access to find nearby players. Please enable Local Network permission in Settings > Privacy & Security > Local Network, then try again.",
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
    
    func startGame(isPlayer1: Bool) {
        // Hide lobby
        lobbyView?.isHidden = true
        
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
        let newGameState = GameState(seed: seed, isPlayer1: isPlayer1)
        gameState = newGameState
        
        // Send round start message
        multiplayerManager?.sendMessage(.roundStart(seed: seed, isInitiator: isPlayer1))
        
        // Setup game scene
        let scene = GameScene.newGameScene()
        scene.startGame(with: newGameState)
        scene.onGameMessage = { [weak self] message in
            self?.handleGameMessage(message)
        }
        
        gameScene = scene
        
        // Present the scene
        guard let skView = skView else { return }
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }
    
    func handleGameMessage(_ message: GameMessage) {
        switch message {
        case .playerMove(let row, let col, let direction):
            multiplayerManager?.sendPositionUpdate(row: row, col: col, direction: direction)
            
        case .playerShoot(let projectile):
            multiplayerManager?.sendMessage(.playerShoot(projectile: projectile))
            
        case .readyForNextRound:
            readyForNextRound = true
            checkAndStartNextRound()
            
        default:
            break
        }
    }
    
    func checkAndStartNextRound() {
        if readyForNextRound && remoteReadyForNextRound {
            // Both players ready, start next round
            readyForNextRound = false
            remoteReadyForNextRound = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.nextRoundStartDelay) { [weak self] in
                self?.startNextRound()
            }
        } else if readyForNextRound {
            // Send ready message
            multiplayerManager?.sendMessage(.readyForNextRound)
        }
    }
    
    func startNextRound() {
        guard let currentState = gameState else { return }
        
        // Generate new seed (fair coin flip)
        let seed = UInt32.random(in: 0...UInt32.max)
        
        // Reset game state
        currentState.reset(seed: seed)
        gameScene?.startGame(with: currentState)
        
        // Send new round message
        multiplayerManager?.sendMessage(.roundStart(seed: seed, isInitiator: true))
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
            peerTableView?.reloadData()
            updatePeerListUI()
            statusLabel?.text = "Found \(discoveredPeers.count) game\(discoveredPeers.count == 1 ? "" : "s"). Tap to join."
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didLosePeer peerID: MCPeerID) {
        discoveredPeers.removeAll { $0 == peerID }
        peerTableView?.reloadData()
        updatePeerListUI()
        if discoveredPeers.isEmpty {
            statusLabel?.text = "Searching for nearby games..."
        } else {
            statusLabel?.text = "Found \(discoveredPeers.count) game\(discoveredPeers.count == 1 ? "" : "s"). Tap to join."
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didConnectToPeer peerID: MCPeerID) {
        activityIndicator?.stopAnimating()
        statusLabel?.text = "Connected to \(peerID.displayName)! Starting game..."
        
        // Determine who is player 1 (lexicographically smaller peer ID becomes player 1)
        guard let myName = multiplayerManager?.session.myPeerID.displayName else { return }
        let remoteName = peerID.displayName
        let isPlayer1 = myName < remoteName
        
        DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.gameStartDelay) { [weak self] in
            self?.startGame(isPlayer1: isPlayer1)
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didDisconnectFromPeer peerID: MCPeerID) {
        // Return to lobby
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
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didReceiveMessage message: GameMessage) {
        switch message {
        case .roundStart(let seed, let isInitiator):
            // Remote player initiated round start
            if gameState == nil {
                // Initial game start - we need to invert the isPlayer1 flag
                let isPlayer1 = !isInitiator
                let newGameState = GameState(seed: seed, isPlayer1: isPlayer1)
                gameState = newGameState
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    // Hide lobby
                    self.lobbyView?.isHidden = true
                    
                    // Create SKView if needed
                    if self.skView == nil {
                        let newSKView = SKView(frame: self.view.bounds)
                        newSKView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        self.view.insertSubview(newSKView, at: 0)
                        self.skView = newSKView
                    }
                    
                    let scene = GameScene.newGameScene()
                    scene.startGame(with: newGameState)
                    scene.onGameMessage = { [weak self] msg in
                        self?.handleGameMessage(msg)
                    }
                    self.gameScene = scene
                    
                    if let skView = self.skView {
                        skView.presentScene(scene)
                        skView.ignoresSiblingOrder = true
                        skView.showsFPS = true
                        skView.showsNodeCount = true
                    }
                }
            } else {
                // Round restart
                gameState?.reset(seed: seed)
                if let state = gameState {
                    gameScene?.startGame(with: state)
                }
            }
            
        case .playerMove(let row, let col, let direction):
            gameState?.remoteTank.row = row
            gameState?.remoteTank.col = col
            gameState?.remoteTank.direction = direction
            gameScene?.renderTanks()
            
        case .playerShoot(let projectile):
            gameState?.projectiles.append(projectile)
            gameScene?.renderProjectiles()
            
        case .readyForNextRound:
            remoteReadyForNextRound = true
            checkAndStartNextRound()
            
        case .playerHit:
            break // Not used in current implementation
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didEncounterError error: Error) {
        // Reset UI and show error alert
        activityIndicator?.stopAnimating()
        
        let alert = UIAlertController(
            title: "Connection Error",
            message: "Unable to start multiplayer session. This may be due to missing Local Network permissions.\n\nError: \(error.localizedDescription)\n\nPlease ensure Local Network access is enabled in Settings > Privacy & Security > Local Network.",
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
        multiplayerManager?.invitePeer(peer)
        statusLabel?.text = "Connecting to \(peer.displayName)..."
        activityIndicator?.startAnimating()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

