//
//  SettingsViewController.swift
//  tankgame iOS
//
//  Created by copilot on 11/10/25.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let soundLabel = UILabel()
    private let soundSwitch = UISwitch()
    private let musicLabel = UILabel()
    private let musicSwitch = UISwitch()
    private let sensitivityLabel = UILabel()
    private let sensitivitySlider = UISlider()
    private let sensitivityValueLabel = UILabel()
    private let playerNameLabel = UILabel()
    private let playerNameTextField = UITextField()
    private let doneButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSettings()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Title
        titleLabel.text = "Settings"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Sound effects
        soundLabel.text = "Sound Effects"
        soundLabel.font = .systemFont(ofSize: 18)
        soundLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(soundLabel)
        
        soundSwitch.translatesAutoresizingMaskIntoConstraints = false
        soundSwitch.addTarget(self, action: #selector(soundSwitchChanged), for: .valueChanged)
        contentView.addSubview(soundSwitch)
        
        // Music
        musicLabel.text = "Music"
        musicLabel.font = .systemFont(ofSize: 18)
        musicLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(musicLabel)
        
        musicSwitch.translatesAutoresizingMaskIntoConstraints = false
        musicSwitch.addTarget(self, action: #selector(musicSwitchChanged), for: .valueChanged)
        contentView.addSubview(musicSwitch)
        
        // Joystick sensitivity
        sensitivityLabel.text = "Joystick Sensitivity"
        sensitivityLabel.font = .systemFont(ofSize: 18)
        sensitivityLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sensitivityLabel)
        
        sensitivitySlider.minimumValue = 0.5
        sensitivitySlider.maximumValue = 2.0
        sensitivitySlider.translatesAutoresizingMaskIntoConstraints = false
        sensitivitySlider.addTarget(self, action: #selector(sensitivitySliderChanged), for: .valueChanged)
        contentView.addSubview(sensitivitySlider)
        
        sensitivityValueLabel.font = .systemFont(ofSize: 16)
        sensitivityValueLabel.textAlignment = .right
        sensitivityValueLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sensitivityValueLabel)
        
        // Player name
        playerNameLabel.text = "Player Name"
        playerNameLabel.font = .systemFont(ofSize: 18)
        playerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(playerNameLabel)
        
        playerNameTextField.borderStyle = .roundedRect
        playerNameTextField.placeholder = "Enter your name"
        playerNameTextField.autocapitalizationType = .words
        playerNameTextField.returnKeyType = .done
        playerNameTextField.delegate = self
        playerNameTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(playerNameTextField)
        
        // Done button
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        doneButton.backgroundColor = .systemBlue
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 12
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        contentView.addSubview(doneButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            soundLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            soundLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            soundSwitch.centerYAnchor.constraint(equalTo: soundLabel.centerYAnchor),
            soundSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            musicLabel.topAnchor.constraint(equalTo: soundLabel.bottomAnchor, constant: 30),
            musicLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            musicSwitch.centerYAnchor.constraint(equalTo: musicLabel.centerYAnchor),
            musicSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            sensitivityLabel.topAnchor.constraint(equalTo: musicLabel.bottomAnchor, constant: 30),
            sensitivityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            sensitivityValueLabel.centerYAnchor.constraint(equalTo: sensitivityLabel.centerYAnchor),
            sensitivityValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            sensitivityValueLabel.widthAnchor.constraint(equalToConstant: 60),
            
            sensitivitySlider.topAnchor.constraint(equalTo: sensitivityLabel.bottomAnchor, constant: 10),
            sensitivitySlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sensitivitySlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            playerNameLabel.topAnchor.constraint(equalTo: sensitivitySlider.bottomAnchor, constant: 30),
            playerNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            playerNameTextField.topAnchor.constraint(equalTo: playerNameLabel.bottomAnchor, constant: 10),
            playerNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            playerNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            playerNameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            doneButton.topAnchor.constraint(equalTo: playerNameTextField.bottomAnchor, constant: 40),
            doneButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: 200),
            doneButton.heightAnchor.constraint(equalToConstant: 50),
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func loadSettings() {
        let settings = Settings.shared
        soundSwitch.isOn = settings.soundEnabled
        musicSwitch.isOn = settings.musicEnabled
        sensitivitySlider.value = settings.joystickSensitivity
        sensitivityValueLabel.text = String(format: "%.1fx", settings.joystickSensitivity)
        playerNameTextField.text = settings.playerName
    }
    
    @objc private func soundSwitchChanged() {
        Settings.shared.soundEnabled = soundSwitch.isOn
    }
    
    @objc private func musicSwitchChanged() {
        Settings.shared.musicEnabled = musicSwitch.isOn
    }
    
    @objc private func sensitivitySliderChanged() {
        let value = sensitivitySlider.value
        Settings.shared.joystickSensitivity = value
        sensitivityValueLabel.text = String(format: "%.1fx", value)
    }
    
    @objc private func doneTapped() {
        // Save player name
        if let name = playerNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            Settings.shared.playerName = name
        }
        
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
