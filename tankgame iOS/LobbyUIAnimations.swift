//
//  LobbyUIAnimations.swift
//  tankgame iOS
//
//  Provides modern animations and visual effects for the lobby UI
//

import UIKit
import QuartzCore

/// Provides modern animations and visual effects for the lobby UI
class LobbyUIAnimations {
    
    // MARK: - Button Animations
    
    /// Add spring animation when button is pressed
    static func addPressAnimation(to button: UIButton) {
        let scale = CASpringAnimation(keyPath: "transform.scale")
        scale.fromValue = 1.0
        scale.toValue = 0.95
        scale.duration = 0.1
        scale.autoreverses = true
        scale.initialVelocity = 0.5
        scale.damping = 10
        button.layer.add(scale, forKey: "pressAnimation")
    }
    
    /// Add subtle pulsing glow effect to button
    static func addPulsingGlow(to button: UIButton, color: UIColor) {
        // Remove existing glow layer
        button.layer.sublayers?.filter { $0.name == "glowLayer" }.forEach { $0.removeFromSuperlayer() }
        
        let glowLayer = CALayer()
        glowLayer.name = "glowLayer"
        glowLayer.frame = button.bounds.insetBy(dx: -8, dy: -8)
        glowLayer.backgroundColor = color.withAlphaComponent(0.3).cgColor
        glowLayer.cornerRadius = button.layer.cornerRadius + 4
        glowLayer.shadowColor = color.cgColor
        glowLayer.shadowOffset = .zero
        glowLayer.shadowRadius = 12
        glowLayer.shadowOpacity = 0.6
        
        // Pulsing animation
        let pulse = CABasicAnimation(keyPath: "shadowOpacity")
        pulse.fromValue = 0.6
        pulse.toValue = 0.2
        pulse.duration = 1.5
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        glowLayer.add(pulse, forKey: "pulseGlow")
        
        button.layer.insertSublayer(glowLayer, at: 0)
    }
    
    /// Animate button entrance with bounce effect
    static func animateEntrance(for button: UIButton, delay: TimeInterval) {
        button.transform = CGAffineTransform(translationX: 0, y: 50).scaledBy(x: 0.8, y: 0.8)
        button.alpha = 0
        
        UIView.animate(
            withDuration: 0.6,
            delay: delay,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            button.transform = .identity
            button.alpha = 1
        }
    }
    
    // MARK: - View Animations
    
    /// Animate title with fade and scale
    static func animateTitleEntrance(for label: UILabel, delay: TimeInterval = 0) {
        label.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        label.alpha = 0
        
        UIView.animate(
            withDuration: 0.8,
            delay: delay,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.3
        ) {
            label.transform = .identity
            label.alpha = 1
        }
    }
    
    /// Add floating animation to a view
    static func addFloatingAnimation(to view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animation.values = [0, -8, 0, 8, 0]
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.duration = 3.0
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(animation, forKey: "floatingAnimation")
    }
    
    /// Add shimmer effect to a view
    static func addShimmerEffect(to view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "shimmerLayer"
        gradientLayer.frame = view.bounds.insetBy(dx: -100, dy: 0)
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let shimmerAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        shimmerAnimation.fromValue = -view.bounds.width * 2
        shimmerAnimation.toValue = view.bounds.width * 2
        shimmerAnimation.duration = 2.5
        shimmerAnimation.repeatCount = .infinity
        shimmerAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        gradientLayer.add(shimmerAnimation, forKey: "shimmerAnimation")
        view.layer.mask = gradientLayer
    }
    
    // MARK: - Gradient Backgrounds
    
    /// Create an animated gradient background layer
    static func createAnimatedGradient(for bounds: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [
            UIColor(red: 0.1, green: 0.15, blue: 0.3, alpha: 1.0).cgColor,
            UIColor(red: 0.15, green: 0.2, blue: 0.35, alpha: 1.0).cgColor,
            UIColor(red: 0.1, green: 0.25, blue: 0.4, alpha: 1.0).cgColor
        ]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
        // Animate gradient colors
        let colorAnimation = CABasicAnimation(keyPath: "colors")
        colorAnimation.fromValue = gradient.colors
        colorAnimation.toValue = [
            UIColor(red: 0.15, green: 0.2, blue: 0.35, alpha: 1.0).cgColor,
            UIColor(red: 0.2, green: 0.15, blue: 0.4, alpha: 1.0).cgColor,
            UIColor(red: 0.1, green: 0.2, blue: 0.35, alpha: 1.0).cgColor
        ]
        colorAnimation.duration = 5.0
        colorAnimation.autoreverses = true
        colorAnimation.repeatCount = .infinity
        colorAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradient.add(colorAnimation, forKey: "gradientAnimation")
        
        return gradient
    }
    
    // MARK: - Particle Effects
    
    /// Add floating particle effect to background
    static func addParticleEffect(to view: UIView) {
        let particleEmitter = CAEmitterLayer()
        particleEmitter.name = "particleEmitter"
        particleEmitter.emitterPosition = CGPoint(x: view.bounds.width / 2, y: view.bounds.height + 20)
        particleEmitter.emitterSize = CGSize(width: view.bounds.width, height: 1)
        particleEmitter.emitterShape = .line
        
        let cell = CAEmitterCell()
        cell.birthRate = 3
        cell.lifetime = 15.0
        cell.velocity = 30
        cell.velocityRange = 20
        cell.emissionLongitude = -.pi / 2
        cell.emissionRange = .pi / 4
        cell.scale = 0.1
        cell.scaleRange = 0.05
        cell.alphaSpeed = -0.02
        cell.color = UIColor.white.withAlphaComponent(0.4).cgColor
        
        // Create a simple circular particle using UIGraphicsImageRenderer
        let particleSize: CGFloat = 20
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: particleSize, height: particleSize))
        let particleImage = renderer.image { context in
            UIColor.white.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: particleSize, height: particleSize))
        }
        
        cell.contents = particleImage.cgImage
        
        particleEmitter.emitterCells = [cell]
        view.layer.insertSublayer(particleEmitter, at: 1)
    }
    
    // MARK: - Transition Animations
    
    /// Animate transition to game
    static func animateTransitionToGame(from view: UIView, completion: @escaping () -> Void) {
        let whiteFlash = UIView(frame: view.bounds)
        whiteFlash.backgroundColor = .white
        whiteFlash.alpha = 0
        view.addSubview(whiteFlash)
        
        UIView.animate(withDuration: 0.2, animations: {
            whiteFlash.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0.1, animations: {
                whiteFlash.alpha = 0
            }) { _ in
                whiteFlash.removeFromSuperview()
                completion()
            }
        }
    }
}
