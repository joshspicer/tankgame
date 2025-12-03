//
//  StoreKitManager.swift
//  tankgame Shared
//
//  Handles in-app purchases using StoreKit 2
//

import Foundation
import StoreKit

/// Product identifiers for microtransaction items
enum StoreProduct: String, CaseIterable {
    case goldTankSkin = "com.tankgame.skin.gold"
    case rainbowTankSkin = "com.tankgame.skin.rainbow"
    case camo = "com.tankgame.skin.camo"
    case speedBoost = "com.tankgame.powerup.speed"
    case extraAmmo = "com.tankgame.powerup.ammo"
    case coinPack100 = "com.tankgame.coins.100"
    case coinPack500 = "com.tankgame.coins.500"
    case coinPack1000 = "com.tankgame.coins.1000"
    
    var displayName: String {
        switch self {
        case .goldTankSkin: return "Gold Tank Skin"
        case .rainbowTankSkin: return "Rainbow Tank Skin"
        case .camo: return "Camo Tank Skin"
        case .speedBoost: return "Speed Boost"
        case .extraAmmo: return "Extra Ammo Pack"
        case .coinPack100: return "100 Coins"
        case .coinPack500: return "500 Coins"
        case .coinPack1000: return "1000 Coins"
        }
    }
    
    var description: String {
        switch self {
        case .goldTankSkin: return "A luxurious golden tank skin"
        case .rainbowTankSkin: return "A dazzling rainbow animated skin"
        case .camo: return "A camouflage pattern skin"
        case .speedBoost: return "Move faster for 3 rounds"
        case .extraAmmo: return "Double your ammo capacity"
        case .coinPack100: return "Get 100 coins to spend"
        case .coinPack500: return "Get 500 coins (10% bonus)"
        case .coinPack1000: return "Get 1000 coins (25% bonus)"
        }
    }
    
    var emoji: String {
        switch self {
        case .goldTankSkin: return "🏆"
        case .rainbowTankSkin: return "🌈"
        case .camo: return "🌲"
        case .speedBoost: return "⚡️"
        case .extraAmmo: return "🎯"
        case .coinPack100: return "💰"
        case .coinPack500: return "💎"
        case .coinPack1000: return "👑"
        }
    }
}

/// Manages in-app purchases using StoreKit 2
@MainActor
class StoreKitManager: NSObject, ObservableObject {
    static let shared = StoreKitManager()
    
    /// Available products fetched from the App Store
    @Published private(set) var products: [Product] = []
    
    /// Products that have been purchased by the user
    @Published private(set) var purchasedProductIDs: Set<String> = []
    
    /// User's coin balance
    @Published var coinBalance: Int = 0
    
    /// Currently selected tank skin
    @Published var selectedTankSkin: StoreProduct?
    
    /// Active power-ups
    @Published var activePowerUps: Set<StoreProduct> = []
    
    /// Loading state
    @Published var isLoading: Bool = false
    
    /// Error message
    @Published var errorMessage: String?
    
    private var updateListenerTask: Task<Void, Error>?
    
    private override init() {
        super.init()
        loadPurchasedProducts()
        loadCoinBalance()
        loadSelectedSkin()
        
        // Start listening for transactions
        updateListenerTask = listenForTransactions()
        
        // Load products from App Store
        Task {
            await loadProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    /// Load products from the App Store
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let productIDs = StoreProduct.allCases.map { $0.rawValue }
            products = try await Product.products(for: productIDs)
            products.sort { $0.price < $1.price }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("Failed to load products: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Purchasing
    
    /// Purchase a product
    func purchase(_ product: Product) async throws -> Transaction? {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateCustomerProductStatus()
            await transaction.finish()
            
            // Handle consumable products (coins)
            handleConsumablePurchase(product: product)
            
            return transaction
            
        case .userCancelled:
            return nil
            
        case .pending:
            errorMessage = "Purchase is pending approval"
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    /// Purchase a product by its store product enum
    func purchase(_ storeProduct: StoreProduct) async throws -> Transaction? {
        guard let product = products.first(where: { $0.id == storeProduct.rawValue }) else {
            errorMessage = "Product not found"
            return nil
        }
        return try await purchase(product)
    }
    
    // MARK: - Transaction Handling
    
    /// Listen for transactions
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updateCustomerProductStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }
    
    /// Verify the transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    /// Update the customer's product status
    func updateCustomerProductStatus() async {
        var purchasedIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Only add non-consumable products to the purchased set
                if transaction.productType != .consumable {
                    purchasedIDs.insert(transaction.productID)
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        
        self.purchasedProductIDs = purchasedIDs
        savePurchasedProducts()
    }
    
    // MARK: - Consumable Handling
    
    /// Handle consumable purchase (coins)
    private func handleConsumablePurchase(product: Product) {
        guard let storeProduct = StoreProduct(rawValue: product.id) else { return }
        
        switch storeProduct {
        case .coinPack100:
            addCoins(100)
        case .coinPack500:
            addCoins(500)
        case .coinPack1000:
            addCoins(1000)
        default:
            break
        }
    }
    
    /// Add coins to balance
    func addCoins(_ amount: Int) {
        coinBalance += amount
        saveCoinBalance()
    }
    
    /// Spend coins
    func spendCoins(_ amount: Int) -> Bool {
        guard coinBalance >= amount else { return false }
        coinBalance -= amount
        saveCoinBalance()
        return true
    }
    
    // MARK: - Skin Selection
    
    /// Select a tank skin
    func selectSkin(_ skin: StoreProduct) {
        guard isPurchased(skin) || skin == .rainbowTankSkin else { return }
        selectedTankSkin = skin
        saveSelectedSkin()
    }
    
    /// Check if product is purchased
    func isPurchased(_ product: StoreProduct) -> Bool {
        return purchasedProductIDs.contains(product.rawValue)
    }
    
    // MARK: - Persistence
    
    private let purchasedProductsKey = "purchasedProducts"
    private let coinBalanceKey = "coinBalance"
    private let selectedSkinKey = "selectedTankSkin"
    
    private func savePurchasedProducts() {
        UserDefaults.standard.set(Array(purchasedProductIDs), forKey: purchasedProductsKey)
    }
    
    private func loadPurchasedProducts() {
        if let products = UserDefaults.standard.array(forKey: purchasedProductsKey) as? [String] {
            purchasedProductIDs = Set(products)
        }
    }
    
    private func saveCoinBalance() {
        UserDefaults.standard.set(coinBalance, forKey: coinBalanceKey)
    }
    
    private func loadCoinBalance() {
        coinBalance = UserDefaults.standard.integer(forKey: coinBalanceKey)
    }
    
    private func saveSelectedSkin() {
        UserDefaults.standard.set(selectedTankSkin?.rawValue, forKey: selectedSkinKey)
    }
    
    private func loadSelectedSkin() {
        if let skinRawValue = UserDefaults.standard.string(forKey: selectedSkinKey),
           let skin = StoreProduct(rawValue: skinRawValue) {
            selectedTankSkin = skin
        }
    }
    
    // MARK: - Restore Purchases
    
    /// Restore previous purchases
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            try await AppStore.sync()
            await updateCustomerProductStatus()
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            print("Failed to restore purchases: \(error)")
        }
    }
}

// MARK: - Store Errors

enum StoreError: Error {
    case failedVerification
    case productNotFound
    case purchaseFailed
}

extension StoreError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Purchase verification failed"
        case .productNotFound:
            return "Product not found in the store"
        case .purchaseFailed:
            return "Purchase failed"
        }
    }
}
