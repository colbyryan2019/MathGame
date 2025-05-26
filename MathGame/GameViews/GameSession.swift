//
//  GameSession.swift
//  MathGame
//
//  Created by Colby Ryan on 4/19/25.
//
import Foundation
import Combine
import SwiftUI

let standardMode = GameModeConfig(
    gameType: .standard,
    winCondition: { state in
        guard let orderedAnswer = state.orderedAnswer else {
            return false
        }
        return orderedAnswer == state.currentQuestion.correctAnswer

    },
    timeLimit: nil
)

let timedMode = GameModeConfig(
    gameType: .timed,
    winCondition: { state in
        guard let orderedAnswer = state.orderedAnswer else {
            return false
        }
        return orderedAnswer == state.currentQuestion.correctAnswer

    },
    timeLimit: 60
)

let operationsMode = GameModeConfig(
    gameType: .operations,
    winCondition: { state in
        guard let orderedAnswer = state.orderedAnswer else {
            return false
        }
        return orderedAnswer == state.currentQuestion.correctAnswer

    },
    timeLimit: nil
)

class GameSession: ObservableObject {
    @Published var currentQuestion: GameQuestion
    @Published var userInputs: [Int?]
    @Published var selectedIndices: [Int]
    @Published var message = ""
    @Published var showNextButton = false

    var scoreTracker: ScoreTracker
    var gameMode: GameModeConfig
    var difficulty: Difficulty
    var numberRange: ClosedRange<Int>
    var numberOfInputs: Int

    init(scoreTracker: ScoreTracker, gameMode: GameModeConfig, difficulty: Difficulty) {
        self.scoreTracker = scoreTracker
        self.gameMode = gameMode
        self.difficulty = difficulty

        switch difficulty {
        case .easy:
            self.numberOfInputs = 3
            self.numberRange = 1...10
        case .medium:
            self.numberOfInputs = 4
            self.numberRange = 5...12
        case .hard:
            self.numberOfInputs = 5
            self.numberRange = 7...15
        }

        self.currentQuestion = GameQuestion.generate(for: difficulty)
        self.userInputs = Array(repeating: nil, count: numberOfInputs)
        self.selectedIndices = []
        let logic = MathGame(difficulty: difficulty)
        self.currentQuestion = GameQuestion(
            numbers: logic.numbers,
            operations: logic.operations,
            correctAnswer: logic.targetNumber
        )
    }

    func reset() {
        userInputs = Array(repeating: nil, count: numberOfInputs)
        selectedIndices = []
        message = ""
    }

    func submit() {
        let ordered = MathGame.calculateTargetWithOrder(
          numbers: userInputs.compactMap { $0 },
          operations: currentQuestion.operations
        )
        let correct = (ordered == currentQuestion.correctAnswer)
        
        let state = GameState(
          currentQuestion: currentQuestion,
          userAnswer: userInputs.compactMap { $0 }.first,
          orderedAnswer: ordered,
          operationAnswer: currentQuestion.constructedEquation(from: userInputs.compactMap { $0 }),
          lastAnswerWasCorrect: correct    // ← set here
        )
        
        if gameMode.winCondition(state) {
            scoreTracker.addWin(for: gameMode.gameType, difficulty: difficulty)
            message = "Correct!"
            withAnimation {
                showNextButton = true
            }
        } else {
            scoreTracker.addLoss(for: gameMode.gameType, difficulty: difficulty)
            message = "Try again!"
            reset()
        }
    }


    func next() {
        currentQuestion = GameQuestion.generate(for: difficulty)
        reset()
        showNextButton = false
    }

    func addNumber(_ number: Int, at index: Int) {
        if let firstEmpty = userInputs.firstIndex(of: nil) {
            userInputs[firstEmpty] = number
            selectedIndices.append(index)
        }
    }

    func removeNumber(at userIndex: Int) {
        guard let removed = userInputs[userIndex] else { return }
        if let selIndex = selectedIndices.firstIndex(where: { currentQuestion.numbers[$0] == removed }) {
            selectedIndices.remove(at: selIndex)
        }
        userInputs[userIndex] = nil
    }

    func canSelect(_ number: Int, at index: Int) -> Bool {
        let usedCount = userInputs.compactMap { $0 }.filter { $0 == number }.count
        let availableCount = currentQuestion.numbers.filter { $0 == number }.count
        return usedCount < availableCount && !selectedIndices.contains(index)
    }
    
    func nextQuestion() {
        let logic = MathGame(difficulty: difficulty)
        let question = GameQuestion(
            numbers: logic.numbers,
            operations: logic.operations,
            correctAnswer: logic.targetNumber
        )
        currentQuestion = question
        message = ""
        showNextButton = false
    }

}
