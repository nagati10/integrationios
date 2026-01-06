//
//  MyOffresView.swift
//  Taleb_5edma
//
//  Created by Apple on 16/11/2025.
//

import SwiftUI

/// Vue pour afficher et gérer les offres de l'utilisateur connecté
/// Permet de modifier et supprimer ses propres offres
struct MyOffresView: View {
    @StateObject private var viewModel = OffreViewModel()
    @State private var selectedOffre: Offre?
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var offreToDelete: Offre?
    
    var body: some View {
        ZStack {
            AppColors.backgroundGray
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Liste des offres
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.offres.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.offres) { offre in
                                MyOffreCard(offre: offre) {
                                    selectedOffre = offre
                                    showingEditSheet = true
                                } onDelete: {
                                    offreToDelete = offre
                                    showingDeleteAlert = true
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedOffre) { offre in
            EditOfferView(offre: offre, viewModel: viewModel) {
                Task {
                    await viewModel.loadMyOffres()
                }
            }
        }
        .alert("Supprimer l'offre", isPresented: $showingDeleteAlert) {
            Button("Annuler", role: .cancel) {
                offreToDelete = nil
            }
            Button("Supprimer", role: .destructive) {
                if let offre = offreToDelete {
                    Task {
                        await deleteOffre(offre)
                    }
                }
            }
        } message: {
            if let offre = offreToDelete {
                Text("Êtes-vous sûr de vouloir supprimer l'offre \"\(offre.title)\" ? Cette action est irréversible.")
            }
        }
        .alert("Erreur", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Une erreur est survenue")
        }
        .onAppear {
            Task {
                await viewModel.loadMyOffres()
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: 0x9333ea), Color(hex: 0xB042FF)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mes offres")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("\(viewModel.offres.count) offre\(viewModel.offres.count > 1 ? "s" : "")")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .frame(height: 120)
            
            // Barre de recherche optionnelle
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.mediumGray)
                
                Text("Rechercher dans mes offres...")
                    .font(.subheadline)
                    .foregroundColor(AppColors.mediumGray)
                
                Spacer()
            }
            .padding()
            .background(AppColors.white)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "briefcase")
                .font(.system(size: 60))
                .foregroundColor(AppColors.mediumGray)
            
            Text("Aucune offre")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.black)
            
            Text("Vous n'avez pas encore créé d'offre")
                .font(.subheadline)
                .foregroundColor(AppColors.mediumGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Actions
    
    private func deleteOffre(_ offre: Offre) async {
        let success = await viewModel.deleteOffre(offre.id)
        if success {
            offreToDelete = nil
        }
    }
}

// MARK: - My Offre Card

