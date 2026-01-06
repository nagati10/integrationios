//
//  OfferDetailView.swift
//  Taleb_5edma
//
//  Created by Apple on 10/11/2025.
//

//
//  OfferDetailView.swift
//  Taleb_5edma
//

import SwiftUI

struct OfferDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var favoritesService = FavoritesService.shared
    let job: Job
    
    private var isLiked: Bool {
        favoritesService.isFavorite(jobId: job.id)
    }
    
    var body: some View {
        ZStack {
            AppColors.backgroundGray
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section avec dégradé
                HeaderSection(job: job, onBack: { dismiss() })
                
                // Content Section
                ScrollView {
                    VStack(spacing: 24) {
                        JobDetailsSection(job: job)
                        JobDescriptionSection(job: job)
                        PrerequisitesSection()
                        BenefitsSection()
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)
                    .padding(.bottom, 100)
                }
            }
            
            // Bottom Action Buttons
            BottomActionButtons(job: job)
                .padding(.horizontal)
                .padding(.bottom, 16)
                .background(AppColors.white)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -2)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Composants de l'écran de détail

struct HeaderSection: View {
    @StateObject private var favoritesService = FavoritesService.shared
    let job: Job
    let onBack: () -> Void
    
    private var isLiked: Bool {
        favoritesService.isFavorite(jobId: job.id)
    }
    
    // Icône selon le type de poste
    private var iconName: String {
        switch job.schedule.lowercased() {
        case "stage", "internship":
            return "iphone"
        case "freelance", "freelance mission":
            return "pencil.and.outline"
        default:
            return "laptopcomputer"
        }
    }
    
    var body: some View {
        ZStack {
            // Dégradé rouge-rose
            LinearGradient(
                gradient: Gradient(colors: [AppColors.primaryRed, AppColors.accentPink]),
                startPoint: .leading,
                endPoint: .trailing
            )
            
            VStack(spacing: 0) {
                // Navigation en haut
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Détails de l'offre")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            favoritesService.toggleFavorite(jobId: job.id)
                        }) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        
                        Button(action: { /* Partager */ }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                // Contenu principal avec icône, titre et tags
                HStack(alignment: .top, spacing: 16) {
                    // Icône carrée blanche
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: iconName)
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(AppColors.primaryRed)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // Titre
                        Text(job.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        // Entreprise
                        Text(job.company)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                        
                        // Tags
                        HStack(spacing: 8) {
                            Tag(text: "\(Int(job.salary)) DT")
                            Tag(text: job.schedule.capitalized)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .frame(height: 240)
    }
}

struct Tag: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppColors.primaryRed.opacity(0.8))
            .cornerRadius(12)
    }
}

// MARK: - Job Details Section

struct JobDetailsSection: View {
    let job: Job
    
    var body: some View {
        GenericCard {
            VStack(spacing: 16) {
                // Première ligne
                HStack(spacing: 20) {
                    DetailRow(
                        icon: "location.fill",
                        label: "Localisation",
                        value: job.location
                    )
                    
                    DetailRow(
                        icon: "clock.fill",
                        label: "Expérience",
                        value: "0-2 ans"
                    )
                }
                
                Divider()
                    .background(AppColors.separatorGray)
                
                // Deuxième ligne
                HStack(spacing: 20) {
                    DetailRow(
                        icon: "briefcase.fill",
                        label: "Salaire",
                        value: "\(Int(job.salary)) DT/an"
                    )
                    
                    DetailRow(
                        icon: "calendar",
                        label: "Publié le",
                        value: formatDate()
                    )
                }
            }
            .padding()
        }
    }
    
    private func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date())
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primaryRed)
                
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.mediumGray)
            }
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Job Description Section

struct JobDescriptionSection: View {
    let job: Job
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description du poste")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.black)
            
            Text("Nous recherchons un développeur web junior passionné pour rejoindre notre équipe dynamique. Vous travaillerez sur des projets innovants utilisant les dernières technologies.")
                .font(.system(size: 14))
                .foregroundColor(AppColors.black)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColors.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Prerequisites Section

struct PrerequisitesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prérequis")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.black)
            
            VStack(alignment: .leading, spacing: 8) {
                PrerequisiteItem(text: "Connaissance de JavaScript, React")
                PrerequisiteItem(text: "Bases en HTML/CSS")
                PrerequisiteItem(text: "Esprit d'équipe")
                PrerequisiteItem(text: "Volonté d'apprendre")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColors.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct PrerequisiteItem: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(AppColors.primaryRed)
                .frame(width: 6, height: 6)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(AppColors.black)
        }
    }
}

// MARK: - Benefits Section

struct BenefitsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Avantages")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.black)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                BenefitChip(icon: "house.fill", text: "Télétravail partiel")
                BenefitChip(icon: "book.fill", text: "Formation continue")
                BenefitChip(icon: "fork.knife", text: "Tickets restaurant")
                BenefitChip(icon: "cross.case.fill", text: "Mutuelle")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColors.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct BenefitChip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(AppColors.successGreen)
            
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppColors.black)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppColors.successGreen.opacity(0.1))
        .cornerRadius(10)
    }
}


struct BottomActionButtons: View {
    let job: Job
    @State private var showingMoreInfo = false
    @State private var showingApply = false
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: { showingMoreInfo = true }) {
                Text("Plus d'infos")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primaryRed)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.primaryRed, lineWidth: 2)
                    )
                    .cornerRadius(12)
            }
            .sheet(isPresented: $showingMoreInfo) {
                // Plus d'informations
                Text("Plus d'informations")
            }
            
            Button(action: { showingApply = true }) {
                Text("Postuler")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [AppColors.primaryRed, AppColors.accentPink]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
            .sheet(isPresented: $showingApply) {
                ChatView(job: job)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    OfferDetailView(job: Job(
        id: "1",
        title: "Assistant de chantier à centre ville Tunis",
        company: "BTP Tunis",
        location: "Centre ville Tunis",
        salary: 105,
        duration: "7j",
        schedule: "Jour",
        shareCount: 20,
        isPopular: true,
        isFavorite: false,
        latitude: 36.8065,
        longitude: 10.1815
    ))
}
