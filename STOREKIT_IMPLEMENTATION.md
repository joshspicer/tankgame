# StoreKit 2 In-App Purchases Implementation Guide

This guide explains how to use the StoreKit 2 implementation in the Tank Game project.

## Overview

The implementation consists of the following components:

1. **StoreManager** - Core class handling product fetching, purchases, and transaction listening
2. **EntitlementManager** - Manages user entitlements based on purchases
3. **StoreView** - SwiftUI view for displaying the store interface
4. **StoreViewController** - UIKit wrapper for iOS integration
5. **StoreKitConfig.storekit** - Configuration file for testing in Xcode

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        App Layer                            │
│  ┌─────────────┐    ┌──────────────────┐                   │
│  │  StoreView  │    │ StoreViewController│                  │
│  │  (SwiftUI)  │    │    (UIKit)        │                  │
│  └──────┬──────┘    └────────┬─────────┘                   │
│         │                    │                              │
│         └─────────┬──────────┘                              │
│                   │                                         │
│         ┌─────────▼─────────┐                               │
│         │  StoreManager     │                               │
│         │  (Singleton)      │                               │
│         └─────────┬─────────┘                               │
│                   │                                         │
│         ┌─────────▼─────────┐                               │
│         │EntitlementManager │                               │
│         │  (Singleton)      │                               │
│         └───────────────────┘                               │
└─────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    StoreKit 2 APIs                          │
│  • Product.products(for:)                                   │
│  • Product.purchase()                                       │
│  • Transaction.updates                                      │
│  • Transaction.currentEntitlements                          │
│  • AppStore.sync()                                          │
└─────────────────────────────────────────────────────────────┘
```

## Product Configuration

### Product IDs

Define your product IDs in `ProductID` enum:

```swift
enum ProductID: String, CaseIterable {
    case removeAds = "com.tankgame.removeads"
    case premiumSkinPack1 = "com.tankgame.skinpack.premium1"
    case premiumSkinPack2 = "com.tankgame.skinpack.premium2"
    case premiumSkinPackBundle = "com.tankgame.skinpack.bundle"
}
```

### App Store Connect Setup

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to your app → Features → In-App Purchases
3. Create new in-app purchases matching the product IDs
4. For non-consumable products (like Remove Ads), ensure "Family Sharing" is configured appropriately

## Usage

### Initializing the Store

The `StoreManager` is a singleton that initializes automatically:

```swift
// Access the shared instance
let storeManager = StoreManager.shared

// Products are fetched automatically on init
// You can also manually refresh:
Task {
    await storeManager.fetchProducts()
}
```

### Displaying Products

```swift
// In SwiftUI
@ObservedObject private var storeManager = StoreManager.shared

var body: some View {
    ForEach(storeManager.products, id: \.id) { product in
        HStack {
            Text(product.displayName)
            Spacer()
            Text(product.displayPrice)
        }
    }
}
```

### Making a Purchase

```swift
// Purchase by product
let result = await storeManager.purchase(product)

// Or purchase by ID
let result = await storeManager.purchase(.removeAds)

// Handle the result
switch result {
case .success(let product):
    print("Successfully purchased \(product.displayName)")
case .userCancelled:
    print("User cancelled")
case .pending:
    print("Purchase pending (Ask to Buy)")
case .failed(let error):
    print("Purchase failed: \(error.localizedDescription)")
}
```

### Checking Entitlements

```swift
// Check if ads are removed
if storeManager.hasRemovedAds {
    // Hide ads
}

// Check specific product
if storeManager.isPurchased(.premiumSkinPack1) {
    // Unlock skin pack 1
}

// Using EntitlementManager for game content
let entitlementManager = EntitlementManager.shared

