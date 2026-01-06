//
//  OverloadedDaysView.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import SwiftUI

/// Vue affichant les jours surchargés
struct OverloadedDaysView: View {
    let overloadedDays: [EnhancedRoutineAnalysisResponse.OverloadedDay]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "calendar.badge.exclamationmark")
                    .foregroundColor(.orange)
                
                Text("Jours surchargés")
                    .font(.headline)
                    .foregroundColor(AppColors.black)
                
                Spacer()
                
                Text("\(overloadedDays.count)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.white)
                    .frame(minWidth: 24)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            if overloadedDays.isEmpty {
                EmptyOverloadedDaysView()
            } else {
                ForEach(overloadedDays) { day in
                    OverloadedDayCard(day: day)
                }
                .padding(.horizontal)
            }
        }
    }
}

/// Carte d'un jour surchargé
struct OverloadedDayCard: View {
    let day: EnhancedRoutineAnalysisResponse.OverloadedDay
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(day.jour)
                        .font(.headline)
                        .foregroundColor(AppColors.black)
                    
                    Text(formatDate(day.date))
                        .font(.caption)
                        .foregroundColor(AppColors.mediumGray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.1f h", day.totalHours))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(day.levelColor)
                    
                    Text(day.level.capitalized)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(day.levelColor)
                        .cornerRadius(8)
                }
            }
            
            // Barre de progression
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(day.levelColor.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(day.levelColor)
                        .frame(width: min(geometry.size.width * (CGFloat(day.totalHours) / 14.0), geometry.size.width), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
            
            // Recommandations (collapsible)
            if isExpanded && !day.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    
                    Text("Recommandations")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.mediumGray)
                    
                    ForEach(day.recommendations, id: \.self) { recommendation in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(AppColors.accentBlue)
                                .font(.caption)
                            
                            Text(recommendation)
                                .font(.caption)
                                .foregroundColor(AppColors.darkGray)
                        }
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding()
        .background(AppColors.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(day.levelColor.opacity(0.2), lineWidth: 1)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
            HapticManager.medium()
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

/// Vue pour aucun jour surchargé
struct EmptyOverloadedDaysView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 48))
                .foregroundColor(AppColors.successGreen)
            
            Text("Aucun jour surchargé")
                .font(.headline)
                .foregroundColor(AppColors.black)
            
            Text("Votre charge de travail est bien répartie")
                .font(.subheadline)
                .foregroundColor(AppColors.mediumGray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal)
        .background(AppColors.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            OverloadedDaysView(overloadedDays: [
                EnhancedRoutineAnalysisResponse.OverloadedDay(
                    date: "2024-01-16",
                    jour: "Mardi",
                    totalHours: 13.5,
                    level: "élevé",
                    recommendations: [
                        "Déplacez 1-2h d'activités",
                        "Prévoyez des pauses"
                    ]
                )
            ])
            
            OverloadedDaysView(overloadedDays: [])
        }
        .padding()
        .background(AppColors.backgroundGray)
    }
}

