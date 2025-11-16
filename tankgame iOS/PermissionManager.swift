//
//  PermissionManager.swift
//  tankgame iOS
//
//  Created by jospicer on 10/28/25.
//

import UIKit

/// Manages permission requests for local network and Bluetooth
class PermissionManager {
    private weak var multiplayerManager: MultiplayerManager?
    private var isRequestingPermissions = false
    
    init(multiplayerManager: MultiplayerManager) {
        self.multiplayerManager = multiplayerManager
    }
    
    /// Request permissions if needed on first launch
    func requestPermissionsIfNeeded() {
        // Check if we've already requested permissions
        let hasRequestedPermissions = UserDefaults.standard.bool(forKey: "tankgame.hasRequestedPermissions")
        
        if !hasRequestedPermissions {
            // Mark that we're requesting permissions
            UserDefaults.standard.set(true, forKey: "tankgame.hasRequestedPermissions")
            isRequestingPermissions = true
            
            // Trigger permission prompts by briefly starting and stopping browsing/advertising
            // This will cause iOS to show the Local Network and Bluetooth permission dialogs
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self, let manager = self.multiplayerManager else { return }
                
                // Start browsing to trigger Local Network permission
                manager.startBrowsing()
                
                // Start hosting to trigger Bluetooth permission
                manager.startHosting()
                
                // Stop after a short delay to allow the permission dialogs to appear
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.multiplayerManager?.stopBrowsing()
                    self?.multiplayerManager?.stopHosting()
                    self?.isRequestingPermissions = false
                }
            }
        }
    }
    
    /// Check if currently requesting permissions
    var isRequesting: Bool {
        return isRequestingPermissions
    }
    
    /// Show alert for permission denial
    static func showPermissionDeniedAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Local Network Access Required",
            message: "Tank Game needs Local Network access to find and connect with nearby players.\n\nTo enable:\n1. Open Settings app\n2. Go to Privacy & Security → Local Network\n3. Find Tank Game and turn it ON\n4. Return here and try again",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        viewController.present(alert, animated: true)
    }
}
