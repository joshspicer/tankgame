//
//  SoundManager.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages sound playback for game events
///
/// Coordinates with SpriteKit's audio system to play sound effects like shooting, explosions, and movement.
/// Can be toggled on/off and requires a reference to the active scene.
class SoundManager {
    /// Whether sound effects should be played
    var soundEnabled = true
    /// Weak reference to the SpriteKit scene for playing sounds
    private weak var scene: SKScene?
    
    /// Creates a new sound manager
    /// - Parameter scene: The SpriteKit scene where sounds will be played
    init(scene: SKScene) {
        self.scene = scene
    }
    
    /// Plays a sound file through the SpriteKit scene
    /// - Parameter soundFile: Name of the sound file to play (e.g., "move.wav")
    func playSound(_ soundFile: String) {
        guard soundEnabled, let scene = scene else { return }
        scene.run(SKAction.playSoundFileNamed(soundFile, waitForCompletion: false))
    }
}
