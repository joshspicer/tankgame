//
//  GameViewControllerStoreHandlers.swift
//  tankgame iOS
//
//  Store button handling logic for GameViewController
//

import UIKit

/// Handles store-related actions for GameViewController
extension GameViewController {
    
    /// Setup the store UI and its callbacks
    func setupStore() {
        storeUI = StoreUI()
        storeUI.setup(in: view)
        
        storeUI.onCloseTapped = { [weak self] in
            self?.handleStoreClose()
        }
        
        storeUI.onRestoreTapped = { [weak self] in
            self?.handleRestorePurchases()
        }
        
        storeUI.onPurchaseTapped = { [weak self] product in
            self?.handlePurchase(product)
        }
        
        storeUI.onSelectTapped = { [weak self] product in
            self?.handleSelectSkin(product)
        }
    }
    
    /// Show the store UI
    func handleStoreTapped() {
        storeUI.show()
    }
    
    /// Hide the store UI
    func handleStoreClose() {
        storeUI.hide()
    }
    
    /// Handle restore purchases action
    func handleRestorePurchases() {
        Task { @MainActor in
            await StoreKitManager.shared.restorePurchases()
            storeUI.refreshProductStates()
            
            let alert = UIAlertController(
                title: "Restored",
                message: "Your purchases have been restored.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    /// Handle purchase action
    func handlePurchase(_ product: TankSkinProduct) {
        Task { @MainActor in
            let success = await StoreKitManager.shared.purchase(product)
            
            if success {
                storeUI.refreshProductStates()
                
                let alert = UIAlertController(
                    title: "Purchase Complete!",
                    message: "You've unlocked \(product.displayName)!",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        }
    }
    
    /// Handle skin selection
    func handleSelectSkin(_ product: TankSkinProduct?) {
        StoreKitManager.shared.selectSkin(product)
        storeUI.refreshProductStates()
        
        let skinName = product?.displayName ?? "Default"
        let alert = UIAlertController(
            title: "Skin Selected",
            message: "You are now using \(skinName) skin!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
