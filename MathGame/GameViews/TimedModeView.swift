//
//  TimedModeView.swift
//  MathGame
//
//  Created by Colby Ryan on 4/17/25.
//

import SwiftUI

struct TimedModeView: View {
    let difficulty: Difficulty
    @State var score: ScoreTracker
    let timeLimit: Int // Track selected time in timed mode


    var body: some View {
        Text("Timed mode coming soon... for limit:  \(timeLimit)")
    }
}
