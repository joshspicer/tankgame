//
//  GameEngine.swift
//  tankgame Shared
//
//  Core game engine protocol
//

import Foundation

/// Protocol defining the game engine interface
protocol GameEngine: AnyObject {
    var state: GameStateModel { get }
    var eventHandler: ((GameEvent) -> Void)? { get set }
    
    func startRound(seed: UInt32)
    func moveTank(playerIndex: Int, direction: Direction) -> Bool
    func rotateTank(playerIndex: Int, direction: Direction)
    func fireTank(playerIndex: Int) -> Bool
    func update(deltaTime: TimeInterval)
    func endRound()
}
