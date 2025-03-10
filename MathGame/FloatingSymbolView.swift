//
//  FloatingSymbolView.swift
//  MathGame
//
//  Created by Colby Ryan on 3/10/25.
//

import SwiftUI

struct FloatingSymbolView: View {
    @State private var symbols: [MathSymbol] = []
    
    let colors: [Color] = [.blue, .purple] // Match title gradient colors
    
    var body: some View {
        ZStack {
            ForEach(symbols) { symbol in
                Text(symbol.text)
                    .font(.system(size: symbol.size))
                    .foregroundColor(symbol.color.opacity(symbol.opacity))
                    .position(symbol.position)
                    .animation(.easeInOut(duration: symbol.duration), value: symbol.opacity)
            }
        }
        .onAppear {
            startGeneratingSymbols()
        }
    }
    
    private func startGeneratingSymbols() {
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            let newSymbol = MathSymbol.createRandomSymbol(screenSize: UIScreen.main.bounds.size, colors: colors)
            
            DispatchQueue.main.async {
                symbols.append(newSymbol)
                
                // Fade out after duration
                DispatchQueue.main.asyncAfter(deadline: .now() + newSymbol.duration) {
                    symbols.removeAll { $0.id == newSymbol.id }
                }
            }
        }
    }
}

struct MathSymbol: Identifiable {
    let id = UUID()
    let text: String
    let position: CGPoint
    let color: Color
    let size: CGFloat
    let opacity: Double
    let duration: Double
    
    static func createRandomSymbol(screenSize: CGSize, colors: [Color]) -> MathSymbol {
        let mathSymbols = ["+", "-", "×", "÷"]
        
        return MathSymbol(
            text: mathSymbols.randomElement()!,
            position: CGPoint(
                x: CGFloat.random(in: 50...(screenSize.width - 50)),
                y: CGFloat.random(in: 50...(screenSize.height - 50))
            ),
            color: colors.randomElement()!,
            size: CGFloat.random(in: 30...60),
            opacity: 1.0,
            duration: Double.random(in: 3...5) // Random fade duration
        )
    }
}
