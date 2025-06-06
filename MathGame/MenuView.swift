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
                .frame(height: 260)

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
            .animation(.easeInOut, value: selectedTab)            
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
                Button(action: {
                    selectedDifficulty = difficulty
                    navigateToGame = true
                }) {
                    difficultyRow(for: difficulty)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .buttonStyle(PlainButtonStyle())

            }

            // Spacer or time buttons go here
            if selectedTab == .timed {
                timeSelectionButtons()
            } else {
                // Add an empty space of equivalent height to preserve layout
                Spacer().frame(height: 50)
            }
        }

        NavigationLink(
            destination: destinationView(),
            isActive: $navigateToGame,
            label: { EmptyView() }
        )
        .hidden()
    }
    
    private func difficultyRow(for difficulty: Difficulty) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(difficulty.rawValue.capitalized)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if selectedTab == .standard {
                    if settings.trackWins{
                        Text("\(score.getWins(for: .standard, difficulty: difficulty))")
                            .foregroundColor(.green)
                        Text("\(score.getLosses(for: .standard, difficulty: difficulty))")
                            .foregroundColor(.red)
                    }
                    if settings.trackWinstreaks{
                        Text("\(score.getWinStreak(for: .standard, difficulty: difficulty))")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }

                } else if selectedTab == .operations {
                    if settings.trackWins{
                        Text("\(score.getWins(for: .operations, difficulty: difficulty))")
                            .foregroundColor(.green)
                        Text("\(score.getLosses(for: .operations, difficulty: difficulty))")
                            .foregroundColor(.red)
                    }
                    if settings.trackWinstreaks{
                        Text("\(score.getWinStreak(for: .standard, difficulty: difficulty))")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                } else if selectedTab == .timed {
                    Text("Best: \(score.getBestScore(for: difficulty, timeLimit: selectedTimeMode))")
                        .foregroundColor(.cyan)
                }
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
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

    @ViewBuilder
    private func destinationView() -> some View {
        switch selectedTab {
        case .standard:
            StandardModeView(difficulty: selectedDifficulty, score: score)
                .environmentObject(settings)
        case .timed:
            TimedModeView(difficulty: selectedDifficulty, score: score, timeLimit: selectedTimeMode)
                .environmentObject(settings)
        case .operations:
            OperationsModeView(difficulty: selectedDifficulty, score: score)
                .environmentObject(settings)

        }
    }
}
