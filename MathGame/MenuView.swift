//
//  MenuView.swift
//  MathGame
//
//  Created by Colby Ryan on 3/5/25.
//
import SwiftUI

struct MenuView: View {
    @ObservedObject var score = ScoreTracker() // Ensure this is observed
    @State private var showSettings = false    // Add this State variable
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        ZStack{
            (settings.isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)

            FloatingSymbolView()
            
            VStack {
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
                
                VStack(spacing: 15) {
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        NavigationLink(destination: ContentView(difficulty: difficulty, score: score).environmentObject(settings)) {
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
                .navigationBarTitle("", displayMode: .inline) // Optional: remove default title
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
}
