//
//  EnhancedRoutineAnalysis.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import Foundation
import SwiftUI

// MARK: - Request Model

/// Modèle de requête pour l'analyse de routine améliorée
struct EnhancedRoutineAnalysisRequest: Codable {
    let evenements: [EvenementInput]
    let disponibilites: [DisponibiliteInput]
    let dateDebut: String
    let dateFin: String
    
    struct EvenementInput: Codable {
        let id: String
        let titre: String
        let type: String
        let date: String
        let heureDebut: String
        let heureFin: String
    }
    
    struct DisponibiliteInput: Codable {
        let id: String
        let jour: String
        let heureDebut: String
        let heureFin: String
    }
}

// MARK: - Response Model

/// Modèle de réponse de l'analyse de routine améliorée
struct EnhancedRoutineAnalysisResponse: Codable {
    let success: Bool
    let data: AnalysisData
    
    struct AnalysisData: Codable {
        let scoreEquilibre: Double
        let scoreBreakdown: ScoreBreakdown
        let conflicts: [Conflict]
        let overloadedDays: [OverloadedDay]
        let availableTimeSlots: [AvailableTimeSlot]
        let recommandations: [Recommendation]
        let analyseHebdomadaire: WeeklyAnalysis
        let healthSummary: HealthSummary
    }
    
    /// Détails du calcul du score
    struct ScoreBreakdown: Codable {
        let baseScore: Double
        let workStudyBalance: Double
        let restPenalty: Double
        let conflictPenalty: Double
        let overloadPenalty: Double
        let bonuses: Double
    }
    
    /// Conflit entre deux événements
    struct Conflict: Codable, Identifiable {
        var id: String { "\(date)-\(event1.titre)-\(event2.titre)" }
        let date: String
        let event1: ConflictEvent
        let event2: ConflictEvent
        let severity: String // "high", "medium", "low"
        let suggestion: String
        let overlapDuration: Int // en minutes
        
        struct ConflictEvent: Codable {
            let titre: String
            let heureDebut: String
        }
        
        /// Couleur selon la gravité
        var severityColor: Color {
            switch severity.lowercased() {
            case "high": return AppColors.errorRed
            case "medium": return .orange
            default: return .yellow
            }
        }
        
        /// Icône selon la gravité
        var severityIcon: String {
            switch severity.lowercased() {
            case "high": return "exclamationmark.triangle.fill"
            case "medium": return "exclamationmark.circle.fill"
            default: return "info.circle.fill"
            }
        }
    }
    
    /// Jour surchargé
    struct OverloadedDay: Codable, Identifiable {
        var id: String { date }
        let date: String
        let jour: String
        let totalHours: Double
        let level: String // "élevé", "modéré", "léger"
        let recommendations: [String]
        
        /// Couleur selon le niveau
        var levelColor: Color {
            switch level.lowercased() {
            case "élevé": return AppColors.errorRed
            case "modéré": return .orange
            default: return .yellow
            }
        }
    }
    
    /// Créneau disponible
    struct AvailableTimeSlot: Codable, Identifiable {
        var id: String { "\(jour)-\(heureDebut)" }
        let jour: String
        let heureDebut: String
        let heureFin: String
        let duration: Double
    }
    
    /// Recommandation IA
    struct Recommendation: Codable, Identifiable {
        let id: String
        let type: String // "optimisation", "warning", "suggestion"
        let titre: String
        let description: String
        let priorite: String // "haute", "moyenne", "basse"
        let actionSuggeree: String
        
        /// Couleur selon la priorité
        var priorityColor: Color {
            switch priorite.lowercased() {
            case "haute": return AppColors.errorRed
            case "moyenne": return .orange
            default: return AppColors.accentBlue
            }
        }
        
        /// Icône selon le type
        var typeIcon: String {
            switch type.lowercased() {
            case "optimisation": return "sparkles"
            case "warning": return "exclamationmark.triangle.fill"
            default: return "lightbulb.fill"
            }
        }
    }
    
    /// Analyse hebdomadaire
    struct WeeklyAnalysis: Codable {
        let heuresTravail: Double
        let heuresEtudes: Double
        let heuresRepos: Double
        let heuresActivites: Double
        
        var total: Double {
            heuresTravail + heuresEtudes + heuresRepos + heuresActivites
        }
        
        /// Pourcentage de chaque catégorie
        var workPercentage: Double {
            guard total > 0 else { return 0 }
            return (heuresTravail / total) * 100
        }
        
        var studyPercentage: Double {
            guard total > 0 else { return 0 }
            return (heuresEtudes / total) * 100
        }
        
        var restPercentage: Double {
            guard total > 0 else { return 0 }
            return (heuresRepos / total) * 100
        }
        
        var activitiesPercentage: Double {
            guard total > 0 else { return 0 }
            return (heuresActivites / total) * 100
        }
    }
    
    /// Résumé de santé
    struct HealthSummary: Codable {
        let status: String // "bon", "moyen", "critique"
        let mainIssues: [String]
        let mainStrengths: [String]
        
        /// Couleur selon le statut
        var statusColor: Color {
            switch status.lowercased() {
            case "bon": return AppColors.successGreen
            case "moyen": return .orange
            default: return AppColors.errorRed
            }
        }
        
        /// Icône selon le statut
        var statusIcon: String {
            switch status.lowercased() {
            case "bon": return "checkmark.circle.fill"
            case "moyen": return "exclamationmark.circle.fill"
            default: return "xmark.circle.fill"
            }
        }
    }
}

// MARK: - Cache Model

/// Modèle pour le cache de l'analyse
struct CachedRoutineAnalysis: Codable {
    let data: EnhancedRoutineAnalysisResponse
    let timestamp: Date
    
    /// Vérifie si le cache est encore valide (moins de 1 heure)
    var isValid: Bool {
        Date().timeIntervalSince(timestamp) < 3600 // 1 heure
    }
}

