//
//  GameViewController.swift
//  Tank Game iOS
//
//  Main view controller - game starts immediately, peers connect dynamically.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    // MARK: - Properties

    private var network: Network!
    private var gameScene: GameScene?
    private var game: Game?
    private var skView: SKView!

    /// Map seed - persisted and shared with peers
    private var mapSeed: UInt32 = 0

    /// Respawn timers keyed by peerId
    private var respawnTimers: [String: Timer] = [:]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)

        network = Network()
        network.delegate = self

        // Start game immediately
        startSoloGame()

        // Start peer-to-peer networking
        network.startPeerToPeer()
    }

    // MARK: - Game Start

    private func startSoloGame() {
        // Generate initial map seed
        mapSeed = UInt32.random(in: 0...UInt32.max)

        // Create game with local player
        game = Game(seed: mapSeed, localPeerId: network.localPeerId)

        // Create SpriteKit view
        skView = SKView(frame: view.bounds)
        skView.ignoresSiblingOrder = true
        view.addSubview(skView)

        let scene = GameScene.newScene()
        scene.gameDelegate = self
        scene.game = game
        self.gameScene = scene

        skView.presentScene(scene)
    }

    // MARK: - Player Management

    private func addPlayerForPeer(_ peerId: String) {
        guard let game = game, let scene = gameScene else { return }

        // Add player to game
        if let tank = game.addPlayer(peerId: peerId) {
            // Broadcast to other peers
            network.send(.playerJoined(peerId: peerId))

            // Render spawn animation
            scene.spawnTank(for: peerId, at: tank.row, col: tank.col, direction: tank.direction)
        }
    }

    private func removePlayerForPeer(_ peerId: String) {
        guard let game = game, let scene = gameScene else { return }

        // Cancel any pending respawn
        respawnTimers[peerId]?.invalidate()
        respawnTimers.removeValue(forKey: peerId)

        // Remove from game and get tank for explosion
        if let tank = game.removePlayer(peerId: peerId) {
            // Show explosion
            scene.showExplosion(at: tank.row, col: tank.col)
            scene.removeTank(for: peerId)

            // Broadcast to other peers
            network.send(.playerLeft(peerId: peerId))
        }

        // Update scores display
        scene.updateScores()
    }

    private func scheduleRespawn(for peerId: String) {
        // Cancel existing timer
        respawnTimers[peerId]?.invalidate()

        // Schedule respawn after 3 seconds
        respawnTimers[peerId] = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            guard let self = self, let game = self.game, let scene = self.gameScene else { return }

            game.respawnPlayer(peerId: peerId)

            if let tank = game.players[peerId]?.tank {
                scene.spawnTank(for: peerId, at: tank.row, col: tank.col, direction: tank.direction)

                // Broadcast respawn
                self.network.send(.respawn(peerId: peerId, row: tank.row, col: tank.col, direction: tank.direction))
            }

            self.respawnTimers.removeValue(forKey: peerId)
        }
    }

    // MARK: - World State Sync

    private func syncToWorldState(_ state: WorldState) {
        guard let scene = gameScene else { return }

        // Apply state to game
        game?.applyWorldState(state)

        // Full scene refresh
        scene.fullRefresh()
    }

    // MARK: - View Configuration

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        UIDevice.current.userInterfaceIdiom == .phone ? .portrait : .all
    }

    override var prefersStatusBarHidden: Bool { true }
}

// MARK: - NetworkDelegate

extension GameViewController: NetworkDelegate {
    func network(_ network: Network, peerConnected peerId: String) {
        guard let game = game else { return }

        // Add the new player
        addPlayerForPeer(peerId)

        // If we're the elder, send world state to the new peer
        if network.isElder {
            let worldState = game.createWorldState()
            network.send(.worldState(worldState), to: peerId)
        }
    }

    func network(_ network: Network, peerDisconnected peerId: String) {
        removePlayerForPeer(peerId)
    }

    func network(_ network: Network, received message: GameMessage, from peerId: String) {
        switch message {
        case .worldState(let state):
            syncToWorldState(state)

        case .playerJoined(let joinedPeerId):
            // Another peer announced a player joined - add if we don't have them
            if game?.players[joinedPeerId] == nil {
                addPlayerForPeer(joinedPeerId)
            }

        case .playerLeft(let leftPeerId):
            // Another peer announced a player left
            removePlayerForPeer(leftPeerId)

        case .move(let movePeerId, let row, let col, let direction):
            guard let game = game else { return }
            game.players[movePeerId]?.tank.row = row
            game.players[movePeerId]?.tank.col = col
            game.players[movePeerId]?.tank.direction = direction
            gameScene?.renderTanksSmooth()

        case .shoot(_, let projectileState):
            guard let game = game else { return }
            let projectile = Projectile.from(projectileState)
            game.projectiles.append(projectile)
            gameScene?.renderProjectiles()

        case .hit(let hitPeerId):
            guard let game = game else { return }
            game.players[hitPeerId]?.tank.isAlive = false
            gameScene?.renderTanksSmooth()
            gameScene?.updateScores()

            // Schedule respawn for local player
            if hitPeerId == network.localPeerId {
                scheduleRespawn(for: hitPeerId)
            }

        case .respawn(let respawnPeerId, let row, let col, let direction):
            guard let game = game, let scene = gameScene else { return }
            game.players[respawnPeerId]?.tank.row = row
            game.players[respawnPeerId]?.tank.col = col
            game.players[respawnPeerId]?.tank.direction = direction
            game.players[respawnPeerId]?.tank.isAlive = true
            scene.spawnTank(for: respawnPeerId, at: row, col: col, direction: direction)
        }
    }
}

// MARK: - GameSceneDelegate

extension GameViewController: GameSceneDelegate {
    func gameScene(_ scene: GameScene, playerMoved direction: Direction) {
        guard let game = game else { return }
        let tank = game.localTank
        network.send(.move(peerId: game.localPeerId, row: tank.row, col: tank.col, direction: tank.direction))
    }

    func gameScene(_ scene: GameScene, playerShot projectile: Projectile) {
        guard let game = game else { return }
        game.projectiles.append(projectile)
        scene.renderProjectiles()
        network.send(.shoot(peerId: game.localPeerId, projectile: projectile.toState()))
    }

    func gameScene(_ scene: GameScene, playerHit peerId: String) {
        guard game != nil else { return }

        // Broadcast hit
        network.send(.hit(peerId: peerId))

        // Update score display
        scene.updateScores()

        // Schedule respawn if it's a local hit
        if peerId == network.localPeerId {
            scheduleRespawn(for: peerId)
        }
    }
}
