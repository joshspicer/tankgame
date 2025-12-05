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
    
    // Modern design elements
    private var headerContainerView: UIView!
    private var titleLabel: UILabel!
    private var tankIconView: UIView!
    private var buttonStackView: UIStackView!
    private var gradientLayer: CAGradientLayer!
    private var particleEmitter: CAEmitterLayer?
    
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
        lobbyView.backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.12, alpha: 1.0)
        parentView.addSubview(lobbyView)
        
        // Add animated gradient background
        setupAnimatedGradientBackground()
        
        // Add subtle particle effect
        setupParticleEffect()
        
        // Setup header with logo and title
        setupHeader()
        
        // Status label with modern styling
        statusLabel = UILabel()
        statusLabel.text = "Choose your battle mode"
        statusLabel.font = .systemFont(ofSize: 16, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(statusLabel)
        
        // Instructions with glass effect container
        let instructionsContainer = createGlassContainer()
        instructionsContainer.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(instructionsContainer)
        
        instructionsLabel = UILabel()
        instructionsLabel.text = "🎮 Battle with 2-4 players via Bluetooth\n🕹️ Move with joystick • Tap FIRE to shoot"
        instructionsLabel.font = .systemFont(ofSize: 14, weight: .regular)
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsContainer.addSubview(instructionsLabel)
        
        // Create button stack with modern styling
        buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 16
        buttonStackView.alignment = .center
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(buttonStackView)
        
        // Single Player button (with AI bots) - prominent primary action
        singlePlayerButton = createModernButton(title: "Single Player", icon: "🤖", style: .primary, gradientColors: [
            UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0),
            UIColor(red: 1.0, green: 0.4, blue: 0.1, alpha: 1.0)
        ])
        singlePlayerButton.addTarget(self, action: #selector(singlePlayerButtonTapped), for: .touchUpInside)
        buttonStackView.addArrangedSubview(singlePlayerButton)
        
        // Host button
        hostButton = createModernButton(title: "Host Game", icon: "📡", style: .secondary, gradientColors: [
            UIColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 1.0),
            UIColor(red: 0.3, green: 0.3, blue: 0.9, alpha: 1.0)
        ])
        hostButton.addTarget(self, action: #selector(hostButtonTapped), for: .touchUpInside)
        buttonStackView.addArrangedSubview(hostButton)
        
        // Join button
        joinButton = createModernButton(title: "Join Game", icon: "🔗", style: .secondary, gradientColors: [
            UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0),
            UIColor(red: 0.1, green: 0.6, blue: 0.3, alpha: 1.0)
        ])
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        buttonStackView.addArrangedSubview(joinButton)
        
        // Bot count selection view with glass morphism
        botCountView = createGlassContainer()
        botCountView.isHidden = true
        botCountView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(botCountView)
        
        let botIconLabel = UILabel()
        botIconLabel.text = "🤖"
        botIconLabel.font = .systemFont(ofSize: 24)
        botIconLabel.translatesAutoresizingMaskIntoConstraints = false
        botCountView.addSubview(botIconLabel)
        
        botCountLabel = UILabel()
        botCountLabel.text = "AI Opponents: 1"
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
        
        // Sprite mode toggle with modern pill design
        spriteModeButton = createSpriteModeButton()
        spriteModeButton.addTarget(self, action: #selector(spriteModeButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(spriteModeButton)
        
        // Cancel button with subtle styling
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("← Back", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .normal)
        cancelButton.isHidden = true
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(cancelButton)
        
        // Start Game button with vibrant gradient
        startGameButton = createModernButton(title: "Start Battle!", icon: "⚔️", style: .primary, gradientColors: [
            UIColor(red: 0.1, green: 0.9, blue: 0.5, alpha: 1.0),
            UIColor(red: 0.0, green: 0.7, blue: 0.3, alpha: 1.0)
        ])
        startGameButton.isHidden = true
        startGameButton.addTarget(self, action: #selector(startGameButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(startGameButton)
        
        // Connected players view with glass morphism
        connectedPlayersView = createGlassContainer()
        connectedPlayersView.isHidden = true
        connectedPlayersView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(connectedPlayersView)
        
        connectedPlayersLabel = UILabel()
        connectedPlayersLabel.text = "👥 Connected: 1/4"
        connectedPlayersLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        connectedPlayersLabel.textColor = .white
        connectedPlayersLabel.textAlignment = .center
        connectedPlayersLabel.numberOfLines = 0
        connectedPlayersLabel.translatesAutoresizingMaskIntoConstraints = false
        connectedPlayersView.addSubview(connectedPlayersLabel)
        
        // Activity indicator with custom styling
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(activityIndicator)
        
        // Peer table view with dark theme
        peerTableView = UITableView()
        peerTableView.isHidden = true
        peerTableView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        peerTableView.layer.cornerRadius = 16
        peerTableView.layer.borderWidth = 1
        peerTableView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        peerTableView.separatorColor = UIColor.white.withAlphaComponent(0.1)
        peerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PeerCell")
        peerTableView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(peerTableView)
        
        // Empty state label
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "🔍 Searching for nearby games...\nMake sure the other device is hosting."
        emptyStateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(emptyStateLabel)
        
        setupConstraints(instructionsContainer: instructionsContainer, botIconLabel: botIconLabel)
        
        // Start entrance animations
        animateEntrance()
    }
    
    private func setupAnimatedGradientBackground() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = lobbyView.bounds
        gradientLayer.colors = [
            UIColor(red: 0.08, green: 0.08, blue: 0.18, alpha: 1.0).cgColor,
            UIColor(red: 0.04, green: 0.04, blue: 0.12, alpha: 1.0).cgColor,
            UIColor(red: 0.06, green: 0.02, blue: 0.15, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        lobbyView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Animate gradient
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = gradientLayer.colors
        animation.toValue = [
            UIColor(red: 0.06, green: 0.02, blue: 0.15, alpha: 1.0).cgColor,
            UIColor(red: 0.08, green: 0.08, blue: 0.18, alpha: 1.0).cgColor,
            UIColor(red: 0.04, green: 0.06, blue: 0.14, alpha: 1.0).cgColor
        ]
        animation.duration = 8.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "gradientAnimation")
    }
    
    private func setupParticleEffect() {
        particleEmitter = CAEmitterLayer()
        particleEmitter?.emitterPosition = CGPoint(x: lobbyView.bounds.width / 2, y: -50)
        particleEmitter?.emitterShape = .line
        particleEmitter?.emitterSize = CGSize(width: lobbyView.bounds.width, height: 1)
        
        let cell = CAEmitterCell()
        cell.birthRate = 2
        cell.lifetime = 15.0
        cell.velocity = 20
        cell.velocityRange = 10
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 4
        cell.scale = 0.02
        cell.scaleRange = 0.01
        cell.alphaSpeed = -0.05
        cell.contents = createParticleImage()?.cgImage
        
        particleEmitter?.emitterCells = [cell]
        if let emitter = particleEmitter {
            lobbyView.layer.insertSublayer(emitter, at: 1)
        }
    }
    
    private func createParticleImage() -> UIImage? {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.withAlphaComponent(0.3).cgColor)
        context?.fillEllipse(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func setupHeader() {
        headerContainerView = UIView()
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(headerContainerView)
        
        // Animated tank icon container
        tankIconView = UIView()
        tankIconView.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.addSubview(tankIconView)
        
        let tankEmojiLabel = UILabel()
        tankEmojiLabel.text = "🎯"
        tankEmojiLabel.font = .systemFont(ofSize: 70)
        tankEmojiLabel.textAlignment = .center
        tankEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
        tankIconView.addSubview(tankEmojiLabel)
        
        // Pulsing glow effect behind icon
        let glowView = UIView()
        glowView.backgroundColor = UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 0.3)
        glowView.layer.cornerRadius = 50
        glowView.translatesAutoresizingMaskIntoConstraints = false
        tankIconView.insertSubview(glowView, at: 0)
        
        // Animate glow
        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            glowView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            glowView.alpha = 0.5
        })
        
        // Title with gradient text effect (simulated)
        titleLabel = UILabel()
        titleLabel.text = "TANK BATTLE"
        titleLabel.font = .systemFont(ofSize: 42, weight: .black)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.addSubview(titleLabel)
        
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "MULTIPLAYER ARENA"
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.8)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            headerContainerView.topAnchor.constraint(equalTo: lobbyView.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerContainerView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            headerContainerView.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor),
            
            tankIconView.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            tankIconView.centerXAnchor.constraint(equalTo: headerContainerView.centerXAnchor),
            tankIconView.widthAnchor.constraint(equalToConstant: 100),
            tankIconView.heightAnchor.constraint(equalToConstant: 100),
            
            tankEmojiLabel.centerXAnchor.constraint(equalTo: tankIconView.centerXAnchor),
            tankEmojiLabel.centerYAnchor.constraint(equalTo: tankIconView.centerYAnchor),
            
            glowView.centerXAnchor.constraint(equalTo: tankIconView.centerXAnchor),
            glowView.centerYAnchor.constraint(equalTo: tankIconView.centerYAnchor),
            glowView.widthAnchor.constraint(equalToConstant: 100),
            glowView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: tankIconView.bottomAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: headerContainerView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.centerXAnchor.constraint(equalTo: headerContainerView.centerXAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor)
        ])
    }
    
    private func createGlassContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        container.layer.cornerRadius = 16
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        
        // Add blur effect
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 16
        blurView.clipsToBounds = true
        blurView.translatesAutoresizingMaskIntoConstraints = false
        container.insertSubview(blurView, at: 0)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: container.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private enum ButtonStyle {
        case primary
        case secondary
    }
    
    private func createModernButton(title: String, icon: String, style: ButtonStyle, gradientColors: [UIColor]) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Create gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = style == .primary ? 20 : 16
        
        // Store gradient layer for later frame update
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        // Configure button appearance
        button.layer.cornerRadius = style == .primary ? 20 : 16
        button.layer.shadowColor = gradientColors[0].cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 12
        
        // Create content stack
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: style == .primary ? 26 : 22)
        
        let textLabel = UILabel()
        textLabel.text = title
        textLabel.font = .systemFont(ofSize: style == .primary ? 20 : 18, weight: .bold)
        textLabel.textColor = .white
        
        stackView.addArrangedSubview(iconLabel)
        stackView.addArrangedSubview(textLabel)
        
        button.addSubview(stackView)
        
        let buttonHeight: CGFloat = style == .primary ? 60 : 54
        let buttonWidth: CGFloat = style == .primary ? 260 : 240
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: buttonWidth),
            button.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
        
        // Add touch animations
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        // Update gradient frame after layout
        DispatchQueue.main.async {
            gradientLayer.frame = button.bounds
        }
        
        return button
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
    
    private func animateEntrance() {
        // Animate header
        headerContainerView?.alpha = 0
        headerContainerView?.transform = CGAffineTransform(translationX: 0, y: -30)
        
        // Animate buttons
        buttonStackView?.alpha = 0
        buttonStackView?.transform = CGAffineTransform(translationX: 0, y: 30)
        
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.headerContainerView?.alpha = 1
            self.headerContainerView?.transform = .identity
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.buttonStackView?.alpha = 1
            self.buttonStackView?.transform = .identity
        }
    }
    
    private func setupConstraints(instructionsContainer: UIView, botIconLabel: UILabel) {
        NSLayoutConstraint.activate([
            // Status label below header
            statusLabel.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            statusLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            // Instructions container
            instructionsContainer.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            instructionsContainer.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 24),
            instructionsContainer.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -24),
            
            instructionsLabel.topAnchor.constraint(equalTo: instructionsContainer.topAnchor, constant: 12),
            instructionsLabel.leadingAnchor.constraint(equalTo: instructionsContainer.leadingAnchor, constant: 16),
            instructionsLabel.trailingAnchor.constraint(equalTo: instructionsContainer.trailingAnchor, constant: -16),
            instructionsLabel.bottomAnchor.constraint(equalTo: instructionsContainer.bottomAnchor, constant: -12),
            
            // Button stack
            buttonStackView.topAnchor.constraint(equalTo: instructionsContainer.bottomAnchor, constant: 24),
            buttonStackView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            // Sprite mode button
            spriteModeButton.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 20),
            spriteModeButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            spriteModeButton.widthAnchor.constraint(equalToConstant: 200),
            spriteModeButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Bot count view
            botCountView.topAnchor.constraint(equalTo: spriteModeButton.bottomAnchor, constant: 16),
            botCountView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            botCountView.widthAnchor.constraint(equalToConstant: 240),
            botCountView.heightAnchor.constraint(equalToConstant: 56),
            
            botIconLabel.leadingAnchor.constraint(equalTo: botCountView.leadingAnchor, constant: 16),
            botIconLabel.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            
            botCountLabel.leadingAnchor.constraint(equalTo: botIconLabel.trailingAnchor, constant: 8),
            botCountLabel.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            
            botCountStepper.trailingAnchor.constraint(equalTo: botCountView.trailingAnchor, constant: -16),
            botCountStepper.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            
            // Cancel button
            cancelButton.topAnchor.constraint(equalTo: botCountView.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            // Connected players view
            connectedPlayersView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            connectedPlayersView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            connectedPlayersView.widthAnchor.constraint(equalToConstant: 280),
            connectedPlayersView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70),
            
            connectedPlayersLabel.topAnchor.constraint(equalTo: connectedPlayersView.topAnchor, constant: 16),
            connectedPlayersLabel.leadingAnchor.constraint(equalTo: connectedPlayersView.leadingAnchor, constant: 16),
            connectedPlayersLabel.trailingAnchor.constraint(equalTo: connectedPlayersView.trailingAnchor, constant: -16),
            connectedPlayersLabel.bottomAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: -16),
            
            // Start game button
            startGameButton.topAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: 16),
            startGameButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            // Activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 30),
            
            // Peer table view
            peerTableView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            peerTableView.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 24),
            peerTableView.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -24),
            peerTableView.heightAnchor.constraint(equalToConstant: 180),
            
            // Empty state label
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
        botCountLabel.text = "AI Opponents: \(botCount)"
    }
    
    /// Create sprite mode toggle button with modern pill design
    private func createSpriteModeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        button.layer.cornerRadius = 22
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
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
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
    }
    
    /// Update sprite mode button to reflect current state
    func updateSpriteModeButton() {
        updateSpriteModeButtonTitle(spriteModeButton)
    }
    
    /// Show single player mode UI with animations
    func showSinglePlayerMode() {
        UIView.animate(withDuration: 0.3) {
            self.buttonStackView?.alpha = 0
            self.buttonStackView?.transform = CGAffineTransform(translationX: -30, y: 0)
        } completion: { _ in
            self.buttonStackView?.isHidden = true
        }
        
        instructionsLabel.superview?.isHidden = true
        botCountView.isHidden = false
        cancelButton.isHidden = false
        startGameButton.isHidden = false
        statusLabel.text = "⚔️ Single Player Mode\nChoose your opponents"
        
        // Animate in the new elements
        botCountView.alpha = 0
        cancelButton.alpha = 0
        startGameButton.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0.1) {
            self.botCountView.alpha = 1
            self.cancelButton.alpha = 1
            self.startGameButton.alpha = 1
        }
    }
    
    /// Reset lobby to initial state with animations
    func reset() {
        buttonStackView?.isHidden = false
        buttonStackView?.alpha = 0
        buttonStackView?.transform = CGAffineTransform(translationX: -30, y: 0)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.buttonStackView?.alpha = 1
            self.buttonStackView?.transform = .identity
        }
        
        instructionsLabel.superview?.isHidden = false
        spriteModeButton.isHidden = false
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
