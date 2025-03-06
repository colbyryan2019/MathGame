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
            Text("Mathematica")
                .font(.largeTitle)
                .padding()

            VStack(spacing: 15) {
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    NavigationLink(destination: ContentView(difficulty: difficulty, score: score)) {
                        HStack {
                            Text(difficulty.rawValue)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("\(score.getWins(for: difficulty))")
                                .foregroundColor(.green)
                                .bold()

                            Text("\(score.getLosses(for: difficulty))")
                                .foregroundColor(.red)
                                .bold()
                        }
                        .padding()
                        .frame(width: 250, height: 50) // Set a fixed width & height
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.4), radius: 5, x: 2, y: 2)
                    }
                }
            }
        }
        .onAppear {
            score.loadScores()
        }
    }
}