if entitlementManager.isSkinUnlocked("desert_camo") {
    // Allow skin selection
}
```

### Restoring Purchases

```swift
// Restore purchases (syncs with App Store)
await storeManager.restorePurchases()
```

### Listening for Transaction Updates

The `StoreManager` automatically listens for transaction updates. You can also subscribe to notifications:

```swift
NotificationCenter.default.addObserver(
    forName: .transactionDidUpdate,
    object: nil,
    queue: .main
) { notification in
    if let productID = notification.userInfo?["productID"] as? String {
        print("Transaction updated for: \(productID)")
    }
}
```

## UIKit Integration

### Presenting the Store

```swift
// From any UIViewController
presentStore { 
    // Called when store is dismissed
    print("Store closed")
}
```

### Adding a Store Button

```swift
let storeButton = StoreButton()
view.addSubview(storeButton)
// Configure constraints...
```

## Testing with StoreKit Configuration

### Setting Up the Configuration File

1. Open `Configuration/StoreKitConfig.storekit` in Xcode
2. The file contains pre-configured products for testing

> **Note:** The `_applicationInternalID` and `_developerTeamID` values in the configuration file are placeholders. For production testing with sandbox accounts, update these values with your actual App Store Connect application ID and developer team ID.

### Enabling Local Testing in Xcode

1. Edit your scheme (Product → Scheme → Edit Scheme)
2. Select "Run" in the left sidebar
3. Go to "Options" tab
4. Under "StoreKit Configuration", select `StoreKitConfig.storekit`

### Testing Scenarios

The StoreKit configuration allows you to test:

- **Normal purchases**: Complete purchases without real money
- **Transaction failures**: Enable errors in the configuration to test error handling
- **Ask to Buy**: Test deferred transactions
- **Refunds**: Test revoked purchases
- **Interrupted purchases**: Test purchases that complete later

### Clearing Test Data

In Xcode's Debug menu → StoreKit → Manage Transactions, you can:
- View all test transactions
- Delete transactions to reset state
- Refund transactions

## Best Practices

### 1. Always Finish Transactions

```swift
// Good - Always finish after processing
let transaction = try checkVerified(verification)
await deliverContent(for: transaction)
await transaction.finish()
```

### 2. Handle Verification Failures

```swift
switch result {
case .verified(let transaction):
    // Safe to deliver content
    break
case .unverified:
    // Don't deliver content
    throw StoreError.failedVerification
}
```

### 3. Persist Purchase State

Cache purchase state for offline access:

```swift
// Save on purchase
UserDefaults.standard.set(Array(purchasedProductIDs), forKey: purchaseStateKey)

// Load on app launch for quick UI updates
if let cached = UserDefaults.standard.stringArray(forKey: purchaseStateKey) {
    purchasedProductIDs = Set(cached)
}

// Then verify with App Store
await updatePurchasedProducts()
```

### 4. Start Transaction Listener Early

Initialize `StoreManager` early in your app lifecycle to catch pending transactions:

```swift
// In AppDelegate or early in app launch
_ = StoreManager.shared
```

### 5. Handle All Purchase States

```swift
switch result {
case .success(let verification):
    // Verify and deliver
    break
case .userCancelled:
    // User cancelled - no error message needed
    break
case .pending:
    // Ask to Buy - inform user
    showPendingMessage()
    break
@unknown default:
    // Handle future cases
    break
}
```

## Troubleshooting

### Products Not Loading

1. Verify product IDs match exactly with App Store Connect
2. Check network connection
3. Ensure StoreKit configuration is selected in scheme
4. Verify your app's bundle ID matches

### Purchases Not Persisting

1. Ensure `transaction.finish()` is called
2. Verify `updatePurchasedProducts()` is called after purchase
3. Check `Transaction.currentEntitlements` is properly iterated

### Transaction Listener Not Working

1. Ensure `listenForTransactions()` is started early
2. Don't cancel the task prematurely
3. Check for verification errors in the listener

## Migration from StoreKit 1

If migrating from StoreKit 1, note these key differences:

| StoreKit 1 | StoreKit 2 |
|------------|------------|
| `SKProductsRequest` | `Product.products(for:)` |
| `SKPaymentQueue` | `product.purchase()` |
| `SKPaymentTransactionObserver` | `Transaction.updates` |
| `finishTransaction(_:)` | `transaction.finish()` |
| `restoreCompletedTransactions()` | `AppStore.sync()` |
| Receipt validation (manual) | `VerificationResult` (automatic) |

## Platform Support

This implementation supports:
- iOS 15.0+
- macOS 12.0+
- tvOS 15.0+
- watchOS 8.0+

All platforms use the same `StoreManager` and `EntitlementManager` classes. Platform-specific UI is provided via:
- SwiftUI `StoreView` (all platforms)
- UIKit `StoreViewController` (iOS/tvOS)

## Security Considerations

1. **Transaction verification** is handled automatically by StoreKit 2
2. **Never trust client-side** purchase state alone for critical features
3. **Server-side validation** is recommended for high-value purchases
4. **App attestation** can be added for additional security

## File Structure

```
tankgame/
├── Configuration/
│   └── StoreKitConfig.storekit    # Testing configuration
├── tankgame Shared/
│   └── Store/
│       ├── StoreManager.swift      # Core purchase logic
│       ├── StoreView.swift         # SwiftUI store UI
│       └── EntitlementManager.swift # Content unlocking
└── tankgame iOS/
    └── StoreViewController.swift   # UIKit wrapper
```
