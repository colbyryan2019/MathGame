//
//  MenuView.swift
//  MathGame
//
//  Created by Colby Ryan on 3/5/25.
//
import SwiftUI

struct MenuView: View {
    @ObservedObject var score = ScoreTracker() // Ensure this is observed

    var body: some View {
        VStack {
            Text("Math Game")
                .font(.largeTitle)
                .padding()

            VStack(spacing: 20) {
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    NavigationLink(destination: ContentView(difficulty: difficulty, score: score)) {
                        HStack {
                            Text(difficulty.rawValue)
                                .font(.title2)

                            Spacer()

                            Text("\(score.getWins(for: difficulty))")
                                .foregroundColor(.green)
                                .bold()

                            Text("\(score.getLosses(for: difficulty))")
                                .foregroundColor(.red)
                                .bold()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
        }
        .onAppear {
            score.loadScores()
        }
    }
}
