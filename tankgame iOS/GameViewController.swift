//
//  GameViewController.swift
//  Tank Game iOS
//
//  Main view controller - connects to Modal server on launch.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    // MARK: - Properties

    private var serverConnection: ServerConnection!
    private var gameScene: GameScene?
    private var game: Game?
    private var skView: SKView!

    /// The player ID assigned by the server
    private var localPlayerId: String?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)

        // Set up SpriteKit view immediately (show loading state)
        skView = SKView(frame: view.bounds)
        skView.ignoresSiblingOrder = true
        view.addSubview(skView)

        // Connect to Modal server — use saved name if available
        let savedName = UserDefaults.standard.string(forKey: "tankgame.playerName") ?? ""
        serverConnection = ServerConnection(displayName: savedName)
        serverConnection.delegate = self
        serverConnection.connect()

        NSLog("[Game] Connecting to server... (savedName: %@)", savedName.isEmpty ? "<none>" : savedName)
    }

    // MARK: - Game Setup

    /// Initialize game from server world state
    private func setupGame(playerId: String, worldState: ServerWorldState) {
        self.localPlayerId = playerId

        // Create game with server-provided seed and the assigned player ID
        let game = Game(seed: worldState.mapSeed, localPeerId: playerId, gridSize: worldState.gridSize)

        // Clear the default local player that Game.init adds - server state is authoritative
        game.players.removeAll()

        // Apply all players from server state
        applyServerWorldState(worldState, to: game)

        self.game = game

        // Create and present the scene
        let scene = GameScene.newScene()
        scene.gameDelegate = self
        scene.game = game
        scene.isLocalPlayerElder = false  // No elder concept in server mode
        self.gameScene = scene

        skView.presentScene(scene)
        NSLog("[Game] Game started with %d players on %dx%d map", game.players.count, worldState.gridSize, worldState.gridSize)
    }

    /// Apply a ServerWorldState to the Game instance
    private func applyServerWorldState(_ state: ServerWorldState, to game: Game) {
        // Update players
        var serverPlayerIds = Set<String>()

        for (playerId, ps) in state.players {
            serverPlayerIds.insert(playerId)

            let dir = Direction(rawValue: ps.direction) ?? .down

            // For the local player, only correct position if server disagrees
            // (client-side prediction already moved the tank locally)
            let isLocal = playerId == localPlayerId

            if game.players[playerId] != nil {
                // Update existing — skip local player position if prediction was correct
                if !isLocal {
                    game.players[playerId]?.tank.row = ps.row
                    game.players[playerId]?.tank.col = ps.col
                    game.players[playerId]?.tank.direction = dir
                } else {
                    // Server correction: only snap if position actually differs
                    let localTank = game.players[playerId]!.tank
                    if localTank.row != ps.row || localTank.col != ps.col {
                        game.players[playerId]?.tank.row = ps.row
                        game.players[playerId]?.tank.col = ps.col
                    }
                    // Always trust server for direction (it's cheap and prevents drift)
                    game.players[playerId]?.tank.direction = dir
                }
                game.players[playerId]?.tank.isAlive = ps.isAlive
                game.players[playerId]?.score = ps.score
                game.players[playerId]?.displayName = ps.displayName
            } else {
                // Add new
                game.addPlayer(peerId: playerId, row: ps.row, col: ps.col, direction: dir, isAlive: ps.isAlive, score: ps.score)
                game.players[playerId]?.displayName = ps.displayName
            }
        }

        // Remove players not in server state (they left)
        for playerId in game.players.keys {
            if !serverPlayerIds.contains(playerId) {
                game.players.removeValue(forKey: playerId)
            }
        }

        // Update projectiles
        game.projectiles = state.projectiles.map { ps in
            Projectile(
                row: ps.row,
                col: ps.col,
                direction: Direction(rawValue: ps.direction) ?? .down,
                ownerId: ps.ownerId
            )
        }
    }

    // MARK: - View Configuration

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        UIDevice.current.userInterfaceIdiom == .phone ? .portrait : .all
    }

    override var prefersStatusBarHidden: Bool { true }
}

// MARK: - ServerConnectionDelegate

extension GameViewController: ServerConnectionDelegate {
    func serverDidConnect(_ connection: ServerConnection) {
        NSLog("[Game] Connected to server")
    }

