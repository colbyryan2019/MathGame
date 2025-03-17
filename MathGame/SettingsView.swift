//
//  SettingsView.swift
//  MathGame
//
//  Created by Colby Ryan on 3/16/25.
//

import SwiftUI
struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        NavigationView {
            Form {
                Toggle(isOn: $settings.isDarkMode) {
                    Text("Dark Mode")
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(leading: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
