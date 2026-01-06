//
//  JobCardView.swift
//  Taleb_5edma
//
//  Created by Apple on 10/11/2025.
//

import SwiftUI

// MARK: - JobCardView

/// Carte d'emploi réutilisable affichant les informations essentielles d'une offre d'emploi
/// Style moderne inspiré des meilleures pratiques UX avec la palette de couleurs unifiée de l'application
///
/// **Éléments affichés:**
/// - Icône carrée colorée selon le type de poste (Stage, Freelance, Job)
/// - Titre du poste et nom de l'entreprise
/// - Localisation avec icône de position
/// - Salaire ou type de contrat
/// - Date de publication simulée
/// - Badge coloré indiquant le type de poste
/// - Bouton favoris (cœur) pour sauvegarder l'offre
///
/// **Fonctionnalités:**
/// - Navigation vers `OfferDetailView` au tap
/// - Toggle des favoris via `FavoritesService`
/// - Couleurs dynamiques selon le type de poste (utilisant `AppColors`)
///
/// **Utilisation:**
/// Utilisé dans `OffersView` et `FavoritesView` pour afficher les listes d'offres d'emploi
struct JobCardView: View {
    // MARK: - Properties
    
    /// L'offre d'emploi à afficher dans la carte
    let job: Job
    
    /// Indique si la vue de détails doit être affichée (sheet)
    @State private var showingDetail = false
    
    /// Service des favoris pour gérer l'état des offres favorites
    @StateObject private var favoritesService = FavoritesService.shared
    
    // MARK: - Computed Properties
    
    /// Couleur de l'icône selon le type de poste
    /// Utilise la palette unifiée de l'application (rouge bordeaux et gris)
    /// - Stage/Internship: Gris foncé
    /// - Freelance: Gris moyen
    /// - Autres: Rouge bordeaux principal
    private var iconColor: Color {
        switch job.schedule.lowercased() {
        case "stage", "internship":
            return AppColors.darkGray
        case "freelance", "freelance mission":
            return AppColors.mediumGray
        default:
            return AppColors.primaryRed
        }
    }
    
    /// Texte du badge affiché en haut à droite de la carte
    /// Indique le type de poste (Stage, Freelance, ou Job)
    private var badgeText: String {
        switch job.schedule.lowercased() {
        case "stage", "internship":
            return "Stage"
        case "freelance", "freelance mission":
            return "Freelance"
        default:
            return "Job"
        }
    }
    
    /// Couleur du badge selon le type de poste
    /// Cohérent avec `iconColor` pour un design harmonieux
    private var badgeColor: Color {
        switch job.schedule.lowercased() {
        case "stage", "internship":
            return AppColors.darkGray
        case "freelance", "freelance mission":
            return AppColors.mediumGray
        default:
            return AppColors.primaryRed
        }
    }
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            HStack(spacing: 16) {
                // Icône carrée avec fond coloré
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: iconName(for: job.schedule))
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(iconColor)
                }
                
                // Contenu principal
                VStack(alignment: .leading, spacing: 8) {
                    // Titre et entreprise
                    VStack(alignment: .leading, spacing: 4) {
                        Text(job.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColors.black)
                            .lineLimit(1)
                        
                        Text(job.company)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.mediumGray)
                            .lineLimit(1)
                    }
                    
                    // Informations avec icônes
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.primaryRed)
                            Text(job.location)
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.mediumGray)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.primaryRed)
                            Text(salaryText)
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.mediumGray)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.mediumGray)
                            Text(formatDate(job))
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.mediumGray)
                        }
                    }
                    
                    // Lien "Voir détails"
                    HStack {
                        Spacer()
                        Text("Voir détails →")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.primaryRed)
                    }
                }
                
                Spacer()
                
                // Badge en haut à droite
                VStack {
                    Text(badgeText)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(badgeColor)
                        .cornerRadius(12)
                    
                    Spacer()
                    
                    // Bouton favoris
                    Button(action: {
                        favoritesService.toggleFavorite(jobId: job.id)
                    }) {
                        Image(systemName: favoritesService.isFavorite(jobId: job.id) ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(favoritesService.isFavorite(jobId: job.id) ? AppColors.primaryRed : AppColors.lightGray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .background(AppColors.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            OfferDetailView(job: job)
        }
    }
    
    // MARK: - Helper Methods
    
    private func iconName(for schedule: String) -> String {
        switch schedule.lowercased() {
        case "stage", "internship":
            return "iphone"
        case "freelance", "freelance mission":
            return "pencil.and.outline"
        default:
            return "laptopcomputer"
        }
    }
    
    private var salaryText: String {
        if job.schedule.lowercased().contains("stage") || job.schedule.lowercased().contains("internship") {
            return "Stage"
        } else if job.schedule.lowercased().contains("freelance") {
            return "Freelance"
        } else {
            return "\(Int(job.salary)) DT/an"
        }
    }
    
    private func formatDate(_ job: Job) -> String {
        // Simuler une date de publication (à remplacer par la vraie date si disponible)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date().addingTimeInterval(-Double.random(in: 0...7) * 24 * 60 * 60))
    }
}

#Preview {
    VStack(spacing: 12) {
        JobCardView(job: sampleJobs[0])
        JobCardView(job: sampleJobs[1])
    }
    .padding()
    .background(AppColors.backgroundGray)
}

