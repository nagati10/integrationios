//
//  Matching.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import Foundation
import SwiftUI

// MARK: - Request Models

/// Modèle de requête pour l'analyse de matching
struct MatchingRequest: Codable {
    let studentId: String
    let disponibilites: [DisponibiliteInput]
    let preferences: MatchingPreferences?
    
    /// Structure simplifiée des disponibilités pour le matching
    struct DisponibiliteInput: Codable {
        let jour: String
        let heureDebut: String
        let heureFin: String?
        
        /// Initializer depuis le modèle Disponibilite
        init(from disponibilite: Disponibilite) {
            self.jour = disponibilite.jour
            self.heureDebut = disponibilite.heureDebut
            self.heureFin = disponibilite.heureFin
        }
    }
    
    /// Préférences de l'utilisateur pour le matching
    struct MatchingPreferences: Codable {
        let jobType: String?
        let salary: String?
        let location: String?
        let category: String?
        
        init(jobType: String? = nil, salary: String? = nil, location: String? = nil, category: String? = nil) {
            self.jobType = jobType
            self.salary = salary
            self.location = location
            self.category = category
        }
    }
}

// MARK: - Response Models

/// Modèle de réponse de l'analyse de matching
struct MatchingResponse: Codable {
    let studentId: String?
    let totalOffres: Int?
    let matches: [MatchResult]
    let summary: MatchingSummary?
    let timestamp: String?
    
    /// Résumé global du matching
    struct MatchingSummary: Codable {
        let bestMatch: MatchResult?
        let averageScore: Double?
        let highScoreCount: Int?
        let mediumScoreCount: Int?
        let lowScoreCount: Int?
    }
}

/// Résultat de matching pour une offre
struct MatchResult: Codable, Identifiable {
    let id: String
    let titre: String
    let entreprise: String?
    let ville: String?
    let horaire: String?
    let jobType: String?
    let scores: MatchScores
    let recommendation: String
    let reasons: [MatchReason]?
    let rank: Int?
    
    /// Scores détaillés du matching
    struct MatchScores: Codable {
        let score: Double // Score global (0-100)
        let timeScore: Double?
        let preferenceScore: Double?
        let profileScore: Double?
        
        enum CodingKeys: String, CodingKey {
            case score
            case timeScore
            case preferenceScore
            case profileScore
        }
        
        // MARK: - Computed Properties (Compatibilité avec l'UI)
        
        /// Alias pour compatibilité avec l'UI existante
        var timeCompatibility: Double? { timeScore }
        
        /// Alias pour compatibilité avec l'UI existante
        var skillsMatch: Double? { profileScore }
        
        /// Alias pour compatibilité avec l'UI existante
        var locationMatch: Double? { nil }
        
        /// Alias pour compatibilité avec l'UI existante
        var salaryMatch: Double? { preferenceScore }
    }
    
    /// Raison du matching
    struct MatchReason: Codable {
        let type: String // "positive", "negative", "neutral"
        let message: String
        let weight: Double?
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "offreId"
        case titre
        case entreprise
        case ville
        case horaire
        case jobType
        case scores
        case recommendation
        case reasons
        case rank
    }
    
    // MARK: - Computed Properties (Compatibilité avec l'UI)
    
    /// Alias pour compatibilité avec l'UI existante
    var company: String? { entreprise }
    
    /// Alias pour compatibilité avec l'UI existante
    var location: String? { ville }
    
    /// Description (utilise horaire si disponible)
    var description: String? { horaire }
    
    /// Salary (non fourni par le backend, nil)
    var salary: String? { nil }
    
    /// Strengths extraits des reasons positives
    var strengths: [String]? {
        reasons?
            .filter { $0.type == "positive" }
            .map { $0.message }
    }
    
    /// Warnings extraits des reasons négatives
    var warnings: [String]? {
        reasons?
            .filter { $0.type == "negative" }
            .map { $0.message }
    }
    
    /// Details (non fourni par le backend, nil)
    var details: MatchDetails? { nil }
    
    /// MatchDetails vide pour compatibilité
    struct MatchDetails: Codable {
        let availableHours: Int?
        let requiredHours: Int?
        let matchedSkills: [String]?
        let missingSkills: [String]?
        
        init(availableHours: Int? = nil, requiredHours: Int? = nil, matchedSkills: [String]? = nil, missingSkills: [String]? = nil) {
            self.availableHours = availableHours
            self.requiredHours = requiredHours
            self.matchedSkills = matchedSkills
            self.missingSkills = missingSkills
        }
    }
    
    /// Niveau de matching basé sur le score
    var matchLevel: MatchLevel {
        let score = scores.score
        if score >= 90 { return .excellent }
        if score >= 75 { return .good }
        if score >= 60 { return .average }
        return .poor
    }
    
    /// Score formaté en pourcentage
    var scorePercentage: String {
        return String(format: "%.0f%%", scores.score)
    }
}

/// Niveau de matching
enum MatchLevel: String, CaseIterable {
    case excellent = "Excellent"
    case good = "Bon"
    case average = "Moyen"
    case poor = "Faible"
    
    var color: Color {
        switch self {
        case .excellent: return AppColors.successGreen
        case .good: return .green
        case .average: return .orange
        case .poor: return AppColors.errorRed
        }
    }
    
    var emoji: String {
        switch self {
        case .excellent: return "🎯"
        case .good: return "👍"
        case .average: return "🤔"
        case .poor: return "⚠️"
        }
    }
}

