//
//  LobbyAnimations.swift
//  tankgame iOS
//
//  Handles animations and visual effects for the lobby UI
//

import UIKit
import QuartzCore

/// Manages lobby animations and visual effects
class LobbyAnimations {
    
    // MARK: - Particle Layer
    
    /// Create an animated particle background layer
    static func createParticleLayer(in view: UIView) -> CAEmitterLayer {
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        emitterLayer.emitterSize = CGSize(width: view.bounds.width, height: 1)
        emitterLayer.emitterShape = .line
        
        // Create tank/target shaped particles
        let cell = CAEmitterCell()
        cell.birthRate = 3
        cell.lifetime = 12
        cell.velocity = 30
        cell.velocityRange = 20
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 8
        cell.scale = 0.08
        cell.scaleRange = 0.04
        cell.alphaSpeed = -0.05
        cell.spin = .pi / 6
        cell.spinRange = .pi / 4
        
        // Use a circular shape with color
        cell.contents = createParticleImage()?.cgImage
        cell.color = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        
        // Add color variance
        cell.redRange = 0.3
        cell.greenRange = 0.3
        cell.blueRange = 0.3
        
        emitterLayer.emitterCells = [cell]
        return emitterLayer
    }
    
    /// Create a particle image for the emitter
    private static func createParticleImage() -> UIImage? {
        let size = CGSize(width: 60, height: 60)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // Draw a tank-like shape
            cgContext.setFillColor(UIColor.white.cgColor)
            
            // Main body
            let bodyRect = CGRect(x: 15, y: 20, width: 30, height: 25)
            cgContext.fill(bodyRect)
            
            // Turret
            let turretRect = CGRect(x: 22, y: 10, width: 16, height: 15)
            cgContext.fill(turretRect)
            
            // Barrel
            let barrelRect = CGRect(x: 27, y: 0, width: 6, height: 15)
            cgContext.fill(barrelRect)
            
            // Treads
            let leftTread = CGRect(x: 10, y: 22, width: 8, height: 22)
            let rightTread = CGRect(x: 42, y: 22, width: 8, height: 22)
            cgContext.fill(leftTread)
            cgContext.fill(rightTread)
        }
    }
    
    // MARK: - Title Animations
    
    /// Add a glow animation to a label
    static func addGlowAnimation(to label: UILabel) {
        label.layer.shadowColor = UIColor.systemYellow.cgColor
        label.layer.shadowRadius = 0
        label.layer.shadowOpacity = 0
        label.layer.shadowOffset = .zero
        
        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.fromValue = 0
        glowAnimation.toValue = 15
        glowAnimation.autoreverses = true
        glowAnimation.duration = 1.5
        glowAnimation.repeatCount = .infinity
        glowAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let opacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        opacityAnimation.fromValue = 0.3
        opacityAnimation.toValue = 0.8
        opacityAnimation.autoreverses = true
        opacityAnimation.duration = 1.5
        opacityAnimation.repeatCount = .infinity
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        label.layer.add(glowAnimation, forKey: "glowRadius")
        label.layer.add(opacityAnimation, forKey: "glowOpacity")
    }
    
    /// Add a floating bounce animation to a view
    static func addFloatingAnimation(to view: UIView) {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = -5
        animation.toValue = 5
        animation.autoreverses = true
        animation.duration = 2.0
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(animation, forKey: "floating")
    }
    
    /// Add a pulse animation to a view
    static func addPulseAnimation(to view: UIView) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1.0
        animation.toValue = 1.05
        animation.autoreverses = true
        animation.duration = 0.8
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(animation, forKey: "pulse")
    }
    
    // MARK: - Button Animations
    
    /// Add tap feedback animation to a button
    static func animateButtonTap(_ button: UIButton, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                button.transform = .identity
            }) { _ in
                completion?()
            }
        }
    }
    
    /// Add shimmer effect to a view
    static func addShimmerEffect(to view: UIView) {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = CGRect(x: -view.bounds.width, y: 0, width: view.bounds.width * 3, height: view.bounds.height)
        gradient.locations = [0, 0.5, 1]
        
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = -view.bounds.width
        animation.toValue = view.bounds.width * 2
        animation.duration = 2.0
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        gradient.add(animation, forKey: "shimmer")
        view.layer.mask = gradient
    }
    
    // MARK: - Transition Animations
    
    /// Fade in animation for views
    static func fadeIn(_ views: [UIView], duration: TimeInterval = 0.5, delay: TimeInterval = 0) {
        views.forEach { $0.alpha = 0 }
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseOut) {
            views.forEach { $0.alpha = 1 }
        }
    }
    
    /// Slide in from bottom animation
    static func slideInFromBottom(_ view: UIView, duration: TimeInterval = 0.5, delay: TimeInterval = 0) {
        let originalY = view.frame.origin.y
        view.frame.origin.y = view.superview?.bounds.height ?? 800
        view.alpha = 0
        
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            view.frame.origin.y = originalY
            view.alpha = 1
        }
    }
    
    /// Create gradient border for a view
    static func addGradientBorder(to view: UIView, colors: [UIColor], width: CGFloat = 2) {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: view.bounds.size)
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
        let shape = CAShapeLayer()
        shape.lineWidth = width
        shape.path = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        view.layer.addSublayer(gradient)
    }
}

// MARK: - UIButton Extension for Modern Styling

extension UIButton {
    
    /// Apply modern gradient style to button
    func applyModernGradient(colors: [UIColor]) {
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = bounds
        gradient.cornerRadius = layer.cornerRadius
        
        // Remove existing gradient layers
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        layer.insertSublayer(gradient, at: 0)
    }
    
    /// Add shadow to button
    func addModernShadow(color: UIColor = .black, opacity: Float = 0.2, radius: CGFloat = 10, offset: CGSize = CGSize(width: 0, height: 5)) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        layer.masksToBounds = false
    }
}
