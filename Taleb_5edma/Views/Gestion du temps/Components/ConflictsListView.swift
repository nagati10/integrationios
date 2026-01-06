//
//  ConflictsListView.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import SwiftUI

/// Vue affichant la liste des conflits détectés
struct ConflictsListView: View {
    let conflicts: [EnhancedRoutineAnalysisResponse.Conflict]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(AppColors.errorRed)
                
                Text("Conflits détectés")
                    .font(.headline)
                    .foregroundColor(AppColors.black)
                
                Spacer()
                
                Text("\(conflicts.count)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.white)
                    .frame(minWidth: 24)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.errorRed)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            if conflicts.isEmpty {
                EmptyConflictsView()
            } else {
                ForEach(conflicts) { conflict in
                    ConflictCard(conflict: conflict)
                }
                .padding(.horizontal)
            }
        }
    }
}

/// Carte d'un conflit individuel
struct ConflictCard: View {
    let conflict: EnhancedRoutineAnalysisResponse.Conflict
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header du conflit
            HStack(spacing: 12) {
                // Icône de gravité
                Image(systemName: conflict.severityIcon)
                    .foregroundColor(conflict.severityColor)
                    .font(.title3)
                
                // Infos principales
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatDate(conflict.date))
                        .font(.caption)
                        .foregroundColor(AppColors.mediumGray)
                    
                    HStack(spacing: 4) {
                        Text(conflict.event1.titre)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.black)
                        
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.caption)
                            .foregroundColor(AppColors.mediumGray)
                        
                        Text(conflict.event2.titre)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.black)
                    }
                }
                
                Spacer()
                
                // Badge de gravité
                Text(severityLabel)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(conflict.severityColor)
                    .cornerRadius(8)
            }
            
            // Détails (collapsible)
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    
                    // Horaires
                    HStack {
                        Label(conflict.event1.heureDebut, systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(AppColors.mediumGray)
                        
                        Spacer()
                        
                        Label(conflict.event2.heureDebut, systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(AppColors.mediumGray)
                    }
                    
                    // Durée de chevauchement
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(AppColors.errorRed)
                        
                        Text("Chevauchement de \(conflict.overlapDuration) min")
                            .font(.caption)
                            .foregroundColor(AppColors.mediumGray)
                    }
                    
                    // Suggestion
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        
                        Text(conflict.suggestion)
                            .font(.caption)
                            .foregroundColor(AppColors.darkGray)
                    }
                    .padding(8)
                    .background(Color.orange.opacity(0.1))
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
                .stroke(conflict.severityColor.opacity(0.2), lineWidth: 1)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
            HapticManager.medium()
        }
    }
    
    private var severityLabel: String {
        switch conflict.severity.lowercased() {
        case "high": return "URGENT"
        case "medium": return "MOYEN"
        default: return "FAIBLE"
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        formatter.dateFormat = "EEEE d MMM"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date).capitalized
    }
}

/// Vue pour aucun conflit
struct EmptyConflictsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(AppColors.successGreen)
            
            Text("Aucun conflit détecté")
                .font(.headline)
                .foregroundColor(AppColors.black)
            
            Text("Votre planning est bien organisé !")
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
            ConflictsListView(conflicts: [
                EnhancedRoutineAnalysisResponse.Conflict(
                    date: "2024-01-15",
                    event1: EnhancedRoutineAnalysisResponse.Conflict.ConflictEvent(
                        titre: "Cours Math",
                        heureDebut: "09:00"
                    ),
                    event2: EnhancedRoutineAnalysisResponse.Conflict.ConflictEvent(
                        titre: "Job Restaurant",
                        heureDebut: "10:30"
                    ),
                    severity: "high",
                    suggestion: "Vous devez déplacer l'un des deux événements",
                    overlapDuration: 30
                )
            ])
            
            ConflictsListView(conflicts: [])
        }
        .padding()
        .background(AppColors.backgroundGray)
    }
}

