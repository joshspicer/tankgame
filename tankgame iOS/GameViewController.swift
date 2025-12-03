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
    
    // Core managers (Bluetooth)
    var multiplayerManager: MultiplayerManager!
    var multiplayerCoordinator: MultiplayerCoordinator!
    var permissionManager: PermissionManager!
    
    // WiFi managers
    var wifiMultiplayerManager: WiFiMultiplayerManager?
    var wifiCoordinator: WiFiMultiplayerCoordinator?
    
    // Connection mode
    var connectionMode: WiFiLobbyUI.ConnectionMode = .bluetooth
    
    // UI components
    var lobbyUI: LobbyUI!
    var wifiLobbyUI: WiFiLobbyUI?
    
    // Game components
    var gameScene: GameScene?
    var gameState: GameState?
    var skView: SKView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Bluetooth managers
        multiplayerManager = MultiplayerManager()
        multiplayerManager.delegate = self
        multiplayerCoordinator = MultiplayerCoordinator(multiplayerManager: multiplayerManager)
        permissionManager = PermissionManager(multiplayerManager: multiplayerManager)
        
        // Initialize WiFi managers
        wifiMultiplayerManager = WiFiMultiplayerManager()
        wifiMultiplayerManager?.delegate = self
        wifiCoordinator = WiFiMultiplayerCoordinator(wifiManager: wifiMultiplayerManager!)
        
        // Setup UI
        setupLobby()
        
        // Request permissions on first launch
        permissionManager.requestPermissionsIfNeeded()
    }
    
    private func setupLobby() {
        lobbyUI = LobbyUI()
        lobbyUI.setup(in: view)
        
        // Setup WiFi lobby UI
        wifiLobbyUI = WiFiLobbyUI()
        wifiLobbyUI?.setup(in: view, below: lobbyUI.statusLabel, lobbyView: lobbyUI.lobbyView)
        
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
        
        // Setup WiFi mode callbacks
        wifiLobbyUI?.onModeChanged = { [weak self] mode in
            self?.handleModeChanged(mode)
        }
        
        wifiLobbyUI?.onJoinByCode = { [weak self] code in
            self?.handleJoinByCode(code)
        }
        
        // Setup table views
        lobbyUI.peerTableView.delegate = self
        lobbyUI.peerTableView.dataSource = self
        wifiLobbyUI?.wifiHostsTableView.delegate = self
        wifiLobbyUI?.wifiHostsTableView.dataSource = self
        
        // Setup coordinator callbacks
        multiplayerCoordinator.onPeersUpdated = { [weak self] in
            self?.updateUI()
        }
        
        multiplayerCoordinator.onReadyForNextRound = { [weak self] in
            self?.startNextRound()
        }
        
        wifiCoordinator?.onPeersUpdated = { [weak self] in
            self?.updateWiFiUI()
        }
        
        wifiCoordinator?.onReadyForNextRound = { [weak self] in
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

