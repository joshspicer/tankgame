//
//  GameViewController.swift
//  tankgame iOS
//
//  Main view controller - Coordinator pattern

import UIKit
import SpriteKit
import Combine

final class GameViewController: UIViewController {

    // MARK: - Properties
    private let viewModel = GameViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var gameScene: GameScene?

    // MARK: - UI Components
    private lazy var lobbyView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        return view
    }()

    private lazy var hostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Host Game", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(hostTapped), for: .touchUpInside)
        return button
    }()

    private lazy var joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Join Game", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(joinTapped), for: .touchUpInside)
        return button
    }()

    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Game", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private lazy var peersTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.register(UITableViewCell.self, forCellReuseIdentifier: "PeerCell")
        table.delegate = self
        table.dataSource = self
        table.isHidden = true
        return table
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    private func setupUI() {
        view.backgroundColor = .black

        // Add lobby view
        view.addSubview(lobbyView)
        lobbyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lobbyView.topAnchor.constraint(equalTo: view.topAnchor),
            lobbyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lobbyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lobbyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Add buttons
        let stackView = UIStackView(arrangedSubviews: [hostButton, joinButton, startButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: lobbyView.centerYAnchor),
            hostButton.widthAnchor.constraint(equalToConstant: 200),
            hostButton.heightAnchor.constraint(equalToConstant: 50),
            joinButton.widthAnchor.constraint(equalToConstant: 200),
            joinButton.heightAnchor.constraint(equalToConstant: 50),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Add table view
        lobbyView.addSubview(peersTableView)
        peersTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            peersTableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            peersTableView.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 20),
            peersTableView.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -20),
            peersTableView.heightAnchor.constraint(equalToConstant: 200)
        ])

        // Add message label
        lobbyView.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            messageLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor)
        ])
    }

    private func setupBindings() {
        viewModel.$gameState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateUI(for: state)
            }
            .store(in: &cancellables)

        viewModel.$message
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.messageLabel.text = message
            }
            .store(in: &cancellables)

        viewModel.$discoveredPeers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.peersTableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$connectedPeers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] peers in
                self?.peersTableView.reloadData()
                self?.startButton.isHidden = peers.isEmpty
            }
            .store(in: &cancellables)
    }

    private func updateUI(for state: GameViewModel.GameState) {
        switch state {
        case .lobby:
            lobbyView.isHidden = false
            hostButton.isHidden = false
            joinButton.isHidden = false
            startButton.isHidden = true
            peersTableView.isHidden = true

        case .waiting:
            hostButton.isHidden = true
            joinButton.isHidden = true
            peersTableView.isHidden = false

        case .playing:
            lobbyView.isHidden = true
            showGameScene()

        case .roundEnd(let winner):
            messageLabel.text = winner != nil ? "Player \(winner! + 1) wins!" : "Draw!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.viewModel.disconnect()
            }
        }
    }

    private func showGameScene() {
        let scene = GameScene.create(viewModel: viewModel)
        self.gameScene = scene

        let skView = SKView(frame: view.bounds)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        view.addSubview(skView)

        skView.presentScene(scene)
    }

    // MARK: - Actions
    @objc private func hostTapped() {
        viewModel.hostGame()
    }

    @objc private func joinTapped() {
        viewModel.joinGame()
    }

    @objc private func startTapped() {
        viewModel.startGame()
    }

    override var prefersStatusBarHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .all }
}

// MARK: - UITableViewDelegate & DataSource
extension GameViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.discoveredPeers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeerCell", for: indexPath)
        let peer = viewModel.discoveredPeers[indexPath.row]
        let isConnected = viewModel.connectedPeers.contains(peer)
        cell.textLabel?.text = "\(peer) \(isConnected ? "✓" : "")"
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peer = viewModel.discoveredPeers[indexPath.row]
        viewModel.invitePeer(peer)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
