//
//  ModernLobbyUI.swift
//  tankgame iOS
//
//  Redesigned lobby interface with modern UX
//

import UIKit
import MultipeerConnectivity
import QuartzCore

/// Modern redesigned lobby user interface with glassmorphism and animations
class ModernLobbyUI {
    
    // MARK: - UI Elements
    
    private(set) var lobbyView: UIView!
    private(set) var backgroundView: GradientBackgroundView!
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
    
    // Title elements
    private var titleLabel: UILabel!
    private var tankIconView: UIView!
    
    // Particle emitter for background
    private var particleEmitter: CAEmitterLayer?
    
    // Gradient layers for buttons (stored separately to avoid using KVO)
    private var buttonGradientLayers: [UIButton: CAGradientLayer] = [:]
    
    /// Number of AI bots to add
    var botCount: Int = 1
    
    // MARK: - Callbacks
    
    var onHostTapped: (() -> Void)?
    var onJoinTapped: (() -> Void)?
    var onSinglePlayerTapped: (() -> Void)?
    var onCancelTapped: (() -> Void)?
    var onStartGameTapped: (() -> Void)?
    
    // MARK: - Setup
    
    func setup(in parentView: UIView) {
        // Create animated gradient background
        backgroundView = GradientBackgroundView(frame: parentView.bounds)
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parentView.addSubview(backgroundView)
        backgroundView.startAnimating()
        
        // Add floating particles
        addParticleEffect(to: backgroundView)
        
        // Create lobby container view
        lobbyView = UIView(frame: parentView.bounds)
        lobbyView.backgroundColor = .clear
        lobbyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parentView.addSubview(lobbyView)
        
        // Setup UI components
        setupTitleSection()
        setupMainButtons()
        setupSecondaryElements()
        setupConstraints()
        
        // Animate entrance
        animateEntrance()
    }
    
    // MARK: - Title Section
    
    private func setupTitleSection() {
        // Animated tank icon
        tankIconView = createAnimatedTankIcon()
        tankIconView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(tankIconView)
        
        // Main title
        titleLabel = UILabel()
        titleLabel.text = "TANK GAME"
        titleLabel.font = UXTheme.Typography.titleFont
        titleLabel.textAlignment = .center
        titleLabel.textColor = UXTheme.Colors.titleText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(titleLabel)
        
        // Add glow effect to title
        titleLabel.layer.shadowColor = UXTheme.Colors.accentBlue.cgColor
        titleLabel.layer.shadowOffset = .zero
        titleLabel.layer.shadowRadius = 15
        titleLabel.layer.shadowOpacity = 0.6
        
        // Status label
        statusLabel = UILabel()
        statusLabel.text = "Choose your battle mode"
        statusLabel.font = UXTheme.Typography.bodyFont
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.textColor = UXTheme.Colors.subtitleText
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(statusLabel)
        
        // Instructions label
        instructionsLabel = UILabel()
        instructionsLabel.text = "Battle with 2-4 players on the same network!\nMove with the joystick, tap FIRE to shoot."
        instructionsLabel.font = UXTheme.Typography.captionFont
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textColor = UXTheme.Colors.bodyText
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(instructionsLabel)
    }
    
    // MARK: - Main Buttons
    
