//
//  UITheme.swift
//  tankgame iOS
//
//  Modern UI theme for UIKit components in the lobby
//

import UIKit

/// UIKit-compatible theme for consistent styling
struct UITheme {
    
    // MARK: - Color Palette
    
    struct Colors {
        // Background colors (dark theme)
        static let backgroundDark = UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
        static let backgroundMedium = UIColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 1.0)
        static let backgroundLight = UIColor(red: 0.18, green: 0.18, blue: 0.24, alpha: 1.0)
        static let cardBackground = UIColor(red: 0.14, green: 0.14, blue: 0.20, alpha: 1.0)
        
        // Primary action colors
        static let primary = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        static let primaryDark = UIColor(red: 0.2, green: 0.45, blue: 0.85, alpha: 1.0)
        static let secondary = UIColor(red: 0.35, green: 0.78, blue: 0.55, alpha: 1.0)
        static let secondaryDark = UIColor(red: 0.25, green: 0.65, blue: 0.45, alpha: 1.0)
        static let accent = UIColor(red: 1.0, green: 0.55, blue: 0.25, alpha: 1.0)
        static let accentDark = UIColor(red: 0.9, green: 0.45, blue: 0.15, alpha: 1.0)
        static let danger = UIColor(red: 0.95, green: 0.35, blue: 0.35, alpha: 1.0)
        
        // Text colors
        static let textPrimary = UIColor.white
        static let textSecondary = UIColor(red: 0.75, green: 0.78, blue: 0.85, alpha: 1.0)
        static let textMuted = UIColor(red: 0.5, green: 0.53, blue: 0.6, alpha: 1.0)
        
        // Border colors
        static let borderLight = UIColor(red: 0.25, green: 0.28, blue: 0.35, alpha: 1.0)
        static let borderHighlight = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.5)
    }
    
    // MARK: - Gradients
    
    struct Gradients {
        static func backgroundGradient() -> CAGradientLayer {
            let gradient = CAGradientLayer()
            gradient.colors = [
                UIColor(red: 0.12, green: 0.12, blue: 0.20, alpha: 1.0).cgColor,
                UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0).cgColor,
                UIColor(red: 0.10, green: 0.10, blue: 0.15, alpha: 1.0).cgColor
            ]
            gradient.locations = [0.0, 0.5, 1.0]
            return gradient
        }
        
        static func primaryButtonGradient() -> CAGradientLayer {
            let gradient = CAGradientLayer()
            gradient.colors = [
                Colors.primary.cgColor,
                Colors.primaryDark.cgColor
            ]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 0, y: 1)
            gradient.cornerRadius = 16
            return gradient
        }
        
        static func secondaryButtonGradient() -> CAGradientLayer {
            let gradient = CAGradientLayer()
            gradient.colors = [
                Colors.secondary.cgColor,
                Colors.secondaryDark.cgColor
            ]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 0, y: 1)
            gradient.cornerRadius = 16
            return gradient
        }
        
        static func accentButtonGradient() -> CAGradientLayer {
            let gradient = CAGradientLayer()
            gradient.colors = [
                Colors.accent.cgColor,
                Colors.accentDark.cgColor
            ]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 0, y: 1)
            gradient.cornerRadius = 16
            return gradient
        }
    }
    
    // MARK: - Typography
    
    struct Typography {
        static let titleFont = UIFont.systemFont(ofSize: 42, weight: .black)
        static let subtitleFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
        static let bodyFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let captionFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        static let buttonFont = UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    // MARK: - Dimensions
    
    struct Dimensions {
        static let buttonHeight: CGFloat = 58
        static let buttonWidth: CGFloat = 260
        static let buttonCornerRadius: CGFloat = 16
        static let cardCornerRadius: CGFloat = 14
        static let standardPadding: CGFloat = 20
        static let smallPadding: CGFloat = 12
    }
    
    // MARK: - Shadows
    
    struct Shadows {
        static func buttonShadow(for layer: CALayer) {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.35
            layer.shadowOffset = CGSize(width: 0, height: 6)
            layer.shadowRadius = 12
        }
        
        static func cardShadow(for layer: CALayer) {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.25
            layer.shadowOffset = CGSize(width: 0, height: 4)
            layer.shadowRadius = 8
        }
        
        static func glowShadow(for layer: CALayer, color: UIColor) {
            layer.shadowColor = color.cgColor
            layer.shadowOpacity = 0.5
            layer.shadowOffset = .zero
            layer.shadowRadius = 10
        }
    }
}
