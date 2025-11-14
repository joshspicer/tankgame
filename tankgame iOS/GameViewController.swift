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
    var internetMultiplayerManager: InternetMultiplayerManager?
    var gameScene: GameScene?
    var gameState: GameState?
    var skView: SKView?
    
    // Lobby UI
    var lobbyView: UIView!
    var hostButton: UIButton!
    var joinButton: UIButton!
    var internetButton: UIButton!
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
    var remoteReadyForNextRound = false
    var isInternetMultiplayer = false
    
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
        instructionsLabel.text = "Battle with a friend on the same network!\nMove with the joystick, tap FIRE to shoot."
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
        
        // Internet lobby button
        internetButton = UIButton(type: .system)
        internetButton.setTitle("🌐 Connect to Internet Lobby", for: .normal)
        internetButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        internetButton.backgroundColor = .systemPurple
        internetButton.setTitleColor(.white, for: .normal)
        internetButton.layer.cornerRadius = 16
        internetButton.layer.shadowColor = UIColor.black.cgColor
        internetButton.layer.shadowOpacity = 0.2
        internetButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        internetButton.layer.shadowRadius = 4
        internetButton.translatesAutoresizingMaskIntoConstraints = false
        internetButton.addTarget(self, action: #selector(internetLobbyTapped), for: .touchUpInside)
        lobbyView.addSubview(internetButton)
        
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
            
            internetButton.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 20),
            internetButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            internetButton.widthAnchor.constraint(equalToConstant: 280),
            internetButton.heightAnchor.constraint(equalToConstant: 56),
            
            cancelButton.topAnchor.constraint(equalTo: internetButton.bottomAnchor, constant: 20),
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
                self.isInternetMultiplayer = false
                self.hostButton.isHidden = true
                self.joinButton.isHidden = true
                self.internetButton.isHidden = true
                self.instructionsLabel.isHidden = true
                self.cancelButton.isHidden = false
                self.activityIndicator.startAnimating()
                self.statusLabel.text = "Hosting game...\nWaiting for a player to join"
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
                self.isInternetMultiplayer = false
                self.hostButton.isHidden = true
                self.joinButton.isHidden = true
                self.internetButton.isHidden = true
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
    
    @objc func internetLobbyTapped() {
        // Show passphrase input dialog
        let alert = UIAlertController(
            title: "Join Internet Lobby",
            message: "Enter a passphrase to join or create a lobby.\nFormat: verb-noun (e.g., jump-rocket)",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "jump-rocket"
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Connect", style: .default) { [weak self] _ in
            guard let self = self,
                  let passphrase = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces).lowercased(),
                  !passphrase.isEmpty else {
                return
            }
            
            self.connectToInternetLobby(passphrase: passphrase)
        })
        
        present(alert, animated: true)
    }
    
    func connectToInternetLobby(passphrase: String) {
        isInternetMultiplayer = true
        hostButton.isHidden = true
        joinButton.isHidden = true
        internetButton.isHidden = true
        instructionsLabel.isHidden = true
        cancelButton.isHidden = false
        activityIndicator.startAnimating()
        statusLabel.text = "Connecting to internet lobby '\(passphrase)'...\nWaiting for opponent"
        
        // Create internet multiplayer manager
        internetMultiplayerManager = InternetMultiplayerManager()
        internetMultiplayerManager?.delegate = self
        
        // Connect to server (you can change this URL to your server)
        let serverURL = "ws://localhost:8765"
        internetMultiplayerManager?.connect(to: serverURL, passphrase: passphrase)
    }
    
    @objc func cancelTapped() {
        // Stop any active connections
        if isInternetMultiplayer {
            internetMultiplayerManager?.disconnect()
            internetMultiplayerManager = nil
        } else {
            multiplayerManager.stopHosting()
            multiplayerManager.stopBrowsing()
            discoveredPeers.removeAll()
        }
        
        // Reset UI
        resetLobbyUI()
    }
    
    func resetLobbyUI() {
        isInternetMultiplayer = false
        hostButton.isHidden = false
        joinButton.isHidden = false
        internetButton.isHidden = false
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
    
    func startGame(isPlayer1: Bool) {
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
        gameState = GameState(seed: seed, isPlayer1: isPlayer1)
        
        // Send round start message
        if isInternetMultiplayer {
            internetMultiplayerManager?.sendMessage(.roundStart(seed: seed, isInitiator: isPlayer1))
        } else {
            multiplayerManager.sendMessage(.roundStart(seed: seed, isInitiator: isPlayer1))
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
        case .playerMove(let row, let col, let direction):
            if isInternetMultiplayer {
                internetMultiplayerManager?.sendMessage(message)
            } else {
                multiplayerManager.sendPositionUpdate(row: row, col: col, direction: direction)
            }
            
        case .playerShoot(let projectile):
            if isInternetMultiplayer {
                internetMultiplayerManager?.sendMessage(message)
            } else {
                multiplayerManager.sendMessage(.playerShoot(projectile: projectile))
            }
            
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.startNextRound()
            }
        } else if readyForNextRound {
            // Send ready message
            if isInternetMultiplayer {
                internetMultiplayerManager?.sendMessage(.readyForNextRound)
            } else {
                multiplayerManager.sendMessage(.readyForNextRound)
            }
        }
    }
    
    func startNextRound() {
        guard let currentState = gameState else { return }
        
        // Generate new seed (fair coin flip)
        let seed = UInt32.random(in: 0...UInt32.max)
        
        // Reset game state
        gameState?.reset(seed: seed)
        gameScene?.startGame(with: gameState!)
        
        // Send new round message
        if isInternetMultiplayer {
            internetMultiplayerManager?.sendMessage(.roundStart(seed: seed, isInitiator: true))
        } else {
            multiplayerManager.sendMessage(.roundStart(seed: seed, isInitiator: true))
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
        activityIndicator.stopAnimating()
        statusLabel.text = "Connected to \(peerID.displayName)! Starting game..."
        
        // Determine who is player 1 (lexicographically smaller peer ID becomes player 1)
        let myName = multiplayerManager.session.myPeerID.displayName
        let remoteName = peerID.displayName
        let isPlayer1 = myName < remoteName
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
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
                gameState = GameState(seed: seed, isPlayer1: isPlayer1)
                
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

// MARK: - InternetMultiplayerManagerDelegate

extension GameViewController: InternetMultiplayerManagerDelegate {
    func internetMultiplayerManager(_ manager: InternetMultiplayerManager, didConnect: Bool) {
        activityIndicator.stopAnimating()
        statusLabel.text = "Connected! Starting game..."
        
        // Determine who is player 1 (random, but both will agree based on server order)
        // For simplicity, just use a random assignment
        let isPlayer1 = Bool.random()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.startGame(isPlayer1: isPlayer1)
        }
    }
    
    func internetMultiplayerManager(_ manager: InternetMultiplayerManager, didReceiveMessage message: GameMessage) {
        // Same message handling as local multiplayer
        switch message {
        case .roundStart(let seed, let isInitiator):
            // Remote player initiated round start
            if gameState == nil {
                // Initial game start - we need to invert the isPlayer1 flag
                let isPlayer1 = !isInitiator
                gameState = GameState(seed: seed, isPlayer1: isPlayer1)
                
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
    
    func internetMultiplayerManager(_ manager: InternetMultiplayerManager, didDisconnect: Bool) {
        // Return to lobby
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view.subviews.forEach { $0.removeFromSuperview() }
            self.viewDidLoad()
            let alert = UIAlertController(
                title: "Disconnected",
                message: "Lost connection to opponent",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.resetLobbyUI()
            })
            self.present(alert, animated: true)
        }
    }
    
    func internetMultiplayerManager(_ manager: InternetMultiplayerManager, didEncounterError error: Error) {
        // Show error alert
        activityIndicator.stopAnimating()
        
        let alert = UIAlertController(
            title: "Connection Error",
            message: "Unable to connect to internet lobby.\n\n\(error.localizedDescription)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.resetLobbyUI()
        })
        
        present(alert, animated: true)
    }
}

