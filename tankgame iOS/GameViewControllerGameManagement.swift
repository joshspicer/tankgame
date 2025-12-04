//
//  GameViewControllerGameManagement.swift
//  tankgame iOS
//
//  Game lifecycle management extracted from GameViewController
//

import UIKit
import SpriteKit
import MultipeerConnectivity

/// Handles game lifecycle management for GameViewController
extension GameViewController {
    
    /// Whether the current game is a single player game with AI bots
    private static var isSinglePlayerGame: Bool = false
    
    func startGame(playerCount: Int, localPlayerIndex: Int, playerAssignments: [String: Int]) {
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
    
    /// Start a single player game with AI bots
    /// - Parameter botCount: Number of AI opponents (default: 1, max: 3)
    func startSinglePlayerGame(botCount: Int = 1) {
        lobbyUI.lobbyView.isHidden = true
        GameViewController.isSinglePlayerGame = true
        
        // Create SKView if needed
        if skView == nil {
            let newSKView = SKView(frame: view.bounds)
            newSKView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(newSKView, at: 0)
            skView = newSKView
        }
        
        let seed = UInt32.random(in: 0...UInt32.max)
        let clampedBotCount = min(max(botCount, 1), 3) // Ensure 1-3 bots
        let playerCount = clampedBotCount + 1 // Player + AI bots
        
        gameState = GameState(seed: seed, playerCount: playerCount, localPlayerIndex: 0)
        
        // Add AI bots for each bot slot
        for i in 1...clampedBotCount {
            gameState?.aiBotManager.addBot(playerIndex: i, difficulty: .medium)
        }
        
        let scene = GameScene.newGameScene()
        scene.startGame(with: gameState!)
        scene.onGameMessage = { [weak self] message in
            self?.handleSinglePlayerGameMessage(message)
        }
        
        gameScene = scene
        
        skView?.presentScene(scene)
        skView?.ignoresSiblingOrder = true
        skView?.showsFPS = true
        skView?.showsNodeCount = true
    }
    
    /// Handle game messages in single player mode
    func handleSinglePlayerGameMessage(_ message: GameMessage) {
        guard let state = gameState else { return }
        
        switch message {
        case .readyForNextRound:
            // In single player, immediately start next round
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.startNextSinglePlayerRound()
            }
        default:
            // Other messages don't need network handling in single player
            break
        }
    }
    
    /// Start the next round in single player mode
    func startNextSinglePlayerRound() {
        guard let currentState = gameState else { return }
        
        let seed = UInt32.random(in: 0...UInt32.max)
        currentState.reset(seed: seed)
        gameScene?.startGame(with: currentState)
    }
    
    func checkAndStartNextRound() {
        guard let state = gameState else { return }
        
        // In single player mode, handle differently
        if GameViewController.isSinglePlayerGame {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.startNextSinglePlayerRound()
            }
            return
        }
        
        if multiplayerCoordinator.isAllPlayersReady(totalPlayers: state.tanks.count) {
            multiplayerCoordinator.resetReadyPlayers()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.startNextRound()
            }
        } else if multiplayerCoordinator.readyPlayers.contains(state.localPlayerIndex) {
            multiplayerManager.sendMessage(.readyForNextRound(playerIndex: state.localPlayerIndex))
        }
    }
    
    func startNextRound() {
        guard let currentState = gameState else { return }
        
        let seed = UInt32.random(in: 0...UInt32.max)
        currentState.reset(seed: seed)
        gameScene?.startGame(with: currentState)
        
        var playerAssignments: [String: Int] = [:]
        playerAssignments[multiplayerManager.session.myPeerID.displayName] = currentState.localPlayerIndex
        for (peer, index) in multiplayerCoordinator.peerToPlayerIndex {
            playerAssignments[peer.displayName] = index
        }
        
        multiplayerManager.sendMessage(.roundStart(seed: seed, playerCount: currentState.tanks.count, hostPlayerIndex: currentState.localPlayerIndex, playerAssignments: playerAssignments))
    }
}
