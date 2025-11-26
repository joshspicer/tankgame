//
//  RainbowModeSettings.swift
//  tankgame Shared
//
//  Manages the rainbow mode setting for the game
//

import Foundation

/// Singleton to manage rainbow mode settings
class RainbowModeSettings {
    
    /// Shared singleton instance
    static let shared = RainbowModeSettings()
    
    /// Key for storing the rainbow mode preference in UserDefaults
    private let rainbowModeKey = "rainbowModeEnabled"
    
    /// Whether rainbow mode is enabled
    var isEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: rainbowModeKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: rainbowModeKey)
        }
    }
    
    private init() {
        // Register default value - rainbow mode is OFF by default
        UserDefaults.standard.register(defaults: [rainbowModeKey: false])
    }
    
    /// Toggle the rainbow mode setting
    func toggle() {
        isEnabled = !isEnabled
    }
}
