//
//  RecommendationsListView.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import SwiftUI

/// Vue affichant les recommandations IA
struct RecommendationsListView: View {
    let recommendations: [EnhancedRoutineAnalysisResponse.Recommendation]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(AppColors.primaryRed)
                
                Text("Recommandations IA")
                    .font(.headline)
                    .foregroundColor(AppColors.black)
                
                Spacer()
                
                Text("\(recommendations.count)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.white)
                    .frame(minWidth: 24)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.primaryRed)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            if recommendations.isEmpty {
                EmptyRecommendationsView()
            } else {
                ForEach(recommendations) { recommendation in
                    RecommendationCard(recommendation: recommendation)
                }
                .padding(.horizontal)
            }
        }
    }
}

/// Carte d'une recommandation individuelle
struct RecommendationCard: View {
    let recommendation: EnhancedRoutineAnalysisResponse.Recommendation
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top, spacing: 12) {
                // Icône
                Image(systemName: recommendation.typeIcon)
                    .foregroundColor(recommendation.priorityColor)
                    .font(.title3)
                    .frame(width: 32, height: 32)
                    .background(recommendation.priorityColor.opacity(0.1))
                    .cornerRadius(8)
                
                // Contenu
                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.titre)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.black)
                    
                    Text(recommendation.type.capitalized)
                        .font(.caption)
                        .foregroundColor(AppColors.mediumGray)
                }
                
                Spacer()
                
                // Badge de priorité
                Text(priorityLabel)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(recommendation.priorityColor)
                    .cornerRadius(8)
            }
            
            // Description (toujours visible mais tronquée)
            Text(recommendation.description)
                .font(.caption)
                .foregroundColor(AppColors.darkGray)
                .lineLimit(isExpanded ? nil : 2)
            
            // Action suggérée (collapsible)
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "hand.tap.fill")
                            .foregroundColor(AppColors.accentBlue)
                            .font(.caption)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Action suggérée")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.mediumGray)
                            
                            Text(recommendation.actionSuggeree)
                                .font(.caption)
                                .foregroundColor(AppColors.darkGray)
                        }
                    }
                    .padding(8)
                    .background(AppColors.accentBlue.opacity(0.1))
                    .cornerRadius(8)
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
                .stroke(recommendation.priorityColor.opacity(0.2), lineWidth: 1)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
            HapticManager.medium()
        }
    }
    
    private var priorityLabel: String {
        switch recommendation.priorite.lowercased() {
        case "haute": return "URGENT"
        case "moyenne": return "MOYEN"
        default: return "INFO"
        }
    }
}

/// Vue pour aucune recommandation
struct EmptyRecommendationsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(AppColors.successGreen)
            
            Text("Tout est parfait !")
                .font(.headline)
                .foregroundColor(AppColors.black)
            
            Text("Aucune recommandation pour le moment")
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
            RecommendationsListView(recommendations: [
                EnhancedRoutineAnalysisResponse.Recommendation(
                    id: "rec1",
                    type: "optimisation",
                    titre: "Résoudre le conflit du mardi",
                    description: "Vous avez un conflit entre votre cours de mathématiques et votre travail au restaurant. Il est important de résoudre ce conflit rapidement.",
                    priorite: "haute",
                    actionSuggeree: "Contactez votre employeur pour décaler votre horaire de 2 heures"
                ),
                EnhancedRoutineAnalysisResponse.Recommendation(
                    id: "rec2",
                    type: "suggestion",
                    titre: "Optimiser votre temps de repos",
                    description: "Vous pourriez mieux répartir vos heures de repos pour améliorer votre productivité.",
                    priorite: "moyenne",
                    actionSuggeree: "Ajoutez des pauses de 15 minutes entre vos activités"
                )
            ])
            
            RecommendationsListView(recommendations: [])
        }
        .padding()
        .background(AppColors.backgroundGray)
    }
}

