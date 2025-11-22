//
//  GameViewController.swift
//  tankgame macOS
//
//  Created by jospicer on 10/28/25.
//

import Cocoa
import SpriteKit
import GameplayKit
import MultipeerConnectivity

/// Main view controller that coordinates the game experience
class GameViewController: NSViewController {
    
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
        lobbyUI.activityIndicator.startAnimation(nil)
        lobbyUI.statusLabel.stringValue = "Hosting game...\nWaiting for players to join (2-4 players)"
        updateConnectedPlayersUI()
        
        multiplayerManager.startHosting()
    }
    
    private func handleJoinTapped() {
        lobbyUI.hostButton.isHidden = true
        lobbyUI.joinButton.isHidden = true
        lobbyUI.instructionsLabel.isHidden = true
        lobbyUI.cancelButton.isHidden = false
        lobbyUI.activityIndicator.startAnimation(nil)
        lobbyUI.statusLabel.stringValue = "Searching for nearby games..."
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
            let alert = NSAlert()
            alert.messageText = "Not Enough Players"
            alert.informativeText = "You need at least 2 players to start the game."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
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
        lobbyUI.connectedPlayersLabel.stringValue = "Connected Players (\(playerCount)/4):\n\n\(namesText)"
        
        if multiplayerManager.isHost {
            lobbyUI.startGameButton.isEnabled = playerCount >= 2
            lobbyUI.startGameButton.alphaValue = playerCount >= 2 ? 1.0 : 0.5
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
            newSKView.autoresizingMask = [.width, .height]
            view.addSubview(newSKView, positioned: .below, relativeTo: lobbyUI.lobbyView)
            skView = newSKView
        }
        
        let seed = UInt32.random(in: 0...UInt32.max)
        gameState = GameState(seed: seed, playerCount: playerCount, localPlayerIndex: localPlayerIndex)
        
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
}

// MARK: - MultiplayerManagerDelegate

extension GameViewController: MultiplayerManagerDelegate {
    func multiplayerManager(_ manager: MultiplayerManager, didFindPeer peerID: MCPeerID) {
        multiplayerCoordinator.addDiscoveredPeer(peerID)
        lobbyUI.statusLabel.stringValue = "Found \(multiplayerCoordinator.discoveredPeers.count) game\(multiplayerCoordinator.discoveredPeers.count == 1 ? "" : "s"). Click to join."
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didLosePeer peerID: MCPeerID) {
        multiplayerCoordinator.removeDiscoveredPeer(peerID)
        if multiplayerCoordinator.discoveredPeers.isEmpty {
            lobbyUI.statusLabel.stringValue = "Searching for nearby games..."
        } else {
            lobbyUI.statusLabel.stringValue = "Found \(multiplayerCoordinator.discoveredPeers.count) game\(multiplayerCoordinator.discoveredPeers.count == 1 ? "" : "s"). Click to join."
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didConnectToPeer peerID: MCPeerID) {
        multiplayerCoordinator.addConnectedPeer(peerID)
        lobbyUI.activityIndicator.stopAnimation(nil)
        
        if multiplayerManager.isHost {
            lobbyUI.statusLabel.stringValue = "Player joined: \(peerID.displayName)"
        } else {
            lobbyUI.statusLabel.stringValue = "Connected! Waiting for host to start game..."
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
                
                let alert = NSAlert()
                alert.messageText = "Disconnected"
                alert.informativeText = "Lost connection to \(peerID.displayName)"
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
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
                        newSKView.autoresizingMask = [.width, .height]
                        self.view.addSubview(newSKView, positioned: .below, relativeTo: self.lobbyUI.lobbyView)
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
            
        case .playerHit, .startGame, .playerJoined:
            break
        }
    }
    
    func multiplayerManager(_ manager: MultiplayerManager, didEncounterError error: Error) {
        if permissionManager.isRequesting {
            return
        }
        
        lobbyUI.activityIndicator.stopAnimation(nil)
        
        let alert = NSAlert()
        alert.messageText = "Unable to Start Multiplayer"
        alert.informativeText = "Could not start multiplayer session. This is likely because:\n\n• Local Network permission was denied\n\nTo fix:\n1. Open System Settings\n2. Go to Privacy & Security → Local Network\n3. Find Tank Game and turn it ON\n4. Return here and try again\n\nTechnical error: \(error.localizedDescription)"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Try Again")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security") {
                NSWorkspace.shared.open(url)
            }
        } else if response == .alertSecondButtonReturn {
            lobbyUI.reset()
        } else {
            lobbyUI.reset()
        }
    }
}

// MARK: - NSTableViewDelegate & DataSource

extension GameViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return multiplayerCoordinator.discoveredPeers.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier = NSUserInterfaceItemIdentifier("PeerCell")
        var cell = tableView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView
        
        if cell == nil {
            cell = NSTableCellView()
            cell?.identifier = identifier
            
            let textField = NSTextField(labelWithString: "")
            textField.translatesAutoresizingMaskIntoConstraints = false
            cell?.addSubview(textField)
            cell?.textField = textField
            
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: cell!.leadingAnchor, constant: 8),
                textField.trailingAnchor.constraint(equalTo: cell!.trailingAnchor, constant: -8),
                textField.centerYAnchor.constraint(equalTo: cell!.centerYAnchor)
            ])
        }
        
        let peer = multiplayerCoordinator.discoveredPeers[row]
        cell?.textField?.stringValue = "📱 \(peer.displayName)"
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else { return }
        let selectedRow = tableView.selectedRow
        
        if selectedRow >= 0 && selectedRow < multiplayerCoordinator.discoveredPeers.count {
            let peer = multiplayerCoordinator.discoveredPeers[selectedRow]
            multiplayerManager.invitePeer(peer)
            lobbyUI.statusLabel.stringValue = "Connecting to \(peer.displayName)..."
            lobbyUI.activityIndicator.startAnimation(nil)
            tableView.deselectRow(selectedRow)
        }
    }
}

