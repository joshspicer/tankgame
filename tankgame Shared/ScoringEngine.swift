//
//  ScoringEngine.swift
//  tankgame Shared
//
//  Centralized scoring engine for managing game scores and statistics
//

import Foundation

/// Statistics tracked for each player
struct PlayerStats: Codable {
    var kills: Int = 0
    var deaths: Int = 0
    var roundWins: Int = 0
    var currentStreak: Int = 0
    var bestStreak: Int = 0
    
    /// Kill/death ratio (returns kills count if no deaths)
    var kdRatio: Double {
        guard deaths > 0 else { return Double(kills) }
        return Double(kills) / Double(deaths)
    }
    
    mutating func recordKill() {
        kills += 1
        currentStreak += 1
        if currentStreak > bestStreak {
            bestStreak = currentStreak
        }
    }
    
    mutating func recordDeath() {
        deaths += 1
        currentStreak = 0
    }
    
    mutating func recordRoundWin() {
        roundWins += 1
    }
    
    mutating func reset() {
        kills = 0
        deaths = 0
        roundWins = 0
        currentStreak = 0
        bestStreak = 0
    }
}

/// Scoring modes for different gameplay styles
enum ScoringMode: Codable {
    case roundWins           // Traditional mode: win by surviving rounds
    case killCount           // Most kills wins
    case pointBased          // Points for kills, bonus for streaks
}

/// Result of a scoring event
struct ScoringEvent {
    let playerIndex: Int
    let eventType: EventType
    let pointsAwarded: Int
    let newTotal: Int
    let streakBonus: Bool
    
    enum EventType {
        case kill
        case death
        case roundWin
        case streakBonus
    }
}

/// Centralized scoring engine that manages all score calculations
class ScoringEngine {
    
    // MARK: - Properties
    
    private(set) var playerStats: [PlayerStats]
    private(set) var scores: [Int]
    private(set) var mode: ScoringMode
    
    /// Points configuration for point-based scoring
    struct PointConfig {
        static let killPoints = 100
        static let roundWinBonus = 50
        static let streakBonus = 25  // Per kill in streak after 2
        static let survivalBonus = 10
    }
    
    // MARK: - Initialization
    
    init(playerCount: Int, mode: ScoringMode = .roundWins) {
        self.playerStats = Array(repeating: PlayerStats(), count: playerCount)
        self.scores = Array(repeating: 0, count: playerCount)
        self.mode = mode
    }
    
    // MARK: - Scoring Events
    
    /// Record a kill by a player
    @discardableResult
    func recordKill(by killerIndex: Int, victim victimIndex: Int) -> [ScoringEvent] {
        guard killerIndex >= 0, killerIndex < playerStats.count,
              victimIndex >= 0, victimIndex < playerStats.count else {
            return []
        }
        
        var events: [ScoringEvent] = []
        
        // Update killer stats
        playerStats[killerIndex].recordKill()
        
        // Update victim stats
        playerStats[victimIndex].recordDeath()
        
        // Calculate points based on mode
        switch mode {
        case .roundWins:
            // No points for individual kills in round-wins mode
            break
            
        case .killCount:
            scores[killerIndex] += 1
            events.append(ScoringEvent(
                playerIndex: killerIndex,
                eventType: .kill,
                pointsAwarded: 1,
                newTotal: scores[killerIndex],
                streakBonus: false
            ))
            
        case .pointBased:
            var points = PointConfig.killPoints
            let streak = playerStats[killerIndex].currentStreak
            let hasStreakBonus = streak > 2
            
            if hasStreakBonus {
                points += PointConfig.streakBonus * (streak - 2)
            }
            
            scores[killerIndex] += points
            events.append(ScoringEvent(
                playerIndex: killerIndex,
                eventType: .kill,
                pointsAwarded: points,
                newTotal: scores[killerIndex],
                streakBonus: hasStreakBonus
            ))
        }
        
        return events
    }
    
    /// Record a round win by a player
    @discardableResult
    func recordRoundWin(by playerIndex: Int) -> ScoringEvent? {
        guard playerIndex >= 0, playerIndex < playerStats.count else {
            return nil
        }
        
        playerStats[playerIndex].recordRoundWin()
        
        switch mode {
        case .roundWins:
            scores[playerIndex] += 1
            return ScoringEvent(
                playerIndex: playerIndex,
                eventType: .roundWin,
                pointsAwarded: 1,
                newTotal: scores[playerIndex],
                streakBonus: false
            )
            
        case .killCount:
            // Round wins don't affect score in kill-count mode
            return nil
            
        case .pointBased:
            let bonus = PointConfig.roundWinBonus
            scores[playerIndex] += bonus
            return ScoringEvent(
                playerIndex: playerIndex,
                eventType: .roundWin,
                pointsAwarded: bonus,
                newTotal: scores[playerIndex],
                streakBonus: false
            )
        }
    }
    
    /// Reset all streaks at the start of a new round
    func resetStreaks() {
        for i in 0..<playerStats.count {
            playerStats[i].currentStreak = 0
        }
    }
    
    /// Reset all scores and stats for a new game
    func resetAll() {
        for i in 0..<playerStats.count {
            playerStats[i].reset()
            scores[i] = 0
        }
    }
    
    // MARK: - Score Queries
    
    /// Get the leading player index, or nil if there's a tie
    func getLeader() -> Int? {
        guard !scores.isEmpty else { return nil }
        
        let maxScore = scores.max() ?? 0
        let leaders = scores.enumerated().filter { $0.element == maxScore }
        
        return leaders.count == 1 ? leaders.first?.offset : nil
    }
    
    /// Check if a player has reached a win condition
    func hasWinner(targetScore: Int) -> Int? {
        for (index, score) in scores.enumerated() {
            if score >= targetScore {
                return index
            }
        }
        return nil
    }
    
    /// Get a formatted score string for display
    func getScoreDisplayText() -> String {
        if scores.count == 2 {
            return "Score: \(scores[0]) - \(scores[1])"
        } else {
            return scores.enumerated()
                .map { "P\($0.offset + 1): \($0.element)" }
                .joined(separator: " | ")
        }
    }
    
    /// Get stats for a specific player
    func getStats(for playerIndex: Int) -> PlayerStats? {
        guard playerIndex >= 0, playerIndex < playerStats.count else {
            return nil
        }
        return playerStats[playerIndex]
    }
    
    /// Get a detailed stats string for display
    func getDetailedStatsText(for playerIndex: Int) -> String? {
        guard let stats = getStats(for: playerIndex) else { return nil }
        
        return "K: \(stats.kills) D: \(stats.deaths) W: \(stats.roundWins)"
    }
}
