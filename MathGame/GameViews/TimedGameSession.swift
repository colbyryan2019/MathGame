//
//  TimedGameSession.swift
//  MathGame
//
//  Created by Colby Ryan on 5/20/25.
//


import Foundation
import Combine

class TimedGameSession: ObservableObject {
    @Published var session: GameSession
    @Published var timeRemaining: Int
    @Published var gameOver = false

    private var timer: AnyCancellable?
    private let totalTime: Int
    private var correctAnswers: Int = 0
    private let scoreTracker: ScoreTracker
    private let difficulty: Difficulty
    private let gameMode: GameModeConfig

    init(scoreTracker: ScoreTracker, gameMode: GameModeConfig, difficulty: Difficulty, timeLimit: Int) {
        self.scoreTracker = scoreTracker
        self.gameMode = gameMode
        self.difficulty = difficulty
        self.totalTime = timeLimit
        self.timeRemaining = timeLimit
        self.session = GameSession(scoreTracker: scoreTracker, gameMode: gameMode, difficulty: difficulty)

        startTimer()
    }

    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.timeRemaining -= 1
                if self.timeRemaining <= 0 {
                    self.endGame()
                }
            }
    }

    func submitAnswer() {
        let wasCorrect = gameMode.winCondition(
            GameState(
                currentQuestion: session.currentQuestion,
                userAnswer: session.userInputs.compactMap { $0 }.first,
                orderedAnswer: MathGame.calculateTargetWithOrder(numbers: session.userInputs.compactMap { $0 }, operations: session.currentQuestion.operations),
                operationAnswer: session.currentQuestion.constructedEquation(from: session.userInputs.compactMap { $0 })
            )
        )

        if wasCorrect {
            correctAnswers += 1
        }

        session.nextQuestion()
    }

    func endGame() {
        timer?.cancel()
        gameOver = true

        // Save best score
        scoreTracker.setBestScore(for: gameMode.gameType, difficulty: difficulty, score: correctAnswers)
    }

    func resetGame() {
        correctAnswers = 0
        timeRemaining = totalTime
        gameOver = false
        session = GameSession(scoreTracker: scoreTracker, gameMode: gameMode, difficulty: difficulty)
        startTimer()
    }
}
