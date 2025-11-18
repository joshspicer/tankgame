//
//  SoundManager.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages sound playback for game events
final class SoundManager {
    // MARK: - Properties
    
    /// Whether sound effects are enabled
    var soundEnabled = true
    
    /// Reference to the scene for playing sounds
    private weak var scene: SKScene?
    
    // MARK: - Initialization
    
    /// Creates a new sound manager
    /// - Parameter scene: The scene in which to play sounds
    init(scene: SKScene) {
        self.scene = scene
    }
    
    // MARK: - Sound Playback
    
    /// Plays a sound file if sound is enabled
    /// - Parameter soundFile: Name of the sound file to play (e.g., "move.wav")
    func playSound(_ soundFile: String) {
        guard soundEnabled, let scene = scene else { return }
        scene.run(SKAction.playSoundFileNamed(soundFile, waitForCompletion: false))
    }
}
