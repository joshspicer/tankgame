//
//  LobbyUI.swift
//  tankgame iOS
//
//  Created by jospicer on 10/28/25.
//

import UIKit
import MultipeerConnectivity

/// Manages the lobby user interface
class LobbyUI {
    // UI Elements
    private(set) var lobbyView: UIView!
    private(set) var hostButton: UIButton!
    private(set) var joinButton: UIButton!
    private(set) var singlePlayerButton: UIButton!
    private(set) var cancelButton: UIButton!
    private(set) var startGameButton: UIButton!
    private(set) var spriteModeButton: UIButton!
    private(set) var botCountStepper: UIStepper!
    private(set) var botCountLabel: UILabel!
    private(set) var botCountView: UIView!
    private(set) var peerTableView: UITableView!
    private(set) var connectedPlayersView: UIView!
    private(set) var connectedPlayersLabel: UILabel!
    private(set) var statusLabel: UILabel!
    private(set) var instructionsLabel: UILabel!
    private(set) var emptyStateLabel: UILabel!
    private(set) var activityIndicator: UIActivityIndicatorView!
    
    /// Number of AI bots to add
    var botCount: Int = 1
    
    // Callbacks
    var onHostTapped: (() -> Void)?
    var onJoinTapped: (() -> Void)?
    var onSinglePlayerTapped: (() -> Void)?
    var onCancelTapped: (() -> Void)?
    var onStartGameTapped: (() -> Void)?
    
