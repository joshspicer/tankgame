//
//  LobbyUI.swift
//  tankgame iOS
//
//  Created by jospicer on 10/28/25.
//

import UIKit
import MultipeerConnectivity
import QuartzCore

/// Manages the lobby user interface with modern, polished design
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
    private var tankEmojiLabel: UILabel!
    private var gradientLayer: CAGradientLayer?
    
    /// Number of AI bots to add
    var botCount: Int = 1
    
    // Callbacks
    var onHostTapped: (() -> Void)?
    var onJoinTapped: (() -> Void)?
    var onSinglePlayerTapped: (() -> Void)?
    var onCancelTapped: (() -> Void)?
    var onStartGameTapped: (() -> Void)?
    
    // Design constants
    private struct Design {
        // Modern color palette
        static let primaryGradientStart = UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        static let primaryGradientEnd = UIColor(red: 0.15, green: 0.2, blue: 0.3, alpha: 1.0)
        static let accentOrange = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
        static let accentBlue = UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0)
        static let accentGreen = UIColor(red: 0.3, green: 0.85, blue: 0.5, alpha: 1.0)
        static let accentPurple = UIColor(red: 0.6, green: 0.4, blue: 0.9, alpha: 1.0)
        
        // Button styling
        static let buttonCornerRadius: CGFloat = 20
        static let buttonHeight: CGFloat = 60
        static let buttonWidth: CGFloat = 280
        static let buttonShadowRadius: CGFloat = 12
        static let buttonShadowOpacity: Float = 0.3
        
        // Typography
        static let titleFontSize: CGFloat = 52
        static let emojiFontSize: CGFloat = 72
        static let statusFontSize: CGFloat = 18
        static let instructionsFontSize: CGFloat = 15
    }
    
    func setup(in parentView: UIView) {
        // Create lobby view
        lobbyView = UIView(frame: parentView.bounds)
        lobbyView.backgroundColor = Design.primaryGradientStart
        parentView.addSubview(lobbyView)
        
        // Add animated gradient background
        setupAnimatedGradientBackground(in: parentView)
        
        // Add subtle particle effect layer
        addParticleEffects()
        
        // Title label with gradient text effect
        titleLabel = UILabel()
        titleLabel.text = "TANK GAME"
        titleLabel.font = .systemFont(ofSize: Design.titleFontSize, weight: .black)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(titleLabel)
        addGlowEffect(to: titleLabel)
        
        // Tank emoji with bounce animation
        tankEmojiLabel = UILabel()
        tankEmojiLabel.text = "🎯"
        tankEmojiLabel.font = .systemFont(ofSize: Design.emojiFontSize)
        tankEmojiLabel.textAlignment = .center
        tankEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(tankEmojiLabel)
        addBounceAnimation(to: tankEmojiLabel)
        
        // Status label with modern styling
        statusLabel = UILabel()
        statusLabel.text = "Choose your battle mode"
        statusLabel.font = .systemFont(ofSize: Design.statusFontSize, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(statusLabel)
        
        // Instructions label with softer appearance
        instructionsLabel = UILabel()
        instructionsLabel.text = "Battle with 2-4 players on the same network!\nMove with the joystick, tap FIRE to shoot."
        instructionsLabel.font = .systemFont(ofSize: Design.instructionsFontSize, weight: .regular)
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(instructionsLabel)
        
        // Single Player button (with AI bots) - orange theme
        singlePlayerButton = createModernButton(title: "Single Player", gradientColors: [Design.accentOrange, Design.accentOrange.withAlphaComponent(0.8)], icon: "🤖")
        singlePlayerButton.addTarget(self, action: #selector(singlePlayerButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(singlePlayerButton)
        
        // Host button - blue theme
        hostButton = createModernButton(title: "Host Game", gradientColors: [Design.accentBlue, Design.accentPurple], icon: "📡")
        hostButton.addTarget(self, action: #selector(hostButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(hostButton)
        
        // Join button - green theme
        joinButton = createModernButton(title: "Join Game", gradientColors: [Design.accentGreen, Design.accentGreen.withAlphaComponent(0.7)], icon: "🔍")
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(joinButton)
        
        // Bot count selection view (for single player mode) with modern glass style
        botCountView = createGlassView()
        botCountView.isHidden = true
        lobbyView.addSubview(botCountView)
        
        botCountLabel = UILabel()
        botCountLabel.text = "AI Bots: 1"
        botCountLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        botCountLabel.textAlignment = .center
        botCountLabel.textColor = .white
        botCountLabel.translatesAutoresizingMaskIntoConstraints = false
        botCountView.addSubview(botCountLabel)
        
        botCountStepper = UIStepper()
        botCountStepper.minimumValue = 1
        botCountStepper.maximumValue = 3
        botCountStepper.value = 1
        botCountStepper.addTarget(self, action: #selector(botCountChanged), for: .valueChanged)
        botCountStepper.translatesAutoresizingMaskIntoConstraints = false
        botCountView.addSubview(botCountStepper)
        
        // Sprite mode toggle button with modern styling
        spriteModeButton = createSpriteModeButton()
        spriteModeButton.addTarget(self, action: #selector(spriteModeButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(spriteModeButton)
        
        // Cancel button with modern styling
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("✕ Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        cancelButton.setTitleColor(UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0), for: .normal)
        cancelButton.isHidden = true
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(cancelButton)
        
        // Start Game button with glowing green style
        startGameButton = createModernButton(title: "Start Battle!", gradientColors: [Design.accentGreen, UIColor(red: 0.2, green: 0.7, blue: 0.4, alpha: 1.0)], icon: "🚀")
        startGameButton.isHidden = true
        startGameButton.addTarget(self, action: #selector(startGameButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(startGameButton)
        addPulseAnimation(to: startGameButton)
        
        // Connected players view with glass effect
        connectedPlayersView = createGlassView()
        connectedPlayersView.isHidden = true
        lobbyView.addSubview(connectedPlayersView)
        
        connectedPlayersLabel = UILabel()
        connectedPlayersLabel.text = "Connected: 1/4"
        connectedPlayersLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        connectedPlayersLabel.textAlignment = .center
        connectedPlayersLabel.numberOfLines = 0
        connectedPlayersLabel.textColor = .white
        connectedPlayersLabel.translatesAutoresizingMaskIntoConstraints = false
        connectedPlayersView.addSubview(connectedPlayersLabel)
        
        // Activity indicator with modern styling
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = Design.accentBlue
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(activityIndicator)
        
        // Peer table view with modern glass effect
        peerTableView = UITableView()
        peerTableView.isHidden = true
        peerTableView.layer.cornerRadius = 16
        peerTableView.layer.borderWidth = 1
        peerTableView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        peerTableView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        peerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PeerCell")
        peerTableView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(peerTableView)
        
        // Empty state label with modern styling
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "🔍 No nearby games found.\nMake sure the other device is hosting."
        emptyStateLabel.font = .systemFont(ofSize: 15, weight: .medium)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(emptyStateLabel)
        
        setupConstraints()
    }
    
    // MARK: - Animation Effects
    
    /// Setup animated gradient background
    private func setupAnimatedGradientBackground(in parentView: UIView) {
        gradientLayer = CAGradientLayer()
        gradientLayer?.frame = parentView.bounds
        gradientLayer?.colors = [
            Design.primaryGradientStart.cgColor,
            Design.primaryGradientEnd.cgColor,
            UIColor(red: 0.2, green: 0.15, blue: 0.35, alpha: 1.0).cgColor
        ]
        gradientLayer?.locations = [0.0, 0.5, 1.0]
        gradientLayer?.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer?.endPoint = CGPoint(x: 1, y: 1)
        lobbyView.layer.insertSublayer(gradientLayer!, at: 0)
        
        // Animate gradient
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = gradientLayer?.colors
        animation.toValue = [
            Design.primaryGradientEnd.cgColor,
            UIColor(red: 0.2, green: 0.15, blue: 0.35, alpha: 1.0).cgColor,
            Design.primaryGradientStart.cgColor
        ]
        animation.duration = 5.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        gradientLayer?.add(animation, forKey: "gradientAnimation")
    }
    
    /// Add subtle particle effects (optimized for performance)
    private func addParticleEffects() {
        // Add floating particles for ambient effect (reduced count for performance)
        let particleCount = 8  // Reduced from 15 for better performance
        for _ in 0..<particleCount {
            let particle = UIView()
            let size = CGFloat.random(in: 4...10)
            particle.frame = CGRect(
                x: CGFloat.random(in: 0...lobbyView.bounds.width),
                y: CGFloat.random(in: 0...lobbyView.bounds.height),
                width: size,
                height: size
            )
            particle.backgroundColor = UIColor.white.withAlphaComponent(CGFloat.random(in: 0.08...0.2))
            particle.layer.cornerRadius = size / 2
            lobbyView.insertSubview(particle, at: 1)  // Insert behind other UI elements
            
            // Animate floating with longer duration for smoother effect
            let duration = Double.random(in: 4...8)
            UIView.animate(withDuration: duration, delay: Double.random(in: 0...3), options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
                particle.transform = CGAffineTransform(translationX: CGFloat.random(in: -20...20), y: CGFloat.random(in: -40...40))
                particle.alpha = CGFloat.random(in: 0.05...0.25)
            })
        }
    }
    
    /// Add glow effect to a view
    private func addGlowEffect(to view: UIView) {
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = .zero
    }
    
    /// Add bounce animation to a view
    private func addBounceAnimation(to view: UIView) {
        UIView.animate(withDuration: 1.5, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
            view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        })
    }
    
    /// Add pulse animation to a button
    private func addPulseAnimation(to button: UIButton) {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1.0
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.03
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        button.layer.add(pulseAnimation, forKey: "pulse")
    }
    
    // MARK: - UI Component Creation
    
    /// Create a modern button with gradient background
    private func createModernButton(title: String, gradientColors: [UIColor], icon: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Add gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = Design.buttonCornerRadius
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        // Create stack view for icon and text
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 14
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 26)
        
        let textLabel = UILabel()
        textLabel.text = title
        textLabel.font = .systemFont(ofSize: 20, weight: .bold)
        textLabel.textColor = .white
        
        stackView.addArrangedSubview(iconLabel)
        stackView.addArrangedSubview(textLabel)
        
        button.addSubview(stackView)
        button.layer.cornerRadius = Design.buttonCornerRadius
        button.clipsToBounds = false  // Allow shadows to show
        button.layer.shadowColor = gradientColors[0].cgColor
        button.layer.shadowOpacity = Design.buttonShadowOpacity
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = Design.buttonShadowRadius
        button.layer.masksToBounds = false
        
        // Apply corner radius to gradient layer separately
        gradientLayer.masksToBounds = true
        
        // Store gradient reference for resizing
        button.layer.setValue(gradientLayer, forKey: "gradientLayer")
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        // Add touch feedback
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return button
    }
    
    /// Create a glass-morphism styled view
    private func createGlassView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subtle shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        
        return view
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.alpha = 0.9
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }
    
    private func createButton(title: String, backgroundColor: UIColor, icon: String) -> UIButton {
        return createModernButton(title: title, gradientColors: [backgroundColor, backgroundColor.withAlphaComponent(0.8)], icon: icon)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tankEmojiLabel.topAnchor.constraint(equalTo: lobbyView.safeAreaLayoutGuide.topAnchor, constant: 30),
            tankEmojiLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: tankEmojiLabel.bottomAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            statusLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            instructionsLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            instructionsLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            instructionsLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            singlePlayerButton.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 28),
            singlePlayerButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            singlePlayerButton.widthAnchor.constraint(equalToConstant: Design.buttonWidth),
            singlePlayerButton.heightAnchor.constraint(equalToConstant: Design.buttonHeight),
            
            hostButton.topAnchor.constraint(equalTo: singlePlayerButton.bottomAnchor, constant: 14),
            hostButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            hostButton.widthAnchor.constraint(equalToConstant: Design.buttonWidth),
            hostButton.heightAnchor.constraint(equalToConstant: Design.buttonHeight),
            
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 14),
            joinButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            joinButton.widthAnchor.constraint(equalToConstant: Design.buttonWidth),
            joinButton.heightAnchor.constraint(equalToConstant: Design.buttonHeight),
            
            spriteModeButton.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 20),
            spriteModeButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            spriteModeButton.widthAnchor.constraint(equalToConstant: 220),
            spriteModeButton.heightAnchor.constraint(equalToConstant: 48),
            
            botCountView.topAnchor.constraint(equalTo: spriteModeButton.bottomAnchor, constant: 16),
            botCountView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            botCountView.widthAnchor.constraint(equalToConstant: 220),
            botCountView.heightAnchor.constraint(equalToConstant: 54),
            
            botCountLabel.leadingAnchor.constraint(equalTo: botCountView.leadingAnchor, constant: 18),
            botCountLabel.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            
            botCountStepper.trailingAnchor.constraint(equalTo: botCountView.trailingAnchor, constant: -18),
            botCountStepper.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: botCountView.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            connectedPlayersView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            connectedPlayersView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            connectedPlayersView.widthAnchor.constraint(equalToConstant: 300),
            connectedPlayersView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            connectedPlayersLabel.topAnchor.constraint(equalTo: connectedPlayersView.topAnchor, constant: 18),
            connectedPlayersLabel.leadingAnchor.constraint(equalTo: connectedPlayersView.leadingAnchor, constant: 18),
            connectedPlayersLabel.trailingAnchor.constraint(equalTo: connectedPlayersView.trailingAnchor, constant: -18),
            connectedPlayersLabel.bottomAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: -18),
            
            startGameButton.topAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: 20),
            startGameButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            startGameButton.widthAnchor.constraint(equalToConstant: Design.buttonWidth),
            startGameButton.heightAnchor.constraint(equalToConstant: Design.buttonHeight),
            
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
        
        // Update gradient layers when layout changes
        DispatchQueue.main.async { [weak self] in
            self?.updateButtonGradients()
        }
    }
    
    /// Update button gradient layer frames
    private func updateButtonGradients() {
        for button in [singlePlayerButton, hostButton, joinButton, startGameButton] {
            if let gradientLayer = button?.layer.value(forKey: "gradientLayer") as? CAGradientLayer {
                gradientLayer.frame = button?.bounds ?? .zero
            }
        }
    }
    
    // MARK: - Button Actions
    
    // MARK: - Button Actions
    
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
        // Toggle between tank and dolphin mode with animation
        let currentMode = GameSettings.shared.spriteMode
        let newMode: SpriteMode = (currentMode == .tank) ? .dolphin : .tank
        GameSettings.shared.spriteMode = newMode
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.spriteModeButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { [weak self] _ in
            UIView.animate(withDuration: 0.2) {
                self?.spriteModeButton.transform = .identity
            }
        }
        
        updateSpriteModeButton()
    }
    
    @objc private func botCountChanged() {
        botCount = Int(botCountStepper.value)
        botCountLabel.text = "AI Bots: \(botCount)"
    }
    
    // MARK: - Sprite Mode Button
    
    /// Create sprite mode toggle button with modern glass style
    private func createSpriteModeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        
        updateSpriteModeButtonTitle(button)
        
        return button
    }
    
    /// Update the sprite mode button title to reflect current mode
    private func updateSpriteModeButtonTitle(_ button: UIButton) {
        let mode = GameSettings.shared.spriteMode
        let title = "\(mode.icon) \(mode.displayName) Mode"
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    }
    
    /// Update sprite mode button to reflect current state
    func updateSpriteModeButton() {
        updateSpriteModeButtonTitle(spriteModeButton)
    }
    
    // MARK: - State Management
    
    /// Show single player mode UI with animation
    func showSinglePlayerMode() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.singlePlayerButton.alpha = 0
            self?.hostButton.alpha = 0
            self?.joinButton.alpha = 0
            self?.instructionsLabel.alpha = 0
        } completion: { [weak self] _ in
            self?.singlePlayerButton.isHidden = true
            self?.hostButton.isHidden = true
            self?.joinButton.isHidden = true
            self?.instructionsLabel.isHidden = true
            self?.botCountView.isHidden = false
            self?.cancelButton.isHidden = false
            self?.startGameButton.isHidden = false
            self?.botCountView.alpha = 0
            self?.cancelButton.alpha = 0
            self?.startGameButton.alpha = 0
            
            UIView.animate(withDuration: 0.3) {
                self?.botCountView.alpha = 1
                self?.cancelButton.alpha = 1
                self?.startGameButton.alpha = 1
            }
        }
        statusLabel.text = "⚔️ Single Player Mode\nSelect number of AI opponents"
    }
    
    /// Reset lobby to initial state with animation
    func reset() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.botCountView.alpha = 0
            self?.cancelButton.alpha = 0
            self?.startGameButton.alpha = 0
            self?.connectedPlayersView.alpha = 0
            self?.peerTableView.alpha = 0
            self?.emptyStateLabel.alpha = 0
        } completion: { [weak self] _ in
            self?.botCountView.isHidden = true
            self?.cancelButton.isHidden = true
            self?.startGameButton.isHidden = true
            self?.connectedPlayersView.isHidden = true
            self?.peerTableView.isHidden = true
            self?.emptyStateLabel.isHidden = true
            
            self?.singlePlayerButton.isHidden = false
            self?.hostButton.isHidden = false
            self?.joinButton.isHidden = false
            self?.instructionsLabel.isHidden = false
            self?.spriteModeButton.isHidden = false
            
            self?.singlePlayerButton.alpha = 0
            self?.hostButton.alpha = 0
            self?.joinButton.alpha = 0
            self?.instructionsLabel.alpha = 0
            
            UIView.animate(withDuration: 0.3) {
                self?.singlePlayerButton.alpha = 1
                self?.hostButton.alpha = 1
                self?.joinButton.alpha = 1
                self?.instructionsLabel.alpha = 1
            }
        }
        
        activityIndicator.stopAnimating()
        statusLabel.text = "Choose your battle mode"
        updateSpriteModeButton()
    }
    
    /// Update layout when view bounds change
    func updateLayout(in parentView: UIView) {
        lobbyView.frame = parentView.bounds
        gradientLayer?.frame = parentView.bounds
        updateButtonGradients()
    }
}
