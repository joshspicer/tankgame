//
//  BotCountSelector.swift
//  tankgame iOS
//
//  Created by AI Assistant on 1/7/26.
//

import UIKit

/// Manages the bot count selection UI for single player mode
class BotCountSelector {
    
    // UI Elements
    private(set) var containerView: UIView!
    private(set) var label: UILabel!
    private(set) var stepper: UIStepper!
    
    /// Current bot count
    var botCount: Int = 1
    
    /// Callback when bot count changes
    var onBotCountChanged: ((Int) -> Void)?
    
    func setup() -> UIView {
        // Container view
        containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 12
        containerView.isHidden = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Label
        label = UILabel()
        label.text = "AI Bots: 1"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        
        // Stepper
        stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.maximumValue = 3
        stepper.value = 1
        stepper.addTarget(self, action: #selector(botCountChanged), for: .valueChanged)
        stepper.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stepper)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            stepper.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stepper.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        return containerView
    }
    
    @objc private func botCountChanged() {
        botCount = Int(stepper.value)
        label.text = "AI Bots: \(botCount)"
        onBotCountChanged?(botCount)
    }
}
