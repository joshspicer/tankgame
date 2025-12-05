//
//  LobbyUI.swift
//  tankgame iOS
//
//  Created by jospicer on 10/28/25.
//

import UIKit
import MultipeerConnectivity

/// Manages the lobby user interface with classic retro styling
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
    private var titleLabel: UILabel!
    
    /// Number of AI bots to add
    var botCount: Int = 1
    
    // Callbacks
    var onHostTapped: (() -> Void)?
    var onJoinTapped: (() -> Void)?
    var onSinglePlayerTapped: (() -> Void)?
    var onCancelTapped: (() -> Void)?
    var onStartGameTapped: (() -> Void)?
    
    func setup(in parentView: UIView) {
        // Create lobby view with retro dark background
        lobbyView = UIView(frame: parentView.bounds)
        lobbyView.backgroundColor = RetroColors.lobbyBackground
        parentView.addSubview(lobbyView)
        
        // Title label with retro font
        titleLabel = UILabel()
        titleLabel.text = "TANK GAME"
        titleLabel.font = UIFont(name: "Courier-Bold", size: 36) ?? .systemFont(ofSize: 36, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = RetroColors.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(titleLabel)
        
        // Status label with retro font
        statusLabel = UILabel()
        statusLabel.text = "SELECT AN OPTION"
        statusLabel.font = UIFont(name: "Courier", size: 15) ?? .systemFont(ofSize: 15)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.textColor = RetroColors.textSecondary
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(statusLabel)
        
        // Instructions label
        instructionsLabel = UILabel()
        instructionsLabel.text = "2-4 PLAYERS - SAME NETWORK\nJOYSTICK TO MOVE - FIRE TO SHOOT"
        instructionsLabel.font = UIFont(name: "Courier", size: 12) ?? .systemFont(ofSize: 12)
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textColor = RetroColors.textMuted
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(instructionsLabel)
        
        // Single Player button
        singlePlayerButton = createRetroButton(title: "SINGLE PLAYER", backgroundColor: RetroColors.buttonWarning)
        singlePlayerButton.addTarget(self, action: #selector(singlePlayerButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(singlePlayerButton)
        
        // Host button
        hostButton = createRetroButton(title: "HOST GAME", backgroundColor: RetroColors.buttonPrimary)
        hostButton.addTarget(self, action: #selector(hostButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(hostButton)
        
        // Join button
        joinButton = createRetroButton(title: "JOIN GAME", backgroundColor: RetroColors.buttonSuccess)
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(joinButton)
        
        // Bot count selection view
        botCountView = UIView()
        botCountView.backgroundColor = RetroColors.buttonSecondary
        botCountView.layer.cornerRadius = 4
        botCountView.layer.borderWidth = 2
        botCountView.layer.borderColor = RetroColors.textSecondary.cgColor
        botCountView.isHidden = true
        botCountView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(botCountView)
        
        botCountLabel = UILabel()
        botCountLabel.text = "AI BOTS: 1"
        botCountLabel.font = UIFont(name: "Courier", size: 14) ?? .systemFont(ofSize: 14)
        botCountLabel.textAlignment = .center
        botCountLabel.textColor = RetroColors.textPrimary
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
        cancelButton.setTitle("CANCEL", for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "Courier-Bold", size: 16) ?? .systemFont(ofSize: 16, weight: .bold)
        cancelButton.setTitleColor(RetroColors.buttonDanger, for: .normal)
        cancelButton.isHidden = true
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(cancelButton)
        
        // Start Game button
        startGameButton = createRetroButton(title: "START GAME", backgroundColor: RetroColors.buttonSuccess)
        startGameButton.isHidden = true
        startGameButton.addTarget(self, action: #selector(startGameButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(startGameButton)
        
        // Connected players view
        connectedPlayersView = UIView()
        connectedPlayersView.backgroundColor = RetroColors.buttonSecondary
        connectedPlayersView.layer.cornerRadius = 4
        connectedPlayersView.layer.borderWidth = 2
        connectedPlayersView.layer.borderColor = RetroColors.textSecondary.cgColor
        connectedPlayersView.isHidden = true
        connectedPlayersView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(connectedPlayersView)
        
        connectedPlayersLabel = UILabel()
        connectedPlayersLabel.text = "CONNECTED: 1/4"
        connectedPlayersLabel.font = UIFont(name: "Courier", size: 14) ?? .systemFont(ofSize: 14)
        connectedPlayersLabel.textAlignment = .center
        connectedPlayersLabel.numberOfLines = 0
        connectedPlayersLabel.textColor = RetroColors.textPrimary
        connectedPlayersLabel.translatesAutoresizingMaskIntoConstraints = false
        connectedPlayersView.addSubview(connectedPlayersLabel)
        
        // Activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = RetroColors.textPrimary
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(activityIndicator)
        
        // Peer table view
        peerTableView = UITableView()
        peerTableView.isHidden = true
        peerTableView.layer.cornerRadius = 4
        peerTableView.layer.borderWidth = 2
        peerTableView.layer.borderColor = RetroColors.textSecondary.cgColor
        peerTableView.backgroundColor = RetroColors.lobbyBackground
        peerTableView.separatorColor = RetroColors.textMuted
        peerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PeerCell")
        peerTableView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(peerTableView)
        
        // Empty state label
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "NO NEARBY GAMES FOUND\nMAKE SURE OTHER DEVICE IS HOSTING"
        emptyStateLabel.font = UIFont(name: "Courier", size: 12) ?? .systemFont(ofSize: 12)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textColor = RetroColors.textMuted
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(emptyStateLabel)
        
        setupConstraints()
    }
    
    /// Create a retro-styled button
    private func createRetroButton(title: String, backgroundColor: PlatformColor) -> UIButton {
        let button = UIButton(type: .system)
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Courier-Bold", size: 16) ?? .systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: lobbyView.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            statusLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            instructionsLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
            instructionsLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            instructionsLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            singlePlayerButton.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 40),
            singlePlayerButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            singlePlayerButton.widthAnchor.constraint(equalToConstant: 220),
            singlePlayerButton.heightAnchor.constraint(equalToConstant: 50),
            
            hostButton.topAnchor.constraint(equalTo: singlePlayerButton.bottomAnchor, constant: 16),
            hostButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            hostButton.widthAnchor.constraint(equalToConstant: 220),
            hostButton.heightAnchor.constraint(equalToConstant: 50),
            
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 16),
            joinButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            joinButton.widthAnchor.constraint(equalToConstant: 220),
            joinButton.heightAnchor.constraint(equalToConstant: 50),
            
            spriteModeButton.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 20),
            spriteModeButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            spriteModeButton.widthAnchor.constraint(equalToConstant: 180),
            spriteModeButton.heightAnchor.constraint(equalToConstant: 40),
            
            botCountView.topAnchor.constraint(equalTo: spriteModeButton.bottomAnchor, constant: 16),
            botCountView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            botCountView.widthAnchor.constraint(equalToConstant: 200),
            botCountView.heightAnchor.constraint(equalToConstant: 50),
            
            botCountLabel.leadingAnchor.constraint(equalTo: botCountView.leadingAnchor, constant: 16),
            botCountLabel.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            
            botCountStepper.trailingAnchor.constraint(equalTo: botCountView.trailingAnchor, constant: -16),
            botCountStepper.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: botCountView.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            connectedPlayersView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            connectedPlayersView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            connectedPlayersView.widthAnchor.constraint(equalToConstant: 260),
            connectedPlayersView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70),
            
            connectedPlayersLabel.topAnchor.constraint(equalTo: connectedPlayersView.topAnchor, constant: 16),
            connectedPlayersLabel.leadingAnchor.constraint(equalTo: connectedPlayersView.leadingAnchor, constant: 16),
            connectedPlayersLabel.trailingAnchor.constraint(equalTo: connectedPlayersView.trailingAnchor, constant: -16),
            connectedPlayersLabel.bottomAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: -16),
            
            startGameButton.topAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: 20),
            startGameButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            startGameButton.widthAnchor.constraint(equalToConstant: 220),
            startGameButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            
            peerTableView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            peerTableView.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            peerTableView.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            peerTableView.heightAnchor.constraint(equalToConstant: 180),
            
            emptyStateLabel.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 40),
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
        botCountLabel.text = "AI BOTS: \(botCount)"
    }
    
    /// Create sprite mode toggle button with retro styling
    private func createSpriteModeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = RetroColors.buttonSecondary
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 2
        button.layer.borderColor = RetroColors.textSecondary.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        updateSpriteModeButtonTitle(button)
        
        return button
    }
    
    /// Update the sprite mode button title
    private func updateSpriteModeButtonTitle(_ button: UIButton) {
        let mode = GameSettings.shared.spriteMode
        let title = "\(mode.displayName.uppercased()) MODE"
        button.setTitle(title, for: .normal)
        button.setTitleColor(RetroColors.textPrimary, for: .normal)
        button.titleLabel?.font = UIFont(name: "Courier-Bold", size: 14) ?? .systemFont(ofSize: 14, weight: .bold)
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
        statusLabel.text = "SINGLE PLAYER MODE\nSELECT AI OPPONENTS"
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
        statusLabel.text = "SELECT AN OPTION"
        updateSpriteModeButton()
    }
}
