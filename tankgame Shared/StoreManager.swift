//
//  StoreManager.swift
//  tankgame Shared
//
//  Manages StoreKit 2 in-app purchases for the tank game.
//

import Foundation
import StoreKit

// MARK: - Product Identifiers

/// Product identifiers for the Tank Game store
enum StoreProductID {
    // MARK: Consumables
    static let smallCoinPack = "com.tankgame.coins.small"      // 100 coins
    static let mediumCoinPack = "com.tankgame.coins.medium"    // 500 coins
    static let largeCoinPack = "com.tankgame.coins.large"      // 1200 coins
    
    // MARK: Non-Consumables (Tank Skins)
    static let redTankSkin = "com.tankgame.skin.red"
    static let blueTankSkin = "com.tankgame.skin.blue"
    static let goldTankSkin = "com.tankgame.skin.gold"
    static let camoTankSkin = "com.tankgame.skin.camo"
    
    /// All product identifiers
    static var allProducts: Set<String> {
        [
            smallCoinPack,
            mediumCoinPack,
            largeCoinPack,
            redTankSkin,
            blueTankSkin,
            goldTankSkin,
            camoTankSkin
        ]
    }
    
    /// Consumable product identifiers
    static var consumables: Set<String> {
        [smallCoinPack, mediumCoinPack, largeCoinPack]
    }
    
    /// Non-consumable product identifiers
    static var nonConsumables: Set<String> {
        [redTankSkin, blueTankSkin, goldTankSkin, camoTankSkin]
    }
}

// MARK: - Purchase Error

/// Errors that can occur during purchase operations
enum StoreError: LocalizedError {
    case productNotFound
    case purchaseFailed
    case verificationFailed
    case userCancelled
    case pending
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "The requested product could not be found."
        case .purchaseFailed:
            return "The purchase could not be completed."
        case .verificationFailed:
            return "The purchase could not be verified."
        case .userCancelled:
            return "The purchase was cancelled."
        case .pending:
            return "The purchase is pending approval."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

// MARK: - Purchase Result

/// Result of a purchase operation
enum PurchaseResult {
    case success(productID: String)
    case pending
    case cancelled
    case failed(Error)
}

// MARK: - Store Manager

/// Manages StoreKit 2 in-app purchases for the Tank Game
@MainActor
final class StoreManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Available products loaded from the App Store
    @Published private(set) var products: [Product] = []
    
    /// Consumable products (coin packs)
    @Published private(set) var consumableProducts: [Product] = []
    
    /// Non-consumable products (tank skins)
    @Published private(set) var nonConsumableProducts: [Product] = []
    
    /// Set of purchased non-consumable product IDs (entitlements)
    @Published private(set) var purchasedProductIDs: Set<String> = []
    
    /// Current coin balance for the player
    @Published var coinBalance: Int = 0
    
    /// Loading state for products
    @Published private(set) var isLoadingProducts: Bool = false
    
    /// Error message if product loading fails
    @Published private(set) var loadError: String?
    
    // MARK: - Private Properties
    
    /// Task for listening to transaction updates
    private var transactionListener: Task<Void, Never>?
    
    /// UserDefaults keys
    private enum UserDefaultsKey {
        static let coinBalance = "tankgame.coinBalance"
        static let purchasedProducts = "tankgame.purchasedProducts"
    }
    
    // MARK: - Singleton
    
    /// Shared instance of the StoreManager
    static let shared = StoreManager()
    
    // MARK: - Initialization
    
