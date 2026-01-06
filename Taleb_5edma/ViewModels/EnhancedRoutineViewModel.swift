//
//  EnhancedRoutineViewModel.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel pour gérer la logique de l'analyse de routine améliorée
@MainActor
class EnhancedRoutineViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Données de l'analyse
    @Published var analysisData: EnhancedRoutineAnalysisResponse.AnalysisData?
    
    /// Indicateur de chargement
    @Published var isLoading: Bool = false
    
    /// Message d'erreur
    @Published var errorMessage: String?
    
    /// Afficher l'alerte d'erreur
    @Published var showError: Bool = false
    
    /// Afficher le message de succès
    @Published var showSuccess: Bool = false
    
    // MARK: - Dependencies
    
    private let service: EnhancedRoutineService
    weak var evenementViewModel: EvenementViewModel?
    weak var availabilityViewModel: AvailabilityViewModel?
    
    // MARK: - Initialization
    
    init(service: EnhancedRoutineService = EnhancedRoutineService()) {
        self.service = service
        
        // Charger depuis le cache au démarrage sera fait dans onAppear
    }
    
    /// Initialise le ViewModel (à appeler depuis onAppear)
    func initialize() {
        loadFromCache()
    }
    
    // MARK: - Methods
    
    /// Analyse la routine avec les événements et disponibilités
    func analyzeRoutine(
        evenements: [Evenement],
        disponibilites: [Disponibilite],
        dateDebut: Date,
        dateFin: Date
    ) async {
        // Vérifier qu'il y a des données
        guard !evenements.isEmpty || !disponibilites.isEmpty else {
            showError(message: "Veuillez ajouter des événements ou disponibilités pour analyser votre planning")
            return
        }
        
        isLoading = true
        errorMessage = nil
        // Calculer la semaine (lundi 00:00:00Z → dimanche 23:59:59Z) à partir de la date sélectionnée
        let weekBounds = Self.weekBounds(from: dateDebut)
        let isoStart = Self.iso8601String(from: weekBounds.start)
        let isoEnd = Self.iso8601String(from: weekBounds.end)
        
        // Préparer le formateur "yyyy-MM-dd" en UTC pour les comparaisons
        let dayFormatter = Self.dayFormatter()
        
        // Filtrer les événements dans la plage de la semaine (comparaison sur le jour uniquement)
        let filteredEvents: [Evenement] = evenements.filter { event in
            guard let eventDate = dayFormatter.date(from: event.date) else {
                print("⚠️ Event ignoré - date invalide: \(event.date)")
                return false
            }
            let eventDay = Calendar.iso8601UTC.startOfDay(for: eventDate)
            let inRange = eventDay >= weekBounds.start && eventDay <= weekBounds.end
            if !inRange {
                print("🪣 Event hors semaine retiré: \(event.titre) (\(event.date))")
            }
            return inRange
        }
        
        // Normaliser les disponibilités sur la semaine courante avec des dates YYYY-MM-DD
        let normalizedDisponibilites: [Disponibilite] = disponibilites.map { dispo in
            let normalizedJour = Self.normalizeDisponibiliteJour(dispo.jour, weekStart: weekBounds.start, formatter: dayFormatter)
            return Disponibilite(
                id: dispo.id,
                jour: normalizedJour,
                heureDebut: dispo.heureDebut,
                heureFin: dispo.heureFin,
                createdAt: dispo.createdAt,
                updatedAt: dispo.updatedAt
            )
        }
        
        print("📆 EnhancedRoutine - Semaine envoyée: \(isoStart) → \(isoEnd)")
        print("📆 EnhancedRoutine - Événements: \(evenements.count) avant filtre → \(filteredEvents.count) après filtre")
        print("📆 EnhancedRoutine - Disponibilités normalisées: \(normalizedDisponibilites.count)")
        
        do {
            let response = try await service.analyzeRoutineEnhanced(
                evenements: filteredEvents,
                disponibilites: normalizedDisponibilites,
                dateDebut: isoStart,
                dateFin: isoEnd
            )
            
            if response.success {
                self.analysisData = response.data
                self.showSuccess = true
                print("✅ Analyse réussie - Score: \(response.data.scoreEquilibre)")
            } else {
                showError(message: "L'analyse a échoué")
            }
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// Recharge l'analyse (pull to refresh)
    func refresh() async {
        guard let evenementVM = evenementViewModel,
              let availabilityVM = availabilityViewModel else {
            return
        }
        
        // Recharger les données
        await evenementVM.loadEvenements()
        await availabilityVM.loadDisponibilites()
        
        // Calculer la plage de dates (semaine courante)
        let now = Date()
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        
        // Analyser
        await analyzeRoutine(
            evenements: evenementVM.evenements,
            disponibilites: availabilityVM.disponibilites,
            dateDebut: startOfWeek,
            dateFin: endOfWeek
        )
    }
    
    /// Charge l'analyse depuis le cache
    func loadFromCache() {
        if let cached = service.loadFromCache() {
            self.analysisData = cached.data
            print("✅ Analyse chargée depuis le cache")
        }
    }
    
    /// Vide le cache
    func clearCache() {
        service.clearCache()
        self.analysisData = nil
    }
    
    // MARK: - Computed Properties
    
    /// Score formaté en pourcentage
    var scorePercentage: String {
        guard let score = analysisData?.scoreEquilibre else { return "0%" }
        return String(format: "%.0f%%", score)
    }
    
    /// Couleur du score
    var scoreColor: Color {
        guard let score = analysisData?.scoreEquilibre else { return AppColors.mediumGray }
        if score >= 75 { return AppColors.successGreen }
        if score >= 50 { return .orange }
        return AppColors.errorRed
    }
    
    /// Label du score
    var scoreLabel: String {
        guard let score = analysisData?.scoreEquilibre else { return "Non analysé" }
        if score >= 75 { return "Bon équilibre" }
        if score >= 50 { return "Équilibre moyen" }
        return "Équilibre faible"
    }
    
    /// Icône du score
    var scoreIcon: String {
        guard let score = analysisData?.scoreEquilibre else { return "questionmark.circle" }
        if score >= 75 { return "checkmark.circle.fill" }
        if score >= 50 { return "exclamationmark.circle.fill" }
        return "xmark.circle.fill"
    }
    
    /// Nombre de conflits
    var conflictsCount: Int {
        analysisData?.conflicts.count ?? 0
    }
    
    /// Nombre de jours surchargés
    var overloadedDaysCount: Int {
        analysisData?.overloadedDays.count ?? 0
    }
    
    /// Nombre de recommandations
    var recommendationsCount: Int {
        analysisData?.recommandations.count ?? 0
    }
    
    /// A des données à afficher
    var hasData: Bool {
        analysisData != nil
    }
    
    // MARK: - Helper Methods
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    private func handleError(_ error: Error) {
        if let routineError = error as? RoutineServiceError {
            errorMessage = routineError.errorDescription
        } else {
            errorMessage = error.localizedDescription
        }
        showError = true
    }
    
    // MARK: - Helpers semaine
    
    /// Retourne les bornes lundi 00:00:00Z → dimanche 23:59:59Z pour la date donnée
    private static func weekBounds(from date: Date) -> (start: Date, end: Date) {
        var calendar = Calendar.iso8601UTC
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? calendar.startOfDay(for: date)
        let start = calendar.startOfDay(for: startOfWeek)
        let endBase = calendar.date(byAdding: .day, value: 6, to: start) ?? start
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endBase) ?? endBase
        return (start, end)
    }
    
    /// Formatteur ISO 8601 UTC avec heures/minutes/secondes
    private static func iso8601String(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        return formatter.string(from: date)
    }
    
    /// Formatteur "yyyy-MM-dd" en UTC
    private static func dayFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
    
    /// Normalise le champ jour d'une disponibilité en YYYY-MM-DD sur la semaine courante
    private static func normalizeDisponibiliteJour(_ jour: String, weekStart: Date, formatter: DateFormatter) -> String {
        // Si déjà au format date, on garde tel quel
        if jour.contains("-"), let _ = formatter.date(from: String(jour.prefix(10))) {
            return String(jour.prefix(10))
        }
        
        let lower = jour.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        let mapping: [String: Int] = [
            "lundi": 0, "mardi": 1, "mercredi": 2, "jeudi": 3,
            "vendredi": 4, "samedi": 5, "dimanche": 6
        ]
        if let offset = mapping[lower] {
            let calendar = Calendar.iso8601UTC
            if let mappedDate = calendar.date(byAdding: .day, value: offset, to: weekStart) {
                return formatter.string(from: mappedDate)
            }
        }
        
        // Fallback: renvoyer le champ original
        return jour
    }
}

private extension Calendar {
    static var iso8601UTC: Calendar {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2 // Lundi
        return calendar
    }
}

