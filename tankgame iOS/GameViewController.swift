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

    /// Periodic sync timer (elder only)
    private var syncTimer: Timer?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)

        network = Network()
        network.delegate = self

        // Start game immediately
        startSoloGame()

        // Start peer-to-peer with jitter to avoid race conditions
        let jitter = connectionJitter(for: network.localPeerId)
        NSLog("[Game] Starting peer-to-peer in %.2f seconds", jitter)
        DispatchQueue.main.asyncAfter(deadline: .now() + jitter) { [weak self] in
            self?.network.startPeerToPeer()
        }

        // Start periodic sync timer
        startSyncTimer()
    }

    /// Calculate deterministic jitter (0-1.5 seconds) based on peerId
    private func connectionJitter(for peerId: String) -> Double {
        var hash: UInt64 = 5381
        for char in peerId.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(char)
        }
        return Double(hash % 1500) / 1000.0  // 0.0 to 1.5 seconds
    }

    // MARK: - Periodic Sync

    private func startSyncTimer() {
        syncTimer?.invalidate()
        syncTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.performPeriodicSync()
        }
    }

    private func performPeriodicSync() {
        guard let game = game, network.isElder, network.isConnected else { return }

        let worldState = game.createWorldState()
        NSLog("[Game] Elder periodic sync: broadcasting worldState with %d players", worldState.players.count)
        network.send(.worldState(worldState))
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
        // Set elder status BEFORE presenting (player is alone at start, so is elder when alone,
        // but we only show settings button when connected with others)
        scene.isLocalPlayerElder = network.isElder && network.isConnected
        self.gameScene = scene

        skView.presentScene(scene)
    }

    // MARK: - Player Management

    private func addPlayerForPeer(_ peerId: String) {
        guard let game = game, let scene = gameScene else { return }

        // Add player to game
        if let tank = game.addPlayer(peerId: peerId) {
            NSLog("[Game] Added player %@... at (%d, %d)", String(peerId.prefix(8)), tank.row, tank.col)
            // Broadcast to other peers
            network.send(.playerJoined(peerId: peerId))

            // Render spawn animation
            scene.spawnTank(for: peerId, at: tank.row, col: tank.col, direction: tank.direction)
        } else {
            NSLog("[Game] Player %@... already exists", String(peerId.prefix(8)))
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

        // Add jitter to respawn time (2.5 to 3.5 seconds) based on peerId hash
        var hash: UInt64 = 5381
        for char in peerId.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(char)
        }
        let jitter = Double(hash % 1000) / 1000.0  // 0.0 to 1.0
        let respawnDelay = 2.5 + jitter  // 2.5 to 3.5 seconds

        // Show countdown overlay for local player
        if peerId == network.localPeerId {
            gameScene?.showRespawnCountdown(duration: respawnDelay)
        }

        respawnTimers[peerId] = Timer.scheduledTimer(withTimeInterval: respawnDelay, repeats: false) { [weak self] _ in
            guard let self = self, let game = self.game, let scene = self.gameScene else { return }

            // Respawn and get the position (creates player if missing)
            guard let spawn = game.respawnPlayer(peerId: peerId) else { return }

            // Render tank locally
            scene.spawnTank(for: peerId, at: spawn.row, col: spawn.col, direction: spawn.direction)

            // Broadcast respawn to all peers
            self.network.send(.respawn(peerId: peerId, row: spawn.row, col: spawn.col, direction: spawn.direction))

            self.respawnTimers.removeValue(forKey: peerId)
        }
    }

    // MARK: - World State Sync

    private func syncToWorldState(_ state: WorldState) {
        guard let scene = gameScene else { return }

        // Apply state to game
        game?.applyWorldState(state)

        NSLog("[Game] After sync, game has %d players", game?.players.count ?? 0)

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

        NSLog("[Game] Peer connected: %@... (isElder: %d, connected: %d)", String(peerId.prefix(8)), network.isElder ? 1 : 0, network.isConnected ? 1 : 0)

        // Update elder status on scene - only show settings when connected AND elder
        gameScene?.isLocalPlayerElder = network.isElder && network.isConnected
        gameScene?.updateSettingsUI()

        // Add the new player
        addPlayerForPeer(peerId)

        // If we're the elder, send world state to the new peer
        if network.isElder {
            let worldState = game.createWorldState()
            NSLog("[Game] Sending worldState with %d players to %@...", worldState.players.count, String(peerId.prefix(8)))
            network.send(.worldState(worldState), to: peerId)
        }
    }

    func network(_ network: Network, peerDisconnected peerId: String) {
        let wasElder = network.isElder
        removePlayerForPeer(peerId)

        // Update elder status on scene - only show settings when connected AND elder
        gameScene?.isLocalPlayerElder = network.isElder && network.isConnected
        gameScene?.updateSettingsUI()

        // If we just became the elder (the old elder disconnected), broadcast world state
        if !wasElder && network.isElder && network.isConnected {
            NSLog("[Game] Became new elder after disconnect, broadcasting worldState")
            if let game = game {
                let worldState = game.createWorldState()
                network.send(.worldState(worldState))
            }
        }
    }

    func network(_ network: Network, received message: GameMessage, from peerId: String) {
        switch message {
        case .worldState(let state):
            NSLog("[Game] Received worldState with %d players from %@...", state.players.count, String(peerId.prefix(8)))
            syncToWorldState(state)

        case .sync:
            // Handled via defensive recovery in individual message handlers
            break

        case .playerJoined(let joinedPeerId):
            // Another peer announced a player joined - add if we don't have them
            if game?.players[joinedPeerId] == nil {
                addPlayerForPeer(joinedPeerId)
            }

        case .playerLeft(let leftPeerId):
            // Another peer announced a player left
            removePlayerForPeer(leftPeerId)

        case .move(let movePeerId, let row, let col, let direction):
            guard let game = game, let scene = gameScene else { return }

            // Ensure player exists - they might have connected but we missed the join
            if game.players[movePeerId] == nil {
                game.addPlayer(peerId: movePeerId, row: row, col: col, direction: direction, isAlive: true, score: 0)
                scene.spawnTank(for: movePeerId, at: row, col: col, direction: direction)
            } else {
                game.players[movePeerId]?.tank.row = row
                game.players[movePeerId]?.tank.col = col
                game.players[movePeerId]?.tank.direction = direction
                scene.renderTanksSmooth()
            }

        case .shoot(_, let projectileState):
            guard let game = game else { return }
            let projectile = Projectile.from(projectileState)
            game.projectiles.append(projectile)
            gameScene?.renderProjectiles()

        case .hit(let victimId, let shooterId):
            guard let game = game, let scene = gameScene else { return }

            // Only process if player exists and is alive
            guard let playerData = game.players[victimId], playerData.tank.isAlive else { return }

            game.players[victimId]?.tank.isAlive = false

            // Award point to shooter (so all peers have consistent scores)
            if let shooterData = game.players[shooterId] {
                game.players[shooterId]?.score = shooterData.score + 1
            }

            scene.renderTanksSmooth()
            scene.updateScores()

            // Schedule respawn for local player
            if victimId == network.localPeerId {
                scheduleRespawn(for: victimId)
            }

        case .respawn(let respawnPeerId, let row, let col, let direction):
            guard let game = game, let scene = gameScene else { return }

            // Ensure player exists in game state
            if game.players[respawnPeerId] == nil {
                // Player doesn't exist - add them at the respawn position
                game.addPlayer(peerId: respawnPeerId, row: row, col: col, direction: direction, isAlive: true, score: 0)
            } else {
                // Update existing player
                game.players[respawnPeerId]?.tank.row = row
                game.players[respawnPeerId]?.tank.col = col
                game.players[respawnPeerId]?.tank.direction = direction
                game.players[respawnPeerId]?.tank.isAlive = true
            }

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

    func gameScene(_ scene: GameScene, playerHit victimId: String, byShooter shooterId: String) {
        guard let game = game else { return }

        // Broadcast hit with correct shooter info
        network.send(.hit(victimId: victimId, byShooterId: shooterId))

        // Update score display
        scene.updateScores()

        // Schedule respawn if it's a local hit
        if victimId == network.localPeerId {
            scheduleRespawn(for: victimId)
        }
    }

    func gameScene(_ scene: GameScene, didChangeGridSize delta: Int) {
        guard let game = game, network.isElder else { return }

        let newSize = max(4, min(12, game.gridSize + delta))
        guard newSize != game.gridSize else { return }

        // Generate new seed for new map
        let newSeed = UInt32.random(in: 0...UInt32.max)

        // Resize locally
        game.resizeGrid(to: newSize, newSeed: newSeed)

        // Broadcast new world state to all peers
        let worldState = game.createWorldState()
        network.send(.worldState(worldState))

        // Refresh local scene
        scene.fullRefresh()
        scene.updateSettingsUI()

        NSLog("[Game] Elder changed grid size to %d", newSize)
    }
}
