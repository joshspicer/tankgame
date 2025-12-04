//
//  GameViewControllerStoreHandlers.swift
//  tankgame iOS
//
//  Store handling logic for GameViewController
//

import UIKit

/// Handles store-related functionality for GameViewController
extension GameViewController {
    
    func setupStore() {
        storeUI = StoreUI()
        storeUI.setup(in: view)
        
        storeUI.onCloseTapped = { [weak self] in
            self?.storeUI.hide()
            self?.lobbyUI.updateCoinsDisplay()
        }
        
        storeUI.onSkinSelected = { [weak self] skin in
            StoreManager.shared.selectSkin(skin.id)
            self?.storeUI.refreshSkinCards()
        }
        
        storeUI.onSkinPurchased = { [weak self] skin in
            self?.handleSkinPurchase(skin)
        }
        
        storeUI.onCoinPackageTapped = { [weak self] packageId in
            self?.handleCoinPackagePurchase(packageId)
        }
    }
    
    func handleStoreTapped() {
        storeUI.show()
    }
    
    func handleSkinPurchase(_ skin: TankSkin) {
        let storeManager = StoreManager.shared
        
        if storeManager.coins < skin.price {
            let alert = UIAlertController(
                title: "Not Enough Coins",
                message: "You need \(skin.price) TankCoins to purchase this skin.\n\nYou have: \(storeManager.coins) TankCoins",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Get Coins", style: .default) { [weak self] _ in
                // Scroll to coins section (handled by UI)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        let alert = UIAlertController(
            title: "Purchase \(skin.name)?",
            message: "This will cost \(skin.price) TankCoins.\n\n\(skin.description)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Buy", style: .default) { [weak self] _ in
            let result = storeManager.purchaseSkin(skin)
            switch result {
            case .success:
                self?.storeUI.refreshSkinCards()
                self?.showPurchaseSuccess(skin.name)
            case .alreadyOwned:
                self?.storeUI.refreshSkinCards()
            case .insufficientFunds:
                break // Should not happen since we checked above
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func handleCoinPackagePurchase(_ packageId: String) {
        // TODO: Implement real StoreKit purchase flow for production
        // This demo mode should be removed before App Store submission
        // Real implementation requires App Store Connect product configuration
        guard let package = StoreManager.coinPackages.first(where: { $0.id == packageId }) else { return }
        
        let alert = UIAlertController(
            title: "Purchase \(package.coins) TankCoins?",
            message: "This will cost \(package.price) (In-App Purchase)\n\nNote: StoreKit integration requires App Store Connect setup.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Buy (Demo)", style: .default) { [weak self] _ in
            // Demo mode: give coins for free
            StoreManager.shared.addCoins(package.coins)
            self?.storeUI.updateCoinsDisplay()
            self?.showPurchaseSuccess("\(package.coins) TankCoins")
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func showPurchaseSuccess(_ itemName: String) {
        let alert = UIAlertController(
            title: "Purchase Successful! 🎉",
            message: "You now own \(itemName)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
