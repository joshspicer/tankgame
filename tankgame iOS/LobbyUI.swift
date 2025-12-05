//
//  LobbyUI.swift
//  tankgame iOS
//
//  Created by jospicer on 10/28/25.
//

import UIKit
import MultipeerConnectivity
import QuartzCore

/// Manages the lobby user interface with modern design
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
    
    // Animation layers
    private var gradientLayer: CAGradientLayer?
    private var particleEmitter: CAEmitterLayer?
    private var titleLabel: UILabel?
    private var tankEmojiLabel: UILabel?
    
    /// Number of AI bots to add
    var botCount: Int = 1
    
    // Callbacks
    var onHostTapped: (() -> Void)?
    var onJoinTapped: (() -> Void)?
    var onSinglePlayerTapped: (() -> Void)?
    var onCancelTapped: (() -> Void)?
    var onStartGameTapped: (() -> Void)?
    
    // Modern color palette
    private let primaryGradientColors = [
        UIColor(red: 0.07, green: 0.07, blue: 0.14, alpha: 1.0).cgColor,  // Deep navy
        UIColor(red: 0.12, green: 0.12, blue: 0.22, alpha: 1.0).cgColor,  // Dark purple-blue
        UIColor(red: 0.08, green: 0.15, blue: 0.20, alpha: 1.0).cgColor   // Dark teal
    ]
    
    private let accentOrange = UIColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 1.0)
    private let accentBlue = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
    private let accentGreen = UIColor(red: 0.2, green: 0.85, blue: 0.5, alpha: 1.0)
    private let accentPurple = UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0)
    
    // Constants for button identification
    private let gradientButtonTag = 1001
    
    func setup(in parentView: UIView) {
        // Create lobby view
        lobbyView = UIView(frame: parentView.bounds)
        lobbyView.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.14, alpha: 1.0)
        parentView.addSubview(lobbyView)
        
        // Add animated gradient background
        setupAnimatedGradientBackground(in: parentView)
        
        // Add subtle particle effects
        setupParticleBackground(in: parentView)
        
        // Title label with glow effect
        let newTitleLabel = UILabel()
        newTitleLabel.text = "TANK BATTLE"
        newTitleLabel.font = UIFont.systemFont(ofSize: 42, weight: .black)
        newTitleLabel.textAlignment = .center
        newTitleLabel.textColor = .white
        newTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add glow effect to title
        newTitleLabel.layer.shadowColor = accentOrange.cgColor
        newTitleLabel.layer.shadowRadius = 15
        newTitleLabel.layer.shadowOpacity = 0.8
        newTitleLabel.layer.shadowOffset = .zero
        lobbyView.addSubview(newTitleLabel)
        titleLabel = newTitleLabel
        
        // Animated tank emoji
        let newTankEmojiLabel = UILabel()
        newTankEmojiLabel.text = "⚔️"
        newTankEmojiLabel.font = .systemFont(ofSize: 80)
        newTankEmojiLabel.textAlignment = .center
        newTankEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(newTankEmojiLabel)
        addPulseAnimation(to: newTankEmojiLabel)
        tankEmojiLabel = newTankEmojiLabel
        
        // Status label with modern styling
        statusLabel = UILabel()
        statusLabel.text = "Choose your battle mode"
        statusLabel.font = .systemFont(ofSize: 18, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(statusLabel)
        
        // Instructions label
        instructionsLabel = UILabel()
        instructionsLabel.text = "Battle with 2-4 players via Bluetooth\nMove • Aim • Fire • Dominate"
        instructionsLabel.font = .systemFont(ofSize: 14, weight: .regular)
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(instructionsLabel)
        
        // Single Player button with modern styling
        singlePlayerButton = createModernButton(title: "SOLO BATTLE", gradientColors: [accentOrange, accentOrange.withAlphaComponent(0.7)], icon: "🤖")
        singlePlayerButton.addTarget(self, action: #selector(singlePlayerButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(singlePlayerButton)
        
        // Host button
        hostButton = createModernButton(title: "HOST GAME", gradientColors: [accentBlue, accentPurple], icon: "📡")
        hostButton.addTarget(self, action: #selector(hostButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(hostButton)
        
        // Join button
        joinButton = createModernButton(title: "JOIN GAME", gradientColors: [accentGreen, accentGreen.withAlphaComponent(0.7)], icon: "🔗")
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(joinButton)
        
        // Bot count selection view with glass morphism
        botCountView = createGlassView()
        botCountView.isHidden = true
        lobbyView.addSubview(botCountView)
        
        botCountLabel = UILabel()
        botCountLabel.text = "AI Opponents: 1"
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
        styleStepper(botCountStepper)
        botCountView.addSubview(botCountStepper)
        
        // Sprite mode toggle button
        spriteModeButton = createSpriteModeButton()
        spriteModeButton.addTarget(self, action: #selector(spriteModeButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(spriteModeButton)
        
        // Cancel button with modern styling
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("✕ Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cancelButton.setTitleColor(UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0), for: .normal)
        cancelButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        cancelButton.layer.cornerRadius = 12
        cancelButton.isHidden = true
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(cancelButton)
        
        // Start Game button (for host)
        startGameButton = createModernButton(title: "START BATTLE", gradientColors: [accentGreen, UIColor(red: 0.1, green: 0.7, blue: 0.4, alpha: 1.0)], icon: "🚀")
        startGameButton.isHidden = true
        startGameButton.addTarget(self, action: #selector(startGameButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(startGameButton)
        
        // Connected players view with glass morphism
        connectedPlayersView = createGlassView()
        connectedPlayersView.isHidden = true
        lobbyView.addSubview(connectedPlayersView)
        
        connectedPlayersLabel = UILabel()
        connectedPlayersLabel.text = "Players: 1/4"
        connectedPlayersLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        connectedPlayersLabel.textAlignment = .center
        connectedPlayersLabel.numberOfLines = 0
        connectedPlayersLabel.textColor = .white
        connectedPlayersLabel.translatesAutoresizingMaskIntoConstraints = false
        connectedPlayersView.addSubview(connectedPlayersLabel)
        
        // Activity indicator with modern styling
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = accentBlue
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(activityIndicator)
        
        // Peer table view with modern styling
        peerTableView = UITableView()
        peerTableView.isHidden = true
        peerTableView.layer.cornerRadius = 16
        peerTableView.layer.borderWidth = 1
        peerTableView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        peerTableView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        peerTableView.separatorColor = UIColor.white.withAlphaComponent(0.1)
        peerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PeerCell")
        peerTableView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(peerTableView)
        
        // Empty state label with modern styling
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "Searching for nearby battles...\nMake sure the host has started their game."
        emptyStateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(emptyStateLabel)
        
        setupConstraints(titleLabel: newTitleLabel, tankEmojiLabel: newTankEmojiLabel)
        
        // Start title glow animation
        startTitleGlowAnimation()
    }
    
    // MARK: - Modern UI Components
    
    /// Creates a modern gradient button with glow effect
    private func createModernButton(title: String, gradientColors: [UIColor], icon: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 16
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        // Create stack view for icon and text
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 22)
        
        let textLabel = UILabel()
        textLabel.text = title
        textLabel.font = .systemFont(ofSize: 17, weight: .bold)
        textLabel.textColor = .white
        
        stackView.addArrangedSubview(iconLabel)
        stackView.addArrangedSubview(textLabel)
        
        button.addSubview(stackView)
        button.layer.cornerRadius = 16
        
        // Shadow for depth
        button.layer.shadowColor = gradientColors.first?.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 12
        
        // Border glow effect
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        // Store gradient layer for layout updates
        button.tag = gradientButtonTag
        
        return button
    }
    
    /// Creates a glass-morphism style view
    private func createGlassView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    /// Style the stepper for dark theme
    private func styleStepper(_ stepper: UIStepper) {
        stepper.tintColor = accentBlue
    }
    
    /// Add animated gradient background
    private func setupAnimatedGradientBackground(in parentView: UIView) {
        gradientLayer = CAGradientLayer()
        gradientLayer?.frame = parentView.bounds
        gradientLayer?.colors = primaryGradientColors
        gradientLayer?.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer?.endPoint = CGPoint(x: 1, y: 1)
        lobbyView.layer.insertSublayer(gradientLayer!, at: 0)
        
        // Animate gradient
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = primaryGradientColors
        animation.toValue = [
            UIColor(red: 0.12, green: 0.12, blue: 0.22, alpha: 1.0).cgColor,
            UIColor(red: 0.08, green: 0.15, blue: 0.20, alpha: 1.0).cgColor,
            UIColor(red: 0.07, green: 0.07, blue: 0.14, alpha: 1.0).cgColor
        ]
        animation.duration = 8.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        gradientLayer?.add(animation, forKey: "gradientAnimation")
    }
    
    /// Add subtle particle background effect
    private func setupParticleBackground(in parentView: UIView) {
        particleEmitter = CAEmitterLayer()
        particleEmitter?.emitterPosition = CGPoint(x: parentView.bounds.width / 2, y: -50)
        particleEmitter?.emitterShape = .line
        particleEmitter?.emitterSize = CGSize(width: parentView.bounds.width, height: 1)
        
        let cell = CAEmitterCell()
        cell.birthRate = 2
        cell.lifetime = 15
        cell.velocity = 20
        cell.velocityRange = 10
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 4
        cell.scale = 0.03
        cell.scaleRange = 0.02
        cell.alphaSpeed = -0.05
        cell.color = UIColor.white.withAlphaComponent(0.15).cgColor
        cell.contents = createCircleImage().cgImage
        
        particleEmitter?.emitterCells = [cell]
        lobbyView.layer.insertSublayer(particleEmitter!, at: 1)
    }
    
    /// Create a simple circle image for particles
    private func createCircleImage() -> UIImage {
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /// Add pulse animation to a view
    private func addPulseAnimation(to view: UIView) {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = 2.0
        pulse.fromValue = 1.0
        pulse.toValue = 1.1
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(pulse, forKey: "pulseAnimation")
    }
    
    /// Animate title glow effect
    private func startTitleGlowAnimation() {
        guard let title = titleLabel else { return }
        
        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.fromValue = 10
        glowAnimation.toValue = 25
        glowAnimation.duration = 1.5
        glowAnimation.autoreverses = true
        glowAnimation.repeatCount = .infinity
        title.layer.add(glowAnimation, forKey: "glowAnimation")
    }
    
    // Legacy button creator for compatibility
    private func createButton(title: String, backgroundColor: UIColor, icon: String) -> UIButton {
        return createModernButton(title: title.uppercased(), gradientColors: [backgroundColor, backgroundColor.withAlphaComponent(0.7)], icon: icon)
    }
    
    /// Update gradient layers on layout change
    func updateGradientFrames(to bounds: CGRect) {
        gradientLayer?.frame = bounds
        particleEmitter?.emitterPosition = CGPoint(x: bounds.width / 2, y: -50)
        particleEmitter?.emitterSize = CGSize(width: bounds.width, height: 1)
        
        // Update button gradient layers - only for buttons with our gradient tag
        let gradientButtons = [singlePlayerButton, hostButton, joinButton, startGameButton]
        for button in gradientButtons {
            guard let btn = button, btn.tag == gradientButtonTag else { continue }
            // Get the first gradient layer (should be at index 0)
            if let firstLayer = btn.layer.sublayers?.first as? CAGradientLayer {
                firstLayer.frame = btn.bounds
            }
        }
    }
    
    private func setupConstraints(titleLabel: UILabel, tankEmojiLabel: UILabel) {
        NSLayoutConstraint.activate([
            tankEmojiLabel.topAnchor.constraint(equalTo: lobbyView.safeAreaLayoutGuide.topAnchor, constant: 30),
            tankEmojiLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: tankEmojiLabel.bottomAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            statusLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            instructionsLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 6),
            instructionsLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            instructionsLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            singlePlayerButton.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 32),
            singlePlayerButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            singlePlayerButton.widthAnchor.constraint(equalToConstant: 260),
            singlePlayerButton.heightAnchor.constraint(equalToConstant: 54),
            
            hostButton.topAnchor.constraint(equalTo: singlePlayerButton.bottomAnchor, constant: 14),
            hostButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            hostButton.widthAnchor.constraint(equalToConstant: 260),
            hostButton.heightAnchor.constraint(equalToConstant: 54),
            
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 14),
            joinButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            joinButton.widthAnchor.constraint(equalToConstant: 260),
            joinButton.heightAnchor.constraint(equalToConstant: 54),
            
            spriteModeButton.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 20),
            spriteModeButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            spriteModeButton.widthAnchor.constraint(equalToConstant: 180),
            spriteModeButton.heightAnchor.constraint(equalToConstant: 42),
            
            botCountView.topAnchor.constraint(equalTo: spriteModeButton.bottomAnchor, constant: 14),
            botCountView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            botCountView.widthAnchor.constraint(equalToConstant: 220),
            botCountView.heightAnchor.constraint(equalToConstant: 54),
            
            botCountLabel.leadingAnchor.constraint(equalTo: botCountView.leadingAnchor, constant: 16),
            botCountLabel.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            
            botCountStepper.trailingAnchor.constraint(equalTo: botCountView.trailingAnchor, constant: -16),
            botCountStepper.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: botCountView.bottomAnchor, constant: 14),
            cancelButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 120),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            
            connectedPlayersView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 16),
            connectedPlayersView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            connectedPlayersView.widthAnchor.constraint(equalToConstant: 280),
            connectedPlayersView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70),
            
            connectedPlayersLabel.topAnchor.constraint(equalTo: connectedPlayersView.topAnchor, constant: 14),
            connectedPlayersLabel.leadingAnchor.constraint(equalTo: connectedPlayersView.leadingAnchor, constant: 14),
            connectedPlayersLabel.trailingAnchor.constraint(equalTo: connectedPlayersView.trailingAnchor, constant: -14),
            connectedPlayersLabel.bottomAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: -14),
            
            startGameButton.topAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: 16),
            startGameButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            startGameButton.widthAnchor.constraint(equalToConstant: 260),
            startGameButton.heightAnchor.constraint(equalToConstant: 54),
            
            activityIndicator.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            
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
        addButtonTapAnimation(hostButton)
        onHostTapped?()
    }
    
    @objc private func joinButtonTapped() {
        addButtonTapAnimation(joinButton)
        onJoinTapped?()
    }
    
    @objc private func singlePlayerButtonTapped() {
        addButtonTapAnimation(singlePlayerButton)
        onSinglePlayerTapped?()
    }
    
    @objc private func cancelButtonTapped() {
        onCancelTapped?()
    }
    
    @objc private func startGameButtonTapped() {
        addButtonTapAnimation(startGameButton)
        onStartGameTapped?()
    }
    
    @objc private func spriteModeButtonTapped() {
        // Toggle between tank and dolphin mode
        let currentMode = GameSettings.shared.spriteMode
        let newMode: SpriteMode = (currentMode == .tank) ? .dolphin : .tank
        GameSettings.shared.spriteMode = newMode
        updateSpriteModeButton()
        
        // Add subtle animation
        UIView.animate(withDuration: 0.15, animations: {
            self.spriteModeButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.spriteModeButton.transform = .identity
            }
        }
    }
    
    @objc private func botCountChanged() {
        botCount = Int(botCountStepper.value)
        botCountLabel.text = "AI Opponents: \(botCount)"
    }
    
    /// Add tap animation to button
    private func addButtonTapAnimation(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        }
    }
    
    /// Create sprite mode toggle button with modern styling
    private func createSpriteModeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        updateSpriteModeButtonTitle(button)
        
        return button
    }
    
    /// Update the sprite mode button title to reflect current mode
    private func updateSpriteModeButtonTitle(_ button: UIButton) {
        let mode = GameSettings.shared.spriteMode
        let title = "\(mode.icon) \(mode.displayName)"
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
    }
    
    /// Update sprite mode button to reflect current state
    func updateSpriteModeButton() {
        updateSpriteModeButtonTitle(spriteModeButton)
    }
    
    /// Show single player mode UI with animation
    func showSinglePlayerMode() {
        UIView.animate(withDuration: 0.3, animations: {
            self.singlePlayerButton.alpha = 0
            self.hostButton.alpha = 0
            self.joinButton.alpha = 0
            self.instructionsLabel.alpha = 0
        }) { _ in
            self.singlePlayerButton.isHidden = true
            self.hostButton.isHidden = true
            self.joinButton.isHidden = true
            self.instructionsLabel.isHidden = true
            
            self.botCountView.isHidden = false
            self.cancelButton.isHidden = false
            self.startGameButton.isHidden = false
            self.botCountView.alpha = 0
            self.cancelButton.alpha = 0
            self.startGameButton.alpha = 0
            
            UIView.animate(withDuration: 0.3) {
                self.botCountView.alpha = 1
                self.cancelButton.alpha = 1
                self.startGameButton.alpha = 1
            }
        }
        statusLabel.text = "Solo Battle Mode\nSelect your opponents"
    }
    
    /// Reset lobby to initial state with animation
    func reset() {
        UIView.animate(withDuration: 0.2) {
            self.botCountView.alpha = 0
            self.cancelButton.alpha = 0
            self.startGameButton.alpha = 0
            self.connectedPlayersView.alpha = 0
            self.peerTableView.alpha = 0
            self.emptyStateLabel.alpha = 0
        } completion: { _ in
            self.singlePlayerButton.isHidden = false
            self.hostButton.isHidden = false
            self.joinButton.isHidden = false
            self.instructionsLabel.isHidden = false
            self.spriteModeButton.isHidden = false
            self.botCountView.isHidden = true
            self.cancelButton.isHidden = true
            self.startGameButton.isHidden = true
            self.connectedPlayersView.isHidden = true
            self.peerTableView.isHidden = true
            self.emptyStateLabel.isHidden = true
            self.activityIndicator.stopAnimating()
            
            self.singlePlayerButton.alpha = 1
            self.hostButton.alpha = 1
            self.joinButton.alpha = 1
            self.instructionsLabel.alpha = 1
        }
        statusLabel.text = "Choose your battle mode"
        updateSpriteModeButton()
    }
}
