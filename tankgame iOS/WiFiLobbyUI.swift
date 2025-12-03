//
//  WiFiLobbyUI.swift
//  tankgame iOS
//
//  UI components for WiFi multiplayer mode in the lobby
//

import UIKit

/// Manages WiFi-specific lobby UI elements
class WiFiLobbyUI {
    
    // MARK: - UI Elements
    
    private(set) var modeSegmentControl: UISegmentedControl!
    private(set) var roomCodeLabel: UILabel!
    private(set) var roomCodeField: UITextField!
    private(set) var joinByCodeButton: UIButton!
    private(set) var wifiHostsTableView: UITableView!
    private(set) var wifiEmptyStateLabel: UILabel!
    
    // MARK: - Callbacks
    
    var onModeChanged: ((ConnectionMode) -> Void)?
    var onJoinByCode: ((String) -> Void)?
    
    // MARK: - Types
    
    enum ConnectionMode: Int {
        case bluetooth = 0
        case wifi = 1
    }
    
    // MARK: - Setup
    
    func setup(in parentView: UIView, below statusLabel: UILabel, lobbyView: UIView) {
        // Mode segment control
        modeSegmentControl = UISegmentedControl(items: ["Bluetooth", "WiFi"])
        modeSegmentControl.selectedSegmentIndex = 0
        modeSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        modeSegmentControl.addTarget(self, action: #selector(modeChanged(_:)), for: .valueChanged)
        lobbyView.addSubview(modeSegmentControl)
        
        // Room code display label (for hosts)
        roomCodeLabel = UILabel()
        roomCodeLabel.text = "Room Code: ------"
        roomCodeLabel.font = .monospacedSystemFont(ofSize: 32, weight: .bold)
        roomCodeLabel.textAlignment = .center
        roomCodeLabel.textColor = .systemBlue
        roomCodeLabel.isHidden = true
        roomCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(roomCodeLabel)
        
        // Room code input field (for joiners)
        roomCodeField = UITextField()
        roomCodeField.placeholder = "Enter room code"
        roomCodeField.font = .monospacedSystemFont(ofSize: 24, weight: .medium)
        roomCodeField.textAlignment = .center
        roomCodeField.autocapitalizationType = .allCharacters
        roomCodeField.autocorrectionType = .no
        roomCodeField.borderStyle = .roundedRect
        roomCodeField.backgroundColor = .secondarySystemBackground
        roomCodeField.isHidden = true
        roomCodeField.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(roomCodeField)
        
        // Join by code button
        joinByCodeButton = createButton(title: "Join by Code", backgroundColor: .systemOrange, icon: "🔗")
        joinByCodeButton.isHidden = true
        joinByCodeButton.addTarget(self, action: #selector(joinByCodeTapped), for: .touchUpInside)
        lobbyView.addSubview(joinByCodeButton)
        
        // WiFi hosts table view
        wifiHostsTableView = UITableView()
        wifiHostsTableView.isHidden = true
        wifiHostsTableView.layer.cornerRadius = 12
        wifiHostsTableView.layer.borderWidth = 1
        wifiHostsTableView.layer.borderColor = UIColor.separator.cgColor
        wifiHostsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "WiFiHostCell")
        wifiHostsTableView.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(wifiHostsTableView)
        
        // WiFi empty state label
        wifiEmptyStateLabel = UILabel()
        wifiEmptyStateLabel.text = "No WiFi games found.\nAsk the host for their room code."
        wifiEmptyStateLabel.font = .systemFont(ofSize: 14)
        wifiEmptyStateLabel.textAlignment = .center
        wifiEmptyStateLabel.numberOfLines = 0
        wifiEmptyStateLabel.textColor = .secondaryLabel
        wifiEmptyStateLabel.isHidden = true
        wifiEmptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        lobbyView.addSubview(wifiEmptyStateLabel)
        
        setupConstraints(statusLabel: statusLabel, lobbyView: lobbyView)
    }
    
    private func createButton(title: String, backgroundColor: UIColor, icon: String) -> UIButton {
        let button = UIButton(type: .system)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 24)
        
        let textLabel = UILabel()
        textLabel.text = title
        textLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        textLabel.textColor = .white
        
        stackView.addArrangedSubview(iconLabel)
        stackView.addArrangedSubview(textLabel)
        
        button.addSubview(stackView)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 14
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        return button
    }
    
