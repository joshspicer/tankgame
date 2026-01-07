//
//  GameStateModel.swift
//  tankgame Shared
//
//  Complete game state representation
//

import Foundation

/// Complete state of the game at a point in time
struct GameStateModel: Codable {
    var board: GameBoard
    var tanks: [TankEntity]
    var projectiles: [ProjectileEntity]
    var players: [PlayerInfo]
    var roundNumber: Int
    var isRoundActive: Bool
    
    init(board: GameBoard, players: [PlayerInfo]) {
        self.board = board
        self.tanks = []
        self.projectiles = []
        self.players = players
        self.roundNumber = 0
        self.isRoundActive = false
    }
    
    /// Get tank for a specific player
    func tank(forPlayerIndex index: Int) -> TankEntity? {
        return tanks.first { $0.playerIndex == index }
    }
    
    /// Get player by index
    func player(at index: Int) -> PlayerInfo? {
        return players.first { $0.index == index }
    }
    
    /// Count alive tanks
    var aliveTankCount: Int {
        return tanks.filter { $0.isAlive }.count
    }
}
