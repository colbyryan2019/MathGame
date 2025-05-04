import SwiftUI

struct GamePlayView: View {
    @ObservedObject var session: GameSession
    @EnvironmentObject var settings: AppSettings
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            (settings.isDarkMode ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
            
            VStack {
                if settings.trackWins {
                    HStack {
                        Text("\(session.scoreTracker.getWins(for: session.gameMode.gameType, difficulty: session.difficulty))")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.leading)
                        Spacer()
                        Text("\(session.scoreTracker.getLosses(for: session.gameMode.gameType, difficulty: session.difficulty))")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding(.trailing)
                    }
                    .padding(.top, 10)
                }

                VStack(spacing: 20) {
                    Text("Target: \(session.currentQuestion.correctAnswer)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.bottom, 10)

                    HStack(spacing: 10) {
                        ForEach(0..<session.userInputs.count, id: \.self) { index in
                            if let input = session.userInputs[index] {
                                Button(action: {
                                    session.removeNumber(at: index)
                                }) {
                                    Text("\(input)")
                                        .frame(width: 50, height: 50)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(5)
                                }
                            } else {
                                Text(" ")
                                    .frame(width: 45, height: 45)
                                    .background(Color.gray.opacity(0.6))
                                    .cornerRadius(5)
                            }

                            if index < session.userInputs.count - 1,
                               index < session.currentQuestion.operations.count {
                                Text(session.currentQuestion.operations[index])
                                    .font(session.difficulty == .hard ? .headline : .title)
                                    .foregroundColor(.blue)
                            }
                        }
                    }

                    HStack(spacing: 15) {
                        ForEach(session.currentQuestion.numbers.indices, id: \.self) { index in
                            let number = session.currentQuestion.numbers[index]
                            Button(action: {
                                session.addNumber(number, at: index)
                            }) {
                                Text("\(number)")
                                    .frame(width: 50, height: 50)
                                    .background(session.selectedIndices.contains(index) ? Color.green : Color.blue.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                            }
                            .disabled(!session.canSelect(number, at: index))
                        }
                    }

                    if !session.showNextButton {
                        HStack(spacing: 20) {
                            Button("Check") {
                                session.submit()
                            }
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)

                            Button(action: {
                                session.reset()
                            }) {
                                Image(systemName: "arrow.uturn.left")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    if !session.message.isEmpty && !session.showNextButton {
                        Text(session.message)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }


                    if session.showNextButton {
                        Button("Next Game") {
                            session.next()
                        }
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    }
                    
                    
                    Text(session.message)
                        .foregroundColor(session.showNextButton ? .green : .red)
                    
                }
                .padding()

                if settings.trackWinstreaks {
                    Text("Win Streak: \(session.scoreTracker.getWinStreak(for: session.gameMode.gameType, difficulty: session.difficulty))")
                        .foregroundColor(.blue)
                }
            }
        }
        .overlay(
            Group {
                if settings.showCelebration && session.showNextButton {
                    FireworkParticleView()
                        .transition(.opacity)
                }
            }
        )
    }
}
