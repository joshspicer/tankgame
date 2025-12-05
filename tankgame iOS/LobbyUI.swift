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
    
    // Store gradient layer for layout updates
    private var gradientLayer: CAGradientLayer?
    private var decorativeLayer: CAShapeLayer?
    
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
        lobbyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parentView.addSubview(lobbyView)
        
        // Add premium gradient background
        setupGradientBackground(in: parentView)
        
        // Add subtle decorative elements
        setupDecorativeElements()
        
        // Create scroll view for content
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        lobbyView.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Title container with glow effect
        let titleContainer = UIView()
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleContainer)
        
        // Tank emoji above title with animation
        let tankEmojiLabel = UILabel()
        tankEmojiLabel.text = "🎮"
        tankEmojiLabel.font = .systemFont(ofSize: 56)
        tankEmojiLabel.textAlignment = .center
        tankEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.addSubview(tankEmojiLabel)
        addPulseAnimation(to: tankEmojiLabel)
        
        // Title label with gradient-like appearance
        let titleLabel = UILabel()
        titleLabel.text = "TANK BATTLE"
        titleLabel.font = .systemFont(ofSize: 42, weight: .black)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.addSubview(titleLabel)
        
        // Subtitle label
        let subtitleLabel = UILabel()
        subtitleLabel.text = "MULTIPLAYER ARENA"
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = UXTheme.primaryUIColor
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.addSubview(subtitleLabel)
        
        // Status label with card styling
        statusLabel = UILabel()
        statusLabel.text = "Ready to Battle?"
        statusLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.textColor = .white
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLabel)
        
        // Instructions card
        let instructionsCard = createCard()
        contentView.addSubview(instructionsCard)
        
        instructionsLabel = UILabel()
        instructionsLabel.text = "Battle with 2-4 players on the same network!\nMove with the joystick • Tap FIRE to shoot"
        instructionsLabel.font = .systemFont(ofSize: 14, weight: .medium)
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsCard.addSubview(instructionsLabel)
        
        // Divider
        let divider = UIView()
        divider.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        divider.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(divider)
        
        // Single Player button (with AI bots)
        singlePlayerButton = createModernButton(
            title: "Single Player",
            subtitle: "vs AI Bots",
            icon: "🤖",
            gradientColors: [UXTheme.orangeAccentUIColor, UXTheme.orangeAccentUIColor.withAlphaComponent(0.8)]
        )
        singlePlayerButton.addTarget(self, action: #selector(singlePlayerButtonTapped), for: .touchUpInside)
        contentView.addSubview(singlePlayerButton)
        
        // Host button
        hostButton = createModernButton(
            title: "Host Game",
            subtitle: "Create lobby",
            icon: "📡",
            gradientColors: [UXTheme.primaryUIColor, UXTheme.primaryUIColor.withAlphaComponent(0.8)]
        )
        hostButton.addTarget(self, action: #selector(hostButtonTapped), for: .touchUpInside)
        contentView.addSubview(hostButton)
        
        // Join button
        joinButton = createModernButton(
            title: "Join Game",
            subtitle: "Find nearby",
            icon: "🔍",
            gradientColors: [UXTheme.successUIColor, UXTheme.successUIColor.withAlphaComponent(0.8)]
        )
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        contentView.addSubview(joinButton)
        
        // Bot count selection view (for single player mode) - styled as card
        botCountView = createCard()
        botCountView.isHidden = true
        contentView.addSubview(botCountView)
        
        let botIcon = UILabel()
        botIcon.text = "🤖"
        botIcon.font = .systemFont(ofSize: 28)
        botIcon.translatesAutoresizingMaskIntoConstraints = false
        botCountView.addSubview(botIcon)
        
        botCountLabel = UILabel()
        botCountLabel.text = "AI Bots: 1"
        botCountLabel.font = .systemFont(ofSize: 17, weight: .semibold)
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
        
        // Sprite mode toggle button - styled more subtly
        spriteModeButton = createSpriteModeButton()
        spriteModeButton.addTarget(self, action: #selector(spriteModeButtonTapped), for: .touchUpInside)
        contentView.addSubview(spriteModeButton)
        
        // Cancel button - styled more prominently
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("✕ Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cancelButton.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .normal)
        cancelButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        cancelButton.layer.cornerRadius = 12
        cancelButton.isHidden = true
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        contentView.addSubview(cancelButton)
        
        // Start Game button (for host) - premium styling
        startGameButton = createModernButton(
            title: "Start Battle!",
            subtitle: "Begin the game",
            icon: "🚀",
            gradientColors: [UXTheme.successUIColor, UXTheme.secondaryUIColor]
        )
        startGameButton.isHidden = true
        startGameButton.addTarget(self, action: #selector(startGameButtonTapped), for: .touchUpInside)
        contentView.addSubview(startGameButton)
        
        // Connected players view - styled as premium card
        connectedPlayersView = createCard()
        connectedPlayersView.isHidden = true
        contentView.addSubview(connectedPlayersView)
        
        let playersIcon = UILabel()
        playersIcon.text = "👥"
        playersIcon.font = .systemFont(ofSize: 24)
        playersIcon.translatesAutoresizingMaskIntoConstraints = false
        connectedPlayersView.addSubview(playersIcon)
        
        connectedPlayersLabel = UILabel()
        connectedPlayersLabel.text = "Connected: 1/4"
        connectedPlayersLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        connectedPlayersLabel.textAlignment = .left
        connectedPlayersLabel.numberOfLines = 0
        connectedPlayersLabel.textColor = .white
        connectedPlayersLabel.translatesAutoresizingMaskIntoConstraints = false
        connectedPlayersView.addSubview(connectedPlayersLabel)
        
        // Activity indicator - custom styled
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = UXTheme.primaryUIColor
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityIndicator)
        
        // Peer table view - modern styling
        peerTableView = UITableView()
        peerTableView.isHidden = true
        peerTableView.backgroundColor = UXTheme.cardBackground
        peerTableView.layer.cornerRadius = 16
        peerTableView.layer.borderWidth = 1
        peerTableView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        peerTableView.separatorColor = UIColor.white.withAlphaComponent(0.1)
        peerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PeerCell")
        peerTableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(peerTableView)
        
        // Empty state label - styled
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "🔍 No nearby games found.\nMake sure the other device is hosting."
        emptyStateLabel.font = .systemFont(ofSize: 15, weight: .medium)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emptyStateLabel)
        
        setupConstraints(
            scrollView: scrollView,
            contentView: contentView,
            titleContainer: titleContainer,
            titleLabel: titleLabel,
            subtitleLabel: subtitleLabel,
            tankEmojiLabel: tankEmojiLabel,
            instructionsCard: instructionsCard,
            divider: divider,
            botIcon: botIcon,
            playersIcon: playersIcon
        )
    }
    
    private func setupGradientBackground(in parentView: UIView) {
        let gradient = CAGradientLayer()
        gradient.frame = parentView.bounds
        gradient.colors = UXTheme.lobbyGradientColors
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        lobbyView.layer.insertSublayer(gradient, at: 0)
        self.gradientLayer = gradient
    }
    
    private func setupDecorativeElements() {
        // Add subtle grid pattern overlay
        let patternLayer = CAShapeLayer()
        patternLayer.frame = lobbyView.bounds
        patternLayer.strokeColor = UIColor.white.withAlphaComponent(0.03).cgColor
        patternLayer.lineWidth = 1
        patternLayer.fillColor = nil
        
        let path = UIBezierPath()
        let spacing: CGFloat = 40
        
        // Vertical lines
        var x: CGFloat = 0
        while x < lobbyView.bounds.width {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: lobbyView.bounds.height))
            x += spacing
        }
        
        // Horizontal lines
        var y: CGFloat = 0
        while y < lobbyView.bounds.height {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: lobbyView.bounds.width, y: y))
            y += spacing
        }
        
        patternLayer.path = path.cgPath
        lobbyView.layer.insertSublayer(patternLayer, at: 1)
        self.decorativeLayer = patternLayer
    }
    
    private func createCard() -> UIView {
        let card = UIView()
        card.backgroundColor = UXTheme.cardBackground
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }
    
    private func addPulseAnimation(to view: UIView) {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = 2.0
        pulse.fromValue = 1.0
        pulse.toValue = 1.1
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(pulse, forKey: "pulse")
    }
    
    private func createModernButton(title: String, subtitle: String, icon: String, gradientColors: [UIColor]) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Container stack
        let mainStack = UIStackView()
        mainStack.axis = .horizontal
        mainStack.spacing = 14
        mainStack.alignment = .center
        mainStack.isUserInteractionEnabled = false
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon container with background
        let iconContainer = UIView()
        iconContainer.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        iconContainer.layer.cornerRadius = 10
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 24)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconLabel)
        
        // Text stack
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)
        
        // Chevron
        let chevron = UILabel()
        chevron.text = "›"
        chevron.font = .systemFont(ofSize: 24, weight: .semibold)
        chevron.textColor = UIColor.white.withAlphaComponent(0.5)
        
        mainStack.addArrangedSubview(iconContainer)
        mainStack.addArrangedSubview(textStack)
        mainStack.addArrangedSubview(UIView()) // Spacer
        mainStack.addArrangedSubview(chevron)
        
        button.addSubview(mainStack)
        
        // Background gradient
        button.backgroundColor = gradientColors.first
        button.layer.cornerRadius = 16
        
        // Shadow
        button.layer.shadowColor = gradientColors.first?.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: button.topAnchor, constant: 14),
            mainStack.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -14),
            
            iconContainer.widthAnchor.constraint(equalToConstant: 44),
            iconContainer.heightAnchor.constraint(equalToConstant: 44),
            iconLabel.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor)
        ])
        
        return button
    }
    
    private func setupConstraints(
        scrollView: UIScrollView,
        contentView: UIView,
        titleContainer: UIView,
        titleLabel: UILabel,
        subtitleLabel: UILabel,
        tankEmojiLabel: UILabel,
        instructionsCard: UIView,
        divider: UIView,
        botIcon: UILabel,
        playersIcon: UILabel
    ) {
        let horizontalPadding: CGFloat = 24
        
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: lobbyView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: lobbyView.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title container
            titleContainer.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            tankEmojiLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor),
            tankEmojiLabel.centerXAnchor.constraint(equalTo: titleContainer.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: tankEmojiLabel.bottomAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: titleContainer.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.centerXAnchor.constraint(equalTo: titleContainer.centerXAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor),
            
            // Status label
            statusLabel.topAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            
            // Instructions card
            instructionsCard.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            instructionsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            instructionsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            
            instructionsLabel.topAnchor.constraint(equalTo: instructionsCard.topAnchor, constant: 16),
            instructionsLabel.leadingAnchor.constraint(equalTo: instructionsCard.leadingAnchor, constant: 16),
            instructionsLabel.trailingAnchor.constraint(equalTo: instructionsCard.trailingAnchor, constant: -16),
            instructionsLabel.bottomAnchor.constraint(equalTo: instructionsCard.bottomAnchor, constant: -16),
            
            // Divider
            divider.topAnchor.constraint(equalTo: instructionsCard.bottomAnchor, constant: 20),
            divider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding + 20),
            divider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -(horizontalPadding + 20)),
            divider.heightAnchor.constraint(equalToConstant: 1),
            
            // Single player button
            singlePlayerButton.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 20),
            singlePlayerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            singlePlayerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            singlePlayerButton.heightAnchor.constraint(equalToConstant: 72),
            
            // Host button
            hostButton.topAnchor.constraint(equalTo: singlePlayerButton.bottomAnchor, constant: 12),
            hostButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            hostButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            hostButton.heightAnchor.constraint(equalToConstant: 72),
            
            // Join button
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 12),
            joinButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            joinButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            joinButton.heightAnchor.constraint(equalToConstant: 72),
            
            // Sprite mode button
            spriteModeButton.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 20),
            spriteModeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spriteModeButton.widthAnchor.constraint(equalToConstant: 200),
            spriteModeButton.heightAnchor.constraint(equalToConstant: 48),
            
            // Bot count view
            botCountView.topAnchor.constraint(equalTo: spriteModeButton.bottomAnchor, constant: 16),
            botCountView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            botCountView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            botCountView.heightAnchor.constraint(equalToConstant: 60),
            
            botIcon.leadingAnchor.constraint(equalTo: botCountView.leadingAnchor, constant: 16),
            botIcon.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            
            botCountLabel.leadingAnchor.constraint(equalTo: botIcon.trailingAnchor, constant: 12),
            botCountLabel.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            
            botCountStepper.trailingAnchor.constraint(equalTo: botCountView.trailingAnchor, constant: -16),
            botCountStepper.centerYAnchor.constraint(equalTo: botCountView.centerYAnchor),
            
            // Cancel button
            cancelButton.topAnchor.constraint(equalTo: botCountView.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 140),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Connected players view
            connectedPlayersView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            connectedPlayersView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            connectedPlayersView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            connectedPlayersView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70),
            
            playersIcon.leadingAnchor.constraint(equalTo: connectedPlayersView.leadingAnchor, constant: 16),
            playersIcon.centerYAnchor.constraint(equalTo: connectedPlayersView.centerYAnchor),
            
            connectedPlayersLabel.leadingAnchor.constraint(equalTo: playersIcon.trailingAnchor, constant: 12),
            connectedPlayersLabel.trailingAnchor.constraint(equalTo: connectedPlayersView.trailingAnchor, constant: -16),
            connectedPlayersLabel.topAnchor.constraint(equalTo: connectedPlayersView.topAnchor, constant: 16),
            connectedPlayersLabel.bottomAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: -16),
            
            // Start game button
            startGameButton.topAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: 20),
            startGameButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            startGameButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            startGameButton.heightAnchor.constraint(equalToConstant: 72),
            
            // Activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 30),
            
            // Peer table view
            peerTableView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            peerTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            peerTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            peerTableView.heightAnchor.constraint(equalToConstant: 200),
            
            // Empty state label
            emptyStateLabel.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 40),
            emptyStateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            emptyStateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            
            // Content view bottom (for scrolling)
            startGameButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    @objc private func hostButtonTapped() {
        animateButtonPress(hostButton)
        onHostTapped?()
    }
    
    @objc private func joinButtonTapped() {
        animateButtonPress(joinButton)
        onJoinTapped?()
    }
    
    @objc private func singlePlayerButtonTapped() {
        animateButtonPress(singlePlayerButton)
        onSinglePlayerTapped?()
    }
    
    @objc private func cancelButtonTapped() {
        animateButtonPress(cancelButton)
        onCancelTapped?()
    }
    
    @objc private func startGameButtonTapped() {
        animateButtonPress(startGameButton)
        onStartGameTapped?()
    }
    
    private func animateButtonPress(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        }
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
    
    /// Create sprite mode toggle button with modern styling
    private func createSpriteModeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UXTheme.cardBackground
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
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
    
    /// Show single player mode UI with animation
    func showSinglePlayerMode() {
        UIView.animate(withDuration: 0.3) {
            self.singlePlayerButton.alpha = 0
            self.hostButton.alpha = 0
            self.joinButton.alpha = 0
            self.instructionsLabel.superview?.alpha = 0
        } completion: { _ in
            self.singlePlayerButton.isHidden = true
            self.hostButton.isHidden = true
            self.joinButton.isHidden = true
            self.instructionsLabel.superview?.isHidden = true
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
        statusLabel.text = "Single Player Mode"
    }
    
    /// Reset lobby to initial state with animation
    func reset() {
        UIView.animate(withDuration: 0.3) {
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
            self.instructionsLabel.superview?.isHidden = false
            self.spriteModeButton.isHidden = false
            self.botCountView.isHidden = true
            self.cancelButton.isHidden = true
            self.startGameButton.isHidden = true
            self.connectedPlayersView.isHidden = true
            self.peerTableView.isHidden = true
            self.emptyStateLabel.isHidden = true
            self.activityIndicator.stopAnimating()
            
            self.singlePlayerButton.alpha = 0
            self.hostButton.alpha = 0
            self.joinButton.alpha = 0
            self.instructionsLabel.superview?.alpha = 0
            
            UIView.animate(withDuration: 0.3) {
                self.singlePlayerButton.alpha = 1
                self.hostButton.alpha = 1
                self.joinButton.alpha = 1
                self.instructionsLabel.superview?.alpha = 1
            }
        }
        statusLabel.text = "Ready to Battle?"
        updateSpriteModeButton()
    }
}
