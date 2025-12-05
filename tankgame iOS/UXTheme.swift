//
//  UXTheme.swift
//  tankgame iOS
//
//  Modern UX theme constants and helpers
//

import UIKit

/// Centralized theme for consistent UX styling across the app
struct UXTheme {
    
    // MARK: - Color Palette
    
    struct Colors {
        // Primary colors
        static let primaryGradientStart = UIColor(red: 0.20, green: 0.35, blue: 0.70, alpha: 1.0)
        static let primaryGradientEnd = UIColor(red: 0.10, green: 0.20, blue: 0.45, alpha: 1.0)
        
        // Accent colors
        static let accentOrange = UIColor(red: 1.0, green: 0.55, blue: 0.20, alpha: 1.0)
        static let accentGreen = UIColor(red: 0.30, green: 0.85, blue: 0.55, alpha: 1.0)
        static let accentBlue = UIColor(red: 0.35, green: 0.65, blue: 1.0, alpha: 1.0)
        static let accentRed = UIColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 1.0)
        
        // Surface colors
        static let cardBackground = UIColor.white.withAlphaComponent(0.12)
        static let cardBorder = UIColor.white.withAlphaComponent(0.25)
        static let glassSurface = UIColor.white.withAlphaComponent(0.08)
        
        // Text colors
        static let titleText = UIColor.white
        static let subtitleText = UIColor.white.withAlphaComponent(0.8)
        static let bodyText = UIColor.white.withAlphaComponent(0.65)
    }
    
    // MARK: - Typography
    
    struct Typography {
        static let titleFont = UIFont.systemFont(ofSize: 42, weight: .black)
        static let headingFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        static let buttonFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
        static let bodyFont = UIFont.systemFont(ofSize: 15, weight: .medium)
        static let captionFont = UIFont.systemFont(ofSize: 13, weight: .regular)
    }
    
    // MARK: - Dimensions
    
    struct Dimensions {
        static let buttonCornerRadius: CGFloat = 16
        static let cardCornerRadius: CGFloat = 20
        static let buttonHeight: CGFloat = 56
        static let buttonWidth: CGFloat = 260
        static let standardPadding: CGFloat = 16
        static let largePadding: CGFloat = 24
    }
    
    // MARK: - Shadows
    
    struct Shadows {
        static func apply(to layer: CALayer, color: UIColor = .black, opacity: Float = 0.3, radius: CGFloat = 12, offset: CGSize = CGSize(width: 0, height: 6)) {
            layer.shadowColor = color.cgColor
            layer.shadowOpacity = opacity
            layer.shadowOffset = offset
            layer.shadowRadius = radius
        }
        
        static func applyGlow(to layer: CALayer, color: UIColor, radius: CGFloat = 16) {
            layer.shadowColor = color.cgColor
            layer.shadowOpacity = 0.5
            layer.shadowOffset = .zero
            layer.shadowRadius = radius
        }
    }
    
    // MARK: - Animation Timings
    
    struct Animation {
        static let quick: TimeInterval = 0.2
        static let standard: TimeInterval = 0.35
        static let slow: TimeInterval = 0.6
        static let springDamping: CGFloat = 0.75
        static let springVelocity: CGFloat = 0.5
    }
}

// MARK: - UIView Extensions for UX

extension UIView {
    
    /// Apply glassmorphism effect to the view
    func applyGlassmorphism(cornerRadius: CGFloat = UXTheme.Dimensions.cardCornerRadius) {
        backgroundColor = UXTheme.Colors.glassSurface
        layer.cornerRadius = cornerRadius
        layer.borderWidth = 1
        layer.borderColor = UXTheme.Colors.cardBorder.cgColor
        
        // Add blur effect
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = cornerRadius
        blurView.clipsToBounds = true
        blurView.isUserInteractionEnabled = false
        insertSubview(blurView, at: 0)
    }
    
    /// Apply card styling to the view
    func applyCardStyle() {
        backgroundColor = UXTheme.Colors.cardBackground
        layer.cornerRadius = UXTheme.Dimensions.cardCornerRadius
        layer.borderWidth = 1
        layer.borderColor = UXTheme.Colors.cardBorder.cgColor
        UXTheme.Shadows.apply(to: layer)
    }
    
    /// Add subtle pulse animation
    func addPulseAnimation(scale: CGFloat = 1.05, duration: TimeInterval = 1.5) {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = scale
        pulse.duration = duration
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(pulse, forKey: "pulse")
    }
    
    /// Add bounce animation for tap feedback
    func addBounceAnimation(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(withDuration: 0.15,
                          delay: 0,
                          usingSpringWithDamping: 0.4,
                          initialSpringVelocity: 0.8,
                          options: [],
                          animations: {
                self.transform = .identity
            }) { _ in
                completion?()
            }
        }
    }
    
    /// Fade in animation
    func fadeIn(duration: TimeInterval = UXTheme.Animation.standard, delay: TimeInterval = 0) {
        alpha = 0
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseOut) {
            self.alpha = 1
        }
    }
    
    /// Slide up animation
    func slideUp(offset: CGFloat = 30, duration: TimeInterval = UXTheme.Animation.standard, delay: TimeInterval = 0) {
        let originalY = frame.origin.y
        frame.origin.y = originalY + offset
        alpha = 0
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: []) {
            self.frame.origin.y = originalY
            self.alpha = 1
        }
    }
}

// MARK: - Gradient Layer Helper

class GradientBackgroundView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private var animationTimer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 0.08, green: 0.12, blue: 0.25, alpha: 1.0).cgColor,
            UIColor(red: 0.15, green: 0.22, blue: 0.40, alpha: 1.0).cgColor,
            UIColor(red: 0.10, green: 0.16, blue: 0.30, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    /// Start subtle color animation
    func startAnimating() {
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = gradientLayer.colors
        animation.toValue = [
            UIColor(red: 0.12, green: 0.15, blue: 0.30, alpha: 1.0).cgColor,
            UIColor(red: 0.18, green: 0.25, blue: 0.45, alpha: 1.0).cgColor,
            UIColor(red: 0.08, green: 0.12, blue: 0.25, alpha: 1.0).cgColor
        ]
        animation.duration = 5.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientLayer.add(animation, forKey: "colorAnimation")
    }
}
