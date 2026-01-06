//
//  User.swift
//  Taleb5edma-cursor
//
//  Created by Apple on 08/11/2025.
//

import Foundation

/// Modèle représentant un utilisateur de l'application
/// Correspond aux DTOs du backend (CreateUserDto, UpdateUserDto)
struct User: Codable, Identifiable, Equatable {
    let id: String
    let email: String
    let nom: String  // ⚠️ Le backend utilise "nom" au lieu de "username"
    let contact: String  // ⚠️ Le backend utilise "contact" au lieu de "contactNumber"
    var image: String?  // ⚠️ Le backend utilise "image" au lieu de "profileImageURL"
    var role: String?  // Rôle de l'utilisateur (optionnel)
    var createdAt: Date?
    var updatedAt: Date?
    
    // User Status & Settings
    var modeExamens: Bool?       // Exam mode enabled/disabled
    var is_archive: Bool?        // Account archived status
    var is_Organization: Bool?   // Organization account flag
    var isOnline: Bool?          // Current online status
    var Currentstatus: String?   // Current status (active, busy, etc.)
    var lastSeen: Date?          // Last activity timestamp
    
    // User Stats & Activity
    var TrustXP: Int?            // Trust/Experience points
    var likedOffres: [String]?   // Array of liked offer IDs
    var chats: [String]?         // Array of chat IDs
    var blockedUsers: [String]?  // Array of blocked user IDs
    
    // CV Analysis Fields (from AI CV Analysis feature)
    var cvExperience: [String]?  // Work experience entries from CV
    var cvEducation: [String]?   // Education history entries from CV
    var cvSkills: [String]?      // Skills extracted from CV
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
        case nom  // Correspond au champ "nom" dans CreateUserDto
        case contact  // Correspond au champ "contact" dans CreateUserDto
        case image  // Correspond au champ "image" dans CreateUserDto
        case role
        case createdAt
        case updatedAt
        
        // Status & Settings
        case modeExamens
        case is_archive
        case is_Organization
        case isOnline
        case Currentstatus
        case lastSeen
        
        // Stats & Activity
        case TrustXP
        case likedOffres
        case chats
        case blockedUsers
        
        // CV Fields
        case cvExperience
        case cvEducation
        case cvSkills
    }
}

/// Modèle pour la réponse d'authentification
/// ⚠️ Le backend renvoie "access_token" au lieu de "token"
struct AuthResponse: Codable {
    let user: User
    let token: String  // Mappé depuis "access_token"
    let refreshToken: String?  // Optionnel, peut ne pas être présent
    let status: String?  // Optionnel : "success" ou "error"
    let message: String?  // Optionnel : message du serveur
    
    enum CodingKeys: String, CodingKey {
        case user
        case token = "access_token"  // ⚠️ Le backend utilise "access_token"
        case refreshToken
        case status
        case message
    }
}

/// Modèle pour la requête de login
struct LoginRequest: Codable {
    let email: String
    let password: String
}

/// Modèle pour la requête d'inscription
/// Correspond au CreateUserDto du backend
struct SignUpRequest: Codable {
    let nom: String  // ⚠️ Le backend attend "nom" (requis)
    let email: String  // Requis
    let password: String  // Requis
    let contact: String  // ⚠️ Le backend attend "contact" (requis)
    let role: String    // Rôle de l'utilisateur ("user" ou "admin")
    let is_Organization: Bool? // Pour différencier les entreprises
    let image: String?  // Optionnel selon le backend
    
    enum CodingKeys: String, CodingKey {
        case nom
        case email
        case password
        case contact
        case role
        case is_Organization
        case image
    }
}

/// Modèle pour la vérification du code
struct VerificationRequest: Codable {
    let code: String
    let email: String
}

/// Modèle pour la requête de réinitialisation du mot de passe
/// Correspond au ResetPasswordDto du backend
struct ResetPasswordRequest: Codable {
    let email: String  // Requis
    let newPassword: String  // ⚠️ Le backend attend "newPassword" (requis)
    
    enum CodingKeys: String, CodingKey {
        case email
        case newPassword
    }
}

/// Modèle pour la requête de mise à jour du profil
struct UpdateUserRequest: Codable {
    let nom: String       // Requis - nom de l'utilisateur
    let email: String     // Requis - email de l'utilisateur
    let contact: String   // Requis - numéro de contact
    let image: String?    // Optionnel - URL de l'image
    
    // Pas besoin de CodingKeys car les noms correspondent exactement au backend
    
    // Initializer pour faciliter la création
    init(nom: String, email: String, contact: String, image: String? = nil) {
        self.nom = nom
        self.email = email
        self.contact = contact
        self.image = image
    }
}

// Modèle pour la réponse de mise à jour (si le backend renvoie un format spécifique)
struct UpdateUserResponse: Codable {
    let message: String?
    let user: User?
    let success: Bool?
    
    enum CodingKeys: String, CodingKey {
        case message
        case user
        case success
    }
}
/// Modèle pour la requête de connexion Google
struct GoogleSignInRequest: Codable {
    let idToken: String  // Le token ID Google
    
    enum CodingKeys: String, CodingKey {
        case idToken = "idToken"  // Le backend peut attendre "idToken" ou "token"
    }
}
