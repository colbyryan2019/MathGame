//
//  MathGameApp.swift
//  MathGame
//
//  Created by Colby Ryan on 11/12/24.
//

import SwiftUI

@main
struct MathGameApp: App {
    @StateObject var settings = AppSettings()
    @AppStorage("isDarkMode") private var isDarkMode = true
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MenuView()
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                    .environmentObject(settings)

            }
        }
    }
}
