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

    var body: some Scene {
        WindowGroup {
            NavigationView {
                MenuView()
                    .environmentObject(settings)

            }
        }
    }
}
