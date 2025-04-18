//
//  MenuView.swift
//  MathGame
//
//  Created by Colby Ryan on 3/5/25.
//
import SwiftUI

enum TimeLimit: String, CaseIterable {
    case oneMinute = "1 Min"
    case threeMinutes = "3 Min"
    case fiveMinutes = "5 Min"
}

enum GameMode: String, CaseIterable {
    case standard = "Standard"
    case timed = "Timed"
    case operations = "Operations"
    var id: String { rawValue }
}


struct MenuView: View {
    @ObservedObject var score = ScoreTracker()
    @State private var showSettings = false
    @State private var selectedTab: GameMode = .standard
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        ZStack {
            (settings.isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)

            FloatingSymbolView()

            VStack {
                Spacer()

                Text("Mathematica")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                ZStack {
                    if selectedTab == .standard {
                        DifficultySelectionView(score: score, selectedTab: selectedTab)
                    } else if selectedTab == .timed {
                        TimedModeSelectionView(score: score, selectedTab: selectedTab)
                    } else if selectedTab == .operations {
                        DifficultySelectionView(score: score, selectedTab: selectedTab) // Now identical to other modes
                    }
                }
                .frame(height: 200)

                Spacer()

                // Game Mode Tabs (Now at the bottom)
                HStack {
                    ForEach(GameMode.allCases, id: \.self) { mode in
                        GameModeButton(mode: mode, isSelected: selectedTab == mode) {
                            selectedTab = mode
                        }
                    }
                }
                .padding(.bottom, 10)
            }
            .navigationBarItems(trailing: Button(action: {
                showSettings.toggle()
            }) {
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
            })
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .onAppear {
            score.loadScores()
        }
    }
}


struct TimedModeSelectionView: View {
    @ObservedObject var score: ScoreTracker
    let selectedTab: GameMode  // Accept selectedTab as a parameter
    @State private var selectedTimeLimit: TimeLimit = .oneMinute

    var body: some View {
        VStack {
            DifficultySelectionView(score: score, selectedTab: selectedTab) // Pass selectedTab here
        }
    }
}
struct GameModeButton: View {
    let mode: GameMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(mode.rawValue)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: mode == .operations ? 110 : 90, height: 40)
                .background(isSelected ?
                            AnyView(Color.blue) :
                            AnyView(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                                                   startPoint: .leading, endPoint: .trailing))
                )

                .cornerRadius(8)
        }
    }
}


struct DifficultySelectionView: View {
    @State private var navigateToGame = false
    @ObservedObject var score: ScoreTracker
    @EnvironmentObject var settings: AppSettings
    let selectedTab: GameMode

    @State private var selectedDifficulty: Difficulty = .easy  // Track selected difficulty
    @State private var selectedTimeMode: Int = 1 // Track selected time in timed mode

    var body: some View {
        VStack(spacing: 15) {
            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                Button(action: { selectedDifficulty = difficulty }) {
                    difficultyRow(for: difficulty)
                }
                .background(Color.gray.opacity(0.5)) // Remove the selection color
                .cornerRadius(12) // Ensures proper button styling
                .buttonStyle(PlainButtonStyle()) // Prevents default button styling
            }
        }
        
        .navigationLink(isActive: $navigateToGame) {
            ContentView(
                score: score,
                difficulty: selectedDifficulty,
                gameMode: selectedTab,
                timeLimit: selectedTimeMode
            )
        }
        

        if selectedTab == .timed {
            timeSelectionButtons()
        }
    }

    private func difficultyRow(for difficulty: Difficulty) -> some View {
        HStack {
            Text(difficulty.rawValue.capitalized)
                .font(.headline)
                .foregroundColor(.white)

            if selectedTab == .standard {
                Text("\(score.getWins(for: difficulty))")
                    .foregroundColor(.green)
                    .bold()
                Text("\(score.getLosses(for: difficulty))")
                    .foregroundColor(.red)
                    .bold()
            } else if selectedTab == .timed {
                Text("TODO")
                    .foregroundColor(.green)
            }else if selectedTab == .operations {
                Text("Wins/Losses?")
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .frame(width: 300)
    }

    private func timeSelectionButtons() -> some View {
        HStack {
            ForEach([1, 3, 5], id: \.self) { minutes in
                Button(action: { selectedTimeMode = minutes }) {
                    Text("\(minutes) min")
                        .padding()
                        .frame(width: 80)
                        .background(selectedTimeMode == minutes ? Color.blue : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle()) // Ensures clean button look
            }
        }
    }
}
