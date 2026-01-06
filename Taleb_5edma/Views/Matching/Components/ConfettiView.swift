//
//  ConfettiView.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import SwiftUI

/// Vue d'animation de confettis pour célébrer un excellent matching
struct ConfettiView: View {
    @State private var confetti: [ConfettiPiece] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confetti) { piece in
                    ConfettiPieceView(piece: piece)
                }
            }
            .onAppear {
                generateConfetti(in: geometry.size)
            }
        }
    }
    
    private func generateConfetti(in size: CGSize) {
        let colors: [Color] = [
            .red, .blue, .green, .yellow, .orange, .pink, .purple,
            AppColors.primaryRed, AppColors.accentBlue, AppColors.successGreen
        ]
        
        for _ in 0..<100 {
            let randomX = CGFloat.random(in: 0...size.width)
            let randomDelay = Double.random(in: 0...0.5)
            let randomDuration = Double.random(in: 2.0...4.0)
            let randomColor = colors.randomElement() ?? .red
            let randomRotation = Double.random(in: 0...360)
            
            let piece = ConfettiPiece(
                id: UUID(),
                x: randomX,
                y: -20,
                color: randomColor,
                rotation: randomRotation,
                delay: randomDelay,
                duration: randomDuration,
                endY: size.height + 50
            )
            
            confetti.append(piece)
        }
    }
}

// MARK: - Confetti Piece Model

struct ConfettiPiece: Identifiable {
    let id: UUID
    let x: CGFloat
    let y: CGFloat
    let color: Color
    let rotation: Double
    let delay: Double
    let duration: Double
    let endY: CGFloat
}

// MARK: - Confetti Piece View

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    @State private var isAnimating = false
    
    var body: some View {
        Rectangle()
            .fill(piece.color)
            .frame(width: 10, height: 10)
            .rotationEffect(.degrees(isAnimating ? piece.rotation + 720 : piece.rotation))
            .offset(
                x: piece.x + (isAnimating ? CGFloat.random(in: -50...50) : 0),
                y: isAnimating ? piece.endY : piece.y
            )
            .opacity(isAnimating ? 0.0 : 1.0)
            .onAppear {
                withAnimation(
                    .easeOut(duration: piece.duration)
                    .delay(piece.delay)
                ) {
                    isAnimating = true
                }
            }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
        
        ConfettiView()
    }
}

