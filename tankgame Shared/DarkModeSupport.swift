//
//  DarkModeSupport.swift
//  tankgame Shared
//
//  Created by Copilot on 12/11/25.
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif
import SpriteKit

/// Helper for dark mode support across platforms
struct DarkModeSupport {
    /// Returns a background color that adapts to the current interface style
    static var gameBackgroundColor: SKColor {
        #if os(iOS) || os(tvOS)
        // Use system colors that adapt to dark mode
        if #available(iOS 13.0, tvOS 13.0, *) {
            return UIColor.systemGray6
        } else {
            return UIColor.darkGray
        }
        #elseif os(OSX)
        if #available(macOS 10.14, *) {
            return NSColor.controlBackgroundColor
        } else {
            return NSColor.darkGray
        }
        #endif
    }
    
    /// Returns a label color that adapts to the current interface style
    static var labelColor: SKColor {
        #if os(iOS) || os(tvOS)
        // Use label color that adapts to dark mode
        if #available(iOS 13.0, tvOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.white
        }
        #elseif os(OSX)
        if #available(macOS 10.14, *) {
            return NSColor.labelColor
        } else {
            return NSColor.white
        }
        #endif
    }
}
