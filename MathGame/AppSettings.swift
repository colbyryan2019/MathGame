//
//  AppSettings.swift
//  MathGame
//
//  Created by Colby Ryan on 3/16/25.
//

import SwiftUI

class AppSettings: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    @Published var showCelebration: Bool {
        didSet {
            UserDefaults.standard.set(showCelebration, forKey: "showCelebration")
        }
    }
    @Published var trackWins: Bool {
        didSet {
            UserDefaults.standard.set(trackWins, forKey: "trackWins")
        }
    }
    @Published var trackWinstreaks: Bool {
        didSet {
            UserDefaults.standard.set(trackWinstreaks, forKey: "trackWinstreaks")
        }
    }
    
    init() {
        // Load values from UserDefaults if they exist, otherwise set default values
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.showCelebration = UserDefaults.standard.bool(forKey: "showCelebration")
        self.trackWins = UserDefaults.standard.bool(forKey: "trackWins")
        self.trackWinstreaks = UserDefaults.standard.bool(forKey: "trackWinstreaks")
    }
}
