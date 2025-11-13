//
//  BluetoothDebugViewController.swift
//  tankgame iOS
//
//  Created by Copilot Agent
//

import UIKit
import MultipeerConnectivity

class BluetoothDebugViewController: UIViewController {
    
    private var multiplayerManager: MultiplayerManager
    private var updateTimer: Timer?
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    private let titleLabel = UILabel()
    private let peerIDLabel = UILabel()
    private let deviceInfoLabel = UILabel()
    private let sessionStateLabel = UILabel()
    private let sessionDetailsLabel = UILabel()
    private let connectedPeersLabel = UILabel()
    private let discoveredPeersLabel = UILabel()
    private let browsingStatusLabel = UILabel()
    private let advertisingStatusLabel = UILabel()
    private let timestampLabel = UILabel()
    
    private let refreshButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)
    
    init(multiplayerManager: MultiplayerManager) {
        self.multiplayerManager = multiplayerManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateDebugInfo()
        
        // Auto-refresh every 2 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateDebugInfo()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Setup content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Setup stack view
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        // Title
        titleLabel.text = "🔧 Bluetooth Debug Info"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        
        // Peer ID
        peerIDLabel.text = "Peer ID: Loading..."
        peerIDLabel.font = .systemFont(ofSize: 14, weight: .medium)
        peerIDLabel.numberOfLines = 0
        
        // Device Info
        deviceInfoLabel.text = "Device Info: Loading..."
        deviceInfoLabel.font = .systemFont(ofSize: 14, weight: .medium)
        deviceInfoLabel.numberOfLines = 0
        
        // Session State
        sessionStateLabel.text = "Session State: Unknown"
        sessionStateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        sessionStateLabel.numberOfLines = 0
        
        // Session Details
        sessionDetailsLabel.text = "Session Details: Loading..."
        sessionDetailsLabel.font = .systemFont(ofSize: 14, weight: .medium)
        sessionDetailsLabel.numberOfLines = 0
        
        // Connected Peers
        connectedPeersLabel.text = "Connected Peers: None"
        connectedPeersLabel.font = .systemFont(ofSize: 14, weight: .medium)
        connectedPeersLabel.numberOfLines = 0
        
        // Discovered Peers
        discoveredPeersLabel.text = "Discovered Peers: None"
        discoveredPeersLabel.font = .systemFont(ofSize: 14, weight: .medium)
        discoveredPeersLabel.numberOfLines = 0
        
        // Browsing Status
        browsingStatusLabel.text = "Browsing: Unknown"
        browsingStatusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        browsingStatusLabel.numberOfLines = 0
        
        // Advertising Status
        advertisingStatusLabel.text = "Advertising: Unknown"
        advertisingStatusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        advertisingStatusLabel.numberOfLines = 0
        
        // Timestamp
        timestampLabel.text = "Last Updated: Never"
        timestampLabel.font = .systemFont(ofSize: 12, weight: .regular)
        timestampLabel.textColor = .secondaryLabel
        timestampLabel.textAlignment = .center
        timestampLabel.numberOfLines = 0
        
        // Refresh button
        refreshButton.setTitle("🔄 Refresh Now", for: .normal)
        refreshButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        refreshButton.backgroundColor = .systemBlue
        refreshButton.setTitleColor(.white, for: .normal)
        refreshButton.layer.cornerRadius = 12
        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Close button
        closeButton.setTitle("✕ Close", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        closeButton.setTitleColor(.systemRed, for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to stack view with cards
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(createSeparator())
        stackView.addArrangedSubview(createCard(with: peerIDLabel))
        stackView.addArrangedSubview(createCard(with: deviceInfoLabel))
        stackView.addArrangedSubview(createCard(with: sessionStateLabel))
        stackView.addArrangedSubview(createCard(with: sessionDetailsLabel))
        stackView.addArrangedSubview(createCard(with: connectedPeersLabel))
        stackView.addArrangedSubview(createCard(with: discoveredPeersLabel))
        stackView.addArrangedSubview(createCard(with: browsingStatusLabel))
        stackView.addArrangedSubview(createCard(with: advertisingStatusLabel))
        stackView.addArrangedSubview(timestampLabel)
        stackView.addArrangedSubview(refreshButton)
        stackView.addArrangedSubview(closeButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            refreshButton.heightAnchor.constraint(equalToConstant: 50),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createCard(with label: UILabel) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.separator.cgColor
        
        label.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
        
        return card
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    @objc private func refreshTapped() {
        updateDebugInfo()
        
        // Visual feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    private func updateDebugInfo() {
        let session = multiplayerManager.session
        
        // Peer ID with more details
        let myPeerID = session?.myPeerID
        let peerIDHash = myPeerID?.hash ?? 0
        peerIDLabel.text = """
        📱 My Peer Info
        Display Name: \(myPeerID?.displayName ?? "Unknown")
        Peer ID Hash: \(peerIDHash)
        """
        
        // Device Info
        let device = UIDevice.current
        deviceInfoLabel.text = """
        📱 Device Details
        Model: \(device.model)
        System: \(device.systemName) \(device.systemVersion)
        Name: \(device.name)
        Identifier: \(device.identifierForVendor?.uuidString ?? "Unknown")
        """
        
        // Session State with more details
        let connectedCount = session?.connectedPeers.count ?? 0
        let stateEmoji = connectedCount > 0 ? "✅" : "⚪️"
        sessionStateLabel.text = """
        \(stateEmoji) Connection Status
        Connected Peers: \(connectedCount)
        Is Connected: \(multiplayerManager.isConnected ? "Yes" : "No")
        """
        
        // Session Details (encryption, configuration)
        let encryptionPreference: String
        if let session = session {
            switch session.encryptionPreference {
            case .none:
                encryptionPreference = "None"
            case .optional:
                encryptionPreference = "Optional"
            case .required:
                encryptionPreference = "Required ✅"
            @unknown default:
                encryptionPreference = "Unknown"
            }
        } else {
            encryptionPreference = "No Session"
        }
        
        sessionDetailsLabel.text = """
        🔐 Session Configuration
        Encryption: \(encryptionPreference)
        Service Type: \(MultiplayerManager.serviceType)
        Protocol: MultipeerConnectivity
        Transport: Bluetooth + WiFi
        """
        
        // Connected Peers with detailed state
        let connectedPeers = session?.connectedPeers ?? []
        if connectedPeers.isEmpty {
            connectedPeersLabel.text = """
            👥 Connected Peers
            None
            """
        } else {
            var peerDetails = [String]()
            for peer in connectedPeers {
                let peerHash = peer.hash
                peerDetails.append("  • \(peer.displayName)\n    Hash: \(peerHash)")
            }
            connectedPeersLabel.text = """
            👥 Connected Peers (\(connectedPeers.count))
            \(peerDetails.joined(separator: "\n"))
            """
        }
        
        // Discovery info
        discoveredPeersLabel.text = """
        🔍 Discovery Info
        Note: Discovered peers are shown in the
        Join Game screen. They are not accessible
        via the MCNearbyServiceBrowser delegate
        after invitation is sent.
        """
        
        // Browsing status with more details
        let browsingEmoji = multiplayerManager.isBrowsing ? "🟢" : "⚪️"
        browsingStatusLabel.text = """
        \(browsingEmoji) Browsing Status
        Currently Browsing: \(multiplayerManager.isBrowsing ? "Yes" : "No")
        \(multiplayerManager.isBrowsing ? "Actively searching for nearby games..." : "Not actively searching")
        \(multiplayerManager.isBrowsing ? "Using service type: \(MultiplayerManager.serviceType)" : "")
        """
        
        // Advertising status with more details
        let advertisingEmoji = multiplayerManager.isAdvertising ? "🟢" : "⚪️"
        advertisingStatusLabel.text = """
        \(advertisingEmoji) Advertising Status
        Currently Advertising: \(multiplayerManager.isAdvertising ? "Yes" : "No")
        \(multiplayerManager.isAdvertising ? "Game is visible to nearby devices" : "Not hosting a game")
        Service Type: \(MultiplayerManager.serviceType)
        \(multiplayerManager.isAdvertising ? "Accepting connections automatically" : "")
        """
        
        // Timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        timestampLabel.text = "Last Updated: \(timestamp)"
    }
}
