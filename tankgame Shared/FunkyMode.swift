//
//  FunkyMode.swift
//  tankgame Shared
//
//  Funky mode settings and state management
//

import Foundation

/// Manages the funky mode state and settings
class FunkyMode {
    /// Shared instance for global access
    static let shared = FunkyMode()
    
    /// Whether funky mode is enabled
    var isEnabled: Bool = false
    
    /// Notification name for when funky mode changes
    static let didChangeNotification = Notification.Name("FunkyModeDidChange")
    
    private init() {}
    
    /// Toggle funky mode on or off
    func toggle() {
        isEnabled = !isEnabled
        NotificationCenter.default.post(name: FunkyMode.didChangeNotification, object: nil)
    }
    
    /// Enable funky mode
    func enable() {
        guard !isEnabled else { return }
        isEnabled = true
        NotificationCenter.default.post(name: FunkyMode.didChangeNotification, object: nil)
    }
    
    /// Disable funky mode
    func disable() {
        guard isEnabled else { return }
        isEnabled = false
        NotificationCenter.default.post(name: FunkyMode.didChangeNotification, object: nil)
    }
}
