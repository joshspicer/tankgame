//
//  LobbyUIButtonFactory.swift
//  tankgame iOS
//
//  Created by AI Assistant on 1/7/26.
//

import UIKit

/// Factory for creating styled buttons in the lobby interface
class LobbyUIButtonFactory {
    
    /// Create a styled primary action button with icon and text
    static func createButton(title: String, backgroundColor: UIColor, icon: String) -> UIButton {
        let button = UIButton(type: .system)
        
        // Create stack view for icon and text
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
    
    /// Create sprite mode toggle button
    static func createSpriteModeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.separator.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        updateSpriteModeButtonTitle(button)
        
        return button
    }
    
    /// Update the sprite mode button title to reflect current mode
    static func updateSpriteModeButtonTitle(_ button: UIButton) {
        let mode = GameSettings.shared.spriteMode
        let title = "\(mode.icon) \(mode.displayName) Mode"
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    }
}
