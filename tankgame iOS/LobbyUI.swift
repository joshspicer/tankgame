//
//  LobbyUI.swift
//  tankgame iOS
//
//  Created by jospicer on 10/28/25.
//

import UIKit
import MultipeerConnectivity
import QuartzCore

/// Manages the lobby user interface with modern dark theme
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
    
    private var backgroundGradient: CAGradientLayer?
    private var titleLabel: UILabel!
    private var tankEmojiLabel: UILabel!
    
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
        lobbyView.backgroundColor = UITheme.Colors.backgroundDark
        parentView.addSubview(lobbyView)
        
        // Add gradient background
        let gradientLayer = UITheme.Gradients.backgroundGradient()
        gradientLayer.frame = parentView.bounds
        lobbyView.layer.insertSublayer(gradientLayer, at: 0)
        backgroundGradient = gradientLayer
        
        // Title label with glow effect
        titleLabel = UILabel()
        titleLabel.text = "TANK GAME"
        titleLabel.font = UITheme.Typography.titleFont
        titleLabel.textAlignment = .center
        titleLabel.textColor = UITheme.Colors.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.layer.shadowColor = UITheme.Colors.primary.cgColor
        titleLabel.layer.shadowOffset = .zero
        titleLabel.layer.shadowRadius = 15
        titleLabel.layer.shadowOpacity = 0.6
        lobbyView.addSubview(titleLabel)
        
        // Tank emoji below title with animation
        tankEmojiLabel = UILabel()
        tankEmojiLabel.text = "🎯"
        tankEmojiLabel.font = .systemFont(ofSize: 70)
        tankEmojiLabel.textAlignment = .center
        tankEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(tankEmojiLabel)
        
        // Animate the emoji
        startEmojiAnimation()
        
        // Status label
        statusLabel = UILabel()
        statusLabel.text = "Choose an option to start"
        statusLabel.font = UITheme.Typography.bodyFont
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.textColor = UITheme.Colors.textSecondary
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(statusLabel)
        
        // Instructions label
        instructionsLabel = UILabel()
        instructionsLabel.text = "Battle with 2-4 players on the same network!\nMove with the joystick, tap FIRE to shoot."
        instructionsLabel.font = UITheme.Typography.captionFont
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textColor = UITheme.Colors.textMuted
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(instructionsLabel)
        
        // Single Player button (with AI bots)
        singlePlayerButton = createModernButton(title: "Single Player", style: .accent, icon: "🤖")
        singlePlayerButton.addTarget(self, action: #selector(singlePlayerButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(singlePlayerButton)
        
        // Host button
        hostButton = createModernButton(title: "Host Game", style: .primary, icon: "📡")
        hostButton.addTarget(self, action: #selector(hostButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(hostButton)
        
        // Join button
        joinButton = createModernButton(title: "Join Game", style: .secondary, icon: "🔍")
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(joinButton)
        
        // Bot count selection view (for single player mode)
        botCountView = createCardView()
        botCountView.isHidden = true
        lobbyView.addSubview(botCountView)
        
        botCountLabel = UILabel()
        botCountLabel.text = "AI Bots: 1"
        botCountLabel.font = UITheme.Typography.bodyFont
        botCountLabel.textColor = UITheme.Colors.textPrimary
        botCountLabel.textAlignment = .center
        botCountLabel.translatesAutoresizingMaskIntoConstraints = false
        botCountView.addSubview(botCountLabel)
        
        botCountStepper = UIStepper()
        botCountStepper.minimumValue = 1
        botCountStepper.maximumValue = 3
        botCountStepper.value = 1
        botCountStepper.tintColor = UITheme.Colors.primary
        botCountStepper.addTarget(self, action: #selector(botCountChanged), for: .valueChanged)
        botCountStepper.translatesAutoresizingMaskIntoConstraints = false
        botCountView.addSubview(botCountStepper)
        
        // Sprite mode toggle button
        spriteModeButton = createSpriteModeButton()
        spriteModeButton.addTarget(self, action: #selector(spriteModeButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(spriteModeButton)
        
        // Cancel button with modern styling
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("← Cancel", for: .normal)
        cancelButton.titleLabel?.font = UITheme.Typography.bodyFont
        cancelButton.setTitleColor(UITheme.Colors.danger, for: .normal)
        cancelButton.isHidden = true
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(cancelButton)
        
        // Start Game button (for host)
        startGameButton = createModernButton(title: "Start Game", style: .secondary, icon: "🚀")
        startGameButton.isHidden = true
        startGameButton.addTarget(self, action: #selector(startGameButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(startGameButton)
        
        // Connected players view with modern card style
        connectedPlayersView = createCardView()
        connectedPlayersView.isHidden = true
        connectedPlayersView.layer.borderColor = UITheme.Colors.primary.withAlphaComponent(0.3).cgColor
        connectedPlayersView.layer.borderWidth = 1
        lobbyView.addSubview(connectedPlayersView)
        
        connectedPlayersLabel = UILabel()
        connectedPlayersLabel.text = "Connected: 1/4"
        connectedPlayersLabel.font = UITheme.Typography.bodyFont
        connectedPlayersLabel.textColor = UITheme.Colors.textPrimary
        connectedPlayersLabel.textAlignment = .center
        connectedPlayersLabel.numberOfLines = 0
        connectedPlayersLabel.translatesAutoresizingMaskIntoConstraints = false
        connectedPlayersView.addSubview(connectedPlayersLabel)
        
        // Activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = UITheme.Colors.primary
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(activityIndicator)
        
        // Peer table view with dark theme
        peerTableView = UITableView()
        peerTableView.isHidden = true
        peerTableView.backgroundColor = UITheme.Colors.cardBackground
        peerTableView.layer.cornerRadius = UITheme.Dimensions.cardCornerRadius
        peerTableView.layer.borderWidth = 1
        peerTableView.layer.borderColor = UITheme.Colors.borderLight.cgColor
        peerTableView.separatorColor = UITheme.Colors.borderLight
        peerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PeerCell")
        peerTableView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(peerTableView)
        
        // Empty state label
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "No nearby games found.\nMake sure the other device is hosting."
        emptyStateLabel.font = UITheme.Typography.captionFont
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textColor = UITheme.Colors.textMuted
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(emptyStateLabel)
        
        setupConstraints()
    }
    
    /// Start the emoji bounce animation
    private func startEmojiAnimation() {
        UIView.animate(withDuration: 1.5, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            self.tankEmojiLabel.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }
    }
    
    /// Button style enum for modern buttons
    enum ButtonStyle {
        case primary
        case secondary
        case accent
    }
    
    /// Create a modern styled button with gradient
    private func createModernButton(title: String, style: ButtonStyle, icon: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Background view for gradient
        let backgroundView = UIView()
        backgroundView.isUserInteractionEnabled = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.layer.cornerRadius = UITheme.Dimensions.buttonCornerRadius
        backgroundView.clipsToBounds = true
        button.insertSubview(backgroundView, at: 0)
        
        // Add gradient based on style
        let gradientLayer: CAGradientLayer
        switch style {
        case .primary:
            gradientLayer = UITheme.Gradients.primaryButtonGradient()
        case .secondary:
            gradientLayer = UITheme.Gradients.secondaryButtonGradient()
        case .accent:
            gradientLayer = UITheme.Gradients.accentButtonGradient()
        }
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UITheme.Dimensions.buttonWidth, height: UITheme.Dimensions.buttonHeight)
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Create stack view for icon and text
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 24)
        
        let textLabel = UILabel()
        textLabel.text = title
        textLabel.font = UITheme.Typography.buttonFont
        textLabel.textColor = UITheme.Colors.textPrimary
        
        stackView.addArrangedSubview(iconLabel)
        stackView.addArrangedSubview(textLabel)
        
        button.addSubview(stackView)
        
        // Apply shadow
        UITheme.Shadows.buttonShadow(for: button.layer)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: button.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: button.bottomAnchor),
            
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        return button
    }
    
    /// Create a card view with dark theme styling
    private func createCardView() -> UIView {
        let view = UIView()
        view.backgroundColor = UITheme.Colors.cardBackground
        view.layer.cornerRadius = UITheme.Dimensions.cardCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        UITheme.Shadows.cardShadow(for: view.layer)
        return view
    }
    
    private func setupConstraints() {
        let buttonWidth = UITheme.Dimensions.buttonWidth
        let buttonHeight = UITheme.Dimensions.buttonHeight
        
        NSLayoutConstraint.activate([
            tankEmojiLabel.topAnchor.constraint(equalTo: lobbyView.safeAreaLayoutGuide.topAnchor, constant: 35),
            tankEmojiLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: tankEmojiLabel.bottomAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            statusLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            instructionsLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            instructionsLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            instructionsLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            singlePlayerButton.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 30),
            singlePlayerButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            singlePlayerButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            singlePlayerButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            hostButton.topAnchor.constraint(equalTo: singlePlayerButton.bottomAnchor, constant: 16),
            hostButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            hostButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            hostButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 16),
            joinButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            joinButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            joinButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            spriteModeButton.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 16),
            spriteModeButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            spriteModeButton.widthAnchor.constraint(equalToConstant: 200),
            spriteModeButton.heightAnchor.constraint(equalToConstant: 44),
            
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
            connectedPlayersView.widthAnchor.constraint(equalToConstant: 280),
            connectedPlayersView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            connectedPlayersLabel.topAnchor.constraint(equalTo: connectedPlayersView.topAnchor, constant: 16),
            connectedPlayersLabel.leadingAnchor.constraint(equalTo: connectedPlayersView.leadingAnchor, constant: 16),
            connectedPlayersLabel.trailingAnchor.constraint(equalTo: connectedPlayersView.trailingAnchor, constant: -16),
            connectedPlayersLabel.bottomAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: -16),
            
            startGameButton.topAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: 20),
            startGameButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            startGameButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            startGameButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
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
    
    /// Create sprite mode toggle button with dark theme
    private func createSpriteModeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UITheme.Colors.cardBackground
        button.layer.cornerRadius = UITheme.Dimensions.cardCornerRadius
        button.layer.borderWidth = 1
        button.layer.borderColor = UITheme.Colors.borderLight.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        updateSpriteModeButtonTitle(button)
        
        return button
    }
    
    /// Update the sprite mode button title to reflect current mode
    private func updateSpriteModeButtonTitle(_ button: UIButton) {
        let mode = GameSettings.shared.spriteMode
        let title = "\(mode.icon) \(mode.displayName) Mode"
        button.setTitle(title, for: .normal)
        button.setTitleColor(UITheme.Colors.textSecondary, for: .normal)
        button.titleLabel?.font = UITheme.Typography.bodyFont
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
        statusLabel.text = "Single Player Mode\nSelect number of AI opponents"
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
        statusLabel.text = "Choose an option to start"
        updateSpriteModeButton()
    }
}
