//
//  ScoreGaugeView.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import SwiftUI

/// Vue affichant le score d'équilibre avec une jauge circulaire animée
struct ScoreGaugeView: View {
    let score: Double
    let label: String
    let color: Color
    
    @State private var animatedScore: Double = 0
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Cercle de fond
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 20)
                    .frame(width: 180, height: 180)
                
                // Cercle de progression
                Circle()
                    .trim(from: 0, to: animatedScore / 100)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [color.opacity(0.7), color]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.5, dampingFraction: 0.7), value: animatedScore)
                
                // Score au centre
                VStack(spacing: 4) {
                    Text(String(format: "%.0f", animatedScore))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(color)
                    
                    Text("/ 100")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.mediumGray)
                }
            }
            
            // Label
            Text(label)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.black)
            
            // Icône de statut
            HStack(spacing: 8) {
                Image(systemName: statusIcon)
                    .foregroundColor(color)
                
                Text(statusText)
                    .font(.subheadline)
                    .foregroundColor(AppColors.mediumGray)
            }
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 1.5, dampingFraction: 0.7).delay(0.2)) {
                animatedScore = score
            }
        }
        .onChange(of: score) { oldValue, newValue in
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                animatedScore = newValue
            }
        }
    }
    
    private var statusIcon: String {
        if score >= 75 { return "checkmark.circle.fill" }
        if score >= 50 { return "exclamationmark.circle.fill" }
        return "xmark.circle.fill"
    }
    
    private var statusText: String {
        if score >= 75 { return "Excellent" }
        if score >= 50 { return "Peut mieux faire" }
        return "Critique"
    }
}

#Preview {
    VStack(spacing: 40) {
        ScoreGaugeView(
            score: 85,
            label: "Score d'équilibre",
            color: AppColors.successGreen
        )
        
        ScoreGaugeView(
            score: 65,
            label: "Score d'équilibre",
            color: .orange
        )
        
        ScoreGaugeView(
            score: 35,
            label: "Score d'équilibre",
            color: AppColors.errorRed
        )
    }
    .padding()
}

