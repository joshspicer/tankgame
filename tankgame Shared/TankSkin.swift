//
//  TankSkin.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Represents a purchasable tank skin
struct TankSkin: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let price: Int  // Price in TankCoins
    let iapProductId: String?  // Optional StoreKit product ID for real money purchase
    
    // Visual properties
    let primaryHue: CGFloat  // Hue value 0-1 for primary color
    let hasRainbowEffect: Bool
    let hasGlowEffect: Bool
    let particleEffect: ParticleEffectType?
    
    enum ParticleEffectType: String, Codable {
        case fire
        case sparkle
        case smoke
        case none
    }
    
    /// Returns the primary color for this skin
    var primaryColor: SKColor {
        return SKColor(hue: primaryHue, saturation: 0.9, brightness: 0.9, alpha: 1.0)
    }
}

// MARK: - Default Skins

extension TankSkin {
    /// All available skins in the game
    static let allSkins: [TankSkin] = [
        // Free default skins
        TankSkin(
            id: "default_blue",
            name: "Classic Blue",
            description: "The standard blue tank",
            price: 0,
            iapProductId: nil,
            primaryHue: 0.6,
            hasRainbowEffect: false,
            hasGlowEffect: false,
            particleEffect: .none
        ),
        TankSkin(
            id: "default_red",
            name: "Classic Red",
            description: "The standard red tank",
            price: 0,
            iapProductId: nil,
            primaryHue: 0.0,
            hasRainbowEffect: false,
            hasGlowEffect: false,
            particleEffect: .none
        ),
        
        // Purchasable with coins
        TankSkin(
            id: "neon_green",
            name: "Neon Green",
            description: "A bright neon green tank that glows!",
            price: 100,
            iapProductId: nil,
            primaryHue: 0.33,
            hasRainbowEffect: false,
            hasGlowEffect: true,
            particleEffect: .none
        ),
        TankSkin(
            id: "purple_haze",
            name: "Purple Haze",
            description: "Mysterious purple with smoke trail",
            price: 200,
            iapProductId: nil,
            primaryHue: 0.75,
            hasRainbowEffect: false,
            hasGlowEffect: true,
            particleEffect: .smoke
        ),
        TankSkin(
            id: "golden_tank",
            name: "Golden Glory",
            description: "A prestigious golden tank",
            price: 500,
            iapProductId: nil,
            primaryHue: 0.12,
            hasRainbowEffect: false,
            hasGlowEffect: true,
            particleEffect: .sparkle
        ),
        TankSkin(
            id: "fire_tank",
            name: "Inferno",
            description: "Leaves a trail of fire!",
            price: 750,
            iapProductId: nil,
            primaryHue: 0.05,
            hasRainbowEffect: false,
            hasGlowEffect: true,
            particleEffect: .fire
        ),
        TankSkin(
            id: "rainbow_tank",
            name: "Rainbow Rider",
            description: "The ultimate rainbow effect!",
            price: 1000,
            iapProductId: "com.tankgame.skin.rainbow",
            primaryHue: 0.0,
            hasRainbowEffect: true,
            hasGlowEffect: true,
            particleEffect: .sparkle
        )
    ]
    
    /// Get a skin by ID
    static func skin(withId id: String) -> TankSkin? {
        return allSkins.first { $0.id == id }
    }
    
    /// Get all free skins
    static var freeSkins: [TankSkin] {
        return allSkins.filter { $0.price == 0 }
    }
    
    /// Get all purchasable skins
    static var purchasableSkins: [TankSkin] {
        return allSkins.filter { $0.price > 0 }
    }
}