    private func setupMainButtons() {
        // Single Player button
        singlePlayerButton = createModernButton(
            title: "Single Player",
            icon: "🤖",
            gradientColors: [UXTheme.Colors.accentOrange, UXTheme.Colors.accentOrange.withAlphaComponent(0.7)]
        )
        singlePlayerButton.addTarget(self, action: #selector(singlePlayerButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(singlePlayerButton)
        
        // Host button
        hostButton = createModernButton(
            title: "Host Game",
            icon: "🎯",
            gradientColors: [UXTheme.Colors.accentBlue, UXTheme.Colors.primaryGradientStart]
        )
        hostButton.addTarget(self, action: #selector(hostButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(hostButton)
        
        // Join button
        joinButton = createModernButton(
            title: "Join Game",
            icon: "🔍",
            gradientColors: [UXTheme.Colors.accentGreen, UXTheme.Colors.accentGreen.withAlphaComponent(0.7)]
        )
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(joinButton)
        
        // Start Game button (hidden initially)
        startGameButton = createModernButton(
            title: "Start Game",
            icon: "🚀",
            gradientColors: [UXTheme.Colors.accentGreen, UXTheme.Colors.accentGreen.withAlphaComponent(0.7)]
        )
        startGameButton.isHidden = true
        startGameButton.addTarget(self, action: #selector(startGameButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(startGameButton)
    }
    
    // MARK: - Secondary Elements
    
    private func setupSecondaryElements() {
        // Sprite mode toggle
        spriteModeButton = createSpriteModeToggle()
        spriteModeButton.addTarget(self, action: #selector(spriteModeButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(spriteModeButton)
        
        // Bot count selection view
        setupBotCountView()
        
        // Cancel button
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("← Cancel", for: .normal)
        cancelButton.titleLabel?.font = UXTheme.Typography.buttonFont
        cancelButton.setTitleColor(UXTheme.Colors.accentRed, for: .normal)
        cancelButton.isHidden = true
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(cancelButton)
        
        // Connected players card
        setupConnectedPlayersView()
        
        // Activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = UXTheme.Colors.accentBlue
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(activityIndicator)
        
        // Peer table view
        setupPeerTableView()
        
        // Empty state label
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "Searching for nearby games...\nMake sure the other device is hosting."
        emptyStateLabel.font = UXTheme.Typography.bodyFont
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textColor = UXTheme.Colors.bodyText
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(emptyStateLabel)
    }
    
    // MARK: - Component Creation Helpers
    
    private func createAnimatedTankIcon() -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        
        let emojiLabel = UILabel()
        emojiLabel.text = "🎮"
        emojiLabel.font = .systemFont(ofSize: 70)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        // Add floating animation
        let floatAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        floatAnimation.fromValue = -5
        floatAnimation.toValue = 5
        floatAnimation.duration = 2.0
        floatAnimation.autoreverses = true
        floatAnimation.repeatCount = .infinity
        floatAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        emojiLabel.layer.add(floatAnimation, forKey: "float")
        
        return container
    }
    
    private func createModernButton(title: String, icon: String, gradientColors: [UIColor]) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Create gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = UXTheme.Dimensions.buttonCornerRadius
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        // Store gradient layer reference in dictionary
        buttonGradientLayers[button] = gradientLayer
        
        // Content stack
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 26)
        
        let textLabel = UILabel()
        textLabel.text = title
        textLabel.font = UXTheme.Typography.buttonFont
        textLabel.textColor = .white
        
        stackView.addArrangedSubview(iconLabel)
        stackView.addArrangedSubview(textLabel)
        button.addSubview(stackView)
        
        // Style
        button.layer.cornerRadius = UXTheme.Dimensions.buttonCornerRadius
        button.clipsToBounds = false
        UXTheme.Shadows.apply(to: button.layer, color: gradientColors[0], opacity: 0.4, radius: 12, offset: CGSize(width: 0, height: 6))
        
        // Constraints
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        // Add press animation
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return button
    }
    
    private func createSpriteModeToggle() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Glassmorphism style
        button.backgroundColor = UXTheme.Colors.glassSurface
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UXTheme.Colors.cardBorder.cgColor
        
        updateSpriteModeButtonTitle(button)
        
        return button
    }
    
    private func setupBotCountView() {
        botCountView = UIView()
        botCountView.backgroundColor = UXTheme.Colors.glassSurface
        botCountView.layer.cornerRadius = 14
        botCountView.layer.borderWidth = 1
        botCountView.layer.borderColor = UXTheme.Colors.cardBorder.cgColor
        botCountView.isHidden = true
        botCountView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(botCountView)
        
        botCountLabel = UILabel()
        botCountLabel.text = "AI Bots: 1"
        botCountLabel.font = UXTheme.Typography.bodyFont
        botCountLabel.textAlignment = .center
        botCountLabel.textColor = UXTheme.Colors.subtitleText
        botCountLabel.translatesAutoresizingMaskIntoConstraints = false
        botCountView.addSubview(botCountLabel)
        
        botCountStepper = UIStepper()
        botCountStepper.minimumValue = 1
        botCountStepper.maximumValue = 3
        botCountStepper.value = 1
        botCountStepper.addTarget(self, action: #selector(botCountChanged), for: .valueChanged)
        botCountStepper.translatesAutoresizingMaskIntoConstraints = false
        botCountView.addSubview(botCountStepper)
        
        NSLayoutConstraint.activate([
            botCountLabel.leadingAnchor.constraint(equalTo: botCountView.leadingAnchor, constant: 16),
            botCountLabel.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            botCountStepper.trailingAnchor.constraint(equalTo: botCountView.trailingAnchor, constant: -16),
            botCountStepper.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor)
        ])
    }
    
