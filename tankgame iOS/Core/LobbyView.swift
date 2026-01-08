//
//  LobbyView.swift
//  tankgame iOS
//
//  Clean lobby UI

import UIKit
import MultipeerConnectivity

/// Lobby view for hosting/joining games
final class LobbyView: UIView {

    var onHost: (() -> Void)?
    var onJoin: (() -> Void)?
    var onStartGame: (() -> Void)?
    var onReturnToLobby: (() -> Void)?
    var onInvitePeer: ((MCPeerID) -> Void)?

    private let titleLabel = UILabel()
    private let hostButton = UIButton(type: .system)
    private let joinButton = UIButton(type: .system)
    private let startButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let tableView = UITableView()

    private var availablePeers: [MCPeerID] = []
    private var isWaiting = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .black

        // Title
        titleLabel.text = "Tank Game"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        addSubview(titleLabel)

        // Host button
        hostButton.setTitle("Host Game", for: .normal)
        hostButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        hostButton.backgroundColor = .systemBlue
        hostButton.setTitleColor(.white, for: .normal)
        hostButton.layer.cornerRadius = 10
        hostButton.addTarget(self, action: #selector(hostTapped), for: .touchUpInside)
        addSubview(hostButton)

        // Join button
        joinButton.setTitle("Join Game", for: .normal)
        joinButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        joinButton.backgroundColor = .systemGreen
        joinButton.setTitleColor(.white, for: .normal)
        joinButton.layer.cornerRadius = 10
        joinButton.addTarget(self, action: #selector(joinTapped), for: .touchUpInside)
        addSubview(joinButton)

        // Start button
        startButton.setTitle("Start Game", for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        startButton.backgroundColor = .systemOrange
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 10
        startButton.isHidden = true
        startButton.addTarget(self, action: #selector(startGameTapped), for: .touchUpInside)
        addSubview(startButton)

        // Status label
        statusLabel.font = .systemFont(ofSize: 16)
        statusLabel.textColor = .lightGray
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        addSubview(statusLabel)

        // Table view
        tableView.backgroundColor = .darkGray
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isHidden = true
        addSubview(tableView)

        setupConstraints()
    }

    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        hostButton.translatesAutoresizingMaskIntoConstraints = false
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 60),

            hostButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            hostButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60),
            hostButton.widthAnchor.constraint(equalToConstant: 200),
            hostButton.heightAnchor.constraint(equalToConstant: 50),

            joinButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 20),
            joinButton.widthAnchor.constraint(equalToConstant: 200),
            joinButton.heightAnchor.constraint(equalToConstant: 50),

            startButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            startButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50),

            statusLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 40),
            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),

            tableView.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    @objc private func hostTapped() {
        onHost?()
    }

    @objc private func joinTapped() {
        onJoin?()
    }

    @objc private func startGameTapped() {
        onStartGame?()
    }

    func showWaiting(isHost: Bool) {
        isWaiting = true
        hostButton.isHidden = true
        joinButton.isHidden = true

        if isHost {
            statusLabel.text = "Waiting for players to join...\n(2-6 players)"
            startButton.isHidden = false
        } else {
            statusLabel.text = "Browsing for games..."
            tableView.isHidden = false
        }
    }

    func updatePeers(_ peers: [MCPeerID]) {
        if !isWaiting {
            availablePeers = peers
            tableView.reloadData()
        } else {
            statusLabel.text = "Connected: \(peers.count + 1) players"
        }
    }

    func reset() {
        isWaiting = false
        hostButton.isHidden = false
        joinButton.isHidden = false
        startButton.isHidden = true
        tableView.isHidden = true
        statusLabel.text = ""
        availablePeers.removeAll()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension LobbyView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        availablePeers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = availablePeers[indexPath.row].displayName
        cell.backgroundColor = .darkGray
        cell.textLabel?.textColor = .white
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onInvitePeer?(availablePeers[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
