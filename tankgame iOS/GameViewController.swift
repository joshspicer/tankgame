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
    var peerTableView: UITableView!
    var statusLabel: UILabel!
    var instructionsLabel: UILabel!
    var emptyStateLabel: UILabel!
    var activityIndicator: UIActivityIndicatorView!
    var discoveredPeers: [MCPeerID] = []
    
    // Game state
    var isWaitingForNextRound = false
    var readyForNextRound = false
    var playersReadyForNextRound: Set<String> = [] // Track which peers are ready
    
    // Multiplayer state
    var playerIndex: Int = 0 // This device's player index
    var peerToPlayerIndex: [MCPeerID: Int] = [:] // Map peers to their player indices
    var isHost: Bool = false // Whether this device is hosting
    
    // Permission tracking
    var permissionCheckInProgress = false

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
        instructionsLabel.text = "Battle with friends on the same network!\nSupports 2-4 players.\nMove with the joystick, tap FIRE to shoot."
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
        checkAndRequestPermissions { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                self.isHost = true
                self.playerIndex = 0 // Host is always player 0
                self.hostButton.isHidden = true
                self.joinButton.isHidden = true
                self.instructionsLabel.isHidden = true
                self.cancelButton.isHidden = false
                self.activityIndicator.startAnimating()
                self.statusLabel.text = "Hosting game...\nWaiting for players to join (2-4 players)"
                self.multiplayerManager.startHosting()
            } else {
                self.showPermissionDeniedAlert()
            }
        }
    }
    
    @objc func joinTapped() {
        checkAndRequestPermissions { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                self.hostButton.isHidden = true
                self.joinButton.isHidden = true
                self.instructionsLabel.isHidden = true
                self.cancelButton.isHidden = false
                self.activityIndicator.startAnimating()
                self.statusLabel.text = "Searching for nearby games..."
                self.peerTableView.isHidden = false
                self.updatePeerListUI()
                self.multiplayerManager.startBrowsing()
            } else {
                self.showPermissionDeniedAlert()
            }
        }
    }
    
    @objc func cancelTapped() {
        // Stop any active connections
        multiplayerManager.stopHosting()
        multiplayerManager.stopBrowsing()
        discoveredPeers.removeAll()
        peerToPlayerIndex.removeAll()
        isHost = false
        
        // Reset UI
        resetLobbyUI()
    }
    
    func resetLobbyUI() {
        hostButton.isHidden = false
        joinButton.isHidden = false
        instructionsLabel.isHidden = false
        cancelButton.isHidden = true
        peerTableView.isHidden = true
        emptyStateLabel.isHidden = true
        activityIndicator.stopAnimating()
        statusLabel.text = "Choose an option to start"
        peerTableView.reloadData()
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
    
    func checkAndRequestPermissions(completion: @escaping (Bool) -> Void) {
        // Prevent multiple simultaneous permission checks
        guard !permissionCheckInProgress else {
            completion(false)
            return
        }
        
        permissionCheckInProgress = true
        statusLabel.text = "Checking permissions..."
        
        // Create a temporary browser to trigger the permission prompt
        // This is necessary because iOS doesn't provide a direct API to check
        // local network permission status
        let tempPeerID = MCPeerID(displayName: "PermissionCheck")
        let tempBrowser = MCNearbyServiceBrowser(peer: tempPeerID, serviceType: MultiplayerManager.serviceType)
        
        // Start browsing briefly to trigger permission prompt
        tempBrowser.startBrowsingForPeers()
        
        // Give iOS time to show the permission dialog and for user to respond
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
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
    
    func startGame() {
        // Hide lobby
        lobbyView.isHidden = true
        
        // Create SKView if needed
        if skView == nil {
            let newSKView = SKView(frame: view.bounds)
            newSKView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(newSKView, at: 0)
            skView = newSKView
        }
        
        // Calculate number of players (local + connected peers)
        let numberOfPlayers = 1 + multiplayerManager.numberOfConnectedPeers
        
        // Generate initial seed
        let seed = UInt32.random(in: 0...UInt32.max)
        
        // Create game state with all players
        gameState = GameState(seed: seed, numberOfPlayers: numberOfPlayers, localPlayerIndex: playerIndex)
        
        // Send round start message to all peers with their indices
        if isHost {
            multiplayerManager.sendMessage(.roundStart(seed: seed, numberOfPlayers: numberOfPlayers, playerIndex: 0))
        }
        
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
        switch message {
        case .playerMove(let playerIndex, let row, let col, let direction):
            multiplayerManager.sendPositionUpdate(playerIndex: playerIndex, row: row, col: col, direction: direction)
            
        case .playerShoot(let playerIndex, let projectile):
            multiplayerManager.sendMessage(.playerShoot(playerIndex: playerIndex, projectile: projectile))
            
        case .readyForNextRound:
            readyForNextRound = true
            checkAndStartNextRound()
            
        default:
            break
        }
    }
    
    func checkAndStartNextRound() {
        // Check if all players are ready
        let allConnectedPeers = multiplayerManager.connectedPeers.map { $0.displayName }
        let allReady = readyForNextRound && playersReadyForNextRound.count == allConnectedPeers.count
        
        if allReady {
            // All players ready, start next round
            readyForNextRound = false
            playersReadyForNextRound.removeAll()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.startNextRound()
            }
        } else if readyForNextRound {
            // Send ready message
            multiplayerManager.sendMessage(.readyForNextRound)
        }
    }
    
    func startNextRound() {
        guard let currentState = gameState else { return }
        
        // Generate new seed
        let seed = UInt32.random(in: 0...UInt32.max)
        
        // Reset game state
        gameState?.reset(seed: seed)
        gameScene?.startGame(with: gameState!)
        
        // Send new round message if host
        if isHost {
            let numberOfPlayers = 1 + multiplayerManager.numberOfConnectedPeers
            multiplayerManager.sendMessage(.roundStart(seed: seed, numberOfPlayers: numberOfPlayers, playerIndex: 0))
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
        // Assign player index for the new peer
        if isHost {
            // Host assigns player indices
            let newPlayerIndex = 1 + peerToPlayerIndex.count
            peerToPlayerIndex[peerID] = newPlayerIndex
            
            // Send player index assignment to the new peer
            multiplayerManager.sendMessage(.playerIndexAssignment(playerIndex: newPlayerIndex))
            
            // Update status
            let totalPlayers = 1 + peerToPlayerIndex.count
            statusLabel.text = "Connected: \(totalPlayers) player\(totalPlayers == 1 ? "" : "s"). Waiting for more players..."
            
            // If we have at least 2 players, start the game after a short delay
            if totalPlayers >= 2 {
                statusLabel.text = "Connected: \(totalPlayers) player\(totalPlayers == 1 ? "" : "s"). Starting game..."
                activityIndicator.stopAnimating()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.startGame()
                }
            }
        } else {
            // Client waits for game start from host
            activityIndicator.stopAnimating()
            statusLabel.text = "Connected to \(peerID.displayName)! Waiting for game to start..."
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
        case .playerIndexAssignment(let assignedIndex):
            // Host is assigning us a player index
            playerIndex = assignedIndex
            print("Assigned player index: \(assignedIndex)")
            
        case .roundStart(let seed, let numberOfPlayers, _):
            // Remote player initiated round start
            if gameState == nil {
                // Initial game start
                gameState = GameState(seed: seed, numberOfPlayers: numberOfPlayers, localPlayerIndex: playerIndex)
                
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
            if playerIndex < gameState?.tanks.count ?? 0 {
                gameState?.tanks[playerIndex].row = row
                gameState?.tanks[playerIndex].col = col
                gameState?.tanks[playerIndex].direction = direction
                gameScene?.renderTanks()
            }
            
        case .playerShoot(let playerIndex, let projectile):
            // Add projectile from specified player
            gameState?.projectiles.append((projectile, playerIndex))
            gameScene?.renderProjectiles()
            
        case .readyForNextRound:
            // Track which player is ready
            playersReadyForNextRound.insert(multiplayerManager.session.myPeerID.displayName)
            checkAndStartNextRound()
            
        case .playerHit:
            break // Not used in current implementation
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didEncounterError error: Error) {
        // Reset UI and show error alert
        activityIndicator.stopAnimating()
        
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
        multiplayerManager.invitePeer(peer)
        statusLabel.text = "Connecting to \(peer.displayName)..."
        activityIndicator.startAnimating()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

