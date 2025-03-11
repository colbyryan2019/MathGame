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
                    .opacity(symbol.opacity)
                    .onAppear {
                        withAnimation(.easeInOut(duration: symbol.fadeInDuration)) {
                            updateOpacity(for: symbol.id, to: 1.0) // Fade in
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + symbol.lifetime / 2) {
                            withAnimation(.easeInOut(duration: symbol.fadeOutDuration)) {
                                updateOpacity(for: symbol.id, to: 0.0) // Fade out
                            }
                        }
                    }
            }
        }
        .onAppear {
            startGeneratingSymbols()
        }
    }
    
    private func startGeneratingSymbols() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in  // edit for time interval
            let newSymbol = MathSymbol.createRandomSymbol(screenSize: UIScreen.main.bounds.size, colors: colors)
            
            DispatchQueue.main.async {
                symbols.append(newSymbol)
                
                // Remove after complete fade-out
                DispatchQueue.main.asyncAfter(deadline: .now() + newSymbol.lifetime) {
                    symbols.removeAll { $0.id == newSymbol.id }
                }
            }
        }
    }

    
    private func updateOpacity(for id: UUID, to newOpacity: Double) {
        if let index = symbols.firstIndex(where: { $0.id == id }) {
            symbols[index].opacity = newOpacity
        }
    }
}

struct MathSymbol: Identifiable {
    let id = UUID()
    let text: String
    let position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
    let fadeInDuration: Double
    let fadeOutDuration: Double
    let lifetime: Double
    
    static func createRandomSymbol(screenSize: CGSize, colors: [Color]) -> MathSymbol {
        let mathSymbols = ["+", "-", "×", "÷"]
        
        let fadeIn = Double.random(in: 1.0...2.0)
        let fadeOut = Double.random(in: 1.0...2.0)
        let lifetime = fadeIn + fadeOut + 1.0 // Ensure they fade smoothly
        
        return MathSymbol(
            text: mathSymbols.randomElement()!,
            position: CGPoint(
                x: CGFloat.random(in: 50...(screenSize.width - 50)),
                y: CGFloat.random(in: 50...(screenSize.height - 50))
            ),
            color: colors.randomElement()!,
            size: CGFloat.random(in: 30...60),
            opacity: 0.0, // Start transparent
            fadeInDuration: fadeIn,
            fadeOutDuration: fadeOut,
            lifetime: lifetime
        )
    }
}
