//
//  CreateOfferRequest.swift
//  Taleb_5edma
//
//  Created by Apple on 10/11/2025.
//

import Foundation

// MARK: - CreateOfferRequest

/// Modèle de requête pour créer une nouvelle offre d'emploi
/// Utilisé lors de la soumission du formulaire dans `CreateOfferView`
/// Conforme au schéma API backend pour la création d'offres
struct CreateOfferRequest: Codable {
    // MARK: - Required Fields
    
    /// Titre de l'offre d'emploi (requis)
    /// Exemple: "Développeur Web Junior"
    let title: String
    
    /// Description détaillée du poste (requis)
    /// Contient les détails, responsabilités et prérequis du poste
    let description: String
    
    /// Liste des tags pour la catégorisation de l'offre
    /// Permet de classifier et de rechercher facilement l'offre
    /// Exemple: ["Urgent", "CDI", "Télétravail"]
    let tags: [String]
    
    /// Informations de localisation du poste (requis)
    /// Structure contenant l'adresse, la ville et les coordonnées GPS
    let location: LocationInfo
    
    // MARK: - Optional Fields
    
    /// Catégorie de l'offre (optionnel)
    /// Correspond à une valeur de `JobCategory` (ex: "Informatique", "BTP")
    let category: String?
    
    /// Fourchette de salaire (optionnel)
    /// Format libre - peut être "500-800 DT/mois" ou "65 DT/an"
    let salary: String?
    
    /// Nom de l'entreprise proposant l'offre (optionnel)
    /// Si non fourni, peut être dérivé du profil de l'utilisateur créateur
    let company: String?
    
    /// Date d'expiration de l'offre (optionnel)
    /// Format ISO8601 - date à laquelle l'offre ne sera plus visible
    let expiresAt: String?
}

// MARK: - LocationInfo

/// Structure contenant les informations de localisation d'une offre d'emploi
/// Utilisée dans `CreateOfferRequest` pour spécifier où se trouve le poste
struct LocationInfo: Codable {
    /// Adresse complète du lieu de travail (requis)
    /// Exemple: "123 Rue de la République"
    let address: String
    
    /// Ville où se trouve le poste (optionnel)
    /// Exemple: "Tunis", "Ariana"
    let city: String?
    
    /// Coordonnée GPS de latitude (optionnel)
    /// Utilisée pour l'affichage sur une carte interactive
    let latitude: Double?
    
    /// Coordonnée GPS de longitude (optionnel)
    /// Utilisée pour l'affichage sur une carte interactive
    let longitude: Double?
}

