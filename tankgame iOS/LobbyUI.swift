//
//  LobbyUI.swift
//  tankgame iOS
//
//  Created by jospicer on 10/28/25.
//

import UIKit
import MultipeerConnectivity

/// Manages the lobby user interface
class LobbyUI {
    // UI Elements
    private(set) var lobbyView: UIView!
    private(set) var hostButton: UIButton!
    private(set) var joinButton: UIButton!
    private(set) var cancelButton: UIButton!
    private(set) var startGameButton: UIButton!
    private(set) var peerTableView: UITableView!
    private(set) var connectedPlayersView: UIView!
    private(set) var connectedPlayersLabel: UILabel!
    private(set) var statusLabel: UILabel!
    private(set) var instructionsLabel: UILabel!
    private(set) var emptyStateLabel: UILabel!
    private(set) var activityIndicator: UIActivityIndicatorView!
    
    // Settings UI Elements
    private(set) var settingsView: UIView!
    private(set) var speedSlider: UISlider!
    private(set) var colorSlider: UISlider!
    private(set) var speedLabel: UILabel!
    private(set) var colorLabel: UILabel!
    private(set) var colorPreview: UIView!
    
    // Callbacks
    var onHostTapped: (() -> Void)?
    var onJoinTapped: (() -> Void)?
    var onCancelTapped: (() -> Void)?
    var onStartGameTapped: (() -> Void)?
    var onSpeedChanged: ((Float) -> Void)?
    var onColorChanged: ((Float) -> Void)?
    
    func setup(in parentView: UIView) {
        // Create lobby view
        lobbyView = UIView(frame: parentView.bounds)
        lobbyView.backgroundColor = .systemBackground
        parentView.addSubview(lobbyView)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "🎮 Tank Game"
        titleLabel.font = .systemFont(ofSize: 36, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(titleLabel)
        
        // Status label
        statusLabel = UILabel()
        statusLabel.text = "Choose an option to start"
        statusLabel.font = .systemFont(ofSize: 18, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.textColor = .secondaryLabel
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(statusLabel)
        
        // Instructions label
        instructionsLabel = UILabel()
        instructionsLabel.text = "Battle with 2-4 players on the same network!\nMove with the joystick, tap FIRE to shoot."
        instructionsLabel.font = .systemFont(ofSize: 14)
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textColor = .secondaryLabel
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(instructionsLabel)
        
        // Host button
        hostButton = createButton(title: "🎯 Host Game", backgroundColor: .systemBlue)
        hostButton.addTarget(self, action: #selector(hostButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(hostButton)
        
        // Join button
        joinButton = createButton(title: "🔍 Join Game", backgroundColor: .systemGreen)
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        lobbyView.addSubview(joinButton)
        
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
        startGameButton = createButton(title: "🚀 Start Game", backgroundColor: .systemGreen)
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
        
        // Settings view
        settingsView = UIView()
        settingsView.backgroundColor = .secondarySystemBackground
        settingsView.layer.cornerRadius = 12
        settingsView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(settingsView)
        
        let settingsTitleLabel = UILabel()
        settingsTitleLabel.text = "⚙️ Your Settings"
        settingsTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        settingsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        settingsView.addSubview(settingsTitleLabel)
        
        // Speed control
        let speedTitleLabel = UILabel()
        speedTitleLabel.text = "Speed:"
        speedTitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        speedTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        settingsView.addSubview(speedTitleLabel)
        
        speedLabel = UILabel()
        speedLabel.text = "1.0x"
        speedLabel.font = .systemFont(ofSize: 14)
        speedLabel.textAlignment = .right
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        settingsView.addSubview(speedLabel)
        
        speedSlider = UISlider()
        speedSlider.minimumValue = 0.5
        speedSlider.maximumValue = 2.0
        speedSlider.value = 1.0
        speedSlider.translatesAutoresizingMaskIntoConstraints = false
        settingsView.addSubview(speedSlider)
        
        // Color control
        let colorTitleLabel = UILabel()
        colorTitleLabel.text = "Color:"
        colorTitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        colorTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        settingsView.addSubview(colorTitleLabel)
        
        colorLabel = UILabel()
        colorLabel.text = "Blue"
        colorLabel.font = .systemFont(ofSize: 14)
        colorLabel.textAlignment = .right
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        settingsView.addSubview(colorLabel)
        
        colorSlider = UISlider()
        colorSlider.minimumValue = 0.0
        colorSlider.maximumValue = 1.0
        colorSlider.value = 0.6
        colorSlider.translatesAutoresizingMaskIntoConstraints = false
        settingsView.addSubview(colorSlider)
        
        colorPreview = UIView()
        colorPreview.layer.cornerRadius = 16
        colorPreview.layer.borderWidth = 2
        colorPreview.layer.borderColor = UIColor.label.cgColor
        colorPreview.translatesAutoresizingMaskIntoConstraints = false
        settingsView.addSubview(colorPreview)
        
        NSLayoutConstraint.activate([
            settingsTitleLabel.topAnchor.constraint(equalTo: settingsView.topAnchor, constant: 12),
            settingsTitleLabel.centerXAnchor.constraint(equalTo: settingsView.centerXAnchor),
            
            speedTitleLabel.topAnchor.constraint(equalTo: settingsTitleLabel.bottomAnchor, constant: 16),
            speedTitleLabel.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: 16),
            
            speedLabel.centerYAnchor.constraint(equalTo: speedTitleLabel.centerYAnchor),
            speedLabel.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor, constant: -16),
            speedLabel.widthAnchor.constraint(equalToConstant: 50),
            
            speedSlider.topAnchor.constraint(equalTo: speedTitleLabel.bottomAnchor, constant: 8),
            speedSlider.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: 16),
            speedSlider.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor, constant: -16),
            
            colorTitleLabel.topAnchor.constraint(equalTo: speedSlider.bottomAnchor, constant: 16),
            colorTitleLabel.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: 16),
            
            colorLabel.centerYAnchor.constraint(equalTo: colorTitleLabel.centerYAnchor),
            colorLabel.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor, constant: -16),
            colorLabel.widthAnchor.constraint(equalToConstant: 80),
            
