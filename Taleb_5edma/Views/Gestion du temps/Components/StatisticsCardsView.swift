//
//  StatisticsCardsView.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import SwiftUI

/// Vue affichant les statistiques hebdomadaires en cartes colorées
struct StatisticsCardsView: View {
    let weeklyAnalysis: EnhancedRoutineAnalysisResponse.WeeklyAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analyse hebdomadaire")
                .font(.headline)
                .foregroundColor(AppColors.black)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                WeeklyStatCard(
                    title: "Travail",
                    hours: weeklyAnalysis.heuresTravail,
                    percentage: weeklyAnalysis.workPercentage,
                    icon: "briefcase.fill",
                    color: AppColors.primaryRed
                )
                
                WeeklyStatCard(
                    title: "Études",
                    hours: weeklyAnalysis.heuresEtudes,
                    percentage: weeklyAnalysis.studyPercentage,
                    icon: "book.fill",
                    color: AppColors.accentBlue
                )
                
                WeeklyStatCard(
                    title: "Repos",
                    hours: weeklyAnalysis.heuresRepos,
                    percentage: weeklyAnalysis.restPercentage,
                    icon: "moon.fill",
                    color: AppColors.successGreen
                )
                
                WeeklyStatCard(
                    title: "Activités",
                    hours: weeklyAnalysis.heuresActivites,
                    percentage: weeklyAnalysis.activitiesPercentage,
                    icon: "flame.fill",
                    color: .orange
                )
            }
            .padding(.horizontal)
        }
    }
}

/// Carte individuelle de statistique hebdomadaire
private struct WeeklyStatCard: View {
    let title: String
    let hours: Double
    let percentage: Double
    let icon: String
    let color: Color
    
    @State private var animatedHours: Double = 0
    @State private var animatedPercentage: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icône et titre
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
                
                Text(String(format: "%.0f%%", animatedPercentage))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.darkGray)
            
            // Heures
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", animatedHours))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.black)
                
                Text("h")
                    .font(.subheadline)
                    .foregroundColor(AppColors.mediumGray)
            }
            
            // Barre de progression
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(color.opacity(0.1))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    // Progress
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * (animatedPercentage / 100), height: 4)
                        .cornerRadius(2)
                        .animation(.spring(response: 1.0, dampingFraction: 0.7), value: animatedPercentage)
                }
            }
            .frame(height: 4)
        }
        .padding()
        .background(AppColors.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .task {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.1)) {
                animatedHours = hours
                animatedPercentage = percentage
            }
        }
    }
}

#Preview {
    StatisticsCardsView(
        weeklyAnalysis: EnhancedRoutineAnalysisResponse.WeeklyAnalysis(
            heuresTravail: 20,
            heuresEtudes: 25,
            heuresRepos: 45,
            heuresActivites: 10
        )
    )
    .padding()
    .background(AppColors.backgroundGray)
}

