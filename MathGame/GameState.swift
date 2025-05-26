//
//  GameState.swift
//  MathGame
//
//  Created by Colby Ryan on 4/19/25.
//

struct GameState {
    let currentQuestion: GameQuestion
    let userAnswer: Int?               // Simple answer (if used)
    let orderedAnswer: Int?           // Used for Standard/Timed mode
    let operationAnswer: Int?         // Used for Operations mode
    var lastAnswerWasCorrect: Bool = false

}
