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
    var settingsButton: UIButton!
    var peerTableView: UITableView!
    var statusLabel: UILabel!
    var discoveredPeers: [MCPeerID] = []
    
    // Game state
    var isWaitingForNextRound = false
    var readyForNextRound = false
    var remoteReadyForNextRound = false
    
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
        titleLabel.text = "Tank Game"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(titleLabel)
        
        // Status label
        statusLabel = UILabel()
        statusLabel.text = "Host a game or join a nearby player"
        statusLabel.font = .systemFont(ofSize: 16)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(statusLabel)
        
        // Host button
        hostButton = UIButton(type: .system)
        hostButton.setTitle("Host Game", for: .normal)
        hostButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        hostButton.backgroundColor = .systemBlue
        hostButton.setTitleColor(.white, for: .normal)
        hostButton.layer.cornerRadius = 12
        hostButton.translatesAutoresizingMaskIntoConstraints = false
        hostButton.addTarget(self, action: #selector(hostTapped), for: .touchUpInside)
        lobbyView.addSubview(hostButton)
        
        // Join button
        joinButton = UIButton(type: .system)
        joinButton.setTitle("Join Game", for: .normal)
        joinButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        joinButton.backgroundColor = .systemGreen
        joinButton.setTitleColor(.white, for: .normal)
        joinButton.layer.cornerRadius = 12
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        joinButton.addTarget(self, action: #selector(joinTapped), for: .touchUpInside)
        lobbyView.addSubview(joinButton)
        
        // Settings button
        settingsButton = UIButton(type: .system)
        settingsButton.setTitle("⚙️ Settings", for: .normal)
        settingsButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        settingsButton.backgroundColor = .systemGray5
        settingsButton.setTitleColor(.label, for: .normal)
        settingsButton.layer.cornerRadius = 12
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        lobbyView.addSubview(settingsButton)
        
        // Peer table view
        peerTableView = UITableView()
        peerTableView.isHidden = true
        peerTableView.delegate = self
        peerTableView.dataSource = self
        peerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PeerCell")
        peerTableView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(peerTableView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: lobbyView.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -20),
            
            hostButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 40),
            hostButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            hostButton.widthAnchor.constraint(equalToConstant: 200),
            hostButton.heightAnchor.constraint(equalToConstant: 50),
            
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 20),
            joinButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            joinButton.widthAnchor.constraint(equalToConstant: 200),
            joinButton.heightAnchor.constraint(equalToConstant: 50),
            
            settingsButton.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 20),
            settingsButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 200),
            settingsButton.heightAnchor.constraint(equalToConstant: 50),
            
            peerTableView.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 20),
            peerTableView.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 20),
            peerTableView.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -20),
            peerTableView.bottomAnchor.constraint(equalTo: lobbyView.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc func hostTapped() {
        checkAndRequestPermissions { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                self.hostButton.isEnabled = false
                self.joinButton.isEnabled = false
                self.statusLabel.text = "Hosting game... Waiting for players to join"
                self.multiplayerManager.startHosting()
            } else {
                self.showPermissionDeniedAlert()
                self.hostButton.isEnabled = true
                self.joinButton.isEnabled = true
            }
        }
    }
    
    @objc func joinTapped() {
        checkAndRequestPermissions { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                self.hostButton.isEnabled = false
                self.joinButton.isEnabled = false
                self.statusLabel.text = "Looking for nearby games..."
                self.peerTableView.isHidden = false
                self.multiplayerManager.startBrowsing()
            } else {
                self.showPermissionDeniedAlert()
                self.hostButton.isEnabled = true
                self.joinButton.isEnabled = true
            }
        }
    }
    
    @objc func settingsTapped() {
        let settingsVC = SettingsViewController()
        settingsVC.modalPresentationStyle = .fullScreen
        present(settingsVC, animated: true)
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
        multiplayerManager.sendMessage(.roundStart(seed: seed, isInitiator: isPlayer1))
        
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
            multiplayerManager.sendPositionUpdate(row: row, col: col, direction: direction)
            
        case .playerShoot(let projectile):
            multiplayerManager.sendMessage(.playerShoot(projectile: projectile))
            
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
            multiplayerManager.sendMessage(.readyForNextRound)
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
        multiplayerManager.sendMessage(.roundStart(seed: seed, isInitiator: true))
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
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didLosePeer peerID: MCPeerID) {
        discoveredPeers.removeAll { $0 == peerID }
        peerTableView.reloadData()
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didConnectToPeer peerID: MCPeerID) {
        statusLabel.text = "Connected to \(peerID.displayName)"
        
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
            self?.view.subviews.forEach { $0.removeFromSuperview() }
            self?.viewDidLoad()
            self?.statusLabel.text = "Disconnected from \(peerID.displayName)"
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
        // Re-enable buttons and show error alert
        hostButton.isEnabled = true
        joinButton.isEnabled = true
        
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
            self?.statusLabel.text = "Host a game or join a nearby player"
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
        cell.textLabel?.text = discoveredPeers[indexPath.row].displayName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peer = discoveredPeers[indexPath.row]
        multiplayerManager.invitePeer(peer)
        statusLabel.text = "Inviting \(peer.displayName)..."
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

