//
//  StoreKitManager.swift
//  tankgame iOS
//
//  Handles in-app purchases using StoreKit
//

import StoreKit

/// Product identifiers for tank skins
enum TankSkinProduct: String, CaseIterable {
    case goldSkin = "com.tankgame.skin.gold"
    case neonSkin = "com.tankgame.skin.neon"
    case camouflage = "com.tankgame.skin.camo"
    case flameSkin = "com.tankgame.skin.flame"
    
    var displayName: String {
        switch self {
        case .goldSkin: return "Golden Tank"
        case .neonSkin: return "Neon Glow"
        case .camouflage: return "Camouflage"
        case .flameSkin: return "Flame Warrior"
        }
    }
    
    var description: String {
        switch self {
        case .goldSkin: return "A luxurious golden tank skin"
        case .neonSkin: return "Bright neon colors that glow"
        case .camouflage: return "Military-style camouflage pattern"
        case .flameSkin: return "Fiery red and orange flames"
        }
    }
    
    var price: String {
        switch self {
        case .goldSkin: return "$0.99"
        case .neonSkin: return "$0.99"
        case .camouflage: return "$1.99"
        case .flameSkin: return "$1.99"
        }
    }
    
    var emoji: String {
        switch self {
        case .goldSkin: return "🥇"
        case .neonSkin: return "💫"
        case .camouflage: return "🌲"
        case .flameSkin: return "🔥"
        }
    }
}

/// Manages StoreKit transactions and purchased items
@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    
    @Published private(set) var purchasedSkins: Set<TankSkinProduct> = []
    @Published private(set) var selectedSkin: TankSkinProduct?
    
    private let purchasedSkinsKey = "purchasedTankSkins"
    private let selectedSkinKey = "selectedTankSkin"
    
    private init() {
        loadPurchasedItems()
    }
    
    /// Load purchased items from UserDefaults
    private func loadPurchasedItems() {
        if let savedSkins = UserDefaults.standard.array(forKey: purchasedSkinsKey) as? [String] {
            purchasedSkins = Set(savedSkins.compactMap { TankSkinProduct(rawValue: $0) })
        }
        
        if let savedSelectedSkin = UserDefaults.standard.string(forKey: selectedSkinKey),
           let skin = TankSkinProduct(rawValue: savedSelectedSkin) {
            selectedSkin = skin
        }
    }
    
    /// Save purchased items to UserDefaults
    private func savePurchasedItems() {
        let skinIds = purchasedSkins.map { $0.rawValue }
        UserDefaults.standard.set(skinIds, forKey: purchasedSkinsKey)
    }
    
    /// Purchase a tank skin (simulated for now without App Store Connect)
    func purchase(_ product: TankSkinProduct) async -> Bool {
        // In a real implementation, this would use StoreKit 2:
        // let result = try await product.purchase()
        // For now, we simulate a successful purchase
        
        purchasedSkins.insert(product)
        savePurchasedItems()
        return true
    }
    
    /// Check if a skin is purchased
    func isPurchased(_ product: TankSkinProduct) -> Bool {
        return purchasedSkins.contains(product)
    }
    
    /// Select a skin to use
    func selectSkin(_ product: TankSkinProduct?) {
        guard product == nil || isPurchased(product!) else { return }
        selectedSkin = product
        
        if let skin = product {
            UserDefaults.standard.set(skin.rawValue, forKey: selectedSkinKey)
        } else {
            UserDefaults.standard.removeObject(forKey: selectedSkinKey)
        }
    }
    
    /// Restore purchases (simulated)
    func restorePurchases() async {
        // In a real implementation, this would restore from App Store
        // For now, we just reload from UserDefaults
        loadPurchasedItems()
    }
}