    private func setupConstraints(statusLabel: UILabel, lobbyView: UIView) {
        NSLayoutConstraint.activate([
            // Mode segment control - positioned above the host/join buttons
            modeSegmentControl.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            modeSegmentControl.bottomAnchor.constraint(equalTo: statusLabel.topAnchor, constant: -20),
            modeSegmentControl.widthAnchor.constraint(equalToConstant: 200),
            
            // Room code label (shown when hosting in WiFi mode)
            roomCodeLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            roomCodeLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            
            // Room code field (shown when joining in WiFi mode)
            roomCodeField.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            roomCodeField.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 30),
            roomCodeField.widthAnchor.constraint(equalToConstant: 200),
            roomCodeField.heightAnchor.constraint(equalToConstant: 50),
            
            // Join by code button
            joinByCodeButton.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            joinByCodeButton.topAnchor.constraint(equalTo: roomCodeField.bottomAnchor, constant: 16),
            joinByCodeButton.widthAnchor.constraint(equalToConstant: 200),
            joinByCodeButton.heightAnchor.constraint(equalToConstant: 50),
            
            // WiFi hosts table view
            wifiHostsTableView.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            wifiHostsTableView.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30),
            wifiHostsTableView.topAnchor.constraint(equalTo: joinByCodeButton.bottomAnchor, constant: 20),
            wifiHostsTableView.heightAnchor.constraint(equalToConstant: 150),
            
            // WiFi empty state label
            wifiEmptyStateLabel.centerXAnchor.constraint(equalTo: lobbyView.centerXAnchor),
            wifiEmptyStateLabel.topAnchor.constraint(equalTo: joinByCodeButton.bottomAnchor, constant: 40),
            wifiEmptyStateLabel.leadingAnchor.constraint(equalTo: lobbyView.leadingAnchor, constant: 30),
            wifiEmptyStateLabel.trailingAnchor.constraint(equalTo: lobbyView.trailingAnchor, constant: -30)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func modeChanged(_ sender: UISegmentedControl) {
        let mode = ConnectionMode(rawValue: sender.selectedSegmentIndex) ?? .bluetooth
        onModeChanged?(mode)
    }
    
    @objc private func joinByCodeTapped() {
        guard let code = roomCodeField.text, !code.isEmpty else { return }
        onJoinByCode?(RoomCodeGenerator.normalize(code))
    }
    
    // MARK: - Public Methods
    
    func showRoomCode(_ code: String) {
        roomCodeLabel.text = "Room Code: \(code)"
        roomCodeLabel.isHidden = false
    }
    
    func showJoinByCodeUI() {
        roomCodeField.isHidden = false
        joinByCodeButton.isHidden = false
    }
    
    func hideJoinByCodeUI() {
        roomCodeField.isHidden = true
        joinByCodeButton.isHidden = true
    }
    
    func showWiFiHostsList(hasHosts: Bool) {
        wifiHostsTableView.isHidden = !hasHosts
        wifiEmptyStateLabel.isHidden = hasHosts
    }
    
    func reset() {
        modeSegmentControl.selectedSegmentIndex = 0
        roomCodeLabel.isHidden = true
        roomCodeField.isHidden = true
        roomCodeField.text = ""
        joinByCodeButton.isHidden = true
        wifiHostsTableView.isHidden = true
        wifiEmptyStateLabel.isHidden = true
    }
    
    var currentMode: ConnectionMode {
        return ConnectionMode(rawValue: modeSegmentControl.selectedSegmentIndex) ?? .bluetooth
    }
}
