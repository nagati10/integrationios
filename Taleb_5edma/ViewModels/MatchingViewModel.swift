//
//  MatchingViewModel.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel pour gérer la logique métier du matching IA
class MatchingViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Liste des résultats de matching
    @Published var matches: [MatchResult] = []
    
    /// Résumé du matching
    @Published var summary: MatchingResponse.MatchingSummary?
    
    /// Indicateur de chargement
    @Published var isLoading: Bool = false
    
    /// Message d'erreur
    @Published var errorMessage: String?
    
    /// Afficher l'alerte d'erreur
    @Published var showError: Bool = false
    
    /// Filtre de recherche
    @Published var searchText: String = ""
    
    /// Filtre par niveau de matching
    @Published var selectedMatchLevel: MatchLevel?
    
    /// Tri sélectionné
    @Published var sortOption: SortOption = .scoreDescending
    
    // MARK: - Dependencies
    
    private let matchingService: MatchingService
    private let availabilityViewModel: AvailabilityViewModel
    
    // MARK: - Computed Properties
    
    /// Matches filtrés selon les critères de recherche
    var filteredMatches: [MatchResult] {
        var results = matches
        
        // Filtrer par texte de recherche
        if !searchText.isEmpty {
            results = results.filter { match in
                match.titre.localizedCaseInsensitiveContains(searchText) ||
                match.company?.localizedCaseInsensitiveContains(searchText) == true ||
                match.location?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // Filtrer par niveau de matching
        if let level = selectedMatchLevel {
            results = results.filter { $0.matchLevel == level }
        }
        
        // Trier selon l'option sélectionnée
        switch sortOption {
        case .scoreDescending:
            results.sort { $0.scores.score > $1.scores.score }
        case .scoreAscending:
            results.sort { $0.scores.score < $1.scores.score }
        case .titleAscending:
            results.sort { $0.titre < $1.titre }
        }
        
        return results
    }
    
    /// Score moyen des matches
    var averageScore: Double {
        guard !matches.isEmpty else { return 0 }
        let total = matches.reduce(0.0) { $0 + $1.scores.score }
        return total / Double(matches.count)
    }
    
    /// Meilleur match
    var bestMatch: MatchResult? {
        matches.max(by: { $0.scores.score < $1.scores.score })
    }
    
    // MARK: - Initialization
    
    init(
        matchingService: MatchingService = MatchingService(),
        availabilityViewModel: AvailabilityViewModel
    ) {
        self.matchingService = matchingService
        self.availabilityViewModel = availabilityViewModel
    }
    
    // MARK: - Methods
    
    /// Lance l'analyse de matching
    func analyzeMatching(preferences: MatchingRequest.MatchingPreferences? = nil) async {
        // Vérifier qu'il y a des disponibilités
        guard !availabilityViewModel.disponibilites.isEmpty else {
            DispatchQueue.main.async {
                self.showError(message: "Veuillez d'abord définir vos disponibilités")
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            // Appeler le service de matching
            let response = try await matchingService.analyzeMatching(
                disponibilites: availabilityViewModel.disponibilites,
                preferences: preferences
            )
            
            // Mettre à jour les résultats sur le main thread
            DispatchQueue.main.async {
                self.matches = response.matches
                self.summary = response.summary
                self.isLoading = false
                print("✅ Matching terminé - \(self.matches.count) résultats")
            }
            
        } catch {
            DispatchQueue.main.async {
                self.handleError(error)
                self.isLoading = false
            }
        }
    }
    
    /// Relance l'analyse (pull to refresh)
    func refresh() async {
        await analyzeMatching()
    }
    
    /// Réinitialise les filtres
    func resetFilters() {
        searchText = ""
        selectedMatchLevel = nil
        sortOption = .scoreDescending
    }
    
    /// Supprime un match de la liste
    func removeMatch(_ match: MatchResult) {
        matches.removeAll { $0.id == match.id }
    }
    
    // MARK: - Helper Methods
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    private func handleError(_ error: Error) {
        if let matchingError = error as? MatchingError {
            errorMessage = matchingError.errorDescription
        } else {
            errorMessage = error.localizedDescription
        }
        showError = true
    }
}

// MARK: - Sort Options

enum SortOption: String, CaseIterable {
    case scoreDescending = "Score (décroissant)"
    case scoreAscending = "Score (croissant)"
    case titleAscending = "Titre (A-Z)"
    
    var icon: String {
        switch self {
        case .scoreDescending: return "arrow.down.circle.fill"
        case .scoreAscending: return "arrow.up.circle.fill"
        case .titleAscending: return "textformat.abc"
        }
    }
}