    private func setupConnectedPlayersView() {
        connectedPlayersView = UIView()
        connectedPlayersView.backgroundColor = UXTheme.Colors.glassSurface
        connectedPlayersView.layer.cornerRadius = 16
        connectedPlayersView.layer.borderWidth = 1
        connectedPlayersView.layer.borderColor = UXTheme.Colors.cardBorder.cgColor
        connectedPlayersView.isHidden = true
        connectedPlayersView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(connectedPlayersView)
        
        connectedPlayersLabel = UILabel()
        connectedPlayersLabel.text = "Connected: 1/4"
        connectedPlayersLabel.font = UXTheme.Typography.bodyFont
        connectedPlayersLabel.textAlignment = .center
        connectedPlayersLabel.numberOfLines = 0
        connectedPlayersLabel.textColor = UXTheme.Colors.subtitleText
        connectedPlayersLabel.translatesAutoresizingMaskIntoConstraints = false
        connectedPlayersView.addSubview(connectedPlayersLabel)
        
        NSLayoutConstraint.activate([
            connectedPlayersLabel.topAnchor.constraint(equalTo: connectedPlayersView.topAnchor, constant: 16),
            connectedPlayersLabel.leadingAnchor.constraint(equalTo: connectedPlayersView.leadingAnchor, constant: 16),
            connectedPlayersLabel.trailingAnchor.constraint(equalTo: connectedPlayersView.trailingAnchor, constant: -16),
            connectedPlayersLabel.bottomAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupPeerTableView() {
        peerTableView = UITableView()
        peerTableView.isHidden = true
        peerTableView.layer.cornerRadius = 16
        peerTableView.backgroundColor = UXTheme.Colors.glassSurface
        peerTableView.layer.borderWidth = 1
        peerTableView.layer.borderColor = UXTheme.Colors.cardBorder.cgColor
        peerTableView.separatorColor = UXTheme.Colors.cardBorder
        peerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PeerCell")
        peerTableView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(peerTableView)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Tank icon
            tankIconView.topAnchor.constraint(equalTo: lobbyView.safeAreaLayoutGuide.topAnchor, constant: 30),
            tankIconView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            tankIconView.widthAnchor.constraint(equalToConstant: 80),
            tankIconView.heightAnchor.constraint(equalToConstant: 80),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: tankIconView.bottomAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            // Status
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            statusLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            // Instructions
            instructionsLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 6),
            instructionsLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            instructionsLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            // Single Player button
            singlePlayerButton.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 28),
            singlePlayerButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            singlePlayerButton.widthAnchor.constraint(equalToConstant: UXTheme.Dimensions.buttonWidth),
            singlePlayerButton.heightAnchor.constraint(equalToConstant: UXTheme.Dimensions.buttonHeight),
            
            // Host button
            hostButton.topAnchor.constraint(equalTo: singlePlayerButton.bottomAnchor, constant: 14),
            hostButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            hostButton.widthAnchor.constraint(equalToConstant: UXTheme.Dimensions.buttonWidth),
            hostButton.heightAnchor.constraint(equalToConstant: UXTheme.Dimensions.buttonHeight),
            
            // Join button
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 14),
            joinButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            joinButton.widthAnchor.constraint(equalToConstant: UXTheme.Dimensions.buttonWidth),
            joinButton.heightAnchor.constraint(equalToConstant: UXTheme.Dimensions.buttonHeight),
            
            // Sprite mode toggle
            spriteModeButton.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 18),
            spriteModeButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            spriteModeButton.widthAnchor.constraint(equalToConstant: 180),
            spriteModeButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Bot count view
            botCountView.topAnchor.constraint(equalTo: spriteModeButton.bottomAnchor, constant: 16),
            botCountView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            botCountView.widthAnchor.constraint(equalToConstant: 200),
            botCountView.heightAnchor.constraint(equalToConstant: 50),
            
            // Cancel button
            cancelButton.topAnchor.constraint(equalTo: botCountView.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            // Start Game button
            startGameButton.topAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: 20),
            startGameButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            startGameButton.widthAnchor.constraint(equalToConstant: UXTheme.Dimensions.buttonWidth),
            startGameButton.heightAnchor.constraint(equalToConstant: UXTheme.Dimensions.buttonHeight),
            
            // Connected players view
            connectedPlayersView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            connectedPlayersView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            connectedPlayersView.widthAnchor.constraint(equalToConstant: 280),
            connectedPlayersView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            // Activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            
            // Peer table view
            peerTableView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            peerTableView.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            peerTableView.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            peerTableView.heightAnchor.constraint(equalToConstant: 200),
            
