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
    
    // Modern UI Components
    private var animatedBackground: AnimatedBackgroundView?
    private var animatedTitle: AnimatedTitleView?
    
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
        
        // Add animated background
        let background = AnimatedBackgroundView(frame: parentView.bounds)
        background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        lobbyView.addSubview(background)
        background.startAnimating()
        animatedBackground = background
        
        // Add animated title view
        let titleView = AnimatedTitleView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(titleView)
        animatedTitle = titleView
        
        // Status label
        statusLabel = UILabel()
        statusLabel.text = "Choose an option to start"
        statusLabel.font = .systemFont(ofSize: 17, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(statusLabel)
        
        // Instructions label
        instructionsLabel = UILabel()
        instructionsLabel.text = "Battle with 2-4 players on the same network!\nMove with the joystick, tap FIRE to shoot."
        instructionsLabel.font = .systemFont(ofSize: 14, weight: .regular)
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(instructionsLabel)
        
        // Single Player button (with AI bots) - Using modern style
        singlePlayerButton = ModernButtonStyle.createGradientButton(
            title: "Single Player",
            icon: "🤖",
            gradientStart: ModernButtonStyle.Colors.warningGradientStart,
            gradientEnd: ModernButtonStyle.Colors.warningGradientEnd
        )
        singlePlayerButton.addTarget(self, action: #selector(singlePlayerButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(singlePlayerButton)
        
        // Host button - Using modern style
        hostButton = ModernButtonStyle.createGradientButton(
            title: "Host Game",
            icon: "🎯",
            gradientStart: ModernButtonStyle.Colors.primaryGradientStart,
            gradientEnd: ModernButtonStyle.Colors.primaryGradientEnd
        )
        hostButton.addTarget(self, action: #selector(hostButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(hostButton)
        
        // Join button - Using modern style
        joinButton = ModernButtonStyle.createGradientButton(
            title: "Join Game",
            icon: "🔍",
            gradientStart: ModernButtonStyle.Colors.secondaryGradientStart,
            gradientEnd: ModernButtonStyle.Colors.secondaryGradientEnd
        )
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(joinButton)
        
        // Bot count selection view (for single player mode)
        botCountView = UIView()
        botCountView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        botCountView.layer.cornerRadius = 14
        botCountView.layer.borderWidth = 1
        botCountView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        botCountView.isHidden = true
        botCountView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(botCountView)
        
        botCountLabel = UILabel()
        botCountLabel.text = "AI Bots: 1"
        botCountLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        botCountLabel.textColor = .white
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
        cancelButton.setTitle("✕ Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        cancelButton.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .normal)
        cancelButton.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        cancelButton.layer.cornerRadius = 12
        cancelButton.isHidden = true
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(cancelButton)
        
        // Start Game button (for host) - Using modern style
        startGameButton = ModernButtonStyle.createGradientButton(
            title: "Start Game",
            icon: "🚀",
            gradientStart: ModernButtonStyle.Colors.secondaryGradientStart,
            gradientEnd: ModernButtonStyle.Colors.secondaryGradientEnd
        )
        startGameButton.isHidden = true
        startGameButton.addTarget(self, action: #selector(startGameButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(startGameButton)
        ModernButtonStyle.addPulseAnimation(to: startGameButton)
        
        // Connected players view
        connectedPlayersView = UIView()
        connectedPlayersView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        connectedPlayersView.layer.cornerRadius = 14
        connectedPlayersView.layer.borderWidth = 1
        connectedPlayersView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        connectedPlayersView.isHidden = true
        connectedPlayersView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(connectedPlayersView)
        
        connectedPlayersLabel = UILabel()
        connectedPlayersLabel.text = "Connected: 1/4"
        connectedPlayersLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        connectedPlayersLabel.textColor = .white
        connectedPlayersLabel.textAlignment = .center
        connectedPlayersLabel.numberOfLines = 0
        connectedPlayersLabel.translatesAutoresizingMaskIntoConstraints = false
        connectedPlayersView.addSubview(connectedPlayersLabel)
        
        // Activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(activityIndicator)
        
        // Peer table view
        peerTableView = UITableView()
        peerTableView.isHidden = true
        peerTableView.layer.cornerRadius = 14
        peerTableView.layer.borderWidth = 1
        peerTableView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        peerTableView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        peerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PeerCell")
        peerTableView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(peerTableView)
        
        // Empty state label
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "No nearby games found.\nMake sure the other device is hosting."
        emptyStateLabel.font = .systemFont(ofSize: 14)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(emptyStateLabel)
        
        setupConstraints()
        
        // Play entrance animation
        animatedTitle?.playEntranceAnimation()
    }
    
    private func setupConstraints() {
        guard let titleView = animatedTitle else { return }
        
        NSLayoutConstraint.activate([
            // Title view at top
            titleView.topAnchor.constraint(equalTo: lobbyView.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleView.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 20),
            titleView.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            statusLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            instructionsLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            instructionsLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            instructionsLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            singlePlayerButton.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 30),
            singlePlayerButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            hostButton.topAnchor.constraint(equalTo: singlePlayerButton.bottomAnchor, constant: 16),
            hostButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 16),
            joinButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            spriteModeButton.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 20),
            spriteModeButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            spriteModeButton.widthAnchor.constraint(equalToConstant: 200),
            spriteModeButton.heightAnchor.constraint(equalToConstant: 44),
            
            botCountView.topAnchor.constraint(equalTo: spriteModeButton.bottomAnchor, constant: 16),
            botCountView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            botCountView.widthAnchor.constraint(equalToConstant: 220),
            botCountView.heightAnchor.constraint(equalToConstant: 54),
            
            botCountLabel.leadingAnchor.constraint(equalTo: botCountView.leadingAnchor, constant: 16),
            botCountLabel.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            
            botCountStepper.trailingAnchor.constraint(equalTo: botCountView.trailingAnchor, constant: -16),
            botCountStepper.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: botCountView.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 140),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
            
            connectedPlayersView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            connectedPlayersView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            connectedPlayersView.widthAnchor.constraint(equalToConstant: 280),
            connectedPlayersView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            connectedPlayersLabel.topAnchor.constraint(equalTo: connectedPlayersView.topAnchor, constant: 16),
            connectedPlayersLabel.leadingAnchor.constraint(equalTo: connectedPlayersView.leadingAnchor, constant: 16),
            connectedPlayersLabel.trailingAnchor.constraint(equalTo: connectedPlayersView.trailingAnchor, constant: -16),
            connectedPlayersLabel.bottomAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: -16),
            
            startGameButton.topAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: 20),
            startGameButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            
            peerTableView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            peerTableView.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            peerTableView.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            peerTableView.heightAnchor.constraint(equalToConstant: 200),
            
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
        botCountLabel.text = "AI Bots: \(botCount)"
    }
    
    /// Create sprite mode toggle button
    private func createSpriteModeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        updateSpriteModeButtonTitle(button)
        
        return button
    }
    
    /// Update the sprite mode button title to reflect current mode
    private func updateSpriteModeButtonTitle(_ button: UIButton) {
        let mode = GameSettings.shared.spriteMode
        let title = "\(mode.icon) \(mode.displayName) Mode"
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    }
    
    /// Update sprite mode button to reflect current state
    func updateSpriteModeButton() {
        updateSpriteModeButtonTitle(spriteModeButton)
        // Update the title view icon as well
        animatedTitle?.updateIcon(for: GameSettings.shared.spriteMode)
    }
    
    /// Show single player mode UI
    func showSinglePlayerMode() {
        // Animate buttons out
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.singlePlayerButton.alpha = 0
            self.singlePlayerButton.transform = CGAffineTransform(translationX: -50, y: 0)
            self.hostButton.alpha = 0
            self.hostButton.transform = CGAffineTransform(translationX: -50, y: 0)
            self.joinButton.alpha = 0
            self.joinButton.transform = CGAffineTransform(translationX: -50, y: 0)
        } completion: { _ in
            self.singlePlayerButton.isHidden = true
            self.hostButton.isHidden = true
            self.joinButton.isHidden = true
        }
        
        instructionsLabel.isHidden = true
        botCountView.isHidden = false
        cancelButton.isHidden = false
        startGameButton.isHidden = false
        
        // Animate new elements in
        botCountView.alpha = 0
        cancelButton.alpha = 0
        startGameButton.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0.2) {
            self.botCountView.alpha = 1
            self.cancelButton.alpha = 1
            self.startGameButton.alpha = 1
        }
        
        statusLabel.text = "Single Player Mode\nSelect number of AI opponents"
    }
    
    /// Reset lobby to initial state
    func reset() {
        // Reset visibility
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
        statusLabel.text = "Choose an option to start"
        updateSpriteModeButton()
        
        // Reset transforms
        singlePlayerButton.alpha = 1
        singlePlayerButton.transform = .identity
        hostButton.alpha = 1
        hostButton.transform = .identity
        joinButton.alpha = 1
        joinButton.transform = .identity
    }
}
