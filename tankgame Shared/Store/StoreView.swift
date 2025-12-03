//
//  StoreView.swift
//  tankgame
//
//  SwiftUI view for displaying in-app purchases
//

import SwiftUI
import StoreKit

/// Main store view for displaying purchasable products
struct StoreView: View {
    @ObservedObject private var storeManager = StoreManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if storeManager.isLoading && storeManager.products.isEmpty {
                    loadingView
                } else if storeManager.products.isEmpty {
                    emptyView
                } else {
                    productListView
                }
            }
            .navigationTitle("Store")
            #if os(iOS) || os(tvOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Restore") {
                        Task {
                            await storeManager.restorePurchases()
                        }
                    }
                    .disabled(storeManager.isLoading)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading products...")
                .foregroundColor(.secondary)
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No products available")
                .font(.headline)
            Text("Please check your connection and try again.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Retry") {
                Task {
                    await storeManager.fetchProducts()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
    }
    
    private var productListView: some View {
        List {
            // Remove Ads Section
            Section {
                ForEach(storeManager.products.filter { $0.isRemoveAds }, id: \.id) { product in
                    ProductRowView(product: product)
                }
            } header: {
                Text("Premium Features")
            } footer: {
                Text("Remove all advertisements from the game permanently.")
            }
            
            // Skin Packs Section
            Section {
                ForEach(storeManager.products.filter { $0.isSkinPack }, id: \.id) { product in
                    ProductRowView(product: product)
                }
            } header: {
                Text("Tank Skins")
            } footer: {
                Text("Customize your tank with premium skins.")
            }
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #endif
        .refreshable {
            await storeManager.fetchProducts()
        }
        .overlay {
            if storeManager.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
    }
}

/// Row view for a single product
struct ProductRowView: View {
    let product: Product
    @ObservedObject private var storeManager = StoreManager.shared
    @State private var showingPurchaseAlert = false
    @State private var purchaseMessage = ""
    
    private var isPurchased: Bool {
        storeManager.isPurchased(product.id)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Product icon
            productIcon
            
            // Product info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.displayName)
                    .font(.headline)
                
                Text(product.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Purchase button or purchased indicator
            purchaseButton
        }
        .padding(.vertical, 8)
        .alert("Purchase", isPresented: $showingPurchaseAlert) {
            Button("OK") { }
        } message: {
            Text(purchaseMessage)
        }
    }
    
    @ViewBuilder
    private var productIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(iconBackgroundColor)
                .frame(width: 50, height: 50)
            
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(.white)
        }
    }
    
    private var iconName: String {
        if product.isRemoveAds {
            return "xmark.circle.fill"
        } else if product.isSkinPack {
            return "paintbrush.fill"
        } else {
            return "star.fill"
        }
    }
    
    private var iconBackgroundColor: Color {
        if product.isRemoveAds {
            return .blue
        } else if product.isSkinPack {
            return .purple
        } else {
            return .orange
        }
    }
    
    @ViewBuilder
    private var purchaseButton: some View {
        if isPurchased {
            Label("Purchased", systemImage: "checkmark.circle.fill")
                .font(.subheadline)
                .foregroundColor(.green)
        } else {
            Button {
                Task {
                    await purchaseProduct()
                }
            } label: {
                Text(product.displayPrice)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .disabled(storeManager.isLoading)
        }
    }
    
    private func purchaseProduct() async {
        let result = await storeManager.purchase(product)
        
        switch result {
        case .success:
            purchaseMessage = "Thank you for your purchase!"
            showingPurchaseAlert = true
        case .userCancelled:
            // No message for user cancellation
            break
        case .pending:
            purchaseMessage = "Your purchase is pending approval."
            showingPurchaseAlert = true
        case .failed(let error):
            purchaseMessage = error.localizedDescription
            showingPurchaseAlert = true
        }
    }
}

// MARK: - Preview

#Preview {
    StoreView()
}
