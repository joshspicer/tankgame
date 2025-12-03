//
//  StoreManager.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import Foundation
import StoreKit
import Combine

/// Manages in-app purchases, virtual currency, and owned items
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    // User defaults keys
    private let coinsKey = "tankCoins"
    private let ownedSkinsKey = "ownedSkins"
    private let selectedSkinKey = "selectedSkin"
    
    // Published properties for UI updates
    @Published private(set) var coins: Int = 0
    @Published private(set) var ownedSkinIds: Set<String> = []
    @Published private(set) var selectedSkinId: String = "default_blue"
    
    // StoreKit products
    private var products: [Product] = []
    private var purchasedProductIds: Set<String> = []
    
    // Coin package definitions
    static let coinPackages: [(id: String, coins: Int, price: String)] = [
        ("com.tankgame.coins.100", 100, "$0.99"),
        ("com.tankgame.coins.500", 500, "$3.99"),
        ("com.tankgame.coins.1200", 1200, "$7.99"),
        ("com.tankgame.coins.3000", 3000, "$14.99")
    ]
    
    private init() {
        loadUserData()
        
        // Ensure default skins are owned
        for skin in TankSkin.freeSkins {
            ownedSkinIds.insert(skin.id)
        }
        saveUserData()
        
        // Load StoreKit products
        Task {
            await loadProducts()
        }
    }
    
    // MARK: - Data Persistence
    
    private func loadUserData() {
        let defaults = UserDefaults.standard
        
        coins = defaults.integer(forKey: coinsKey)
        
        if let savedSkins = defaults.array(forKey: ownedSkinsKey) as? [String] {
            ownedSkinIds = Set(savedSkins)
        }
        
        if let savedSkin = defaults.string(forKey: selectedSkinKey) {
            selectedSkinId = savedSkin
        }
    }
    
    private func saveUserData() {
        let defaults = UserDefaults.standard
        defaults.set(coins, forKey: coinsKey)
        defaults.set(Array(ownedSkinIds), forKey: ownedSkinsKey)
        defaults.set(selectedSkinId, forKey: selectedSkinKey)
    }
    
    // MARK: - Coin Management
    
    /// Add coins to the user's balance
    func addCoins(_ amount: Int) {
        coins += amount
        saveUserData()
    }
    
    /// Spend coins if the user has enough
    func spendCoins(_ amount: Int) -> Bool {
        guard coins >= amount else { return false }
        coins -= amount
        saveUserData()
        return true
    }
    
    /// Award coins for winning a round
    func awardWinCoins() {
        addCoins(10)
    }
    
    /// Award coins for playing a round
    func awardPlayCoins() {
        addCoins(2)
    }
    
    // MARK: - Skin Management
    
    /// Check if a skin is owned
    func isSkinOwned(_ skinId: String) -> Bool {
        return ownedSkinIds.contains(skinId)
    }
    
    /// Purchase result enum
    enum PurchaseResult {
        case success
        case alreadyOwned
        case insufficientFunds
    }
    
    /// Purchase a skin with coins
    func purchaseSkin(_ skin: TankSkin) -> PurchaseResult {
        guard !isSkinOwned(skin.id) else { return .alreadyOwned }
        guard spendCoins(skin.price) else { return .insufficientFunds }
        
        ownedSkinIds.insert(skin.id)
        saveUserData()
        return .success
    }
    
    /// Select a skin as the active skin
    func selectSkin(_ skinId: String) {
        guard isSkinOwned(skinId) else { return }
        selectedSkinId = skinId
        saveUserData()
    }
    
    /// Get the currently selected skin
    var selectedSkin: TankSkin {
        return TankSkin.skin(withId: selectedSkinId) ?? TankSkin.allSkins[0]
    }
    
    // MARK: - StoreKit Integration
    
    /// Load available products from App Store
    @MainActor
    func loadProducts() async {
        let coinProductIds = StoreManager.coinPackages.map { $0.id }
        let skinProductIds = TankSkin.allSkins.compactMap { $0.iapProductId }
        let productIds = coinProductIds + skinProductIds
        
        do {
            products = try await Product.products(for: Set(productIds))
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    /// Get a StoreKit product by ID
    func product(for id: String) -> Product? {
        return products.first { $0.id == id }
    }
    
    /// Purchase a StoreKit product
    @MainActor
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            // Handle the purchase
            await handlePurchase(productId: transaction.productID)
            
            await transaction.finish()
            return true
            
        case .userCancelled, .pending:
            return false
            
        @unknown default:
            return false
        }
    }
    
    /// Verify a transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let value):
            return value
        }
    }
    
    /// Handle a successful purchase
    @MainActor
    private func handlePurchase(productId: String) async {
        // Check if it's a coin package
        if let package = StoreManager.coinPackages.first(where: { $0.id == productId }) {
            addCoins(package.coins)
            return
        }
        
        // Check if it's a skin purchase
        if let skin = TankSkin.allSkins.first(where: { $0.iapProductId == productId }) {
            ownedSkinIds.insert(skin.id)
            saveUserData()
        }
    }
    
    /// Restore previous purchases
    @MainActor
    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                await handlePurchase(productId: transaction.productID)
            }
        }
    }
}

// MARK: - Store Errors

enum StoreError: Error {
    case verificationFailed
    case purchaseFailed
}
