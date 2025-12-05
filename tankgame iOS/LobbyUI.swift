//
//  LobbyUI.swift
//  tankgame iOS
//
//  Created by jospicer on 10/28/25.
//

import UIKit
import MultipeerConnectivity
import QuartzCore

/// Manages the lobby user interface with premium visual design
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
    
    // Private UI elements for premium design
    private var titleLabel: UILabel!
    private var iconLabel: UILabel!
    private var gradientLayer: CAGradientLayer!
    private var particleLayer: CAEmitterLayer?
    
    /// Number of AI bots to add
    var botCount: Int = 1
    
    // Callbacks
    var onHostTapped: (() -> Void)?
    var onJoinTapped: (() -> Void)?
    var onSinglePlayerTapped: (() -> Void)?
    var onCancelTapped: (() -> Void)?
    var onStartGameTapped: (() -> Void)?
    
    func setup(in parentView: UIView) {
        // Create lobby view with dark theme
        lobbyView = UIView(frame: parentView.bounds)
        lobbyView.backgroundColor = UIColor(red: 0.05, green: 0.08, blue: 0.15, alpha: 1.0)
        parentView.addSubview(lobbyView)
        
        // Add premium animated gradient background
        gradientLayer = LobbyUIEffects.createAnimatedGradient(frame: parentView.bounds)
        lobbyView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Add subtle particle effect
        particleLayer = LobbyUIEffects.createParticleEffect(in: lobbyView)
        if let particles = particleLayer {
            lobbyView.layer.addSublayer(particles)
        }
        
        // Title label with premium styling
        titleLabel = UILabel()
        titleLabel.text = "TANK GAME"
        titleLabel.font = LobbyUITheme.titleFont
        titleLabel.textAlignment = .center
        titleLabel.textColor = LobbyUITheme.titleColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add glow effect to title
        titleLabel.layer.shadowColor = LobbyUITheme.accentBlue.cgColor
        titleLabel.layer.shadowOpacity = 0.8
        titleLabel.layer.shadowOffset = .zero
        titleLabel.layer.shadowRadius = 15
        lobbyView.addSubview(titleLabel)
        
        // Tank emoji with animation
        iconLabel = UILabel()
        iconLabel.text = "🎮"
        iconLabel.font = .systemFont(ofSize: 70)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(iconLabel)
        
        // Add floating animation to icon
        addFloatingAnimation(to: iconLabel)
        
        // Status label with modern styling
        statusLabel = UILabel()
        statusLabel.text = "Choose your battle mode"
        statusLabel.font = LobbyUITheme.subtitleFont
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.textColor = LobbyUITheme.subtitleColor
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(statusLabel)
        
        // Instructions label
        instructionsLabel = UILabel()
        instructionsLabel.text = "Battle with 2-4 players on the same network\nMove with joystick • Tap FIRE to shoot"
        instructionsLabel.font = LobbyUITheme.bodyFont
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textColor = LobbyUITheme.bodyTextColor
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(instructionsLabel)
        
        // Create premium buttons
        singlePlayerButton = createPremiumButton(
            title: "Single Player",
            icon: "🤖",
            colors: [LobbyUITheme.accentOrange, LobbyUITheme.accentOrange.withAlphaComponent(0.7)]
        )
        singlePlayerButton.addTarget(self, action: #selector(singlePlayerButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(singlePlayerButton)
        
        hostButton = createPremiumButton(
            title: "Host Game",
            icon: "🎯",
            colors: [LobbyUITheme.accentBlue, LobbyUITheme.accentPurple]
        )
        hostButton.addTarget(self, action: #selector(hostButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(hostButton)
        
        joinButton = createPremiumButton(
            title: "Join Game",
            icon: "🔍",
            colors: [LobbyUITheme.accentGreen, LobbyUITheme.accentGreen.withAlphaComponent(0.6)]
        )
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(joinButton)
        
        // Bot count selection view with glass effect
        botCountView = UIView()
        botCountView.backgroundColor = LobbyUITheme.glassBackgroundColor
        botCountView.layer.cornerRadius = LobbyUITheme.cardCornerRadius
        botCountView.layer.borderWidth = 1
        botCountView.layer.borderColor = LobbyUITheme.glassBorderColor.cgColor
        botCountView.isHidden = true
        botCountView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(botCountView)
        
        botCountLabel = UILabel()
        botCountLabel.text = "AI Bots: 1"
        botCountLabel.font = LobbyUITheme.subtitleFont
        botCountLabel.textColor = LobbyUITheme.titleColor
        botCountLabel.textAlignment = .center
        botCountLabel.translatesAutoresizingMaskIntoConstraints = false
        botCountView.addSubview(botCountLabel)
        
        botCountStepper = UIStepper()
        botCountStepper.minimumValue = 1
        botCountStepper.maximumValue = 3
        botCountStepper.value = 1
        botCountStepper.tintColor = LobbyUITheme.accentBlue
        botCountStepper.addTarget(self, action: #selector(botCountChanged), for: .valueChanged)
        botCountStepper.translatesAutoresizingMaskIntoConstraints = false
        botCountView.addSubview(botCountStepper)
        
        // Sprite mode toggle button with glass styling
        spriteModeButton = createSpriteModeButton()
        spriteModeButton.addTarget(self, action: #selector(spriteModeButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(spriteModeButton)
        
        // Cancel button with modern styling
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("← Cancel", for: .normal)
        cancelButton.titleLabel?.font = LobbyUITheme.subtitleFont
        cancelButton.setTitleColor(LobbyUITheme.accentRed, for: .normal)
        cancelButton.isHidden = true
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(cancelButton)
        
        // Start Game button with premium styling
        startGameButton = createPremiumButton(
            title: "Start Game",
            icon: "🚀",
            colors: [LobbyUITheme.accentGreen, LobbyUITheme.accentGreen.withAlphaComponent(0.6)]
        )
        startGameButton.isHidden = true
        startGameButton.addTarget(self, action: #selector(startGameButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(startGameButton)
        
        // Connected players view with glass effect
        connectedPlayersView = UIView()
        connectedPlayersView.backgroundColor = LobbyUITheme.glassBackgroundColor
        connectedPlayersView.layer.cornerRadius = LobbyUITheme.cardCornerRadius
        connectedPlayersView.layer.borderWidth = 1
        connectedPlayersView.layer.borderColor = LobbyUITheme.glassBorderColor.cgColor
        connectedPlayersView.isHidden = true
        connectedPlayersView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(connectedPlayersView)
        
        connectedPlayersLabel = UILabel()
        connectedPlayersLabel.text = "Connected: 1/4"
        connectedPlayersLabel.font = LobbyUITheme.subtitleFont
        connectedPlayersLabel.textColor = LobbyUITheme.titleColor
        connectedPlayersLabel.textAlignment = .center
        connectedPlayersLabel.numberOfLines = 0
        connectedPlayersLabel.translatesAutoresizingMaskIntoConstraints = false
        connectedPlayersView.addSubview(connectedPlayersLabel)
        
        // Activity indicator with accent color
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = LobbyUITheme.accentBlue
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(activityIndicator)
        
        // Peer table view with dark theme
        peerTableView = UITableView()
        peerTableView.isHidden = true
        peerTableView.backgroundColor = LobbyUITheme.glassBackgroundColor
        peerTableView.layer.cornerRadius = LobbyUITheme.cardCornerRadius
        peerTableView.layer.borderWidth = 1
        peerTableView.layer.borderColor = LobbyUITheme.glassBorderColor.cgColor
        peerTableView.separatorColor = LobbyUITheme.glassBorderColor
        peerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PeerCell")
        peerTableView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(peerTableView)
        
        // Empty state label with theme styling
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "No nearby games found\nMake sure the other device is hosting"
        emptyStateLabel.font = LobbyUITheme.bodyFont
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textColor = LobbyUITheme.bodyTextColor
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(emptyStateLabel)
        
        setupConstraints()
    }
    
    /// Create a premium button with gradient background
    private func createPremiumButton(title: String, icon: String, colors: [UIColor]) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Add gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = LobbyUITheme.buttonCornerRadius
        gradientLayer.frame = CGRect(x: 0, y: 0, width: LobbyUITheme.buttonWidth, height: LobbyUITheme.buttonHeight)
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        // Add glow effect
        button.layer.shadowColor = colors.first?.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 12
        
        // Configure button appearance
        button.layer.cornerRadius = LobbyUITheme.buttonCornerRadius
        button.clipsToBounds = false
        
        // Create content stack
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: LobbyUITheme.iconSize)
        
        let textLabel = UILabel()
        textLabel.text = title
        textLabel.font = LobbyUITheme.buttonFont
        textLabel.textColor = .white
        
        stackView.addArrangedSubview(iconLabel)
        stackView.addArrangedSubview(textLabel)
        
        button.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        // Add press animation
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return button
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            sender.alpha = 0.9
        }
    }
    
    @objc private func buttonReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }
    
    /// Add floating animation to a view
    private func addFloatingAnimation(to view: UIView) {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = 0
        animation.toValue = -10
        animation.duration = 1.5
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(animation, forKey: "floating")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: lobbyView.safeAreaLayoutGuide.topAnchor, constant: 30),
            iconLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            statusLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            instructionsLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 6),
            instructionsLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            instructionsLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            singlePlayerButton.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 28),
            singlePlayerButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            singlePlayerButton.widthAnchor.constraint(equalToConstant: LobbyUITheme.buttonWidth),
            singlePlayerButton.heightAnchor.constraint(equalToConstant: LobbyUITheme.buttonHeight),
            
            hostButton.topAnchor.constraint(equalTo: singlePlayerButton.bottomAnchor, constant: LobbyUITheme.buttonSpacing),
            hostButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            hostButton.widthAnchor.constraint(equalToConstant: LobbyUITheme.buttonWidth),
            hostButton.heightAnchor.constraint(equalToConstant: LobbyUITheme.buttonHeight),
            
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: LobbyUITheme.buttonSpacing),
            joinButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            joinButton.widthAnchor.constraint(equalToConstant: LobbyUITheme.buttonWidth),
            joinButton.heightAnchor.constraint(equalToConstant: LobbyUITheme.buttonHeight),
            
            spriteModeButton.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 20),
            spriteModeButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            spriteModeButton.widthAnchor.constraint(equalToConstant: 220),
            spriteModeButton.heightAnchor.constraint(equalToConstant: 48),
            
            botCountView.topAnchor.constraint(equalTo: spriteModeButton.bottomAnchor, constant: 16),
            botCountView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            botCountView.widthAnchor.constraint(equalToConstant: 220),
            botCountView.heightAnchor.constraint(equalToConstant: 56),
            
            botCountLabel.leadingAnchor.constraint(equalTo: botCountView.leadingAnchor, constant: 20),
            botCountLabel.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            
            botCountStepper.trailingAnchor.constraint(equalTo: botCountView.trailingAnchor, constant: -20),
            botCountStepper.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: botCountView.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            connectedPlayersView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            connectedPlayersView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            connectedPlayersView.widthAnchor.constraint(equalToConstant: 300),
            connectedPlayersView.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),
            
            connectedPlayersLabel.topAnchor.constraint(equalTo: connectedPlayersView.topAnchor, constant: 16),
            connectedPlayersLabel.leadingAnchor.constraint(equalTo: connectedPlayersView.leadingAnchor, constant: 16),
            connectedPlayersLabel.trailingAnchor.constraint(equalTo: connectedPlayersView.trailingAnchor, constant: -16),
            connectedPlayersLabel.bottomAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: -16),
            
            startGameButton.topAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: 20),
            startGameButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            startGameButton.widthAnchor.constraint(equalToConstant: LobbyUITheme.buttonWidth),
            startGameButton.heightAnchor.constraint(equalToConstant: LobbyUITheme.buttonHeight),
            
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
    
    /// Create sprite mode toggle button with glass styling
    private func createSpriteModeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = LobbyUITheme.glassBackgroundColor
        button.layer.cornerRadius = LobbyUITheme.buttonCornerRadius
        button.layer.borderWidth = 1
        button.layer.borderColor = LobbyUITheme.glassBorderColor.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        updateSpriteModeButtonTitle(button)
        
        return button
    }
    
    /// Update the sprite mode button title to reflect current mode
    private func updateSpriteModeButtonTitle(_ button: UIButton) {
        let mode = GameSettings.shared.spriteMode
        let title = "\(mode.icon) \(mode.displayName) Mode"
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = LobbyUITheme.subtitleFont
        button.setTitleColor(LobbyUITheme.titleColor, for: .normal)
    }
    
    /// Update sprite mode button to reflect current state
    func updateSpriteModeButton() {
        updateSpriteModeButtonTitle(spriteModeButton)
    }
    
    /// Show single player mode UI with animation
    func showSinglePlayerMode() {
        UIView.animate(withDuration: 0.3) {
            self.singlePlayerButton.alpha = 0
            self.hostButton.alpha = 0
            self.joinButton.alpha = 0
            self.instructionsLabel.alpha = 0
        } completion: { _ in
            self.singlePlayerButton.isHidden = true
            self.hostButton.isHidden = true
            self.joinButton.isHidden = true
            self.instructionsLabel.isHidden = true
        }
        
        botCountView.isHidden = false
        cancelButton.isHidden = false
        startGameButton.isHidden = false
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
    
    /// Reset lobby to initial state with animation
    func reset() {
        singlePlayerButton.isHidden = false
        hostButton.isHidden = false
        joinButton.isHidden = false
        instructionsLabel.isHidden = false
        spriteModeButton.isHidden = false
        
        singlePlayerButton.alpha = 0
        hostButton.alpha = 0
        joinButton.alpha = 0
        instructionsLabel.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.singlePlayerButton.alpha = 1
            self.hostButton.alpha = 1
            self.joinButton.alpha = 1
            self.instructionsLabel.alpha = 1
        }
        
        botCountView.isHidden = true
        cancelButton.isHidden = true
        startGameButton.isHidden = true
        connectedPlayersView.isHidden = true
        peerTableView.isHidden = true
        emptyStateLabel.isHidden = true
        activityIndicator.stopAnimating()
        statusLabel.text = "Choose your battle mode"
        updateSpriteModeButton()
    }
}
