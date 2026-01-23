//
//  AppDelegate.swift
//  tankgame tvOS
//
//  tvOS app entry point.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Pause ongoing tasks when app becomes inactive
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Release shared resources and save user data
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Undo changes made when entering background
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any paused tasks
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Save data if appropriate
    }

}
