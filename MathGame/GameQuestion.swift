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
        let mathGame = MathGame(difficulty: difficulty)
        return GameQuestion(
            numbers: mathGame.numbers,
            operations: mathGame.operations,
            correctAnswer: mathGame.targetNumber
        )
    }
}
