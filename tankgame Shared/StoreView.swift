//
//  StoreView.swift
//  tankgame Shared
//
//  SwiftUI view for displaying and purchasing in-app products.
//

import SwiftUI
import StoreKit

// MARK: - Store View

/// Main store view displaying all available products
@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
struct StoreView: View {
    @ObservedObject var storeManager = StoreManager.shared
    @State private var purchaseInProgress: String?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Coin Balance Header
                    coinBalanceHeader
                    
                    // Loading State
                    if storeManager.isLoadingProducts {
                        loadingView
                    } else if let error = storeManager.loadError {
                        errorView(message: error)
                    } else {
                        // Coin Packs Section
                        if !storeManager.consumableProducts.isEmpty {
                            ProductSectionView(
                                title: "Coin Packs",
                                subtitle: "Spend coins on power-ups and upgrades",
                                products: storeManager.consumableProducts,
                                purchasedIDs: [],
                                purchaseInProgress: $purchaseInProgress,
                                onPurchase: purchaseProduct
                            )
                        }
                        
                        // Tank Skins Section
                        if !storeManager.nonConsumableProducts.isEmpty {
                            ProductSectionView(
                                title: "Tank Skins",
                                subtitle: "Customize your tank's appearance",
                                products: storeManager.nonConsumableProducts,
                                purchasedIDs: storeManager.purchasedProductIDs,
                                purchaseInProgress: $purchaseInProgress,
                                onPurchase: purchaseProduct
                            )
                        }
                        
                        // Restore Purchases Button
                        restorePurchasesButton
                    }
                }
                .padding()
            }
            .navigationTitle("Store")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var coinBalanceHeader: some View {
        HStack {
            Image(systemName: "dollarsign.circle.fill")
                .font(.title)
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading) {
                Text("Your Balance")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(storeManager.coinBalance) Coins")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading products...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Try Again") {
                Task {
                    await storeManager.loadProducts()
                }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var restorePurchasesButton: some View {
        Button {
            Task {
                await storeManager.restorePurchases()
                showAlert(title: "Restored", message: "Your purchases have been restored.")
            }
        } label: {
            Text("Restore Purchases")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(.top, 16)
    }
    
    // MARK: - Actions
    
    private func purchaseProduct(_ product: Product) {
        Task {
            purchaseInProgress = product.id
            
            let result = await storeManager.purchase(product)
            
            purchaseInProgress = nil
            
            switch result {
            case .success:
                if product.isConsumable {
                    showAlert(title: "Purchase Complete!", message: "Coins have been added to your balance.")
                } else {
                    showAlert(title: "Purchase Complete!", message: "Your new tank skin is now available.")
                }
                
            case .pending:
                showAlert(title: "Purchase Pending", message: "Your purchase is pending approval.")
                
            case .cancelled:
                // User cancelled, no alert needed
                break
                
            case .failed(let error):
                showAlert(title: "Purchase Failed", message: error.localizedDescription)
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

// MARK: - Product Section View

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
struct ProductSectionView: View {
    let title: String
    let subtitle: String
    let products: [Product]
    let purchasedIDs: Set<String>
    @Binding var purchaseInProgress: String?
    let onPurchase: (Product) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ForEach(products, id: \.id) { product in
                ProductRowView(
                    product: product,
                    isPurchased: purchasedIDs.contains(product.id),
                    isPurchasing: purchaseInProgress == product.id,
                    onPurchase: { onPurchase(product) }
                )
            }
        }
    }
}

// MARK: - Product Row View

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
struct ProductRowView: View {
    let product: Product
    let isPurchased: Bool
    let isPurchasing: Bool
    let onPurchase: () -> Void
    
    var body: some View {
        HStack {
            // Product Icon
            productIcon
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.displayName)
                    .font(.headline)
                
                Text(product.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Purchase Button
            purchaseButton
        }
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(12)
    }
    
    private var productIcon: some View {
        Group {
            if product.isConsumable {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
            } else {
                Image(systemName: "paintbrush.fill")
                    .font(.title)
                    .foregroundColor(skinColor(for: product.id))
            }
        }
        .frame(width: 44, height: 44)
    }
    
    @ViewBuilder
    private var purchaseButton: some View {
        if isPurchased {
            Text("Owned")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
        } else if isPurchasing {
            ProgressView()
                .frame(width: 60)
        } else {
            Button(action: onPurchase) {
                Text(product.displayPrice)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func skinColor(for productID: String) -> Color {
        switch productID {
        case StoreProductID.redTankSkin:
            return .red
        case StoreProductID.blueTankSkin:
            return .blue
        case StoreProductID.goldTankSkin:
            return .yellow
        case StoreProductID.camoTankSkin:
            return .green
        default:
            return .gray
        }
    }
}

// MARK: - Preview

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
    }
}
