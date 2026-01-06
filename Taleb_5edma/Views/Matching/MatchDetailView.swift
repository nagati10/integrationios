//
//  MatchDetailView.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import SwiftUI

/// Vue détaillée d'un résultat de matching
struct MatchDetailView: View {
    let match: MatchResult
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header avec score principal
                    scoreHeader
                    
                    // Détails du poste
                    jobDetails
                    
                    // Scores détaillés
                    if hasDetailedScores {
                        detailedScores
                    }
                    
                    // Points forts
                    if let strengths = match.strengths, !strengths.isEmpty {
                        strengthsSection(strengths: strengths)
                    }
                    
                    // Avertissements
                    if let warnings = match.warnings, !warnings.isEmpty {
                        warningsSection(warnings: warnings)
                    }
                    
                    // Détails supplémentaires
                    if let details = match.details {
                        additionalDetails(details: details)
                    }
                    
                    // Bouton d'action
                    actionButton
                }
                .padding()
            }
            .background(backgroundColor)
            .navigationTitle(match.titre)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryRed)
                }
            }
        }
    }
    
    // MARK: - Colors
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : AppColors.backgroundGray
    }
    
    private var textColor: Color {
        colorScheme == .dark ? .white : AppColors.black
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? .gray : AppColors.mediumGray
    }
    
    private var cardBackground: Color {
        colorScheme == .dark ? Color(uiColor: .systemGray6) : .white
    }
    
    // MARK: - Score Header
    
    private var scoreHeader: some View {
        VStack(spacing: 16) {
            // Score circulaire animé
            ZStack {
                Circle()
                    .stroke(AppColors.lightGray, lineWidth: 12)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: match.scores.score / 100)
                    .stroke(match.matchLevel.color, lineWidth: 12)
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text(String(format: "%.0f", match.scores.score))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(textColor)
                    
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(secondaryTextColor)
                }
            }
            .padding()
            
            // Niveau et recommandation
            VStack(spacing: 8) {
                HStack {
                    Text(match.matchLevel.emoji)
                        .font(.title)
                    
                    Text(match.matchLevel.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(match.matchLevel.color)
                }
                
                Text(match.recommendation)
                    .font(.body)
                    .foregroundColor(secondaryTextColor)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Job Details
    
    private var jobDetails: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Détails du poste")
                .font(.headline)
                .foregroundColor(textColor)
            
            if let description = match.description {
                Text(description)
                    .font(.body)
                    .foregroundColor(secondaryTextColor)
            }
            
            VStack(spacing: 12) {
                if let company = match.company {
                    MatchingDetailRow(icon: "building.2.fill", title: "Entreprise", value: company, colorScheme: colorScheme)
                }
                
                if let location = match.location {
                    MatchingDetailRow(icon: "mappin.circle.fill", title: "Localisation", value: location, colorScheme: colorScheme)
                }
                
                if let salary = match.salary {
                    MatchingDetailRow(icon: "banknote.fill", title: "Salaire", value: salary, colorScheme: colorScheme)
                }
                
                if let jobType = match.jobType {
                    MatchingDetailRow(icon: "briefcase.fill", title: "Type", value: jobType, colorScheme: colorScheme)
                }
            }
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Detailed Scores
    
    private var hasDetailedScores: Bool {
        match.scores.timeCompatibility != nil ||
        match.scores.skillsMatch != nil ||
        match.scores.locationMatch != nil ||
        match.scores.salaryMatch != nil
    }
    
    private var detailedScores: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Scores détaillés")
                .font(.headline)
                .foregroundColor(textColor)
            
            if let score = match.scores.timeCompatibility {
                ScoreBar(title: "Compatibilité temporelle", score: score, color: AppColors.successGreen)
            }
            
            if let score = match.scores.skillsMatch {
                ScoreBar(title: "Compétences", score: score, color: AppColors.accentBlue)
            }
            
            if let score = match.scores.locationMatch {
                ScoreBar(title: "Localisation", score: score, color: .orange)
            }
            
            if let score = match.scores.salaryMatch {
                ScoreBar(title: "Salaire", score: score, color: .purple)
            }
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Strengths Section
    
    private func strengthsSection(strengths: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                
                Text("Points forts")
                    .font(.headline)
                    .foregroundColor(textColor)
            }
            
            ForEach(strengths, id: \.self) { strength in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.successGreen)
                    
                    Text(strength)
                        .font(.body)
                        .foregroundColor(secondaryTextColor)
                }
            }
        }
        .padding()
        .background(AppColors.successGreen.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Warnings Section
    
    private func warningsSection(warnings: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                Text("Points d'attention")
                    .font(.headline)
                    .foregroundColor(textColor)
            }
            
            ForEach(warnings, id: \.self) { warning in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.orange)
                    
                    Text(warning)
                        .font(.body)
                        .foregroundColor(secondaryTextColor)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Additional Details
    
    private func additionalDetails(details: MatchResult.MatchDetails) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Informations complémentaires")
                .font(.headline)
                .foregroundColor(textColor)
            
            if let available = details.availableHours {
                MatchingDetailRow(icon: "clock.fill", title: "Heures disponibles", value: "\(available)h/semaine", colorScheme: colorScheme)
            }
            
            if let required = details.requiredHours {
                MatchingDetailRow(icon: "clock.badge.checkmark.fill", title: "Heures requises", value: "\(required)h/semaine", colorScheme: colorScheme)
            }
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Action Button
    
    private var actionButton: some View {
        Button(action: {
            HapticManager.shared.impact(style: .heavy)
            // TODO: Implémenter la candidature
            print("Postuler à: \(match.titre)")
        }) {
            Text("Postuler maintenant")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [AppColors.primaryRed, AppColors.primaryRed.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
        }
        .shadow(color: AppColors.primaryRed.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Matching Detail Row Component

struct MatchingDetailRow: View {
    let icon: String
    let title: String
    let value: String
    let colorScheme: ColorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primaryRed)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .gray : AppColors.mediumGray)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(colorScheme == .dark ? .white : AppColors.black)
        }
    }
}

// MARK: - Score Bar Component

struct ScoreBar: View {
    let title: String
    let score: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppColors.black)
                
                Spacer()
                
                Text(String(format: "%.0f%%", score))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppColors.lightGray)
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * (score / 100), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

#Preview {
    MatchDetailView(match: MatchResult(
        id: "1",
        titre: "Développeur iOS",
        entreprise: "Tech Corp",
        ville: "Tunis",
        horaire: "Journée (environ 09:00-17:00)",
        jobType: "Stage",
        scores: MatchResult.MatchScores(
            score: 92,
            timeScore: 95,
            preferenceScore: 85,
            profileScore: 88
        ),
        recommendation: "Excellente opportunité pour développer vos compétences",
        reasons: [
            MatchResult.MatchReason(type: "positive", message: "Horaires flexibles", weight: 0.8),
            MatchResult.MatchReason(type: "positive", message: "Proche de votre domicile", weight: 0.7),
            MatchResult.MatchReason(type: "negative", message: "Salaire en dessous de vos attentes", weight: 0.5)
        ],
        rank: 1
    ))
}

