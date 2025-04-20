//
//  GameSession.swift
//  MathGame
//
//  Created by Colby Ryan on 4/19/25.
//
import Foundation
import Combine

let standardMode = GameModeConfig(
    gameType: .standard,
    winCondition: { state in
        state.userAnswer == state.currentQuestion.correctAnswer
    },
    timeLimit: nil
)

let timedMode = GameModeConfig(
    gameType: .timed,
    winCondition: { state in
        state.userAnswer == state.currentQuestion.correctAnswer
    },
    timeLimit: 60
)


class GameSession: ObservableObject {
    @Published var currentQuestion: GameQuestion
    @Published var message = ""
    @Published var showNextButton = false
    
    var scoreTracker: ScoreTracker
    var gameMode: GameModeConfig
    var difficulty: Difficulty

    init(scoreTracker: ScoreTracker, gameMode: GameModeConfig, difficulty: Difficulty) {
        self.scoreTracker = scoreTracker
        self.gameMode = gameMode
        self.difficulty = difficulty
        self.currentQuestion = GameQuestion.generate(for: difficulty)
    }

    func submitAnswer(_ answer: Int) {
        let state = GameState(currentQuestion: currentQuestion, userAnswer: answer)
        if gameMode.winCondition(state) {
            scoreTracker.addWin(for: gameMode.gameType, difficulty: difficulty)
            message = "Correct!"
            showNextButton = true
        } else {
            scoreTracker.addLoss(for: gameMode.gameType, difficulty: difficulty)
            message = "Try again!"
            showNextButton = false
        }
    }

    func nextQuestion() {
        currentQuestion = GameQuestion.generate(for: difficulty)
        message = ""
        showNextButton = false
    }
}
