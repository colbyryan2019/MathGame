//
//  GameModeConfig.swift
//  MathGame
//
//  Created by Colby Ryan on 4/19/25.
//

struct GameModeConfig {
    var gameType: GameType
    var winCondition: (GameState) -> Bool
    var timeLimit: Int? // nil for standard/operations
}
