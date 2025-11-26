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
        
        let currentGameMode = GameModeSettings.shared.currentMode
        multiplayerManager.sendMessage(.roundStart(seed: seed, playerCount: playerCount, hostPlayerIndex: localPlayerIndex, playerAssignments: playerAssignments, gameMode: currentGameMode))
        
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
        
        let currentGameMode = GameModeSettings.shared.currentMode
        multiplayerManager.sendMessage(.roundStart(seed: seed, playerCount: currentState.tanks.count, hostPlayerIndex: currentState.localPlayerIndex, playerAssignments: playerAssignments, gameMode: currentGameMode))
    }
}
