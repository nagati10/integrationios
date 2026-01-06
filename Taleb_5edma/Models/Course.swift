//
//  Course.swift
//  Taleb_5edma
//
//  Created by Apple on 07/12/2025.
//

import Foundation

/// Modèle représentant un cours extrait d'un emploi du temps PDF
/// Correspond à la réponse du backend après traitement IA
struct Course: Codable, Identifiable {
    let id: UUID
    let day: String           // "Monday", "Tuesday", etc.
    let start: String         // Format: "09:00"
    let end: String           // Format: "10:30"
    let subject: String       // Nom du cours
    let classroom: String?    // Salle de cours (optionnel)
    let teacher: String?      // Professeur (optionnel)
    
    enum CodingKeys: String, CodingKey {
        case day
        case start
        case end
        case subject
        case classroom
        case teacher
    }
    
    init(day: String, start: String, end: String, subject: String, classroom: String? = nil, teacher: String? = nil) {
        self.id = UUID()
        self.day = day
        self.start = start
        self.end = end
        self.subject = subject
        self.classroom = classroom
        self.teacher = teacher
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.day = try container.decode(String.self, forKey: .day)
        self.start = try container.decode(String.self, forKey: .start)
        self.end = try container.decode(String.self, forKey: .end)
        self.subject = try container.decode(String.self, forKey: .subject)
        self.classroom = try container.decodeIfPresent(String.self, forKey: .classroom)
        self.teacher = try container.decodeIfPresent(String.self, forKey: .teacher)
    }
    
    /// Convertit le jour anglais en français
    var dayInFrench: String {
        switch day.lowercased() {
        case "monday": return "Lundi"
        case "tuesday": return "Mardi"
        case "wednesday": return "Mercredi"
        case "thursday": return "Jeudi"
        case "friday": return "Vendredi"
        case "saturday": return "Samedi"
        case "sunday": return "Dimanche"
        default: return day
        }
    }
    
    /// Génère une description complète du cours
    var fullDescription: String {
        var description = subject
        if let classroom = classroom {
            description += " - Salle \(classroom)"
        }
        if let teacher = teacher {
            description += " - Prof. \(teacher)"
        }
        return description
    }
}

/// Réponse du backend après traitement du PDF
struct ProcessedScheduleResponse: Codable {
    let courses: [Course]
    let message: String?
}

/// Requête pour créer les événements à partir des cours
struct CreateEventsFromScheduleRequest: Codable {
    let courses: [Course]
    let weekStartDate: String?  // Format: "2024-12-01" (optionnel, par défaut lundi de la semaine courante)
    
    init(courses: [Course], weekStartDate: String? = nil) {
        self.courses = courses
        self.weekStartDate = weekStartDate
    }
}

/// Réponse après création des événements
struct CreateEventsResponse: Codable {
    let message: String
    let eventsCreated: Int
    let events: [Evenement]?
}

