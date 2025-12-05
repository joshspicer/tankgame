//
//  LobbyUITheme.swift
//  tankgame iOS
//
//  Premium visual theme constants and utilities for the lobby UI
//

import UIKit
import QuartzCore

/// Premium visual theme for the lobby UI
struct LobbyUITheme {
    // MARK: - Colors
    
    /// Primary gradient colors for background
    static let primaryGradientColors: [CGColor] = [
        UIColor(red: 0.05, green: 0.08, blue: 0.18, alpha: 1.0).cgColor,  // Deep navy
        UIColor(red: 0.08, green: 0.12, blue: 0.25, alpha: 1.0).cgColor,  // Dark blue
        UIColor(red: 0.04, green: 0.06, blue: 0.15, alpha: 1.0).cgColor   // Darker navy
    ]
    
    /// Accent colors
    static let accentOrange = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
    static let accentBlue = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
    static let accentGreen = UIColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1.0)
    static let accentPurple = UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0)
    static let accentRed = UIColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 1.0)
    
    /// Glass effect colors
    static let glassBackgroundColor = UIColor.white.withAlphaComponent(0.08)
    static let glassBorderColor = UIColor.white.withAlphaComponent(0.2)
    static let glassHighlightColor = UIColor.white.withAlphaComponent(0.15)
    
    /// Text colors
    static let titleColor = UIColor.white
    static let subtitleColor = UIColor.white.withAlphaComponent(0.7)
    static let bodyTextColor = UIColor.white.withAlphaComponent(0.6)
    
    // MARK: - Typography
    
    /// Title font (game name)
    static let titleFont = UIFont.systemFont(ofSize: 52, weight: .black)
    
    /// Subtitle font
    static let subtitleFont = UIFont.systemFont(ofSize: 17, weight: .medium)
    
    /// Button text font
    static let buttonFont = UIFont.systemFont(ofSize: 18, weight: .bold)
    
    /// Body text font
    static let bodyFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    
    /// Small text font
    static let smallFont = UIFont.systemFont(ofSize: 13, weight: .medium)
    
    // MARK: - Spacing and Sizes
    
    static let buttonHeight: CGFloat = 60
    static let buttonWidth: CGFloat = 280
    static let buttonCornerRadius: CGFloat = 16
    static let buttonSpacing: CGFloat = 16
    
    static let cardCornerRadius: CGFloat = 20
    static let cardBorderWidth: CGFloat = 1
    
    static let iconSize: CGFloat = 28
}

/// Helper class for creating premium UI effects
class LobbyUIEffects {
    
    /// Create an animated gradient layer for backgrounds
    static func createAnimatedGradient(frame: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = LobbyUITheme.primaryGradientColors
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
        return gradient
    }
    
    /// Create a floating particle effect layer
    static func createParticleEffect(in view: UIView) -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 1)
        emitter.frame = view.bounds
        
        let cell = CAEmitterCell()
        cell.birthRate = 3
        cell.lifetime = 15.0
        cell.lifetimeRange = 5.0
        cell.velocity = 30
        cell.velocityRange = 20
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 4
        cell.spin = 0.5
        cell.spinRange = 0.5
        cell.scale = 0.04
        cell.scaleRange = 0.02
        cell.alphaSpeed = -0.03
        
        // Create a star-like particle
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.white.withAlphaComponent(0.6).cgColor)
            context.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        cell.contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        UIGraphicsEndImageContext()
        
        emitter.emitterCells = [cell]
        return emitter
    }
    
    /// Create a glass-morphism view
    static func createGlassView(frame: CGRect) -> UIView {
        let glassView = UIView(frame: frame)
        glassView.backgroundColor = LobbyUITheme.glassBackgroundColor
        glassView.layer.cornerRadius = LobbyUITheme.cardCornerRadius
        glassView.layer.borderWidth = LobbyUITheme.cardBorderWidth
        glassView.layer.borderColor = LobbyUITheme.glassBorderColor.cgColor
        
        // Add blur effect
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = glassView.bounds
        blurView.layer.cornerRadius = LobbyUITheme.cardCornerRadius
        blurView.clipsToBounds = true
        blurView.alpha = 0.5
        glassView.insertSubview(blurView, at: 0)
        
        // Add inner highlight
        let highlightLayer = CAGradientLayer()
        highlightLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height * 0.5)
        highlightLayer.colors = [
            LobbyUITheme.glassHighlightColor.cgColor,
            UIColor.clear.cgColor
        ]
        highlightLayer.cornerRadius = LobbyUITheme.cardCornerRadius
        highlightLayer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        glassView.layer.addSublayer(highlightLayer)
        
        return glassView
    }
    
    /// Create a premium button with gradient and glow
    static func createPremiumButton(title: String, icon: String, gradientColors: [UIColor]) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Add gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = LobbyUITheme.buttonCornerRadius
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        // Add glow effect
        button.layer.shadowColor = gradientColors.first?.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 12
        
        // Configure button appearance
        button.layer.cornerRadius = LobbyUITheme.buttonCornerRadius
        button.clipsToBounds = false
        
        // Create content stack
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: LobbyUITheme.iconSize)
        
        let textLabel = UILabel()
        textLabel.text = title
        textLabel.font = LobbyUITheme.buttonFont
        textLabel.textColor = .white
        
        stackView.addArrangedSubview(iconLabel)
        stackView.addArrangedSubview(textLabel)
        
        button.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        return button
    }
    
    /// Add press animation to button
    static func addPressAnimation(to button: UIButton) {
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private static func buttonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            sender.alpha = 0.9
        }
    }
    
    @objc private static func buttonReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }
    
    /// Update gradient layer frame (call on layout changes)
    static func updateGradientFrame(in button: UIButton, size: CGSize) {
        if let gradientLayer = button.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = CGRect(origin: .zero, size: size)
        }
    }
}

/// Extension to add shimmer animation to views
extension UIView {
    func addShimmerAnimation() {
        let shimmerLayer = CAGradientLayer()
        shimmerLayer.frame = bounds
        shimmerLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.1).cgColor,
            UIColor.clear.cgColor
        ]
        shimmerLayer.locations = [0.0, 0.5, 1.0]
        shimmerLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: 1, y: 0.5)
        shimmerLayer.name = "shimmer"
        layer.addSublayer(shimmerLayer)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 2.0
        animation.repeatCount = .infinity
        shimmerLayer.add(animation, forKey: "shimmer")
    }
    
    func removeShimmerAnimation() {
        layer.sublayers?.removeAll { $0.name == "shimmer" }
    }
}
