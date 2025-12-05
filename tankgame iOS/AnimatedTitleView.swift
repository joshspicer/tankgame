//
//  AnimatedTitleView.swift
//  tankgame iOS
//
//  Animated title with gradient text and glow effects
//

import UIKit

/// An animated title view with gradient text, glow effects, and animations
class AnimatedTitleView: UIView {
    
    // MARK: - Properties
    
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    private var glowLayer: CALayer!
    private var iconLabel: UILabel!
    
    /// The main title text
    var titleText: String = "TANK GAME" {
        didSet {
            titleLabel?.text = titleText
        }
    }
    
    /// The subtitle text
    var subtitleText: String = "Battle Arena" {
        didSet {
            subtitleLabel?.text = subtitleText
        }
    }
    
    /// The icon emoji
    var iconEmoji: String = "🎯" {
        didSet {
            iconLabel?.text = iconEmoji
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .clear
        
        // Icon label
        iconLabel = UILabel()
        iconLabel.text = iconEmoji
        iconLabel.font = .systemFont(ofSize: 70)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconLabel)
        
        // Title label with shadow for glow effect
        titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = UIFont.systemFont(ofSize: 52, weight: .black)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.layer.shadowColor = UIColor.systemBlue.cgColor
        titleLabel.layer.shadowRadius = 10
        titleLabel.layer.shadowOpacity = 0.8
        titleLabel.layer.shadowOffset = .zero
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        // Subtitle label
        subtitleLabel = UILabel()
        subtitleLabel.text = subtitleText
        subtitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subtitleLabel)
        
        setupConstraints()
        startAnimations()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: topAnchor),
            iconLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Animations
    
    func startAnimations() {
        // Icon bounce animation
        addIconBounceAnimation()
        
        // Title glow pulse animation
        addGlowPulseAnimation()
        
        // Subtle title scale animation
        addTitleScaleAnimation()
    }
    
    private func addIconBounceAnimation() {
        let bounce = CAKeyframeAnimation(keyPath: "transform.translation.y")
        bounce.values = [0, -8, 0, -4, 0]
        bounce.keyTimes = [0, 0.3, 0.5, 0.7, 1.0]
        bounce.duration = 2.0
        bounce.repeatCount = .infinity
        bounce.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        iconLabel.layer.add(bounce, forKey: "bounce")
        
        // Also add rotation
        let rotate = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotate.values = [0, CGFloat.pi * 0.05, 0, -CGFloat.pi * 0.05, 0]
        rotate.keyTimes = [0, 0.25, 0.5, 0.75, 1.0]
        rotate.duration = 3.0
        rotate.repeatCount = .infinity
        iconLabel.layer.add(rotate, forKey: "wobble")
    }
    
    private func addGlowPulseAnimation() {
        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.fromValue = 8
        glowAnimation.toValue = 20
        glowAnimation.duration = 1.5
        glowAnimation.autoreverses = true
        glowAnimation.repeatCount = .infinity
        glowAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        titleLabel.layer.add(glowAnimation, forKey: "glowPulse")
        
        // Also animate shadow opacity
        let opacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        opacityAnimation.fromValue = 0.6
        opacityAnimation.toValue = 1.0
        opacityAnimation.duration = 1.5
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        titleLabel.layer.add(opacityAnimation, forKey: "opacityPulse")
    }
    
    private func addTitleScaleAnimation() {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.02
        scaleAnimation.duration = 2.0
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = .infinity
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        titleLabel.layer.add(scaleAnimation, forKey: "scale")
    }
    
    /// Update the icon for sprite mode changes
    func updateIcon(for spriteMode: SpriteMode) {
        UIView.transition(with: iconLabel, duration: 0.3, options: .transitionFlipFromTop) {
            self.iconLabel.text = spriteMode.icon
        }
    }
    
    // MARK: - Entrance Animation
    
    /// Play entrance animation when view appears
    func playEntranceAnimation() {
        iconLabel.alpha = 0
        iconLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        titleLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        subtitleLabel.alpha = 0
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            self.iconLabel.alpha = 1
            self.iconLabel.transform = .identity
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.4, options: .curveEaseOut) {
            self.subtitleLabel.alpha = 1
        }
    }
}
