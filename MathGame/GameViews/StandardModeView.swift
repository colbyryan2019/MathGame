//
//  StandardModeView.swift
//  MathGame
//
//  Created by Colby Ryan on 4/17/25.
//

// StandardModeView.swift
import SwiftUI

struct StandardModeView: View {
    let difficulty: Difficulty
    @State private var score: ScoreTracker

    init(difficulty: Difficulty, score: ScoreTracker) {
        self.difficulty = difficulty
        self._score = State(initialValue: score)
    }

    var body: some View {
        ContentView(difficulty: difficulty, score: score)
    }
}