            colorSlider.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor, constant: 8),
            colorSlider.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: 16),
            colorSlider.trailingAnchor.constraint(equalTo: colorPreview.leadingAnchor, constant: -12),
            
            colorPreview.centerYAnchor.constraint(equalTo: colorSlider.centerYAnchor),
            colorPreview.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor, constant: -16),
            colorPreview.widthAnchor.constraint(equalToConstant: 32),
            colorPreview.heightAnchor.constraint(equalToConstant: 32),
            colorPreview.bottomAnchor.constraint(equalTo: settingsView.bottomAnchor, constant: -16)
        ])
        
        setupConstraints(titleLabel: titleLabel)
    }
    
    private func createButton(title: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func setupConstraints(titleLabel: UILabel) {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: lobbyView.safeAreaLayoutGuide.topAnchor, constant: 80),
            titleLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            statusLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            instructionsLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
            instructionsLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            instructionsLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            settingsView.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 20),
            settingsView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            settingsView.widthAnchor.constraint(equalToConstant: 300),
            
            hostButton.topAnchor.constraint(equalTo: settingsView.bottomAnchor, constant: 20),
            hostButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            hostButton.widthAnchor.constraint(equalToConstant: 240),
            hostButton.heightAnchor.constraint(equalToConstant: 56),
            
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 20),
            joinButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            joinButton.widthAnchor.constraint(equalToConstant: 240),
            joinButton.heightAnchor.constraint(equalToConstant: 56),
            
            cancelButton.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 20),
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
            startGameButton.widthAnchor.constraint(equalToConstant: 240),
            startGameButton.heightAnchor.constraint(equalToConstant: 56),
            
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
    
    @objc private func cancelButtonTapped() {
        onCancelTapped?()
    }
    
    @objc private func startGameButtonTapped() {
        onStartGameTapped?()
    }
    
    /// Update settings display based on current settings
    func updateSettingsDisplay(_ settings: PlayerSettings) {
        speedSlider.value = Float(settings.speed)
        speedLabel.text = String(format: "%.1fx", settings.speed)
        
        colorSlider.value = Float(settings.colorHue)
        // Convert SKColor to UIColor for iOS
        colorPreview.backgroundColor = UIColor(hue: CGFloat(settings.colorHue), saturation: 0.9, brightness: 0.9, alpha: 1.0)
        
        // Update color name
        let hue = settings.colorHue
        let colorName: String
        if hue < 0.08 || hue > 0.92 {
            colorName = "Red"
        } else if hue < 0.17 {
            colorName = "Orange"
        } else if hue < 0.25 {
            colorName = "Yellow"
        } else if hue < 0.42 {
            colorName = "Green"
        } else if hue < 0.58 {
            colorName = "Cyan"
        } else if hue < 0.75 {
            colorName = "Blue"
        } else if hue < 0.83 {
            colorName = "Purple"
        } else {
            colorName = "Pink"
        }
        colorLabel.text = colorName
    }
    
    /// Reset lobby to initial state
    func reset() {
        hostButton.isHidden = false
        joinButton.isHidden = false
        instructionsLabel.isHidden = false
        cancelButton.isHidden = true
        startGameButton.isHidden = true
        connectedPlayersView.isHidden = true
        peerTableView.isHidden = true
        emptyStateLabel.isHidden = true
        activityIndicator.stopAnimating()
        statusLabel.text = "Choose an option to start"
    }
}
