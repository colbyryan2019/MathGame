//
//  ScoreTracker.swift
//  MathGame
//
//  Created by Colby Ryan on 3/5/25.

import Foundation

enum Difficulty: String, Codable, CaseIterable {
    case easy, medium, hard
}

enum GameType: String, Codable, CaseIterable {
    case standard, timed, operations
}

struct TimedScore: Codable {
    var bestScores: [Int: Int] // timeLimit (1, 3, 5) -> best score
}

struct ModeScore: Codable {
    var wins: Int
    var losses: Int
    var currentWinStreak: Int
    var timed: TimedScore?
}

struct Score: Codable {
    var wins: Int
    var losses: Int
    var currentWinStreak: Int
}

class ScoreTracker: ObservableObject {
    @Published private var scores: [GameType: [Difficulty: ModeScore]] = [:]

    init() {
        loadScores()
    }
    
    // Standard + Operations
    func getWins(for gameType: GameType, difficulty: Difficulty) -> Int {
        scores[gameType]?[difficulty]?.wins ?? 0
    }

    func getLosses(for gameType: GameType, difficulty: Difficulty) -> Int {
        scores[gameType]?[difficulty]?.losses ?? 0
    }

    func addWin(for gameType: GameType, difficulty: Difficulty) {
        var score = scores[gameType]?[difficulty] ?? ModeScore(wins: 0, losses: 0, currentWinStreak: 0, timed: nil)
        score.wins += 1
        score.currentWinStreak += 1
        scores[gameType, default: [:]][difficulty] = score
        saveScores()
        objectWillChange.send()
    }

    func addLoss(for gameType: GameType, difficulty: Difficulty) {
        var score = scores[gameType]?[difficulty] ?? ModeScore(wins: 0, losses: 0, currentWinStreak: 0, timed: nil)
        score.losses += 1
        score.currentWinStreak = 0
        scores[gameType, default: [:]][difficulty] = score
        saveScores()
        objectWillChange.send()
    }
    
    func getBestScore(for difficulty: Difficulty, timeLimit: Int) -> Int {
        scores[.timed]?[difficulty]?.timed?.bestScores[timeLimit] ?? 0
    }

    func updateBestScore(for difficulty: Difficulty, timeLimit: Int, newScore: Int) {
        var score = scores[.timed]?[difficulty] ?? ModeScore(wins: 0, losses: 0, currentWinStreak: 0, timed: TimedScore(bestScores: [:]))
        
        if score.timed == nil {
            score.timed = TimedScore(bestScores: [:])
        }

        let currentBest = score.timed!.bestScores[timeLimit] ?? 0
        if newScore > currentBest {
            score.timed!.bestScores[timeLimit] = newScore
            scores[.timed, default: [:]][difficulty] = score
            saveScores()
            objectWillChange.send()
        }
    }
    
    func getWinStreak(for gameType: GameType, difficulty: Difficulty) -> Int {
        return scores[gameType]?[difficulty]?.currentWinStreak ?? 0
    }
    
    private func saveScores() {
        if let encoded = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(encoded, forKey: "ScoreTrackerDataV2")
        }
    }

    func loadScores() {
        if let saved = UserDefaults.standard.data(forKey: "ScoreTrackerDataV2"),
           let decoded = try? JSONDecoder().decode([GameType: [Difficulty: ModeScore]].self, from: saved) {
            self.scores = decoded
        }
    }

}

// Helper extension to map dictionary keys
extension Dictionary {
    func mapKeys<K: Hashable>(_ transform: (Key) -> K) -> [K: Value] {
        return Dictionary<K, Value>(uniqueKeysWithValues: map { (transform($0.key), $0.value) })
    }
}
