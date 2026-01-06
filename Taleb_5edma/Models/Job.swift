//
//  Job.swift
//  Taleb_5edma
//
//  Created by Apple on 10/11/2025.
//

import Foundation

// MARK: - Job Model

/// Modèle représentant une offre d'emploi dans l'application
/// Conforme aux protocoles `Identifiable` pour l'utilisation dans les listes SwiftUI
/// et `Codable` pour la sérialisation/désérialisation JSON avec l'API backend
struct Job: Identifiable, Codable {
    // MARK: - Properties
    
    /// Identifiant unique de l'offre d'emploi renvoyé par l'API backend
    /// Utilisé pour l'identification et la navigation vers les détails de l'offre
    let id: String
    
    /// Intitulé du poste proposé
    /// Exemple: "Développeur Web Junior", "Assistant de chantier"
    let title: String
    
    /// Nom de l'entreprise proposant l'offre d'emploi
    /// Exemple: "Tech Solutions", "Restaurant Le Parisien"
    let company: String
    
    /// Localisation géographique du poste
    /// Peut être une adresse complète ou simplement une ville
    /// Exemple: "Tunis", "Lafayette", "Centre ville Tunis"
    let location: String
    
    /// Rémunération associée au job en dinars tunisiens (DT)
    /// Valeur numérique représentant le salaire ou la rémunération proposée
    let salary: Double
    
    /// Durée du contrat ou de la mission
    /// Exemple: "6 mois", "CDI", "Mission ponctuelle"
    let duration: String
    
    /// Horaires de travail proposés
    /// Valeurs possibles: "Jour", "Nuit", "Flexible"
    /// Utilisé pour le filtrage et l'affichage des offres
    let schedule: String
    
    /// Nombre de partages de l'offre par les utilisateurs
    /// Indicateur de popularité de l'offre
    let shareCount: Int
    
    /// Indique si l'offre est mise en avant par le back-office
    /// Les offres populaires peuvent être affichées en priorité dans les résultats
    let isPopular: Bool
    
    /// Indique si l'utilisateur actuel a ajouté cette offre à ses favoris
    /// Utilisé pour l'affichage de l'icône cœur dans les cartes d'offres
    let isFavorite: Bool
    
    /// Coordonnée de latitude pour la géolocalisation
    /// Optionnelle - utilisée pour l'affichage sur une carte interactive
    let latitude: Double?
    
    /// Coordonnée de longitude pour la géolocalisation
    /// Optionnelle - utilisée pour l'affichage sur une carte interactive
    let longitude: Double?
    
    
    // MARK: - CodingKeys
    
    /// Mappage des clés JSON pour la désérialisation
    /// Le backend utilise "_id" au lieu de "id" pour l'identifiant
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, company, location, salary, duration, schedule
        case shareCount, isPopular, isFavorite, latitude, longitude
    }
}

// MARK: - JobFilter

/// Structure de filtrage pour les offres d'emploi
/// Utilisée dans `OffersView` et `FilterView` pour permettre aux utilisateurs
/// de filtrer les offres selon différents critères
struct JobFilter {
    /// Texte libre pour rechercher dans les offres par mot-clé
    /// Recherche dans le titre, l'entreprise et la localisation
    var searchText: String = ""
    
    /// Catégorie d'emploi sélectionnée pour le filtrage
    /// Par défaut: toutes les catégories
    var selectedCategory: JobCategory = .all
    
    /// Fourchette de salaire pour filtrer les offres
    /// Par défaut: 0 à 200 DT
    var salaryRange: ClosedRange<Double> = 0...200
    
    /// Localisation géographique pour le filtrage
    /// Exemple: "Tunis", "Ariana"
    var location: String = ""
    
    /// Type d'horaires pour le filtrage
    /// Par défaut: tous les types d'horaires
    var scheduleType: ScheduleType = .all
    
    /// Afficher uniquement les offres populaires mises en avant
    /// Filtre supplémentaire pour les offres marquées comme `isPopular: true`
    var showPopularOnly: Bool = false
    
    /// Afficher uniquement les offres favorites de l'utilisateur
    /// Utilisé dans `FavoritesView` pour filtrer les offres sauvegardées
    var showFavoritesOnly: Bool = false
}

// MARK: - JobCategory

/// Catégories d'emploi disponibles dans l'application
/// Utilisées pour organiser et filtrer les offres par secteur d'activité
enum JobCategory: String, CaseIterable {
    /// Toutes les catégories (pas de filtre)
    case all = "Tous"
    
    /// Bâtiment et travaux publics
    case construction = "BTP"
    
    /// Technologies de l'information et informatique
    case tech = "Informatique"
    
    /// Marketing et communication
    case marketing = "Marketing"
    
    /// Restauration et service alimentaire
    case restaurant = "Restauration"
    
    /// Livraison et logistique
    case delivery = "Livraison"
    
    /// Vente et commerce de détail
    case retail = "Vente"
}

// MARK: - ScheduleType

/// Types d'horaires de travail disponibles pour les offres d'emploi
/// Utilisés pour le filtrage et l'affichage des offres selon les préférences de l'utilisateur
enum ScheduleType: String, CaseIterable {
    /// Tous les types d'horaires (pas de filtre)
    case all = "Tous"
    
    /// Horaires de jour (typiquement 8h-18h)
    case day = "Jour"
    
    /// Horaires de nuit (typiquement après 18h ou nocturnes)
    case night = "Nuit"
    
    /// Horaires flexibles permettant à l'employé de choisir ses heures
    case flexible = "Flexible"
}
