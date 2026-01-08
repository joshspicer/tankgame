//
//  MainViewController.swift
//  tankgame iOS
//
//  Main view controller using MVVM pattern

import UIKit
import SpriteKit
import Combine

/// Main view controller coordinating the entire game flow
final class MainViewController: UIViewController {

    private let coordinator = AppCoordinator()
    private var cancellables = Set<AnyCancellable>()

    // UI Elements
    private let lobbyView = LobbyView()
    private var gameView: SKView?
    private var gameScene: TankGameScene?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupLobby()
        setupBindings()
    }

    private func setupLobby() {
        lobbyView.frame = view.bounds
        view.addSubview(lobbyView)

        lobbyView.onHost = { [weak self] in
            self?.coordinator.startHosting()
        }

        lobbyView.onJoin = { [weak self] in
            self?.coordinator.joinGame()
        }

        lobbyView.onStartGame = { [weak self] in
            self?.coordinator.startGame()
        }

        lobbyView.onReturnToLobby = { [weak self] in
            self?.coordinator.returnToLobby()
        }

        lobbyView.onInvitePeer = { [weak self] peer in
            self?.coordinator.networkService.invitePeer(peer)
        }
    }

    private func setupBindings() {
        // Update UI based on coordinator state
        coordinator.$state
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)

        // Update peer list
        coordinator.networkService.peersChanged
            .sink { [weak self] peers in
                self?.lobbyView.updatePeers(peers)
            }
            .store(in: &cancellables)

        // Start game
        coordinator.networkService.gameDidStart
            .sink { [weak self] info in
                self?.startGame(with: info)
            }
            .store(in: &cancellables)

        // Update game state
        coordinator.gameEngine.stateChanged
            .sink { [weak self] state in
                self?.gameScene?.render(state: state)
            }
            .store(in: &cancellables)

        // Handle round end
        coordinator.gameEngine.roundDidEnd
            .sink { [weak self] winner in
                self?.showRoundEnd(winner: winner)
            }
            .store(in: &cancellables)

        // Network messages
        coordinator.networkService.messageReceived
            .sink { [weak self] command in
                self?.handleNetworkCommand(command)
            }
            .store(in: &cancellables)
    }

    private func handleStateChange(_ state: AppCoordinator.State) {
        switch state {
        case .lobby:
            showLobby()
        case .waitingForPlayers:
            lobbyView.showWaiting(isHost: coordinator.networkService.isHost)
        case .playing:
            break // Handled by gameDidStart
        case .roundEnd:
            break // Handled by roundDidEnd
        }
    }

    private func startGame(with info: GameStartInfo) {
        let localPlayerIndex = info.assignments[UIDevice.current.name] ?? 0

        // Setup game scene
        let scene = TankGameScene(size: CGSize(width: 600, height: 800))
        scene.scaleMode = .aspectFit
        scene.gameEngine = coordinator.gameEngine
        scene.networkService = coordinator.networkService
        scene.localPlayerIndex = localPlayerIndex
        gameScene = scene

        // Setup game view
        let skView = SKView(frame: view.bounds)
        skView.presentScene(scene)
        view.addSubview(skView)
        gameView = skView

        // Hide lobby
        lobbyView.isHidden = true

        // Start game engine
        coordinator.gameEngine.start(seed: info.seed, playerCount: info.playerCount, localPlayerIndex: localPlayerIndex)
    }

    private func handleNetworkCommand(_ command: GameCommand) {
        switch command {
        case .move(let playerIndex, let position, let direction):
            let move = MoveCommand(playerIndex: playerIndex, direction: direction)
            coordinator.gameEngine.execute(move)
        case .shoot(let playerIndex, let projectile):
            let shoot = ShootCommand(playerIndex: playerIndex)
            coordinator.gameEngine.execute(shoot)
        case .startGame:
            break // Handled by gameDidStart
        }
    }

    private func showRoundEnd(winner: Winner?) {
        let alert = UIAlertController(
            title: "Round Over",
            message: winner.map { "Player \($0.index + 1) wins!" } ?? "Draw",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Next Round", style: .default) { [weak self] _ in
            self?.coordinator.returnToLobby()
        })
        present(alert, animated: true)
    }

    private func showLobby() {
        gameView?.removeFromSuperview()
        gameView = nil
        gameScene = nil
        lobbyView.isHidden = false
        lobbyView.reset()
    }

    override var prefersStatusBarHidden: Bool { true }
}
