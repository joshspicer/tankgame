//
//  LobbyUI.swift
//  tankgame iOS
//
//  Created by jospicer on 10/28/25.
//

import UIKit
import MultipeerConnectivity
import QuartzCore

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
    private(set) var peerTableView: UITableView!
    private(set) var connectedPlayersView: UIView!
    private(set) var connectedPlayersLabel: UILabel!
    private(set) var statusLabel: UILabel!
    private(set) var instructionsLabel: UILabel!
    private(set) var emptyStateLabel: UILabel!
    private(set) var activityIndicator: UIActivityIndicatorView!
    
    // Bot count selector
    private var botCountSelector = BotCountSelector()
    
    /// Number of AI bots to add
    var botCount: Int {
        get { botCountSelector.botCount }
        set { 
            botCountSelector.botCount = newValue
            botCountSelector.stepper.value = Double(newValue)
            botCountSelector.label.text = "AI Bots: \(newValue)"
        }
    }
    
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
        
        // Add gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = parentView.bounds
        gradientLayer.colors = [
            UIColor.systemBlue.withAlphaComponent(0.1).cgColor,
            UIColor.systemBackground.cgColor,
            UIColor.systemGreen.withAlphaComponent(0.05).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        lobbyView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "TANK GAME"
        titleLabel.font = .systemFont(ofSize: 48, weight: .black)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(titleLabel)
        
        // Tank emoji below title
        let tankEmojiLabel = UILabel()
        tankEmojiLabel.text = "🎯"
        tankEmojiLabel.font = .systemFont(ofSize: 60)
        tankEmojiLabel.textAlignment = .center
        tankEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(tankEmojiLabel)
        
        // Status label
        statusLabel = UILabel()
        statusLabel.text = "Choose an option to start"
        statusLabel.font = .systemFont(ofSize: 17, weight: .regular)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.textColor = .secondaryLabel
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(statusLabel)
        
        // Instructions label
        instructionsLabel = UILabel()
        instructionsLabel.text = "Battle with 2-4 players on the same network!\nMove with the joystick, tap FIRE to shoot."
        instructionsLabel.font = .systemFont(ofSize: 15, weight: .regular)
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textColor = .tertiaryLabel
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(instructionsLabel)
        
        // Single Player button (with AI bots)
        singlePlayerButton = LobbyUIButtonFactory.createButton(title: "Single Player", backgroundColor: .systemOrange, icon: "🤖")
        singlePlayerButton.addTarget(self, action: #selector(singlePlayerButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(singlePlayerButton)
        
        // Host button
        hostButton = LobbyUIButtonFactory.createButton(title: "Host Game", backgroundColor: .systemBlue, icon: "🎯")
        hostButton.addTarget(self, action: #selector(hostButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(hostButton)
        
        // Join button
        joinButton = LobbyUIButtonFactory.createButton(title: "Join Game", backgroundColor: .systemGreen, icon: "🔍")
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(joinButton)
        
        // Bot count selection view (for single player mode)
        let botCountView = botCountSelector.setup()
        lobbyView.addSubview(botCountView)
        
        // Sprite mode toggle button
        spriteModeButton = LobbyUIButtonFactory.createSpriteModeButton()
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
        startGameButton = LobbyUIButtonFactory.createButton(title: "Start Game", backgroundColor: .systemGreen, icon: "🚀")
        startGameButton.isHidden = true
        startGameButton.addTarget(self, action: #selector(startGameButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(startGameButton)
        
        // Connected players view
        connectedPlayersView = UIView()
        connectedPlayersView.backgroundColor = .secondarySystemBackground
        connectedPlayersView.layer.cornerRadius = 12
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
        peerTableView.layer.cornerRadius = 12
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
        
        // Setup all constraints
        LobbyUIConstraints.setupConstraints(
            in: lobbyView,
            titleLabel: titleLabel,
            tankEmojiLabel: tankEmojiLabel,
            statusLabel: statusLabel,
            instructionsLabel: instructionsLabel,
            singlePlayerButton: singlePlayerButton,
            hostButton: hostButton,
            joinButton: joinButton,
            spriteModeButton: spriteModeButton,
            botCountView: botCountView,
            cancelButton: cancelButton,
            connectedPlayersView: connectedPlayersView,
            connectedPlayersLabel: connectedPlayersLabel,
            startGameButton: startGameButton,
            activityIndicator: activityIndicator,
            peerTableView: peerTableView,
            emptyStateLabel: emptyStateLabel
        )
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
    
    /// Update sprite mode button to reflect current state
    func updateSpriteModeButton() {
        LobbyUIButtonFactory.updateSpriteModeButtonTitle(spriteModeButton)
    }
    
    /// Show single player mode UI
    func showSinglePlayerMode() {
        singlePlayerButton.isHidden = true
        hostButton.isHidden = true
        joinButton.isHidden = true
        instructionsLabel.isHidden = true
        botCountSelector.containerView.isHidden = false
        cancelButton.isHidden = false
        startGameButton.isHidden = false
        statusLabel.text = "Single Player Mode\nSelect number of AI opponents"
    }
    
    /// Reset lobby to initial state
    func reset() {
        singlePlayerButton.isHidden = false
        hostButton.isHidden = false
        joinButton.isHidden = false
        instructionsLabel.isHidden = false
        spriteModeButton.isHidden = false
        botCountSelector.containerView.isHidden = true
        cancelButton.isHidden = true
        startGameButton.isHidden = true
        connectedPlayersView.isHidden = true
        peerTableView.isHidden = true
        emptyStateLabel.isHidden = true
        activityIndicator.stopAnimating()
        statusLabel.text = "Choose an option to start"
        updateSpriteModeButton()
    }
}
