//
//  TankPackManager.swift
//  tankgame Shared
//
//  Manages purchased and selected tank packs
//

import Foundation

/// Manages the user's tank pack collection and selection
class TankPackManager {
    /// Shared singleton instance
    static let shared = TankPackManager()
    
    /// UserDefaults keys
    private enum Keys {
        static let selectedPackID = "tankpack.selected"
        static let purchasedPackIDs = "tankpack.purchased"
    }
    
    /// Currently selected tank pack ID
    private(set) var selectedPackID: String {
        didSet {
            UserDefaults.standard.set(selectedPackID, forKey: Keys.selectedPackID)
            NotificationCenter.default.post(name: .tankPackSelectionChanged, object: nil)
        }
    }
    
    /// Set of purchased pack IDs
    private(set) var purchasedPackIDs: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(purchasedPackIDs), forKey: Keys.purchasedPackIDs)
        }
    }
    
    /// Currently selected tank pack
    var selectedPack: TankPack {
        return TankPack.pack(forID: selectedPackID) ?? TankPack.classic
    }
    
    private init() {
        // Load selected pack from UserDefaults
        selectedPackID = UserDefaults.standard.string(forKey: Keys.selectedPackID) ?? TankPack.classic.id
        
        // Load purchased packs from UserDefaults
        let savedPurchased = UserDefaults.standard.stringArray(forKey: Keys.purchasedPackIDs) ?? []
        purchasedPackIDs = Set(savedPurchased)
        
        // Classic pack is always available
        purchasedPackIDs.insert(TankPack.classic.id)
    }
    
    /// Check if a pack is owned (purchased or free)
    func isPackOwned(_ pack: TankPack) -> Bool {
        return !pack.isPremium || purchasedPackIDs.contains(pack.id)
    }
    
    /// Select a tank pack
    func selectPack(_ pack: TankPack) {
        guard isPackOwned(pack) else { return }
        selectedPackID = pack.id
    }
    
    /// Mark a pack as purchased
    func markPackAsPurchased(_ packID: String) {
        purchasedPackIDs.insert(packID)
    }
    
    /// Get available packs (both free and premium)
    func availablePacks() -> [TankPack] {
        return TankPack.allPacks
    }
    
    /// Get owned packs only
    func ownedPacks() -> [TankPack] {
        return TankPack.allPacks.filter { isPackOwned($0) }
    }
    
    /// Get colors for the selected pack
    func colorsForSelectedPack() -> [CodableColor] {
        return selectedPack.style.primaryColors
    }
    
    /// Restore purchases (called when StoreKit restores transactions)
    func restorePurchases(productIDs: [String]) {
        for productID in productIDs {
            if let pack = TankPack.allPacks.first(where: { $0.productID == productID }) {
                markPackAsPurchased(pack.id)
            }
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let tankPackSelectionChanged = Notification.Name("tankPackSelectionChanged")
    static let tankPackPurchaseCompleted = Notification.Name("tankPackPurchaseCompleted")
}
