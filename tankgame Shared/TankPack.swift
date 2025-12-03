//
//  TankPack.swift
//  tankgame Shared
//
//  Data model for tank pack themes
//

import SpriteKit

/// Represents a purchasable tank pack theme
struct TankPack: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let productID: String
    let style: TankStyle
    let isPremium: Bool
    
    /// Visual style configuration for a tank pack
    struct TankStyle: Codable {
        let primaryColors: [CodableColor]
        let animationType: AnimationType
        let bodyShape: BodyShape
        let barrelStyle: BarrelStyle
        
        enum AnimationType: String, Codable {
            case rainbow
            case pulse
            case glow
            case static_
            case sparkle
            
            var codingValue: String {
                switch self {
                case .static_: return "static"
                default: return rawValue
                }
            }
        }
        
        enum BodyShape: String, Codable {
            case square
            case rounded
            case diamond
            case hexagon
        }
        
        enum BarrelStyle: String, Codable {
            case standard
            case double
            case wide
            case pointed
        }
    }
}

/// A codable wrapper for SKColor
struct CodableColor: Codable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
    
    init(color: SKColor) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        #if os(macOS)
        let ciColor = CIColor(color: color)
        r = ciColor?.red ?? 0
        g = ciColor?.green ?? 0
        b = ciColor?.blue ?? 0
        a = ciColor?.alpha ?? 1
        #else
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif
        self.red = r
        self.green = g
        self.blue = b
        self.alpha = a
    }
    
    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    var skColor: SKColor {
        return SKColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// MARK: - Predefined Tank Packs

extension TankPack {
    /// The default free tank pack
    static let classic = TankPack(
        id: "classic",
        name: "Classic",
        description: "The original tank design with rainbow animation",
        productID: "",
        style: TankStyle(
            primaryColors: [
                CodableColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0),  // Blue
                CodableColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0),  // Red
                CodableColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0),  // Green
                CodableColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)   // Orange
            ],
            animationType: .rainbow,
            bodyShape: .square,
            barrelStyle: .standard
        ),
        isPremium: false
    )
    
    /// Neon pack with glowing effects
    static let neon = TankPack(
        id: "neon",
        name: "Neon Nights",
        description: "Vibrant neon colors with a pulsing glow effect",
        productID: "com.tankgame.tankpack.neon",
        style: TankStyle(
            primaryColors: [
                CodableColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),  // Cyan
                CodableColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),  // Magenta
                CodableColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0),  // Yellow
                CodableColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 1.0)   // Spring green
            ],
            animationType: .glow,
            bodyShape: .rounded,
            barrelStyle: .wide
        ),
        isPremium: true
    )
    
    /// Military themed pack
    static let military = TankPack(
        id: "military",
        name: "Military",
        description: "Authentic military camouflage colors",
        productID: "com.tankgame.tankpack.military",
        style: TankStyle(
            primaryColors: [
                CodableColor(red: 0.3, green: 0.35, blue: 0.2, alpha: 1.0), // Olive
                CodableColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0),  // Desert tan
                CodableColor(red: 0.2, green: 0.3, blue: 0.2, alpha: 1.0),  // Forest green
                CodableColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)   // Gray
            ],
            animationType: .static_,
            bodyShape: .hexagon,
            barrelStyle: .double
        ),
        isPremium: true
    )
    
    /// Retro pixel pack
    static let retro = TankPack(
        id: "retro",
        name: "Retro Pixels",
        description: "8-bit inspired pixel art style",
        productID: "com.tankgame.tankpack.retro",
        style: TankStyle(
            primaryColors: [
                CodableColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0),  // Retro blue
                CodableColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0),  // Retro red
                CodableColor(red: 0.3, green: 0.9, blue: 0.3, alpha: 1.0),  // Retro green
                CodableColor(red: 0.9, green: 0.9, blue: 0.3, alpha: 1.0)   // Retro yellow
            ],
            animationType: .pulse,
            bodyShape: .square,
            barrelStyle: .pointed
        ),
        isPremium: true
    )
    
    /// Galaxy themed pack
    static let galaxy = TankPack(
        id: "galaxy",
        name: "Galaxy",
        description: "Cosmic colors with sparkle effects",
        productID: "com.tankgame.tankpack.galaxy",
        style: TankStyle(
            primaryColors: [
                CodableColor(red: 0.4, green: 0.2, blue: 0.8, alpha: 1.0),  // Deep purple
                CodableColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0),  // Space blue
                CodableColor(red: 0.8, green: 0.2, blue: 0.6, alpha: 1.0),  // Nebula pink
                CodableColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1.0)   // Cosmic teal
            ],
            animationType: .sparkle,
            bodyShape: .diamond,
            barrelStyle: .standard
        ),
        isPremium: true
    )
    
    /// All available tank packs
    static let allPacks: [TankPack] = [classic, neon, military, retro, galaxy]
    
    /// Get a pack by its ID
    static func pack(forID id: String) -> TankPack? {
        return allPacks.first { $0.id == id }
    }
}
