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
    private var scrollView: NSScrollView!
    private(set) var connectedPlayersView: NSView!
    private(set) var connectedPlayersLabel: NSTextField!
    private(set) var statusLabel: NSTextField!
    private(set) var instructionsLabel: NSTextField!
    private(set) var emptyStateLabel: NSTextField!
    private(set) var activityIndicator: NSProgressIndicator!
    
    // Callbacks
    var onHostTapped: (() -> Void)?
    var onJoinTapped: (() -> Void)?
    var onCancelTapped: (() -> Void)?
    var onStartGameTapped: (() -> Void)?
    
    func setup(in parentView: NSView) {
        // Create lobby view
        lobbyView = NSView(frame: parentView.bounds)
        lobbyView.autoresizingMask = [.width, .height]
        lobbyView.wantsLayer = true
        lobbyView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
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
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(statusLabel)
        
        // Instructions label
        instructionsLabel = NSTextField(labelWithString: "Battle with 2-4 players on the same network!\nUse WASD or Arrow keys to move, SPACE to shoot.")
        instructionsLabel.font = .systemFont(ofSize: 14)
        instructionsLabel.alignment = .center
        instructionsLabel.textColor = .secondaryLabelColor
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.maximumNumberOfLines = 2
        lobbyView.addSubview(instructionsLabel)
        
        // Host button
        hostButton = createButton(title: "🎯 Host Game", color: .systemBlue)
        hostButton.target = self
        hostButton.action = #selector(hostButtonTapped)
        lobbyView.addSubview(hostButton)
        
        // Join button
        joinButton = createButton(title: "🔍 Join Game", color: .systemGreen)
        joinButton.target = self
        joinButton.action = #selector(joinButtonTapped)
        lobbyView.addSubview(joinButton)
        
        // Cancel button
        cancelButton = NSButton()
        cancelButton.title = "Cancel"
        cancelButton.bezelStyle = .rounded
        cancelButton.font = .systemFont(ofSize: 18, weight: .medium)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.target = self
        cancelButton.action = #selector(cancelButtonTapped)
        cancelButton.isHidden = true
        lobbyView.addSubview(cancelButton)
        
        // Start Game button
        startGameButton = createButton(title: "🚀 Start Game", color: .systemRed)
        startGameButton.target = self
        startGameButton.action = #selector(startGameButtonTapped)
        startGameButton.isHidden = true
        lobbyView.addSubview(startGameButton)
        
        // Connected players view
        connectedPlayersView = NSView()
        connectedPlayersView.wantsLayer = true
        connectedPlayersView.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        connectedPlayersView.layer?.cornerRadius = 12
        connectedPlayersView.translatesAutoresizingMaskIntoConstraints = false
        connectedPlayersView.isHidden = true
        lobbyView.addSubview(connectedPlayersView)
        
        // Connected players label
        connectedPlayersLabel = NSTextField(labelWithString: "Connected Players: 0")
        connectedPlayersLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        connectedPlayersLabel.translatesAutoresizingMaskIntoConstraints = false
        connectedPlayersView.addSubview(connectedPlayersLabel)
        
        // Activity indicator
        activityIndicator = NSProgressIndicator()
        activityIndicator.style = .spinning
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isHidden = true
        lobbyView.addSubview(activityIndicator)
        
        // Peer table view
        peerTableView = NSTableView()
        peerTableView.headerView = nil
        peerTableView.backgroundColor = .clear
        peerTableView.gridStyleMask = []
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("PeerColumn"))
        column.width = 300
        peerTableView.addTableColumn(column)
        
        scrollView = NSScrollView()
        scrollView.documentView = peerTableView
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .noBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isHidden = true
        lobbyView.addSubview(scrollView)
        
        // Empty state label
        emptyStateLabel = NSTextField(labelWithString: "No players found nearby.\nMake sure other devices are hosting or browsing.")
        emptyStateLabel.font = .systemFont(ofSize: 14)
        emptyStateLabel.alignment = .center
        emptyStateLabel.textColor = .secondaryLabelColor
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.maximumNumberOfLines = 2
        emptyStateLabel.isHidden = true
        lobbyView.addSubview(emptyStateLabel)
        
        // Layout constraints
        setupConstraints(titleLabel: titleLabel)
    }
    
    private func setupConstraints(titleLabel: NSTextField) {
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: lobbyView.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: lobbyView.widthAnchor, multiplier: 0.8),
            
            // Status
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            statusLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            statusLabel.widthAnchor.constraint(equalTo: lobbyView.widthAnchor, multiplier: 0.8),
            
            // Instructions
            instructionsLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 15),
            instructionsLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            instructionsLabel.widthAnchor.constraint(equalTo: lobbyView.widthAnchor, multiplier: 0.8),
            
            // Host button
            hostButton.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 40),
            hostButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            hostButton.widthAnchor.constraint(equalToConstant: 250),
            hostButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Join button
            joinButton.topAnchor.constraint(equalTo: hostButton.bottomAnchor, constant: 20),
            joinButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            joinButton.widthAnchor.constraint(equalToConstant: 250),
            joinButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Cancel button
            cancelButton.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 20),
            cancelButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 150),
            
            // Connected players view
            connectedPlayersView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 30),
            connectedPlayersView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            connectedPlayersView.widthAnchor.constraint(equalToConstant: 300),
            connectedPlayersView.heightAnchor.constraint(equalToConstant: 50),
            
            // Connected players label
            connectedPlayersLabel.centerYAnchor.constraint(equalTo: connectedPlayersView.centerYAnchor),
            connectedPlayersLabel.centerXAnchor.constraint(equalTo: connectedPlayersView.centerXAnchor),
            
            // Activity indicator
            activityIndicator.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            activityIndicator.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            
            // Scroll view (peer table)
            scrollView.topAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: 20),
            scrollView.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: 300),
            scrollView.heightAnchor.constraint(equalToConstant: 200),
            
            // Empty state
            emptyStateLabel.topAnchor.constraint(equalTo: connectedPlayersView.bottomAnchor, constant: 80),
            emptyStateLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            emptyStateLabel.widthAnchor.constraint(equalTo: lobbyView.widthAnchor, multiplier: 0.6),
            
            // Start game button
            startGameButton.bottomAnchor.constraint(equalTo: lobbyView.bottomAnchor, constant: -40),
            startGameButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            startGameButton.widthAnchor.constraint(equalToConstant: 250),
            startGameButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    private func createButton(title: String, color: NSColor) -> NSButton {
        let button = NSButton()
        button.title = title
        button.bezelStyle = .rounded
        button.font = .systemFont(ofSize: 18, weight: .semibold)
        button.contentTintColor = color
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    func showTableView(_ show: Bool) {
        scrollView.isHidden = !show
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