    func setup(in parentView: UIView) {
        // Create lobby view
        lobbyView = UIView(frame: parentView.bounds)
        lobbyView.backgroundColor = .systemBackground
        parentView.addSubview(lobbyView)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "Tank Game"
        titleLabel.font = .systemFont(ofSize: 36, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(titleLabel)
        
        // Status label
        statusLabel = UILabel()
        statusLabel.text = "Choose an option"
        statusLabel.font = .systemFont(ofSize: 16, weight: .regular)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.textColor = .secondaryLabel
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(statusLabel)
        
        // Instructions label
        instructionsLabel = UILabel()
        instructionsLabel.text = "2-4 players"
        instructionsLabel.font = .systemFont(ofSize: 14, weight: .regular)
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textColor = .tertiaryLabel
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(instructionsLabel)
        
        // Single Player button (with AI bots)
        singlePlayerButton = createButton(title: "Single Player", backgroundColor: .systemBlue)
        singlePlayerButton.addTarget(self, action: #selector(singlePlayerButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(singlePlayerButton)
        
        // Host button
        hostButton = createButton(title: "Host Game", backgroundColor: .systemBlue)
        hostButton.addTarget(self, action: #selector(hostButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(hostButton)
        
        // Join button
        joinButton = createButton(title: "Join Game", backgroundColor: .systemBlue)
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(joinButton)
        
        // Bot count selection view (for single player mode)
        botCountView = UIView()
        botCountView.backgroundColor = .secondarySystemBackground
        botCountView.layer.cornerRadius = 8
        botCountView.isHidden = true
        botCountView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(botCountView)
        
        botCountLabel = UILabel()
        botCountLabel.text = "Bots: 1"
        botCountLabel.font = .systemFont(ofSize: 14, weight: .medium)
        botCountLabel.textAlignment = .center
        botCountLabel.translatesAutoresizingMaskIntoConstraints = false
        botCountView.addSubview(botCountLabel)
        
        botCountStepper = UIStepper()
        botCountStepper.minimumValue = 1
        botCountStepper.maximumValue = 3
        botCountStepper.value = 1
        botCountStepper.addTarget(self, action: #selector(botCountChanged), for: .valueChanged)
        botCountStepper.translatesAutoresizingMaskIntoConstraints = false
        botCountView.addSubview(botCountStepper)
        
        // Sprite mode toggle button
        spriteModeButton = createSpriteModeButton()
        spriteModeButton.addTarget(self, action: #selector(spriteModeButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(spriteModeButton)
        
        // Cancel button
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.isHidden = true
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(cancelButton)
        
        // Start Game button (for host)
        startGameButton = createButton(title: "Start Game", backgroundColor: .systemGreen)
        startGameButton.isHidden = true
        startGameButton.addTarget(self, action: #selector(startGameButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(startGameButton)
        
        // Connected players view
        connectedPlayersView = UIView()
        connectedPlayersView.backgroundColor = .secondarySystemBackground
        connectedPlayersView.layer.cornerRadius = 8
        connectedPlayersView.isHidden = true
        connectedPlayersView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(connectedPlayersView)
        
        connectedPlayersLabel = UILabel()
        connectedPlayersLabel.text = "Connected: 1/4"
        connectedPlayersLabel.font = .systemFont(ofSize: 16, weight: .medium)
        connectedPlayersLabel.textAlignment = .center
        connectedPlayersLabel.numberOfLines = 0
        connectedPlayersLabel.translatesAutoresizingMaskIntoConstraints = false
        connectedPlayersView.addSubview(connectedPlayersLabel)
        
        // Activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .systemBlue
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(activityIndicator)
        
        // Peer table view
        peerTableView = UITableView()
        peerTableView.isHidden = true
        peerTableView.layer.cornerRadius = 8
        peerTableView.layer.borderWidth = 1
        peerTableView.layer.borderColor = UIColor.separator.cgColor
        peerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PeerCell")
        peerTableView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(peerTableView)
        
        // Empty state label
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "No nearby games found.\nMake sure the other device is hosting."
        emptyStateLabel.font = .systemFont(ofSize: 14)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(emptyStateLabel)
        
        setupConstraints(titleLabel: titleLabel)
    }
    
    private func createButton(title: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func setupConstraints(titleLabel: UILabel) {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: lobbyView.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            statusLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            instructionsLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            instructionsLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            instructionsLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            singlePlayerButton.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 40),
            singlePlayerButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            singlePlayerButton.widthAnchor.constraint(equalToConstant: 220),
            singlePlayerButton.heightAnchor.constraint(equalToConstant: 50),
            
            hostButton.topAnchor.constraint(equalTo: singlePlayerButton.bottomAnchor, constant: 12),
            hostButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            hostButton.widthAnchor.constraint(equalToConstant: 220),
            hostButton.heightAnchor.constraint(equalToConstant: 50),
            
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 12),
            joinButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            joinButton.widthAnchor.constraint(equalToConstant: 220),
            joinButton.heightAnchor.constraint(equalToConstant: 50),
            
            spriteModeButton.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 12),
            spriteModeButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            spriteModeButton.widthAnchor.constraint(equalToConstant: 180),
            spriteModeButton.heightAnchor.constraint(equalToConstant: 40),
            
            botCountView.topAnchor.constraint(equalTo: spriteModeButton.bottomAnchor, constant: 12),
            botCountView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            botCountView.widthAnchor.constraint(equalToConstant: 180),
            botCountView.heightAnchor.constraint(equalToConstant: 44),
            
            botCountLabel.leadingAnchor.constraint(equalTo: botCountView.leadingAnchor, constant: 16),
            botCountLabel.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            
            botCountStepper.trailingAnchor.constraint(equalTo: botCountView.trailingAnchor, constant: -16),
            botCountStepper.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: botCountView.bottomAnchor, constant: 12),
            cancelButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            connectedPlayersView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 16),
            connectedPlayersView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            connectedPlayersView.widthAnchor.constraint(equalToConstant: 240),
            connectedPlayersView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70),
            
            connectedPlayersLabel.topAnchor.constraint(equalTo: connectedPlayersView.topAnchor, constant: 12),
            connectedPlayersLabel.leadingAnchor.constraint(equalTo: connectedPlayersView.leadingAnchor, constant: 12),
            connectedPlayersLabel.trailingAnchor.constraint(equalTo: connectedPlayersView.trailingAnchor, constant: -12),
            connectedPlayersLabel.bottomAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: -12),
            
            startGameButton.topAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: 16),
            startGameButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            startGameButton.widthAnchor.constraint(equalToConstant: 220),
            startGameButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            
            peerTableView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 16),
            peerTableView.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            peerTableView.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            peerTableView.heightAnchor.constraint(equalToConstant: 180),
            
            emptyStateLabel.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 30),
            emptyStateLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            emptyStateLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30)
        ])
    }
    
    @objc private func hostButtonTapped() {
        onHostTapped?()
    }
    
    @objc private func joinButtonTapped() {
        onJoinTapped?()
    }
    
    @objc private func singlePlayerButtonTapped() {
        onSinglePlayerTapped?()
    }
    
    @objc private func cancelButtonTapped() {
        onCancelTapped?()
    }
    
    @objc private func startGameButtonTapped() {
        onStartGameTapped?()
    }
    
    @objc private func spriteModeButtonTapped() {
        // Toggle between tank and dolphin mode
        let currentMode = GameSettings.shared.spriteMode
        let newMode: SpriteMode = (currentMode == .tank) ? .dolphin : .tank
        GameSettings.shared.spriteMode = newMode
        updateSpriteModeButton()
    }
    
    @objc private func botCountChanged() {
        botCount = Int(botCountStepper.value)
        botCountLabel.text = "Bots: \(botCount)"
    }
    
    /// Create sprite mode toggle button
    private func createSpriteModeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        updateSpriteModeButtonTitle(button)
        return button
    }
    
    /// Update the sprite mode button title to reflect current mode
    private func updateSpriteModeButtonTitle(_ button: UIButton) {
        let mode = GameSettings.shared.spriteMode
        let title = mode.displayName
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    /// Update sprite mode button to reflect current state
    func updateSpriteModeButton() {
        updateSpriteModeButtonTitle(spriteModeButton)
    }
    
    /// Show single player mode UI
    func showSinglePlayerMode() {
        singlePlayerButton.isHidden = true
        hostButton.isHidden = true
        joinButton.isHidden = true
        instructionsLabel.isHidden = true
        botCountView.isHidden = false
        cancelButton.isHidden = false
        startGameButton.isHidden = false
        statusLabel.text = "Select opponent count"
    }
    
    /// Reset lobby to initial state
    func reset() {
        singlePlayerButton.isHidden = false
        hostButton.isHidden = false
        joinButton.isHidden = false
        instructionsLabel.isHidden = false
        spriteModeButton.isHidden = false
        botCountView.isHidden = true
        cancelButton.isHidden = true
        startGameButton.isHidden = true
        connectedPlayersView.isHidden = true
        peerTableView.isHidden = true
        emptyStateLabel.isHidden = true
        activityIndicator.stopAnimating()
        statusLabel.text = "Choose an option"
        updateSpriteModeButton()
    }
}
