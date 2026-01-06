//
//  ScheduleUploadViewModel.swift
//  Taleb_5edma
//
//  Created by Apple on 07/12/2025.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel pour gérer l'upload et le traitement des emplois du temps PDF
class ScheduleUploadViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Liste des cours extraits du PDF
    @Published var extractedCourses: [Course] = []
    
    /// Indique si un traitement est en cours
    @Published var isProcessing: Bool = false
    
    /// Indique si la création des événements est en cours
    @Published var isCreatingEvents: Bool = false
    
    /// Indique si une erreur doit être affichée
    @Published var showError: Bool = false
    
    /// Message d'erreur à afficher
    @Published var errorMessage: String?
    
    /// Indique si un succès doit être affiché
    @Published var showSuccess: Bool = false
    
    /// Message de succès à afficher
    @Published var successMessage: String?
    
    /// Date de début de semaine sélectionnée (optionnel)
    @Published var selectedWeekStartDate: Date = Date.mondayOfCurrentWeek()
    
    // MARK: - Properties
    
    /// Service pour gérer les schedules
    private let scheduleService = ScheduleService()
    
    /// Service d'authentification
    var authService: AuthService?
    
    // MARK: - Public Methods
    
    /// Upload et traite un PDF d'emploi du temps
    /// - Parameter pdfData: Les données du fichier PDF
    @MainActor
    func uploadSchedulePDF(_ pdfData: Data) async {
        isProcessing = true
        errorMessage = nil
        
        do {
            let courses = try await scheduleService.uploadSchedulePDF(pdfData)
            
            self.extractedCourses = courses
            self.isProcessing = false
            
            if courses.isEmpty {
                self.errorMessage = "Aucun cours trouvé dans le PDF. Vérifiez que le format est correct."
                self.showError = true
            } else {
                self.successMessage = "\(courses.count) cours extraits avec succès!"
                self.showSuccess = true
            }
        } catch {
            self.isProcessing = false
            if let scheduleError = error as? ScheduleError {
                self.errorMessage = scheduleError.errorDescription
            } else {
                self.errorMessage = "Erreur lors du traitement du PDF: \(error.localizedDescription)"
            }
            self.showError = true
        }
    }
    
    /// Crée automatiquement les événements dans le calendrier
    @MainActor
    func createEvents() async {
        guard !extractedCourses.isEmpty else {
            errorMessage = "Aucun cours à créer. Veuillez d'abord uploader un PDF."
            showError = true
            return
        }
        
        isCreatingEvents = true
        errorMessage = nil
        
        // Formater la date au format "yyyy-MM-dd"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let weekStartDateString = dateFormatter.string(from: selectedWeekStartDate)
        
        do {
            let response = try await scheduleService.createEventsFromSchedule(
                courses: extractedCourses,
                weekStartDate: weekStartDateString
            )
            
            self.isCreatingEvents = false
            self.successMessage = response.message
            self.showSuccess = true
            
            // Réinitialiser les cours extraits après la création
            self.extractedCourses = []
        } catch {
            self.isCreatingEvents = false
            if let scheduleError = error as? ScheduleError {
                self.errorMessage = scheduleError.errorDescription
            } else {
                self.errorMessage = "Erreur lors de la création des événements: \(error.localizedDescription)"
            }
            self.showError = true
        }
    }
    
    /// Supprime un cours de la liste
    /// - Parameter course: Le cours à supprimer
    func removeCourse(_ course: Course) {
        extractedCourses.removeAll { $0.id == course.id }
    }
    
    /// Réinitialise l'état du ViewModel
    func reset() {
        extractedCourses = []
        isProcessing = false
        isCreatingEvents = false
        errorMessage = nil
        successMessage = nil
        showError = false
        showSuccess = false
        selectedWeekStartDate = Date.mondayOfCurrentWeek()
    }
}

// MARK: - Date Extension
extension Date {
    /// Retourne le lundi de la semaine courante
    static func mondayOfCurrentWeek() -> Date {
        let calendar = Calendar.current
        let today = Date()
        
        // Trouver le début de la semaine (lundi)
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2 // 2 = Lundi
        
        return calendar.date(from: components) ?? today
    }
    
    /// Retourne le lundi de la semaine suivante
    func nextMonday() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .weekOfYear, value: 1, to: self) ?? self
    }
    
    /// Retourne le lundi de la semaine précédente
    func previousMonday() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .weekOfYear, value: -1, to: self) ?? self
    }
    
    /// Formate la date au format "dd/MM/yyyy"
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: self)
    }
}

