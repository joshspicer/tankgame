//
//  LobbyUI.swift
//  tankgame macOS
//
//  Created by jospicer on 10/28/25.
//

import Cocoa
import MultipeerConnectivity

/// Manages the lobby user interface for macOS
class LobbyUI {
    // UI Elements
    private(set) var lobbyView: NSView!
    private(set) var hostButton: NSButton!
    private(set) var joinButton: NSButton!
    private(set) var cancelButton: NSButton!
    private(set) var startGameButton: NSButton!
    private(set) var peerTableView: NSTableView!
    private(set) var connectedPlayersView: NSBox!
    private(set) var connectedPlayersLabel: NSTextField!
    private(set) var statusLabel: NSTextField!
    private(set) var instructionsLabel: NSTextField!
    private(set) var emptyStateLabel: NSTextField!
    private(set) var activityIndicator: NSProgressIndicator!
    private var scrollView: NSScrollView!
    
    // Callbacks
    var onHostTapped: (() -> Void)?
    var onJoinTapped: (() -> Void)?
    var onCancelTapped: (() -> Void)?
    var onStartGameTapped: (() -> Void)?
    
    func setup(in parentView: NSView) {
        // Create lobby view
        lobbyView = NSView(frame: parentView.bounds)
        lobbyView.autoresizingMask = [.width, .height]
        parentView.addSubview(lobbyView)
        
        // Title label
        let titleLabel = NSTextField(labelWithString: "🎮 Tank Game")
        titleLabel.font = .systemFont(ofSize: 36, weight: .bold)
        titleLabel.alignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(titleLabel)
        
        // Status label
        statusLabel = NSTextField(labelWithString: "Choose an option to start")
        statusLabel.font = .systemFont(ofSize: 18, weight: .medium)
        statusLabel.alignment = .center
        statusLabel.textColor = .secondaryLabelColor
        statusLabel.maximumNumberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(statusLabel)
        
        // Instructions label
        instructionsLabel = NSTextField(labelWithString: "Battle with 2-4 players on the same network!\nUse WASD or arrow keys to move, SPACE to shoot.")
        instructionsLabel.font = .systemFont(ofSize: 14)
        instructionsLabel.alignment = .center
        instructionsLabel.textColor = .secondaryLabelColor
        instructionsLabel.maximumNumberOfLines = 0
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(instructionsLabel)
        
        // Host button
        hostButton = createButton(title: "🎯 Host Game", backgroundColor: .systemBlue)
        hostButton.target = self
        hostButton.action = #selector(hostButtonClicked)
        lobbyView.addSubview(hostButton)
        
        // Join button
        joinButton = createButton(title: "🔍 Join Game", backgroundColor: .systemGreen)
        joinButton.target = self
        joinButton.action = #selector(joinButtonClicked)
        lobbyView.addSubview(joinButton)
        
        // Cancel button
        cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancelButtonClicked))
        cancelButton.isHidden = true
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(cancelButton)
        
        // Start Game button (for host)
        startGameButton = createButton(title: "🚀 Start Game", backgroundColor: .systemGreen)
        startGameButton.isHidden = true
        startGameButton.target = self
        startGameButton.action = #selector(startGameButtonClicked)
        lobbyView.addSubview(startGameButton)
        
        // Connected players view
        connectedPlayersView = NSBox()
        connectedPlayersView.boxType = .custom
        connectedPlayersView.borderType = .lineBorder
        connectedPlayersView.cornerRadius = 12
        connectedPlayersView.fillColor = NSColor.controlBackgroundColor
        connectedPlayersView.isHidden = true
        connectedPlayersView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(connectedPlayersView)
        
        connectedPlayersLabel = NSTextField(labelWithString: "Connected: 1/4")
        connectedPlayersLabel.font = .systemFont(ofSize: 16, weight: .medium)
        connectedPlayersLabel.alignment = .center
        connectedPlayersLabel.maximumNumberOfLines = 0
        connectedPlayersLabel.translatesAutoresizingMaskIntoConstraints = false
        connectedPlayersView.addSubview(connectedPlayersLabel)
        
        // Activity indicator
        activityIndicator = NSProgressIndicator()
        activityIndicator.style = .spinning
        activityIndicator.controlSize = .large
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(activityIndicator)
        
        // Peer table view
        scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .lineBorder
        scrollView.isHidden = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        peerTableView = NSTableView()
        peerTableView.headerView = nil
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("PeerColumn"))
        column.width = 280
        peerTableView.addTableColumn(column)
        
        scrollView.documentView = peerTableView
        lobbyView.addSubview(scrollView)
        
        // Empty state label
        emptyStateLabel = NSTextField(labelWithString: "No nearby games found.\nMake sure the other device is hosting.")
        emptyStateLabel.font = .systemFont(ofSize: 14)
        emptyStateLabel.alignment = .center
        emptyStateLabel.textColor = .secondaryLabelColor
        emptyStateLabel.maximumNumberOfLines = 0
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(emptyStateLabel)
        
        setupConstraints(titleLabel: titleLabel)
    }
    
    private func createButton(title: String, backgroundColor: NSColor) -> NSButton {
        let button = NSButton(title: title, target: nil, action: nil)
        button.bezelStyle = .rounded
        button.controlSize = .large
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func setupConstraints(titleLabel: NSTextField) {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: lobbyView.topAnchor, constant: 80),
            titleLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            statusLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            instructionsLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
            instructionsLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            instructionsLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            
            hostButton.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 50),
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
            
            scrollView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            scrollView.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            scrollView.heightAnchor.constraint(equalToConstant: 200),
            
            emptyStateLabel.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 40),
            emptyStateLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            emptyStateLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30)
        ])
    }
    
    @objc private func hostButtonClicked() {
        onHostTapped?()
    }
    
    @objc private func joinButtonClicked() {
        onJoinTapped?()
    }
    
    @objc private func cancelButtonClicked() {
        onCancelTapped?()
    }
    
    @objc private func startGameButtonClicked() {
        onStartGameTapped?()
    }
    
    /// Reset lobby to initial state
    func reset() {
        hostButton.isHidden = false
        joinButton.isHidden = false
        instructionsLabel.isHidden = false
        cancelButton.isHidden = true
        startGameButton.isHidden = true
        connectedPlayersView.isHidden = true
        scrollView.isHidden = true
        emptyStateLabel.isHidden = true
        activityIndicator.stopAnimation(nil)
        statusLabel.stringValue = "Choose an option to start"
    }
}
