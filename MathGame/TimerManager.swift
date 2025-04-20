//
//  TimerManager.swift
//  MathGame
//
//  Created by Colby Ryan on 4/19/25.
//
import SwiftUI

class TimerManager: ObservableObject {
    @Published var timeRemaining: Int
    private var timer: Timer?

    init(timeLimit: Int) {
        self.timeRemaining = timeLimit
    }

    func start(completion: @escaping () -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timer?.invalidate()
                completion()
            }
        }
    }

    func stop() {
        timer?.invalidate()
    }
}
