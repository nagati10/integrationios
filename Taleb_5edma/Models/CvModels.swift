// CvModels.swift
//  Taleb_5edma

import Foundation

/// Réponse de ton backend CV (même structure que sur Android)
struct CvStructuredResponse: Codable {
    let name: String?
    let email: String?
    let phone: String?
    let experience: [String]
    let education: [String]
    let skills: [String]
}

/// Body pour PATCH /user/me/cv/profile
/// Le backend attend experience, education, skills (sans préfixe "cv")
/// mais les stocke comme cvExperience, cvEducation, cvSkills
/// Note: On n'envoie PAS l'email car l'utilisateur est déjà connecté
struct CreateProfileFromCvRequest: Codable {
    let name: String?
    let phone: String?
    let experience: [String]?
    let education: [String]?
    let skills: [String]?
    
    // Initializer pour faciliter la création depuis CvStructuredResponse
    // On n'utilise pas l'email du CV car l'utilisateur en a déjà un
    init(name: String?, phone: String?, experience: [String], education: [String], skills: [String]) {
        self.name = name
        self.phone = phone
        self.experience = experience.isEmpty ? nil : experience
        self.education = education.isEmpty ? nil : education
        self.skills = skills.isEmpty ? nil : skills
    }
}


