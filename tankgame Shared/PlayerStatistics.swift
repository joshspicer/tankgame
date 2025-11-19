//
//  PlayerStatistics.swift
//  tankgame Shared
//
//  Track player performance statistics
//

import Foundation

struct PlayerStatistics: Codable {
    var shotsFired: Int = 0
    var hits: Int = 0
    var powerUpsCollected: Int = 0
    var roundStartTime: TimeInterval = 0
    var survivalTime: TimeInterval = 0
    
    var accuracy: Double {
        guard shotsFired > 0 else { return 0.0 }
        return Double(hits) / Double(shotsFired) * 100.0
    }
    
    mutating func resetRound() {
        shotsFired = 0
        hits = 0
        powerUpsCollected = 0
        survivalTime = 0
    }
    
    mutating func recordShot() {
        shotsFired += 1
    }
    
    mutating func updateSurvivalTime(_ time: TimeInterval) {
        survivalTime = time - roundStartTime
    }
}