    private init() {
        // Load saved state
        loadSavedState()
        
        // Start listening for transaction updates
        transactionListener = listenForTransactionUpdates()
        
        // Load products on init
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    // MARK: - Product Loading
    
    /// Load products from the App Store
    func loadProducts() async {
        isLoadingProducts = true
        loadError = nil
        
        do {
            let loadedProducts = try await Product.products(for: StoreProductID.allProducts)
            
            // Sort products by price
            products = loadedProducts.sorted { $0.price < $1.price }
            
            // Separate consumables and non-consumables
            consumableProducts = products.filter { StoreProductID.consumables.contains($0.id) }
                .sorted { $0.price < $1.price }
            nonConsumableProducts = products.filter { StoreProductID.nonConsumables.contains($0.id) }
                .sorted { $0.price < $1.price }
            
            isLoadingProducts = false
        } catch {
            loadError = "Failed to load products: \(error.localizedDescription)"
            isLoadingProducts = false
        }
    }
    
    /// Get a specific product by ID
    func product(for productID: String) -> Product? {
        products.first { $0.id == productID }
    }
    
    // MARK: - Purchasing
    
    /// Purchase a product
    /// - Parameter product: The product to purchase
    /// - Returns: Result of the purchase operation
    func purchase(_ product: Product) async -> PurchaseResult {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerification(verification)
                
                // Handle the purchase based on product type
                await handlePurchase(transaction: transaction)
                
                // Always finish the transaction
                await transaction.finish()
                
                return .success(productID: product.id)
                
            case .userCancelled:
                return .cancelled
                
            case .pending:
                return .pending
                
            @unknown default:
                return .failed(StoreError.unknown)
            }
        } catch {
            return .failed(error)
        }
    }
    
    /// Purchase a product by its ID
    /// - Parameter productID: The product ID to purchase
    /// - Returns: Result of the purchase operation
    func purchase(productID: String) async -> PurchaseResult {
        guard let product = product(for: productID) else {
            return .failed(StoreError.productNotFound)
        }
        return await purchase(product)
    }
    
    // MARK: - Transaction Verification
    
    /// Verify a transaction
    /// - Parameter result: The verification result to check
    /// - Returns: The verified transaction
    /// - Throws: StoreError.verificationFailed if verification fails
    private func checkVerification<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw StoreError.verificationFailed
        }
    }
    
    // MARK: - Transaction Handling
    
    /// Handle a verified purchase transaction
    /// - Parameter transaction: The verified transaction
    private func handlePurchase(transaction: Transaction) async {
        let productID = transaction.productID
        
        if StoreProductID.consumables.contains(productID) {
            // Handle consumable purchase
            await handleConsumablePurchase(productID: productID)
        } else if StoreProductID.nonConsumables.contains(productID) {
            // Handle non-consumable purchase
            await handleNonConsumablePurchase(productID: productID)
        }
    }
    
    /// Handle a consumable purchase (coins)
    /// - Parameter productID: The consumable product ID
    private func handleConsumablePurchase(productID: String) async {
        let coinsToAdd: Int
        
        switch productID {
        case StoreProductID.smallCoinPack:
            coinsToAdd = 100
        case StoreProductID.mediumCoinPack:
            coinsToAdd = 500
        case StoreProductID.largeCoinPack:
            coinsToAdd = 1200
        default:
            coinsToAdd = 0
        }
        
        addCoins(coinsToAdd)
    }
    
    /// Handle a non-consumable purchase (skin)
    /// - Parameter productID: The non-consumable product ID
    private func handleNonConsumablePurchase(productID: String) async {
        purchasedProductIDs.insert(productID)
        savePurchasedProducts()
    }
    
    // MARK: - Transaction Updates Listener
    
    /// Listen for transaction updates (e.g., purchases from another device)
    /// - Returns: A task that listens for updates
    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                do {
                    guard let self = self else { return }
                    let transaction = try self.checkVerificationAsync(result)
                    await self.handleTransactionUpdate(transaction)
                } catch {
                    // Transaction verification failed, ignore
                }
            }
        }
    }
    
    /// Handle transaction update from listener
    /// - Parameter transaction: The verified transaction to handle
    private func handleTransactionUpdate(_ transaction: Transaction) async {
        await handlePurchase(transaction: transaction)
        await transaction.finish()
    }
    
    /// Async version of verification check for use in detached task
    private nonisolated func checkVerificationAsync<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw StoreError.verificationFailed
        }
    }
    
    // MARK: - Entitlements
    
    /// Refresh entitlements from the App Store
    /// This checks for non-consumable purchases and active subscriptions
    func refreshEntitlements() async {
        var entitlements: Set<String> = []
        
        // Iterate through current entitlements
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerification(result)
                
                // Only track non-consumable entitlements
                if StoreProductID.nonConsumables.contains(transaction.productID) {
                    entitlements.insert(transaction.productID)
                }
            } catch {
                // Verification failed, skip this transaction
            }
        }
        
        purchasedProductIDs = entitlements
        savePurchasedProducts()
    }
    
    /// Check if a non-consumable product has been purchased
    /// - Parameter productID: The product ID to check
    /// - Returns: True if the product has been purchased
    func isPurchased(_ productID: String) -> Bool {
        purchasedProductIDs.contains(productID)
    }
    
    /// Restore purchases
    /// This is mainly for non-consumables and subscriptions
    func restorePurchases() async {
        await refreshEntitlements()
    }
    
    // MARK: - Coin Management
    
    /// Add coins to the player's balance
    /// - Parameter amount: Number of coins to add
    func addCoins(_ amount: Int) {
        coinBalance += amount
        saveCoinBalance()
    }
    
    /// Spend coins from the player's balance
    /// - Parameter amount: Number of coins to spend
    /// - Returns: True if the coins were successfully spent
    @discardableResult
    func spendCoins(_ amount: Int) -> Bool {
        guard coinBalance >= amount else { return false }
        coinBalance -= amount
        saveCoinBalance()
        return true
    }
    
    /// Check if the player can afford a certain amount
    /// - Parameter amount: Number of coins to check
    /// - Returns: True if the player has enough coins
    func canAfford(_ amount: Int) -> Bool {
        coinBalance >= amount
    }
    
    // MARK: - Persistence
    
    /// Load saved state from UserDefaults
    private func loadSavedState() {
        coinBalance = UserDefaults.standard.integer(forKey: UserDefaultsKey.coinBalance)
        
        if let savedProducts = UserDefaults.standard.array(forKey: UserDefaultsKey.purchasedProducts) as? [String] {
            purchasedProductIDs = Set(savedProducts)
        }
    }
    
    /// Save coin balance to UserDefaults
    private func saveCoinBalance() {
        UserDefaults.standard.set(coinBalance, forKey: UserDefaultsKey.coinBalance)
    }
    
    /// Save purchased products to UserDefaults
    private func savePurchasedProducts() {
        UserDefaults.standard.set(Array(purchasedProductIDs), forKey: UserDefaultsKey.purchasedProducts)
    }
    
    // MARK: - Convenience Methods
    
    /// Get all available tank skins (including purchased ones)
    func availableTankSkins() -> [Product] {
        nonConsumableProducts
    }
    
    /// Get only purchased tank skins
    func purchasedTankSkins() -> [Product] {
        nonConsumableProducts.filter { isPurchased($0.id) }
    }
    
    /// Get coin packs sorted by value
    func coinPacks() -> [Product] {
        consumableProducts
    }
}

// MARK: - Product Extensions

extension Product {
    /// Check if this product is a consumable
    var isConsumable: Bool {
        StoreProductID.consumables.contains(self.id)
    }
    
    /// Check if this product is a non-consumable
    var isNonConsumable: Bool {
        StoreProductID.nonConsumables.contains(self.id)
    }
}

// MARK: - StoreKit Configuration File Products
/*
 To test in-app purchases during development, create a StoreKit Configuration File
 in Xcode with the following products:
 
 Consumables:
 - com.tankgame.coins.small (100 Coins - $0.99)
 - com.tankgame.coins.medium (500 Coins - $3.99)
 - com.tankgame.coins.large (1200 Coins - $7.99)
 
 Non-Consumables:
 - com.tankgame.skin.red (Red Tank Skin - $1.99)
 - com.tankgame.skin.blue (Blue Tank Skin - $1.99)
 - com.tankgame.skin.gold (Gold Tank Skin - $4.99)
 - com.tankgame.skin.camo (Camo Tank Skin - $2.99)
 */
