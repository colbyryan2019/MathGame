//
//  FireworkView.swift
//  MathGame
//
//  Created by Colby Ryan on 3/16/25.
//
import SwiftUI

struct FireworkParticle: Identifiable {
    let id = UUID()
    var startPosition: CGPoint
    var endPosition: CGPoint
    var symbol: String
    var rotation: Angle
    var color: Color
}

struct FireworkParticleView: View {
    @State private var particles: [FireworkParticle] = []
    @State private var animate = false

    let symbols = ["+", "x", "*", "-", "="]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Text(particle.symbol)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(particle.color)
                        .rotationEffect(particle.rotation)
                        .position(animate ? particle.endPosition : particle.startPosition)
                        .opacity(animate ? 0 : 1)
                        .scaleEffect(animate ? 2 : 1)
                        .animation(.easeOut(duration: 1), value: animate)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                generateParticles(in: geometry.size)
                withAnimation {
                    animate = true
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private func generateParticles(in size: CGSize) {
        // Firework center near the top (25% down)
        let center = CGPoint(x: size.width / 2, y: size.height * 0.25)
        
        particles = (0..<20).map { _ in
            let angle = Double.random(in: 0...2 * .pi)
            let radius = Double.random(in: 50...150) // Final spread radius
            let offsetX = CGFloat(cos(angle) * radius)
            let offsetY = CGFloat(sin(angle) * radius)
            
            // Gradient color between blue & purple
            let t = Double.random(in: 0...1)
            let blue = Color.blue
            let purple = Color.purple
            let color = Color(
                red: (1 - t) * blue.components.red + t * purple.components.red,
                green: (1 - t) * blue.components.green + t * purple.components.green,
                blue: (1 - t) * blue.components.blue + t * purple.components.blue
            )
            
            return FireworkParticle(
                startPosition: center, // Start tightly together
                endPosition: CGPoint(x: center.x + offsetX, y: center.y + offsetY), // End spread out
                symbol: symbols.randomElement()!,
                rotation: .degrees(Double.random(in: 0...360)),
                color: color
            )
        }
    }
}

// RGB helper stays the same
extension Color {
    var components: (red: Double, green: Double, blue: Double) {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        return (Double(red), Double(green), Double(blue))
    }
}
