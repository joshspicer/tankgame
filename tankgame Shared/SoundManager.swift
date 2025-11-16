//
//  SoundManager.swift
//  tankgame Shared
//
//  Created by jospicer on 10/28/25.
//

import SpriteKit

/// Manages sound playback for game events
class SoundManager {
    var soundEnabled = true
    private weak var scene: SKScene?
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    /// Play a sound file
    /// - Parameter soundFile: Name of the sound file to play (e.g., "move.wav")
    func playSound(_ soundFile: String) {
        guard soundEnabled, let scene = scene else { return }
        scene.run(SKAction.playSoundFileNamed(soundFile, waitForCompletion: false))
    }
}
