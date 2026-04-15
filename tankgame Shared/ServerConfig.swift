//
//  ServerConfig.swift
//  Tank Game
//
//  Configuration for the Modal game server.
//

import Foundation

/// Server configuration for Modal-hosted multiplayer
enum ServerConfig {
    /// Modal deployed server URL (change after `modal deploy`)
    /// Use the `modal serve` dev URL during development
    static let serverURL: URL = {
        // Default to the deployed Modal URL
        // Override with TANKGAME_SERVER_URL environment variable or change this constant
        if let envURL = ProcessInfo.processInfo.environment["TANKGAME_SERVER_URL"],
           let url = URL(string: envURL) {
            return url
        }
        return URL(string: "wss://joshspicer--tankgame-server-web.modal.run/ws")!
    }()

    /// Health check endpoint
    static var healthURL: URL {
        var components = URLComponents(url: serverURL, resolvingAgainstBaseURL: false)!
        components.scheme = components.scheme == "wss" ? "https" : "http"
        components.path = "/health"
        return components.url!
    }
}
