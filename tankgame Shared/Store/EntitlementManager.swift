//
//  EntitlementManager.swift
//  tankgame
//
//  Manages user entitlements based on purchases
//

import Foundation
import StoreKit

/// Manages user entitlements and content unlocking based on purchases
@MainActor
final class EntitlementManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Whether ads should be shown
    @Published private(set) var shouldShowAds: Bool = true
    
    /// Set of unlocked skin pack IDs
    @Published private(set) var unlockedSkinPacks: Set<String> = []
    
    // MARK: - Singleton
    
    static let shared = EntitlementManager()
    
    // MARK: - Private Properties
    
    private var notificationTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    private init() {
        // Load cached state for immediate UI updates
        loadCachedState()
        
        // Start observing purchase changes
        setupTransactionObserver()
        
        // Update from store
        Task {
            await updateEntitlements()
        }
    }
    
    deinit {
        notificationTask?.cancel()
    }
    
    // MARK: - Setup
    
    private func setupTransactionObserver() {
        notificationTask = Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(named: .transactionDidUpdate) {
                await self?.updateEntitlements()
            }
        }
    }
    
    // MARK: - Entitlement Updates
    
    /// Update entitlements based on current purchases
    func updateEntitlements() async {
        let storeManager = StoreManager.shared
        await storeManager.updatePurchasedProducts()
        
        // Update ad entitlement
        shouldShowAds = !storeManager.hasRemovedAds
        
        // Update skin pack entitlements
        var skinPacks = Set<String>()
        
        if storeManager.hasSkinPack(.premiumSkinPack1) {
            skinPacks.insert(ProductID.premiumSkinPack1.rawValue)
        }
        
        if storeManager.hasSkinPack(.premiumSkinPack2) {
            skinPacks.insert(ProductID.premiumSkinPack2.rawValue)
        }
        
        // Bundle unlocks all skin packs
        if storeManager.hasSkinPack(.premiumSkinPackBundle) {
            skinPacks.insert(ProductID.premiumSkinPack1.rawValue)
            skinPacks.insert(ProductID.premiumSkinPack2.rawValue)
            skinPacks.insert(ProductID.premiumSkinPackBundle.rawValue)
        }
        
        unlockedSkinPacks = skinPacks
        
        // Persist state
        saveState()
    }
    
    // MARK: - Entitlement Checks
    
    /// Check if a specific skin is unlocked
    /// - Parameter skinID: The skin identifier to check
    /// - Returns: Whether the skin is unlocked
    func isSkinUnlocked(_ skinID: String) -> Bool {
        // Map skin IDs to their product IDs
        // Default skins are always unlocked
        if isDefaultSkin(skinID) {
            return true
        }
        
        // Check if any purchased pack includes this skin
        return skinBelongsToUnlockedPack(skinID)
    }
    
    /// Check if a skin is a default (free) skin
    private func isDefaultSkin(_ skinID: String) -> Bool {
        // Define your default skins here
        let defaultSkins = ["default", "green", "blue"]
        return defaultSkins.contains(skinID.lowercased())
    }
    
    /// Check if a skin belongs to an unlocked pack
    private func skinBelongsToUnlockedPack(_ skinID: String) -> Bool {
        // Map skins to packs
        let pack1Skins = ["desert_camo", "arctic_white", "olive_drab"]
        let pack2Skins = ["jungle_hunter", "night_ops", "urban_gray"]
        
        if pack1Skins.contains(skinID.lowercased()) {
            return unlockedSkinPacks.contains(ProductID.premiumSkinPack1.rawValue)
        }
        
        if pack2Skins.contains(skinID.lowercased()) {
            return unlockedSkinPacks.contains(ProductID.premiumSkinPack2.rawValue)
        }
        
        return false
    }
    
    /// Get all available skins for the user
    func availableSkins() -> [TankSkin] {
        var skins = TankSkin.defaultSkins
        
        if unlockedSkinPacks.contains(ProductID.premiumSkinPack1.rawValue) {
            skins.append(contentsOf: TankSkin.pack1Skins)
        }
        
        if unlockedSkinPacks.contains(ProductID.premiumSkinPack2.rawValue) {
            skins.append(contentsOf: TankSkin.pack2Skins)
        }
        
        return skins
    }
    
    // MARK: - Persistence
    
    private let adsKey = "com.tankgame.entitlements.showAds"
    private let skinsKey = "com.tankgame.entitlements.skins"
    
    private func saveState() {
        UserDefaults.standard.set(shouldShowAds, forKey: adsKey)
        UserDefaults.standard.set(Array(unlockedSkinPacks), forKey: skinsKey)
    }
    
    private func loadCachedState() {
        // Default to showing ads if no cached value
        shouldShowAds = UserDefaults.standard.object(forKey: adsKey) as? Bool ?? true
        
        if let cachedSkins = UserDefaults.standard.stringArray(forKey: skinsKey) {
            unlockedSkinPacks = Set(cachedSkins)
        }
    }
}

// MARK: - Tank Skin Model

/// Represents a tank skin
struct TankSkin: Identifiable, Hashable {
    let id: String
    let displayName: String
    let imageName: String
    let isPremium: Bool
    
    /// Default skins available to all users
    static let defaultSkins: [TankSkin] = [
        TankSkin(id: "default", displayName: "Classic Green", imageName: "tank_default", isPremium: false),
        TankSkin(id: "green", displayName: "Forest Green", imageName: "tank_green", isPremium: false),
        TankSkin(id: "blue", displayName: "Ocean Blue", imageName: "tank_blue", isPremium: false)
    ]
    
    /// Premium Skin Pack 1 skins
    static let pack1Skins: [TankSkin] = [
        TankSkin(id: "desert_camo", displayName: "Desert Camo", imageName: "tank_desert", isPremium: true),
        TankSkin(id: "arctic_white", displayName: "Arctic White", imageName: "tank_arctic", isPremium: true),
        TankSkin(id: "olive_drab", displayName: "Olive Drab", imageName: "tank_olive", isPremium: true)
    ]
    
    /// Premium Skin Pack 2 skins
    static let pack2Skins: [TankSkin] = [
        TankSkin(id: "jungle_hunter", displayName: "Jungle Hunter", imageName: "tank_jungle", isPremium: true),
        TankSkin(id: "night_ops", displayName: "Night Ops", imageName: "tank_night", isPremium: true),
        TankSkin(id: "urban_gray", displayName: "Urban Gray", imageName: "tank_urban", isPremium: true)
    ]
}
