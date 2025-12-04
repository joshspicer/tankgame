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
    
    func startGame(playerCount: Int, localPlayerIndex: Int, playerAssignments: [String: Int]) {
        print("[GameViewController] startGame called - playerCount: \(playerCount), localPlayerIndex: \(localPlayerIndex)")
        print("[GameViewController] playerAssignments: \(playerAssignments)")
        print("[GameViewController] Connected peers: \(multiplayerManager.session.connectedPeers.map { $0.displayName })")
        
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
        
        print("[GameViewController] Sending roundStart message to peers")
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
        print("[GameViewController] Host game scene presented")
    }
    
    func startGameWithBots(playerCount: Int, localPlayerIndex: Int, botIndices: [Int]) {
        lobbyUI.lobbyView.isHidden = true
        
        // Create SKView if needed
        if skView == nil {
            let newSKView = SKView(frame: view.bounds)
            newSKView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(newSKView, at: 0)
            skView = newSKView
        }
        
        let seed = UInt32.random(in: 0...UInt32.max)
        gameState = GameState(seed: seed, playerCount: playerCount, localPlayerIndex: localPlayerIndex, botIndices: botIndices)
        
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
    
    func checkAndStartNextRound() {
        guard let state = gameState else { return }
        
        // In single player mode, just start the next round immediately
        if isSinglePlayerMode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.startNextRound()
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
        
        // Only send network messages in multiplayer mode
        if !isSinglePlayerMode {
            var playerAssignments: [String: Int] = [:]
            playerAssignments[multiplayerManager.session.myPeerID.displayName] = currentState.localPlayerIndex
            for (peer, index) in multiplayerCoordinator.peerToPlayerIndex {
                playerAssignments[peer.displayName] = index
            }
            
            multiplayerManager.sendMessage(.roundStart(seed: seed, playerCount: currentState.tanks.count, hostPlayerIndex: currentState.localPlayerIndex, playerAssignments: playerAssignments))
        }
    }
}
