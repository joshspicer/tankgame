//
//  LobbyUIConstraints.swift
//  tankgame iOS
//
//  Created by AI Assistant on 1/7/26.
//

import UIKit

/// Manages Auto Layout constraints for lobby UI elements
class LobbyUIConstraints {
    
    /// Setup all constraints for the lobby UI
    static func setupConstraints(
        in lobbyView: UIView,
        titleLabel: UILabel,
        tankEmojiLabel: UILabel,
        statusLabel: UILabel,
        instructionsLabel: UILabel,
        singlePlayerButton: UIButton,
        hostButton: UIButton,
        joinButton: UIButton,
        spriteModeButton: UIButton,
        botCountView: UIView,
        cancelButton: UIButton,
        connectedPlayersView: UIView,
        connectedPlayersLabel: UILabel,
        startGameButton: UIButton,
        activityIndicator: UIActivityIndicatorView,
        peerTableView: UITableView,
        emptyStateLabel: UILabel
    ) {
        NSLayoutConstraint.activate([
            // Title and emoji
            tankEmojiLabel.topAnchor.constraint(equalTo: lobbyView.safeAreaLayoutGuide.topAnchor, constant: 40),
            tankEmojiLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: tankEmojiLabel.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            // Status and instructions
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            statusLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            instructionsLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            instructionsLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            instructionsLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            // Main buttons
            singlePlayerButton.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 30),
            singlePlayerButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            singlePlayerButton.widthAnchor.constraint(equalToConstant: 240),
            singlePlayerButton.heightAnchor.constraint(equalToConstant: 56),
            
            hostButton.topAnchor.constraint(equalTo: singlePlayerButton.bottomAnchor, constant: 16),
            hostButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            hostButton.widthAnchor.constraint(equalToConstant: 240),
            hostButton.heightAnchor.constraint(equalToConstant: 56),
            
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 16),
            joinButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            joinButton.widthAnchor.constraint(equalToConstant: 240),
            joinButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Sprite mode button
            spriteModeButton.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 16),
            spriteModeButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            spriteModeButton.widthAnchor.constraint(equalToConstant: 200),
            spriteModeButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Bot count selector
            botCountView.topAnchor.constraint(equalTo: spriteModeButton.bottomAnchor, constant: 16),
            botCountView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            botCountView.widthAnchor.constraint(equalToConstant: 200),
            botCountView.heightAnchor.constraint(equalToConstant: 50),
            
            // Cancel button
            cancelButton.topAnchor.constraint(equalTo: botCountView.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            // Connected players view
            connectedPlayersView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            connectedPlayersView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            connectedPlayersView.widthAnchor.constraint(equalToConstant: 280),
            connectedPlayersView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            connectedPlayersLabel.topAnchor.constraint(equalTo: connectedPlayersView.topAnchor, constant: 16),
            connectedPlayersLabel.leadingAnchor.constraint(equalTo: connectedPlayersView.leadingAnchor, constant: 16),
            connectedPlayersLabel.trailingAnchor.constraint(equalTo: connectedPlayersView.trailingAnchor, constant: -16),
            connectedPlayersLabel.bottomAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: -16),
            
            // Start game button
            startGameButton.topAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: 20),
            startGameButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            startGameButton.widthAnchor.constraint(equalToConstant: 240),
            startGameButton.heightAnchor.constraint(equalToConstant: 56),
            
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
}
