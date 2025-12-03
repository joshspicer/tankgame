//
//  TankPackStore.swift
//  tankgame Shared
//
//  StoreKit 2 integration for in-app purchases
//

import StoreKit

/// Handles in-app purchase operations for tank packs using StoreKit 2
@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
class TankPackStore: ObservableObject {
    /// Shared singleton instance
    static let shared = TankPackStore()
    
    /// Available products from the App Store
    @Published private(set) var products: [Product] = []
    
    /// Currently purchasing product ID
    @Published private(set) var purchasingProductID: String?
    
    /// Error message if something went wrong
    @Published var errorMessage: String?
    
    /// All product identifiers for tank packs
    private let productIDs: Set<String> = {
        Set(TankPack.allPacks.compactMap { $0.productID.isEmpty ? nil : $0.productID })
    }()
    
    /// Transaction listener task
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        // Start listening for transactions
        updateListenerTask = listenForTransactions()
        
        // Load products
        Task {
            await loadProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    /// Load products from the App Store
    @MainActor
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
            products.sort { $0.price < $1.price }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }
    
    /// Purchase a tank pack
    @MainActor
    func purchase(_ pack: TankPack) async -> Bool {
        guard !pack.productID.isEmpty else { return false }
        guard let product = products.first(where: { $0.id == pack.productID }) else {
            errorMessage = "Product not found"
            return false
        }
        
        purchasingProductID = pack.productID
        defer { purchasingProductID = nil }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                
                // Mark pack as purchased
                TankPackManager.shared.markPackAsPurchased(pack.id)
                
                // Finish the transaction
                await transaction.finish()
                
                // Post notification
                NotificationCenter.default.post(name: .tankPackPurchaseCompleted, object: pack.id)
                
                return true
                
            case .userCancelled:
                return false
                
            case .pending:
                errorMessage = "Purchase is pending approval"
                return false
                
            @unknown default:
                return false
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            return false
        }
    }
    
    /// Restore previous purchases
    @MainActor
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    if let pack = TankPack.allPacks.first(where: { $0.productID == transaction.productID }) {
                        TankPackManager.shared.markPackAsPurchased(pack.id)
                    }
                }
            }
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
        }
    }
    
    /// Get the product for a tank pack
    func product(for pack: TankPack) -> Product? {
        return products.first { $0.id == pack.productID }
    }
    
    /// Check if a product is currently being purchased
    func isPurchasing(_ pack: TankPack) -> Bool {
        return purchasingProductID == pack.productID
    }
    
    // MARK: - Private Methods
    
    /// Listen for transaction updates
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // Find the pack for this transaction
                    if let pack = TankPack.allPacks.first(where: { $0.productID == transaction.productID }) {
                        await MainActor.run {
                            TankPackManager.shared.markPackAsPurchased(pack.id)
                        }
                    }
                    
                    await transaction.finish()
                } catch {
                    // Transaction verification failed
                }
            }
        }
    }
    
    /// Verify a transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Store Errors

enum StoreError: Error {
    case failedVerification
    case productNotFound
    case purchaseFailed
}

// MARK: - Fallback for older iOS versions

/// A fallback store manager for older iOS versions that don't support StoreKit 2
class TankPackStoreLegacy {
    static let shared = TankPackStoreLegacy()
    
    private init() {}
    
    /// On older versions, only classic pack is available
    var isLegacyMode: Bool { true }
}
