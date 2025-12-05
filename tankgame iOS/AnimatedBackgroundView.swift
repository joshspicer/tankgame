//
//  AnimatedBackgroundView.swift
//  tankgame iOS
//
//  Animated background with floating particles and gradient effects
//

import UIKit

/// An animated background view with floating particles and dynamic gradient
class AnimatedBackgroundView: UIView {
    
    // MARK: - Properties
    
    private var gradientLayer: CAGradientLayer!
    private var particleLayers: [CAShapeLayer] = []
    private var displayLink: CADisplayLink?
    private var animationTime: TimeInterval = 0
    
    /// Number of floating particles
    var particleCount: Int = 15
    
    /// Background gradient colors
    var gradientColors: [UIColor] = [
        UIColor(red: 0.05, green: 0.1, blue: 0.2, alpha: 1.0),
        UIColor(red: 0.1, green: 0.15, blue: 0.3, alpha: 1.0),
        UIColor(red: 0.05, green: 0.1, blue: 0.25, alpha: 1.0)
    ] {
        didSet {
            updateGradient()
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackground()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBackground()
    }
    
    // MARK: - Setup
    
    private func setupBackground() {
        setupGradient()
        setupParticles()
    }
    
    private func setupGradient() {
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
        
        // Add subtle gradient animation
        startGradientAnimation()
    }
    
    private func setupParticles() {
        for _ in 0..<particleCount {
            let particle = createParticle()
            particleLayers.append(particle)
            layer.addSublayer(particle)
        }
    }
    
    private func createParticle() -> CAShapeLayer {
        let particle = CAShapeLayer()
        let size = CGFloat.random(in: 4...12)
        
        // Vary particle shapes
        if Bool.random() {
            particle.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: size, height: size)).cgPath
        } else {
            particle.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size, height: size), cornerRadius: size * 0.3).cgPath
        }
        
        // Random colors with low opacity
        let colors: [UIColor] = [
            UIColor.systemBlue.withAlphaComponent(0.3),
            UIColor.systemCyan.withAlphaComponent(0.25),
            UIColor.systemTeal.withAlphaComponent(0.2),
            UIColor.white.withAlphaComponent(0.15)
        ]
        particle.fillColor = colors.randomElement()?.cgColor
        particle.opacity = Float.random(in: 0.3...0.6)
        
        // Random initial position
        particle.position = CGPoint(
            x: CGFloat.random(in: 0...bounds.width),
            y: CGFloat.random(in: 0...bounds.height)
        )
        
        // Store animation data in layer
        particle.setValue(CGFloat.random(in: 0.3...1.0), forKey: "speed")
        particle.setValue(CGFloat.random(in: 0...CGFloat.pi * 2), forKey: "angle")
        particle.setValue(CGFloat.random(in: 0.5...2.0), forKey: "amplitude")
        
        return particle
    }
    
    // MARK: - Animation
    
    func startAnimating() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateParticles))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stopAnimating() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateParticles(displayLink: CADisplayLink) {
        animationTime += displayLink.duration
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        for particle in particleLayers {
            let speed = particle.value(forKey: "speed") as? CGFloat ?? 0.5
            let angle = particle.value(forKey: "angle") as? CGFloat ?? 0
            let amplitude = particle.value(forKey: "amplitude") as? CGFloat ?? 1.0
            
            // Calculate new position with gentle floating motion
            var newY = particle.position.y - speed
            let xOffset = sin(animationTime * 2 + angle) * amplitude
            var newX = particle.position.x + xOffset
            
            // Wrap around screen
            if newY < -20 {
                newY = bounds.height + 20
                newX = CGFloat.random(in: 0...bounds.width)
            }
            
            if newX < -20 {
                newX = bounds.width + 20
            } else if newX > bounds.width + 20 {
                newX = -20
            }
            
            particle.position = CGPoint(x: newX, y: newY)
            
            // Add gentle scale pulsing
            let scale = 1.0 + sin(animationTime * 3 + angle) * 0.1
            particle.transform = CATransform3DMakeScale(scale, scale, 1)
        }
        
        CATransaction.commit()
    }
    
    private func startGradientAnimation() {
        let animation = CABasicAnimation(keyPath: "colors")
        let shiftedColors = gradientColors.shuffled().map { $0.cgColor }
        animation.toValue = shiftedColors
        animation.duration = 8.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientLayer.add(animation, forKey: "gradientAnimation")
    }
    
    private func updateGradient() {
        gradientLayer?.colors = gradientColors.map { $0.cgColor }
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
    }
    
    // MARK: - Cleanup
    
    deinit {
        stopAnimating()
    }
}
