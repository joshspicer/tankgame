//
//  ModernButtonFactory.swift
//  tankgame iOS
//
//  Factory for creating modern, visually appealing buttons
//

import UIKit

/// Factory for creating modern, visually appealing buttons
class ModernButtonFactory {
    
    /// Button style presets
    enum ButtonStyle {
        case primary     // Main action button (e.g., Start Game)
        case secondary   // Secondary action (e.g., Host Game)
        case tertiary    // Less prominent action (e.g., Cancel)
        case accent      // Accent color action (e.g., Single Player)
    }
    
    /// Create a modern styled button
    static func createButton(
        title: String,
        icon: String,
        style: ButtonStyle,
        width: CGFloat = 260,
        height: CGFloat = 60
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure button based on style
        let config = configuration(for: style)
        
        // Create gradient layer for background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        gradientLayer.colors = config.gradientColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 16
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        // Create content stack view
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 14
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon label
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 28)
        iconLabel.isUserInteractionEnabled = false
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.isUserInteractionEnabled = false
        
        stackView.addArrangedSubview(iconLabel)
        stackView.addArrangedSubview(titleLabel)
        button.addSubview(stackView)
        
        // Configure button appearance
        button.layer.cornerRadius = 16
        button.layer.shadowColor = config.shadowColor.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 12
        
        // Add inner highlight
        let highlightLayer = CALayer()
        highlightLayer.frame = CGRect(x: 2, y: 2, width: width - 4, height: height / 2 - 2)
        highlightLayer.backgroundColor = UIColor.white.withAlphaComponent(0.15).cgColor
        highlightLayer.cornerRadius = 14
        highlightLayer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        button.layer.addSublayer(highlightLayer)
        
        // Add border for depth
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        
        // Setup constraints
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: width),
            button.heightAnchor.constraint(equalToConstant: height),
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        // Add touch highlight
        addTouchHandling(to: button, gradientLayer: gradientLayer)
        
        return button
    }
    
    /// Create a compact toggle button
    static func createToggleButton(title: String, width: CGFloat = 200, height: CGFloat = 48) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Style
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        // Title
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        
        // Size
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: width),
            button.heightAnchor.constraint(equalToConstant: height)
        ])
        
        return button
    }
    
    /// Create a text-only button (like Cancel)
    static func createTextButton(title: String, color: UIColor = .systemRed) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(color, for: .normal)
        return button
    }
    
    // MARK: - Private Helpers
    
    private struct ButtonConfig {
        let gradientColors: [CGColor]
        let shadowColor: UIColor
    }
    
    private static func configuration(for style: ButtonStyle) -> ButtonConfig {
        switch style {
        case .primary:
            return ButtonConfig(
                gradientColors: [
                    UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0).cgColor,
                    UIColor(red: 0.1, green: 0.65, blue: 0.35, alpha: 1.0).cgColor
                ],
                shadowColor: UIColor(red: 0.1, green: 0.65, blue: 0.35, alpha: 1.0)
            )
        case .secondary:
            return ButtonConfig(
                gradientColors: [
                    UIColor(red: 0.25, green: 0.5, blue: 0.95, alpha: 1.0).cgColor,
                    UIColor(red: 0.2, green: 0.4, blue: 0.85, alpha: 1.0).cgColor
                ],
                shadowColor: UIColor(red: 0.2, green: 0.4, blue: 0.85, alpha: 1.0)
            )
        case .tertiary:
            return ButtonConfig(
                gradientColors: [
                    UIColor(red: 0.3, green: 0.35, blue: 0.45, alpha: 1.0).cgColor,
                    UIColor(red: 0.25, green: 0.3, blue: 0.4, alpha: 1.0).cgColor
                ],
                shadowColor: UIColor(red: 0.2, green: 0.25, blue: 0.35, alpha: 1.0)
            )
        case .accent:
            return ButtonConfig(
                gradientColors: [
                    UIColor(red: 1.0, green: 0.55, blue: 0.2, alpha: 1.0).cgColor,
                    UIColor(red: 0.9, green: 0.4, blue: 0.15, alpha: 1.0).cgColor
                ],
                shadowColor: UIColor(red: 0.9, green: 0.4, blue: 0.15, alpha: 1.0)
            )
        }
    }
    
    private static func addTouchHandling(to button: UIButton, gradientLayer: CAGradientLayer) {
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private static func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            sender.alpha = 0.9
        }
    }
    
    @objc private static func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5
        ) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }
}
