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
    
    func startWiFiGame(playerCount: Int, localPlayerIndex: Int, playerAssignments: [String: Int]) {
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
        
        // Send via WiFi instead of Bluetooth
        wifiMultiplayerManager?.sendMessage(.roundStart(seed: seed, playerCount: playerCount, hostPlayerIndex: localPlayerIndex, playerAssignments: playerAssignments))
        
        let scene = GameScene.newGameScene()
        scene.startGame(with: gameState!)
        scene.onGameMessage = { [weak self] message in
            self?.handleWiFiGameMessage(message)
        }
        
        gameScene = scene
        
        skView?.presentScene(scene)
        skView?.ignoresSiblingOrder = true
        skView?.showsFPS = true
        skView?.showsNodeCount = true
    }
    
    func checkAndStartNextRound() {
        guard let state = gameState else { return }
        
        if connectionMode == .wifi {
            if wifiCoordinator?.isAllPlayersReady(totalPlayers: state.tanks.count) == true {
                wifiCoordinator?.resetReadyPlayers()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.startNextRound()
                }
            } else if wifiCoordinator?.readyPlayers.contains(state.localPlayerIndex) == true {
                wifiMultiplayerManager?.sendMessage(.readyForNextRound(playerIndex: state.localPlayerIndex))
            }
        } else {
            if multiplayerCoordinator.isAllPlayersReady(totalPlayers: state.tanks.count) {
                multiplayerCoordinator.resetReadyPlayers()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.startNextRound()
                }
            } else if multiplayerCoordinator.readyPlayers.contains(state.localPlayerIndex) {
                multiplayerManager.sendMessage(.readyForNextRound(playerIndex: state.localPlayerIndex))
            }
        }
    }
    
    func startNextRound() {
        guard let currentState = gameState else { return }
        
        let seed = UInt32.random(in: 0...UInt32.max)
        currentState.reset(seed: seed)
        gameScene?.startGame(with: currentState)
        
        if connectionMode == .wifi {
            var playerAssignments: [String: Int] = [:]
            let localName = UIDevice.current.name
            playerAssignments[localName] = currentState.localPlayerIndex
            if let coordinator = wifiCoordinator {
                for (peerName, index) in coordinator.peerToPlayerIndex {
                    playerAssignments[peerName] = index
                }
            }
            
            wifiMultiplayerManager?.sendMessage(.roundStart(seed: seed, playerCount: currentState.tanks.count, hostPlayerIndex: currentState.localPlayerIndex, playerAssignments: playerAssignments))
        } else {
            var playerAssignments: [String: Int] = [:]
            playerAssignments[multiplayerManager.session.myPeerID.displayName] = currentState.localPlayerIndex
            for (peer, index) in multiplayerCoordinator.peerToPlayerIndex {
                playerAssignments[peer.displayName] = index
            }
            
            multiplayerManager.sendMessage(.roundStart(seed: seed, playerCount: currentState.tanks.count, hostPlayerIndex: currentState.localPlayerIndex, playerAssignments: playerAssignments))
        }
    }
}
