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
    var multiplayerManager: MultiplayerManager!
    var multiplayerCoordinator: MultiplayerCoordinator!
    var permissionManager: PermissionManager!
    
    // UI components
    var lobbyUI: LobbyUI!
    
    // Game components
    var gameScene: GameScene?
    var gameState: GameState?
    var skView: SKView?
    
    // Game mode
    var gameMode: GameMode = .tank

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
        
        lobbyUI.onGameModeChanged = { [weak self] mode in
            self?.gameMode = mode
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

