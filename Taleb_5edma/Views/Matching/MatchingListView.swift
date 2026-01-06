//
//  MatchingListView.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import SwiftUI

/// Vue simple pour afficher les résultats du matching (sans animations complexes)
struct MatchingListView: View {
    @StateObject private var viewModel: MatchingViewModel
    @EnvironmentObject var authService: AuthService
    
    init(availabilityViewModel: AvailabilityViewModel) {
        _viewModel = StateObject(wrappedValue: MatchingViewModel(availabilityViewModel: availabilityViewModel))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundGray
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.matches.isEmpty {
                    emptyStateView
                } else {
                    matchesListView
                }
            }
            .navigationTitle("Matching IA")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.analyzeMatching()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(AppColors.primaryRed)
                    }
                }
            }
            .alert("Erreur", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Une erreur est survenue")
            }
            .task {
                // Lancer l'analyse au chargement
                await viewModel.analyzeMatching()
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(AppColors.primaryRed)
            
            Text("Analyse en cours...")
                .font(.headline)
                .foregroundColor(AppColors.mediumGray)
            
            Text("L'IA analyse vos disponibilités")
                .font(.subheadline)
                .foregroundColor(AppColors.mediumGray)
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(AppColors.mediumGray)
            
            Text("Aucun résultat")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.black)
            
            Text("Aucune offre ne correspond à vos disponibilités pour le moment")
                .font(.body)
                .foregroundColor(AppColors.mediumGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                Task {
                    await viewModel.analyzeMatching()
                }
            }) {
                Text("Relancer l'analyse")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.primaryRed)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
        .padding()
    }
    
    // MARK: - Matches List View
    
    private var matchesListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Header avec statistiques
                statisticsHeader
                
                // Liste des matches
                ForEach(viewModel.filteredMatches) { match in
                    NavigationLink(destination: MatchDetailView(match: match)) {
                        MatchCard(match: match)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    // MARK: - Statistics Header
    
    private var statisticsHeader: some View {
        VStack(spacing: 12) {
            HStack {
                StatCard(
                    title: "Matches",
                    value: "\(viewModel.matches.count)",
                    icon: "checkmark.circle.fill",
                    color: AppColors.successGreen
                )
                
                StatCard(
                    title: "Score Moyen",
                    value: String(format: "%.0f%%", viewModel.averageScore),
                    icon: "chart.bar.fill",
                    color: AppColors.accentBlue
                )
            }
            
            if let bestMatch = viewModel.bestMatch {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Text("Meilleur match: \(bestMatch.titre)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.black)
                    
                    Spacer()
                    
                    Text(bestMatch.scorePercentage)
                        .font(.headline)
                        .foregroundColor(AppColors.primaryRed)
                }
                .padding()
                .background(AppColors.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
    }
}

// MARK: - Match Card Component

struct MatchCard: View {
    let match: MatchResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header avec titre et score
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(match.titre)
                        .font(.headline)
                        .foregroundColor(AppColors.black)
                        .lineLimit(2)
                    
                    if let company = match.company {
                        Text(company)
                            .font(.subheadline)
                            .foregroundColor(AppColors.mediumGray)
                    }
                }
                
                Spacer()
                
                // Score circulaire
                ZStack {
                    Circle()
                        .stroke(AppColors.lightGray, lineWidth: 4)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: match.scores.score / 100)
                        .stroke(match.matchLevel.color, lineWidth: 4)
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text(String(format: "%.0f", match.scores.score))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColors.black)
                        
                        Text("%")
                            .font(.caption2)
                            .foregroundColor(AppColors.mediumGray)
                    }
                }
            }
            
            // Tags
            HStack(spacing: 8) {
                if let location = match.location {
                    TagView(text: location, icon: "mappin.circle.fill", color: AppColors.accentBlue)
                }
                
                if let jobType = match.jobType {
                    TagView(text: jobType, icon: "briefcase.fill", color: AppColors.mediumDarkGray)
                }
                
                Spacer()
            }
            
            // Recommendation
            HStack {
                Text(match.matchLevel.emoji)
                    .font(.title3)
                
                Text(match.recommendation)
                    .font(.subheadline)
                    .foregroundColor(AppColors.mediumGray)
                    .lineLimit(2)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(match.matchLevel.color.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(AppColors.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.black)
            
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.mediumGray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Tag View Component

struct TagView: View {
    let text: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            
            Text(text)
                .font(.caption)
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    MatchingListView(availabilityViewModel: AvailabilityViewModel())
        .environmentObject(AuthService())
}