            // Empty state label
            emptyStateLabel.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 40),
            emptyStateLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            emptyStateLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30)
        ])
    }
    
    // MARK: - Particle Effect
    
    private func addParticleEffect(to view: UIView) {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: 0)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 1)
        
        let cell = CAEmitterCell()
        cell.birthRate = 1.5
        cell.lifetime = 15.0
        cell.velocity = 15
        cell.velocityRange = 10
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 4
        cell.scale = 0.06
        cell.scaleRange = 0.03
        cell.alphaSpeed = -0.05
        cell.color = UIColor.white.withAlphaComponent(0.25).cgColor
        cell.contents = createCircleImage()?.cgImage
        
        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)
        particleEmitter = emitter
    }
    
    private func createCircleImage() -> UIImage? {
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
    }
    
    // MARK: - Animations
    
    private func animateEntrance() {
        // Stagger button entrance animations
        let buttons = [singlePlayerButton, hostButton, joinButton, spriteModeButton]
        for (index, button) in buttons.enumerated() {
            button?.alpha = 0
            button?.transform = CGAffineTransform(translationX: 0, y: 30)
            UIView.animate(
                withDuration: 0.5,
                delay: 0.1 + Double(index) * 0.1,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: []
            ) {
                button?.alpha = 1
                button?.transform = .identity
            }
        }
        
        // Animate title
        titleLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        }
    }
    
    // MARK: - Button Actions
    
    @objc private func hostButtonTapped() {
        hostButton.addBounceAnimation { [weak self] in
            self?.onHostTapped?()
        }
    }
    
    @objc private func joinButtonTapped() {
        joinButton.addBounceAnimation { [weak self] in
            self?.onJoinTapped?()
        }
    }
    
    @objc private func singlePlayerButtonTapped() {
        singlePlayerButton.addBounceAnimation { [weak self] in
            self?.onSinglePlayerTapped?()
        }
    }
    
    @objc private func cancelButtonTapped() {
        onCancelTapped?()
    }
    
    @objc private func startGameButtonTapped() {
        startGameButton.addBounceAnimation { [weak self] in
            self?.onStartGameTapped?()
        }
    }
    
    @objc private func spriteModeButtonTapped() {
        spriteModeButton.addBounceAnimation { [weak self] in
            guard let self = self else { return }
            let currentMode = GameSettings.shared.spriteMode
            let newMode: SpriteMode = (currentMode == .tank) ? .dolphin : .tank
            GameSettings.shared.spriteMode = newMode
            self.updateSpriteModeButton()
        }
    }
    
    @objc private func botCountChanged() {
        botCount = Int(botCountStepper.value)
        botCountLabel.text = "AI Bots: \(botCount)"
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            sender.transform = .identity
        }
    }
    
    // MARK: - Sprite Mode
    
    private func updateSpriteModeButtonTitle(_ button: UIButton) {
        let mode = GameSettings.shared.spriteMode
        let title = "\(mode.icon) \(mode.displayName)"
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UXTheme.Typography.bodyFont
        button.setTitleColor(UXTheme.Colors.subtitleText, for: .normal)
    }
    
    func updateSpriteModeButton() {
        updateSpriteModeButtonTitle(spriteModeButton)
    }
    
    // MARK: - State Management
    
    func showSinglePlayerMode() {
        UIView.animate(withDuration: UXTheme.Animation.standard) {
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
        
        botCountView.fadeIn(delay: 0.1)
        cancelButton.fadeIn(delay: 0.15)
        startGameButton.fadeIn(delay: 0.2)
        
        statusLabel.text = "Single Player Mode\nSelect number of AI opponents"
    }
    
    func reset() {
        singlePlayerButton.isHidden = false
        hostButton.isHidden = false
        joinButton.isHidden = false
        instructionsLabel.isHidden = false
        spriteModeButton.isHidden = false
        
        singlePlayerButton.alpha = 1
        hostButton.alpha = 1
        joinButton.alpha = 1
        instructionsLabel.alpha = 1
        
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
    
    // MARK: - Layout Updates
    
    func updateLayout(for bounds: CGRect) {
        // Update gradient layer frames for buttons using stored references
        let buttons = [singlePlayerButton, hostButton, joinButton, startGameButton]
        for button in buttons {
            guard let btn = button else { continue }
            if let gradientLayer = buttonGradientLayers[btn] {
                gradientLayer.frame = btn.bounds
            }
        }
        
        // Update particle emitter
        particleEmitter?.emitterPosition = CGPoint(x: bounds.midX, y: 0)
        particleEmitter?.emitterSize = CGSize(width: bounds.width, height: 1)
    }
}
