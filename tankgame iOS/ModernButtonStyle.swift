//
//  ModernButtonStyle.swift
//  tankgame iOS
//
//  Modern button styling with gradients, shadows, and animations
//

import UIKit

/// Provides modern button styling utilities for consistent UI
class ModernButtonStyle {
    
    // MARK: - Color Palette
    
    /// Primary button colors
    struct Colors {
        static let primaryGradientStart = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        static let primaryGradientEnd = UIColor(red: 0.1, green: 0.4, blue: 0.9, alpha: 1.0)
        
        static let secondaryGradientStart = UIColor(red: 0.3, green: 0.8, blue: 0.5, alpha: 1.0)
        static let secondaryGradientEnd = UIColor(red: 0.2, green: 0.6, blue: 0.4, alpha: 1.0)
        
        static let warningGradientStart = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
        static let warningGradientEnd = UIColor(red: 0.9, green: 0.4, blue: 0.1, alpha: 1.0)
        
        static let dangerGradientStart = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        static let dangerGradientEnd = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        
        static let shadowColor = UIColor.black.withAlphaComponent(0.25)
    }
    
    // MARK: - Gradient Button Creation
    
    /// Create a button with gradient background and modern styling
    static func createGradientButton(
        title: String,
        icon: String,
        gradientStart: UIColor,
        gradientEnd: UIColor,
        width: CGFloat = 260,
        height: CGFloat = 60
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Create gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [gradientStart.cgColor, gradientEnd.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.cornerRadius = 16
        gradientLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        gradientLayer.name = "gradientLayer"
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        // Create content stack
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon label
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 26)
        iconLabel.tag = 100
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.tag = 101
        
        stackView.addArrangedSubview(iconLabel)
        stackView.addArrangedSubview(titleLabel)
        button.addSubview(stackView)
        
        // Button styling
        button.layer.cornerRadius = 16
        button.layer.shadowColor = Colors.shadowColor.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 10
        button.clipsToBounds = false
        
        // Constraints
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: width),
            button.heightAnchor.constraint(equalToConstant: height),
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        // Add touch animations
        button.addTarget(nil, action: #selector(handleTouchDown(_:)), for: .touchDown)
        button.addTarget(nil, action: #selector(handleTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return button
    }
    
    // MARK: - Animation Handlers
    
    @objc static func handleTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.layer.shadowOpacity = 0.15
            sender.layer.shadowOffset = CGSize(width: 0, height: 3)
        }
    }
    
    @objc static func handleTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            sender.transform = .identity
            sender.layer.shadowOpacity = 0.3
            sender.layer.shadowOffset = CGSize(width: 0, height: 6)
        }
    }
    
    // MARK: - Preset Button Styles
    
    /// Create a primary action button (blue gradient)
    static func createPrimaryButton(title: String, icon: String) -> UIButton {
        return createGradientButton(
            title: title,
            icon: icon,
            gradientStart: Colors.primaryGradientStart,
            gradientEnd: Colors.primaryGradientEnd
        )
    }
    
    /// Create a secondary action button (green gradient)
    static func createSecondaryButton(title: String, icon: String) -> UIButton {
        return createGradientButton(
            title: title,
            icon: icon,
            gradientStart: Colors.secondaryGradientStart,
            gradientEnd: Colors.secondaryGradientEnd
        )
    }
    
    /// Create a warning button (orange gradient)
    static func createWarningButton(title: String, icon: String) -> UIButton {
        return createGradientButton(
            title: title,
            icon: icon,
            gradientStart: Colors.warningGradientStart,
            gradientEnd: Colors.warningGradientEnd
        )
    }
    
    // MARK: - Utility Functions
    
    /// Update gradient frame when button layout changes
    static func updateGradientFrame(for button: UIButton) {
        if let gradientLayer = button.layer.sublayers?.first(where: { $0.name == "gradientLayer" }) as? CAGradientLayer {
            gradientLayer.frame = button.bounds
        }
    }
    
    /// Add subtle pulse animation to a button
    static func addPulseAnimation(to button: UIButton) {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1.5
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.02
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        button.layer.add(pulseAnimation, forKey: "pulse")
    }
    
    /// Remove pulse animation from button
    static func removePulseAnimation(from button: UIButton) {
        button.layer.removeAnimation(forKey: "pulse")
    }
    
    /// Add shimmer effect to a button
    static func addShimmerEffect(to button: UIButton) {
        let shimmerLayer = CAGradientLayer()
        shimmerLayer.colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        shimmerLayer.locations = [0.0, 0.5, 1.0]
        shimmerLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: 1, y: 0.5)
        shimmerLayer.frame = CGRect(x: -button.bounds.width, y: 0, width: button.bounds.width * 2, height: button.bounds.height)
        shimmerLayer.name = "shimmerLayer"
        shimmerLayer.cornerRadius = button.layer.cornerRadius
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: button.bounds, cornerRadius: button.layer.cornerRadius).cgPath
        button.layer.mask = maskLayer
        
        button.layer.addSublayer(shimmerLayer)
        
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = -button.bounds.width
        animation.toValue = button.bounds.width * 2
        animation.duration = 2.0
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        shimmerLayer.add(animation, forKey: "shimmer")
    }
}