struct MyOffreCard: View {
    let offre: Offre
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Section
            if let images = offre.images, let firstImage = images.first, !firstImage.isEmpty {
                // Essayer plusieurs URLs en cascade
                let possibleURLs = buildPossibleImageURLs(from: firstImage)
                FallbackAsyncImage(
                    urls: possibleURLs,
                    placeholder: AnyView(
                        Rectangle()
                            .fill(AppColors.backgroundGray)
                            .frame(height: 160)
                            .overlay(
                                ProgressView()
                                    .tint(Color(hex: 0x9333ea))
                            )
                    ),
                    failureView: AnyView(
                        Rectangle()
                            .fill(AppColors.backgroundGray)
                            .frame(height: 160)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(AppColors.mediumGray.opacity(0.3))
                                    Text("Image non disponible")
                                        .font(.caption)
                                        .foregroundColor(AppColors.mediumGray)
                                }
                            )
                    )
                )
                .aspectRatio(contentMode: .fill)
                .frame(height: 160)
                .clipped()
            } else {
                // Default placeholder if no image
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [AppColors.backgroundGray, AppColors.lightGray]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 120)
                    .overlay(
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppColors.mediumGray.opacity(0.2))
                    )
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(offre.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColors.black)
                            .lineLimit(2)
                        
                        Text(offre.company)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.mediumGray)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: 0x9333ea))
                            Text(offre.location.address)
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.mediumGray)
                        }
                        
                        if let city = offre.location.city {
                            Text(city)
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.mediumGray)
                        }
                    }
                
                Spacer()
                
                if let salary = offre.salary {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(salary)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: 0x9333ea))
                    }
                }
            }
            
            // Tags
            if let tags = offre.tags, !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 11))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: 0x9333ea).opacity(0.1))
                                .foregroundColor(Color(hex: 0x9333ea))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            // Statistiques
            HStack {
                if let likeCount = offre.likeCount {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                        Text("\(likeCount)")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(AppColors.mediumGray)
                }
                
                if let viewCount = offre.viewCount {
                    HStack(spacing: 4) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 12))
                        Text("\(viewCount)")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(AppColors.mediumGray)
                }
                
                Spacer()
                
                // Badge actif/inactif
                if let isActive = offre.isActive {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(isActive ? AppColors.successGreen : AppColors.mediumGray)
                            .frame(width: 6, height: 6)
                        Text(isActive ? "Active" : "Inactive")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(isActive ? AppColors.successGreen : AppColors.mediumGray)
                    }
                }
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // Actions
            HStack(spacing: 12) {
                Button(action: onEdit) {
                    HStack {
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                        Text("Modifier")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: 0x9333ea))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppColors.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: 0x9333ea), lineWidth: 1.5)
                    )
                    .cornerRadius(8)
                }
                
                Button(action: onDelete) {
                    HStack {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                        Text("Supprimer")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(hex: 0x9333ea))
                    .cornerRadius(8)
                }
            }
            }
            .padding()
        }
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onAppear {
            // Log pour débogage
            if let images = offre.images, let firstImage = images.first, !firstImage.isEmpty {
                let imageURL = buildImageURL(from: firstImage)
                let possibleURLs = buildPossibleImageURLs(from: firstImage)
                print("🖼️ MyOffreCard - Offre '\(offre.title)'")
                print("   Chemin image original: '\(firstImage)'")
                print("   URL utilisée: '\(imageURL)'")
                print("   Autres URLs possibles: \(possibleURLs)")
            } else {
                print("⚠️ MyOffreCard - Offre '\(offre.title)' n'a pas d'images")
            }
        }
    }
    
    /// Construit l'URL de l'image (format principal)
    private func buildImageURL(from urlString: String) -> String {
        let cleanPath = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanPath.starts(with: "http://") || cleanPath.starts(with: "https://") {
            return cleanPath
        }
        
        if cleanPath.starts(with: "/") {
            return APIConfig.baseURL + cleanPath
        }
        
        // Format standard: baseURL + / + chemin
        return APIConfig.baseURL + "/" + cleanPath
    }
    
    /// Construit plusieurs URLs possibles pour l'image (pour débogage)
    /// Le backend NestJS peut servir les fichiers via différents chemins selon la configuration
    private func buildPossibleImageURLs(from urlString: String) -> [String] {
        // Nettoyer le chemin
        let cleanPath = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Si c'est déjà une URL complète, la retourner telle quelle
        if cleanPath.starts(with: "http://") || cleanPath.starts(with: "https://") {
            return [cleanPath]
        }
        
        var urls: [String] = []
        let baseURL = APIConfig.baseURL
        
        // Format 1: Directement depuis /uploads/ (configuration standard NestJS)
        if cleanPath.starts(with: "uploads/") {
            urls.append(baseURL + "/" + cleanPath)
        } else if cleanPath.starts(with: "/") {
            urls.append(baseURL + cleanPath)
        } else {
            // Format 2: Via /uploads/ (si le chemin ne commence pas par uploads/)
            urls.append(baseURL + "/uploads/" + cleanPath)
            // Format 3: Directement depuis la racine
            urls.append(baseURL + "/" + cleanPath)
        }
        
        // Format 4: Via un endpoint /files/ (configuration alternative)
        if cleanPath.contains("uploads/") {
            let relativePath = cleanPath.replacingOccurrences(of: "uploads/", with: "")
            urls.append(baseURL + "/files/" + relativePath)
        }
        
        // Format 5: Via un endpoint /static/ (autre configuration alternative)
        if cleanPath.contains("uploads/") {
            urls.append(baseURL + "/static/" + cleanPath)
        }
        
        // Retourner les URLs uniques
        return Array(Set(urls))
    }
}

#Preview {
    NavigationView {
        MyOffresView()
    }
}

