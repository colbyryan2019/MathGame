//
//  ScoreTracker.swift
//  MathGame
//
//  Created by Colby Ryan on 3/5/25.

import Foundation

enum Difficulty: String, Codable, CaseIterable {
    case easy, medium, hard
}

struct Score: Codable {
    var wins: Int
    var losses: Int
    var currentWinStreak: Int
}

class ScoreTracker: ObservableObject {
    @Published private var scores: [Difficulty: Score] = [:]
    
    init() {
        loadScores()
    }
    
    func getWins(for difficulty: Difficulty) -> Int {
        return scores[difficulty]?.wins ?? 0
    }
    
    func getLosses(for difficulty: Difficulty) -> Int {
        return scores[difficulty]?.losses ?? 0
    }
    
    func getWinStreak(for difficulty: Difficulty) -> Int {
        return scores[difficulty]?.currentWinStreak ?? 0
    }
    
    func addWin(for difficulty: Difficulty) {
        var score = scores[difficulty, default: Score(wins: 0, losses: 0, currentWinStreak: 0)]
        score.wins += 1
        score.currentWinStreak += 1 // increment streak
        scores[difficulty] = score
        saveScores()
        objectWillChange.send()
    }
    
    func addLoss(for difficulty: Difficulty) {
        var score = scores[difficulty, default: Score(wins: 0, losses: 0, currentWinStreak: 0)]
        score.losses += 1
        score.currentWinStreak = 0 // reset streak
        scores[difficulty] = score
        saveScores()
        objectWillChange.send()
    }
    
    private func saveScores() {
        let stringKeyScores = scores.mapKeys { $0.rawValue } // Convert Difficulty keys to strings
        if let encoded = try? JSONEncoder().encode(stringKeyScores) {
            UserDefaults.standard.set(encoded, forKey: "ScoreTrackerData")
        }
    }
    
    public func loadScores() {
        if let savedData = UserDefaults.standard.data(forKey: "ScoreTrackerData"),
           let decoded = try? JSONDecoder().decode([String: Score].self, from: savedData) {
            scores = decoded.mapKeys { Difficulty(rawValue: $0) ?? .easy } // Convert string keys back to Difficulty
        }
    }
}

// Helper extension to map dictionary keys
extension Dictionary {
    func mapKeys<K: Hashable>(_ transform: (Key) -> K) -> [K: Value] {
        return Dictionary<K, Value>(uniqueKeysWithValues: map { (transform($0.key), $0.value) })
    }
}
