//
//  Settings.swift
//  tankgame Shared
//
//  Created by copilot on 11/10/25.
//

import Foundation

final class Settings {
    static let shared = Settings()
    
    private let defaults = UserDefaults.standard
    
    // Settings keys
    private enum Keys {
        static let soundEnabled = "settings.soundEnabled"
        static let musicEnabled = "settings.musicEnabled"
        static let joystickSensitivity = "settings.joystickSensitivity"
        static let playerName = "settings.playerName"
    }
    
    // Sound settings
    var soundEnabled: Bool {
        get {
            if defaults.object(forKey: Keys.soundEnabled) == nil {
                return true // Default to enabled
            }
            return defaults.bool(forKey: Keys.soundEnabled)
        }
        set {
            defaults.set(newValue, forKey: Keys.soundEnabled)
        }
    }
    
    var musicEnabled: Bool {
        get {
            if defaults.object(forKey: Keys.musicEnabled) == nil {
                return true // Default to enabled
            }
            return defaults.bool(forKey: Keys.musicEnabled)
        }
        set {
            defaults.set(newValue, forKey: Keys.musicEnabled)
        }
    }
    
    // Joystick sensitivity (0.5 to 2.0, default 1.0)
    var joystickSensitivity: Float {
        get {
            let value = defaults.float(forKey: Keys.joystickSensitivity)
            return value > 0 ? value : 1.0 // Default to 1.0
        }
        set {
            defaults.set(newValue, forKey: Keys.joystickSensitivity)
        }
    }
    
    // Player name
    var playerName: String {
        get {
            return defaults.string(forKey: Keys.playerName) ?? ""
        }
        set {
            defaults.set(newValue, forKey: Keys.playerName)
        }
    }
    
    private init() {}
}
