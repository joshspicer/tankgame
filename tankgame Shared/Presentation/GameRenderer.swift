//
//  GameRenderer.swift
//  tankgame Shared
//
//  Protocol for rendering the game
//

import SpriteKit

/// Protocol for rendering game state
protocol GameRenderer: AnyObject {
    func setup(in scene: SKScene)
    func render(state: GameStateModel)
    func handleEvent(_ event: GameEvent)
}
