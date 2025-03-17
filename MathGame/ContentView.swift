import SwiftUI

struct ContentView: View {
    let difficulty: Difficulty
    @State private var numOfInputs: Int
    @State private var numberRange: ClosedRange<Int>
    @State private var userInputs: [Int?]
    @State private var game: MathGame
    @State private var selectedIndices: [Int] = []
    @State private var message: String = ""
    @State private var showNextButton: Bool = false
    @State private var score: ScoreTracker = ScoreTracker()

    @EnvironmentObject var settings: AppSettings

    @Environment(\.presentationMode) var presentationMode // For dismissing view

    
    init(difficulty: Difficulty, score: ScoreTracker) {
        self.difficulty = difficulty
        
        switch difficulty {
        case .easy:
            _numOfInputs = State(initialValue: 3)
            _numberRange = State(initialValue: 1...10) // Adjusted range for Easy
        case .medium:
            _numOfInputs = State(initialValue: 4)
            _numberRange = State(initialValue: 5...12) // Adjusted range for Medium
        case .hard:
            _numOfInputs = State(initialValue: 5)
            _numberRange = State(initialValue: 7...15) // Adjusted range for Hard
        }
        _userInputs = State(initialValue: Array(repeating: nil, count: _numOfInputs.wrappedValue))
        _game = State(initialValue: MathGame(numberOfNumbers: _numOfInputs.wrappedValue, range: _numberRange.wrappedValue))
    }

    var body: some View {

        ZStack {
            (settings.isDarkMode ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
            /*FloatingSymbolView()
                .zIndex(-1) It's a bit distracting on the game play page*/
                .navigationBarBackButtonHidden(true) // This hides the default back button
                .navigationBarItems(leading: Button(action: {
                    // Custom back action: Dismiss the current view (navigate back)
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                })
            
            VStack {
                HStack {
                    Text("\(score.getWins(for: difficulty))")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding(.leading)
                    Spacer()
                    Text("\(score.getLosses(for: difficulty))")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding(.trailing)
                }
                .padding(.top, 10)
                
                
                
                VStack(spacing: 20) {
                    
                    // Target number moved above the equation
                    Text("Target: \(game.targetNumber)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.bottom, 10) // Add spacing below target number
                    
                    // Display blanks and operations
                    HStack(spacing: 10) {
                        ForEach(0..<numOfInputs, id: \.self) { index in
                            if let userNumber = userInputs[index] {
                                Button(action: {
                                    removeNumber(at: index)
                                }) {
                                    Text("\(userNumber)")
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
                            
                            if index < numOfInputs - 1 {
                                //update the text size for hard mode to be slightly smaller otherwise they don't fit
                                Text(game.operations[index])
                                    .font(difficulty == .hard ? .headline : .title)
                                    .foregroundColor(.blue) // Make operations blue for visibility in both light and dark mode
                                
                            }
                        }
                    }
                }
                
                // Number buttons
                HStack(spacing: 15) {
                    ForEach(game.numbers.indices, id: \.self) { index in
                        let number = game.numbers[index]
                        Button(action: {
                            addNumber(number, at: index)
                        }) {
                            Text("\(number)")
                                .frame(width: 50, height: 50)
                                .background(selectedIndices.contains(index) ? Color.green : Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                        .disabled(!canSelect(number, at: index))
                    }
                }
                
                if !showNextButton {
                    
                    HStack(spacing: 20) {
                        //  Check Button
                        Button(action: checkAnswer) {
                            Text("Check")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        //  Reset Button
                        
                        Button(action: resetGame) {
                            Image(systemName: "arrow.uturn.left") // Reset icon
                                .resizable()
                                .frame(width: 30, height: 30) // Smaller size
                                .foregroundColor(.red) // Red for reset action
                        }
                        
                        
                    }
                }
                
                if showNextButton {
                    Button("Next Game") {
                        nextGame()
                    }
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(8)
                    .foregroundColor(.white)
                }
                
                Text(message)
                    .foregroundColor(showNextButton ? .green : .red)
            }
            .padding()
        
        }
    }

    func resetGame() {
        userInputs = Array(repeating: nil, count: numOfInputs) // Clears inputs
        selectedIndices = [] // Deselects all tiles
        message = "" // Clears any feedback message
    }
    
    private func addNumber(_ number: Int, at index: Int) {
        if let userIndex = userInputs.firstIndex(of: nil) {
            userInputs[userIndex] = number
            selectedIndices.append(index)
        }
    }

    private func removeNumber(at userIndex: Int) {
        guard let removedNumber = userInputs[userIndex] else { return }

        // Find the specific index in selectedIndices that corresponds to the removed number
        if let selectedIndex = selectedIndices.firstIndex(where: { game.numbers[$0] == removedNumber }) {
            selectedIndices.remove(at: selectedIndex) // Remove only the corresponding selection
        }

        userInputs[userIndex] = nil
    }

    private func canSelect(_ number: Int, at index: Int) -> Bool {
        let usedCount = userInputs.compactMap { $0 }.filter { $0 == number }.count
        let availableCount = game.numbers.filter { $0 == number }.count
        return usedCount < availableCount && !selectedIndices.contains(index)
    }

    private func checkAnswer() {
        guard !userInputs.contains(nil) else {
            message = "Fill in all blanks first!"
            return
        }

        if MathGame.calculateTargetWithOrder(numbers: userInputs.compactMap { $0 }, operations: game.operations) == game.targetNumber {
            score.addWin(for: difficulty)
            message = "Correct!"
            showNextButton = true
        } else {
            
                score.addLoss(for: difficulty)
            message = "Try again!"
            resetTiles()
        }
    }

    private func resetTiles() {
        userInputs = Array(repeating: nil, count: numOfInputs)
        selectedIndices = []
    }

    private func nextGame() {
        game = MathGame(numberOfNumbers: numOfInputs, range: 2...12)
        userInputs = Array(repeating: nil, count: numOfInputs)
        selectedIndices = []
        message = ""
        showNextButton = false
        print("next game")
    }
}

