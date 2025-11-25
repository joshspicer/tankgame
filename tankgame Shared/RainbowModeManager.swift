//
//  RainbowModeManager.swift
//  tankgame Shared
//
//  Manages the rainbow mode state across the game
//

import Foundation

/// Singleton manager for rainbow mode state
class RainbowModeManager {
    
    /// Shared instance
    static let shared = RainbowModeManager()
    
    /// UserDefaults key for storing rainbow mode preference
    private let rainbowModeKey = "rainbowModeEnabled"
    
    /// Whether rainbow mode is currently enabled
    var isEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: rainbowModeKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: rainbowModeKey)
            NotificationCenter.default.post(name: .rainbowModeChanged, object: nil)
        }
    }
    
    private init() {}
    
    /// Toggle rainbow mode on/off
    func toggle() {
        isEnabled = !isEnabled
    }
}

/// Notification name for rainbow mode changes
extension Notification.Name {
    static let rainbowModeChanged = Notification.Name("rainbowModeChanged")
}