    func serverDidDisconnect(_ connection: ServerConnection) {
        NSLog("[Game] Disconnected from server")
        gameScene?.statusLabel?.text = "Reconnecting..."
    }

    func server(_ connection: ServerConnection, didReceive message: ServerMessage) {
        switch message {
        case .welcome(let playerId, let worldState):
            NSLog("[Game] Welcome! Player ID: %@, %d players on map", String(playerId.prefix(8)), worldState.players.count)
            // Save our assigned name for next launch
            if let myState = worldState.players[playerId], let name = myState.displayName, !name.isEmpty {
                UserDefaults.standard.set(name, forKey: "tankgame.playerName")
                NSLog("[Game] Saved player name: %@", name)
            }
            setupGame(playerId: playerId, worldState: worldState)

        case .stateUpdate(let worldState):
            guard let game = game, let scene = gameScene else { return }
            applyServerWorldState(worldState, to: game)
            scene.renderTanksSmooth()
            scene.renderProjectiles()
            scene.updateScores()

        case .playerJoined(let playerId, let displayName):
            NSLog("[Game] Player joined: %@ (%@)", displayName, String(playerId.prefix(8)))
            // Player will appear in next state_update

        case .playerLeft(let playerId):
            guard let game = game, let scene = gameScene else { return }
            NSLog("[Game] Player left: %@", String(playerId.prefix(8)))

            if let tank = game.removePlayer(peerId: playerId) {
                scene.showExplosion(at: tank.row, col: tank.col)
                scene.removeTank(for: playerId)
            }
            scene.updateScores()

        case .hit(let victimId, let shooterId):
            guard let game = game, let scene = gameScene else { return }

            game.players[victimId]?.tank.isAlive = false
            if let shooterData = game.players[shooterId] {
                game.players[shooterId]?.score = shooterData.score + 1
            }

            scene.renderTanksSmooth()
            scene.updateScores()

            // Show respawn countdown for local player (server controls actual respawn)
            if victimId == localPlayerId {
                scene.showRespawnCountdown(duration: 3.0)
            }

        case .respawn(let playerId, let row, let col, let direction):
            guard let game = game, let scene = gameScene else { return }
            let dir = Direction(rawValue: direction) ?? .down

            if game.players[playerId] == nil {
                game.addPlayer(peerId: playerId, row: row, col: col, direction: dir, isAlive: true, score: 0)
            } else {
                game.players[playerId]?.tank.row = row
                game.players[playerId]?.tank.col = col
                game.players[playerId]?.tank.direction = dir
                game.players[playerId]?.tank.isAlive = true
            }
            scene.spawnTank(for: playerId, at: row, col: col, direction: dir)

        case .mapUpdate(let worldState):
            guard let game = game, let scene = gameScene else { return }
            game.applyWorldState(WorldState(
                mapSeed: worldState.mapSeed,
                gridSize: worldState.gridSize,
                players: worldState.players.map { (id, ps) in
                    PlayerState(peerId: id, row: ps.row, col: ps.col,
                                direction: Direction(rawValue: ps.direction) ?? .down,
                                isAlive: ps.isAlive)
                },
                projectiles: worldState.projectiles.map { ps in
                    ProjectileState(row: ps.row, col: ps.col,
                                    direction: Direction(rawValue: ps.direction) ?? .down,
                                    ownerId: ps.ownerId)
                },
                scores: worldState.scores
            ))
            scene.fullRefresh()

        case .error(let message):
            NSLog("[Game] Server error: %@", message)

        case .unknown:
            break
        }
    }

    func server(_ connection: ServerConnection, didEncounterError error: Error) {
        NSLog("[Game] Connection error: %@", error.localizedDescription)
    }
}

// MARK: - GameSceneDelegate

extension GameViewController: GameSceneDelegate {
    func gameScene(_ scene: GameScene, playerMoved direction: Direction) {
        // Send movement INPUT to server (server validates and broadcasts)
        serverConnection.sendMove(direction: direction)
    }

    func gameScene(_ scene: GameScene, playerShot projectile: Projectile) {
        // Send shoot INPUT to server (server creates projectile)
        serverConnection.sendShoot()
    }

    func gameScene(_ scene: GameScene, playerHit victimId: String, byShooter shooterId: String) {
        // No-op: server handles collision detection
    }

    func gameScene(_ scene: GameScene, didChangeGridSize delta: Int) {
        // No-op: server controls grid size
    }
}
