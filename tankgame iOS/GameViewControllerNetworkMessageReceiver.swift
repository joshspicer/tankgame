//
//  GameViewControllerNetworkMessageReceiver.swift
//  tankgame iOS
//
//  Network message receiving logic extracted from GameViewController
//

import UIKit
import SpriteKit
import MultipeerConnectivity

/// Handles received network messages for GameViewController
extension GameViewController {
    
    func handleReceivedMessage(_ message: GameMessage, from peerID: MCPeerID) {
        switch message {
        case .roundStart(let seed, let playerCount, let hostPlayerIndex, let playerAssignments):
            handleRoundStartMessage(seed: seed, playerCount: playerCount, hostPlayerIndex: hostPlayerIndex, playerAssignments: playerAssignments)
            
        case .playerMove(let playerIndex, let row, let col, let direction):
            handlePlayerMoveMessage(playerIndex: playerIndex, row: row, col: col, direction: direction)
            
        case .playerShoot(let playerIndex, let projectile):
            handlePlayerShootMessage(projectile: projectile)
            
        case .readyForNextRound(let playerIndex):
            multiplayerCoordinator.markPlayerReady(playerIndex)
            checkAndStartNextRound()
            
        case .playerHit, .startGame, .playerJoined:
            break
        }
    }
    
    private func handleRoundStartMessage(seed: UInt32, playerCount: Int, hostPlayerIndex: Int, playerAssignments: [String: Int]) {
        if gameState == nil {
            let myName = multiplayerManager.session.myPeerID.displayName
            let localPlayerIndex = playerAssignments[myName] ?? 1
            
            gameState = GameState(seed: seed, playerCount: playerCount, localPlayerIndex: localPlayerIndex)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let state = self.gameState else { return }
                
                self.lobbyUI.lobbyView.isHidden = true
                
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
            gameState?.reset(seed: seed)
            gameScene?.startGame(with: gameState!)
        }
    }
    
    private func handlePlayerMoveMessage(playerIndex: Int, row: Int, col: Int, direction: Direction) {
        if let state = gameState, playerIndex < state.tanks.count {
            state.tanks[playerIndex].row = row
            state.tanks[playerIndex].col = col
            state.tanks[playerIndex].direction = direction
            gameScene?.renderTanks()
        }
    }
    
    private func handlePlayerShootMessage(projectile: Projectile) {
        gameState?.projectiles.append(projectile)
        gameScene?.renderProjectiles()
    }
}
