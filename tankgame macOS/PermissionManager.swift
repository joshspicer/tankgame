//
//  PermissionManager.swift
//  tankgame macOS
//
//  Created by jospicer on 10/28/25.
//

import Cocoa
import Network

/// Manages permission requests for local network on macOS
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
            // This will cause macOS to show the Local Network permission dialog
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self, let manager = self.multiplayerManager else { return }
                
                // Start browsing to trigger Local Network permission
                manager.startBrowsing()
                
                // Start hosting
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
    static func showPermissionDeniedAlert(on viewController: NSViewController) {
        let alert = NSAlert()
        alert.messageText = "Local Network Access Required"
        alert.informativeText = "Tank Game needs Local Network access to find and connect with nearby players.\n\nTo enable:\n1. Open System Settings\n2. Go to Privacy & Security → Local Network\n3. Find Tank Game and turn it ON\n4. Return here and try again"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Open System Settings")
        
        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            // Open System Settings to Privacy & Security
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}
