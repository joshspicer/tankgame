//
//  GameViewControllerNetwork.swift
//  tankgame iOS
//
//  Consolidated network and game management logic
//

import UIKit
import SpriteKit
import MultipeerConnectivity

// MARK: - Game Management

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

// MARK: - Network Message Receiver

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
            guard let state = gameState else { return }
            state.reset(seed: seed)
            gameScene?.startGame(with: state)
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
