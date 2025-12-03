//
//  StoreManager.swift
//  tankgame
//
//  StoreKit 2 implementation for in-app purchases
//

import Foundation
import StoreKit

/// Product identifiers for the tank game
enum ProductID: String, CaseIterable {
    case removeAds = "com.tankgame.removeads"
    case premiumSkinPack1 = "com.tankgame.skinpack.premium1"
    case premiumSkinPack2 = "com.tankgame.skinpack.premium2"
    case premiumSkinPackBundle = "com.tankgame.skinpack.bundle"
    
    /// Returns all product identifiers as strings
    static var allIdentifiers: [String] {
        allCases.map { $0.rawValue }
    }
}

/// Errors that can occur during store operations
enum StoreError: LocalizedError {
    case failedVerification
    case productNotFound
    case purchaseFailed(Error)
    case networkError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed(let error):
            return "Purchase failed: \(error.localizedDescription)"
        case .networkError:
            return "Network error occurred"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}

/// Purchase result for UI feedback
enum PurchaseResult {
    case success(Product)
    case userCancelled
    case pending
    case failed(StoreError)
}

/// Main store manager class using StoreKit 2
/// Observable for SwiftUI integration and delegate pattern for UIKit
@MainActor
final class StoreManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// All available products fetched from the App Store
    @Published private(set) var products: [Product] = []
    
    /// Currently purchased non-consumable product IDs
    @Published private(set) var purchasedProductIDs: Set<String> = []
    
    /// Loading state for UI
    @Published private(set) var isLoading: Bool = false
    
    /// Last error that occurred
    @Published private(set) var lastError: StoreError?
    
    // MARK: - Computed Properties
    
    /// Check if ads have been removed
    var hasRemovedAds: Bool {
        purchasedProductIDs.contains(ProductID.removeAds.rawValue)
    }
    
    /// Check if a specific skin pack is purchased
    func hasSkinPack(_ productID: ProductID) -> Bool {
        purchasedProductIDs.contains(productID.rawValue)
    }
    
    /// Get products by type
    var nonConsumableProducts: [Product] {
        products.filter { $0.type == .nonConsumable }
    }
    
    // MARK: - Private Properties
    
    /// Task that listens for transaction updates
    private var transactionListenerTask: Task<Void, Error>?
    
    /// Singleton instance
    static let shared = StoreManager()
    
    // MARK: - Initialization
    
    private init() {
        // Start listening for transactions immediately
        transactionListenerTask = listenForTransactions()
        
        // Fetch products and update purchase status
        Task {
            await fetchProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        transactionListenerTask?.cancel()
    }
    
    // MARK: - Transaction Listener
    
    /// Listen for transaction updates from the App Store
    /// This is critical for handling:
    /// - Transactions that complete while the app is not running
    /// - Ask to Buy transactions that are approved later
    /// - Subscription renewals
    /// - Refunds
    private func listenForTransactions() -> Task<Void, Error> {
        Task { [weak self] in
            // Iterate through any transactions that don't have a corresponding
            // call to `purchase()` (e.g., interrupted purchases, Ask to Buy)
            for await result in Transaction.updates {
                // Check if self is still alive
                guard let self = self else { return }
                
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // Update the purchased products
                    await self.updatePurchasedProducts()
                    
                    // Always finish a transaction after processing
                    await transaction.finish()
                    
                    // Post notification for any observers
                    NotificationCenter.default.post(
                        name: .transactionDidUpdate,
                        object: nil,
                        userInfo: ["productID": transaction.productID]
                    )
                } catch {
                    // Transaction failed verification, don't deliver content
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }
    
    // MARK: - Fetch Products
    
    /// Fetch all products from the App Store
    func fetchProducts() async {
        isLoading = true
        lastError = nil
        
        do {
            // Request products using the product identifiers
            let storeProducts = try await Product.products(for: ProductID.allIdentifiers)
            
            // Sort products by price for consistent display
            products = storeProducts.sorted { $0.price < $1.price }
            
            isLoading = false
        } catch {
            print("Failed to fetch products: \(error)")
            lastError = .networkError
            isLoading = false
        }
    }
    
    /// Get a specific product by ID
    func product(for id: ProductID) -> Product? {
        products.first { $0.id == id.rawValue }
    }
    
    // MARK: - Purchase
    
    /// Purchase a product
    /// - Parameter product: The product to purchase
    /// - Returns: The result of the purchase
    func purchase(_ product: Product) async -> PurchaseResult {
        isLoading = true
        lastError = nil
        
        do {
            // Begin a purchase
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Check whether the transaction is verified
                let transaction = try checkVerified(verification)
                
                // Update purchase status
                await updatePurchasedProducts()
                
                // Always finish a transaction
                await transaction.finish()
                
                isLoading = false
                return .success(product)
                
            case .userCancelled:
                isLoading = false
                return .userCancelled
                
            case .pending:
                // Transaction is pending (e.g., Ask to Buy)
                isLoading = false
                return .pending
                
            @unknown default:
                isLoading = false
                return .failed(.unknownError)
            }
        } catch StoreError.failedVerification {
            lastError = .failedVerification
            isLoading = false
            return .failed(.failedVerification)
        } catch {
            lastError = .purchaseFailed(error)
            isLoading = false
            return .failed(.purchaseFailed(error))
        }
    }
    
    /// Purchase a product by ID
    func purchase(_ productID: ProductID) async -> PurchaseResult {
        guard let product = product(for: productID) else {
            lastError = .productNotFound
            return .failed(.productNotFound)
        }
        return await purchase(product)
    }
    
    // MARK: - Restore Purchases
    
    /// Restore purchases for the current user
    /// This syncs the purchase state with the App Store
    func restorePurchases() async {
        isLoading = true
        lastError = nil
        
        do {
            // Sync with the App Store to get the latest transaction state
            try await AppStore.sync()
            await updatePurchasedProducts()
            isLoading = false
        } catch {
            print("Failed to restore purchases: \(error)")
            lastError = .networkError
            isLoading = false
        }
    }
    
    // MARK: - Update Purchase Status
    
    /// Update the set of purchased product IDs
    /// Checks the current entitlements for the user
    func updatePurchasedProducts() async {
        var purchased = Set<String>()
        
        // Iterate through all the user's purchased products
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Check if the transaction is still valid
                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                }
            } catch {
                // Transaction failed verification
                print("Transaction failed verification: \(error)")
            }
        }
        
        purchasedProductIDs = purchased
        
        // Persist purchase state to UserDefaults for offline access
        savePurchaseState()
    }
    
    // MARK: - Verification
    
    /// Verify a transaction using StoreKit's built-in verification
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            // StoreKit verification failed - don't deliver content
            throw StoreError.failedVerification
        case .verified(let safe):
            // Transaction is verified
            return safe
        }
    }
    
    // MARK: - Persistence
    
    private let purchaseStateKey = "com.tankgame.purchaseState"
    
    /// Save purchase state to UserDefaults for offline access
    private func savePurchaseState() {
        UserDefaults.standard.set(Array(purchasedProductIDs), forKey: purchaseStateKey)
    }
    
    /// Load cached purchase state (for quick UI updates before server sync)
    func loadCachedPurchaseState() {
        if let cached = UserDefaults.standard.stringArray(forKey: purchaseStateKey) {
            purchasedProductIDs = Set(cached)
        }
    }
    
    // MARK: - Product Information Helpers
    
    /// Get the localized price string for a product
    func priceString(for product: Product) -> String {
        product.displayPrice
    }
    
    /// Check if a product is purchased
    func isPurchased(_ productID: ProductID) -> Bool {
        purchasedProductIDs.contains(productID.rawValue)
    }
    
    /// Check if a product is purchased by string ID
    func isPurchased(_ productID: String) -> Bool {
        purchasedProductIDs.contains(productID)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    /// Posted when a transaction is updated
    static let transactionDidUpdate = Notification.Name("StoreManager.transactionDidUpdate")
}

// MARK: - Product Extensions

extension Product {
    /// Check if this product is a skin pack
    var isSkinPack: Bool {
        id.contains("skinpack")
    }
    
    /// Check if this is the remove ads product
    var isRemoveAds: Bool {
        id == ProductID.removeAds.rawValue
    }
}
