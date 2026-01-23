//
//  AppDelegate.swift
//  tankgame macOS
//
//  macOS app entry point.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // macOS app initialized
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // macOS app terminating
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}
