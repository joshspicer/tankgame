//
//  PlayerSettings.swift
//  tankgame Shared
//
//  Created by GitHub Copilot
//

import Foundation
#if os(iOS)
import UIKit
typealias PlatformColor = UIColor
#elseif os(macOS)
import AppKit
typealias PlatformColor = NSColor
#endif

/// Player-specific settings that sync across devices
struct PlayerSettings: Codable, Equatable {
    var speed: Double // Movement speed multiplier (0.5 to 2.0)
    var colorHue: Double // HSB color hue value (0.0 to 1.0)
    
    init(speed: Double = 1.0, colorHue: Double = 0.6) {
        self.speed = max(0.5, min(2.0, speed))
        self.colorHue = colorHue
    }
    
    /// Get the SKColor representation of the player's color
    var color: SKColor {
        #if os(iOS)
        return UIColor(hue: CGFloat(colorHue), saturation: 0.9, brightness: 0.9, alpha: 1.0)
        #elseif os(macOS)
        return NSColor(hue: CGFloat(colorHue), saturation: 0.9, brightness: 0.9, alpha: 1.0)
        #endif
    }
}
