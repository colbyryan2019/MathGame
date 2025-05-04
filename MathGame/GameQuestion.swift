//
//  GameQuestion.swift
//  MathGame
//
//  Created by Colby Ryan on 4/19/25.
//

import Foundation

struct GameQuestion {
    let numbers: [Int]
    let operations: [String]
    let correctAnswer: Int

    static func generate(for difficulty: Difficulty) -> GameQuestion {
        let logic = MathGame(difficulty: difficulty)
        return GameQuestion(
            numbers: logic.numbers,
            operations: logic.operations,
            correctAnswer: logic.targetNumber
        )
    }

    func constructedEquation(from input: [Int]) -> Int? {
        guard input.count == operations.count + 1 else { return nil }
        return MathGame.calculateTargetWithOrder(numbers: input, operations: operations)
    }
}


