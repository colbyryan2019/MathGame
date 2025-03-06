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
            _numberRange = State(initialValue: 5...20) // Adjusted range for Hard
        }
        _userInputs = State(initialValue: Array(repeating: nil, count: _numOfInputs.wrappedValue))
        _game = State(initialValue: MathGame(numberOfNumbers: _numOfInputs.wrappedValue, range: _numberRange.wrappedValue))
    }

    var body: some View {
        VStack {
            /*Button(action: {
                presentationMode.wrappedValue.dismiss() // Navigate back
            }) {
                HStack {
                    Image(systemName: "house.fill") // House icon
                        .font(.title2)
                    Text("Menu")
                        .font(.headline)
                        .padding(.leading, 5)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 3)
            }
            .padding(.top, 10)
            .padding(.horizontal)*/
        }
        
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
            
            Text("\(difficulty.rawValue)")
                .font(.headline)
                .padding()
        }
    
        VStack(spacing: 20) {
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
                        Text("_")
                            .frame(width: 50, height: 50)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                    }

                    if index < numOfInputs - 1 {
                        Text(game.operations[index])
                            .font(.title)
                    }
                }
                Text("= \(game.targetNumber)")
                    .font(.title)
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
                Button(action: checkAnswer) {
                    Text("Check")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
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
                .foregroundColor(.red)
        }
        .padding()
    }

    private func addNumber(_ number: Int, at index: Int) {
        if let userIndex = userInputs.firstIndex(of: nil) {
            userInputs[userIndex] = number
            selectedIndices.append(index)
        }
    }

    private func removeNumber(at userIndex: Int) {
        if let originalIndex = game.numbers.firstIndex(of: userInputs[userIndex]!) {
            selectedIndices.removeAll { $0 == originalIndex }
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

