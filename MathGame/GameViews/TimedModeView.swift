//
//  TimedModeView.swift
//  MathGame
//
//  Created by Colby Ryan on 4/17/25.
//

import SwiftUI

struct TimedModeView: View {
    let difficulty: Difficulty
    let timeLimit: Int // In seconds

    var body: some View {
        GamePlayView(
            session: GameSession(scoreTracker: ScoreTracker.shared, gameMode: GameModeConfig(
                gameType: .timed,
                winCondition: { gameState in
                    // A round is "won" if the player got it correct
                    return gameState.lastAnswerWasCorrect
                },
                timeLimit: timeLimit
            ), difficulty: difficulty),
            timeLimit: timeLimit
        )
    }
}
