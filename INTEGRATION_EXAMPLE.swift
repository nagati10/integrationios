//
//  INTEGRATION_EXAMPLE.swift
//  Taleb_5edma
//
//  Exemples d'intégration du système de Matching IA
//  NE PAS INCLURE CE FICHIER DANS LE PROJET - C'EST JUSTE UN EXEMPLE
//

import SwiftUI

// ============================================
// EXEMPLE 1 : Intégration dans le Dashboard
// ============================================

struct DashboardView_WithMatching: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var availabilityViewModel = AvailabilityViewModel()
    @State private var selectedTab = 0
    @State private var showMatchingView = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Écran 1 - Dashboard/Accueil
            homeScreen
                .tag(0)
            
            // Écran 2 - Calendrier
            CalendarView()
                .tag(1)
            
            // Écran 3 - Disponibilités
            AvailabilityView()
                .tag(2)
            
            // Écran 4 - Matching IA (NOUVEAU)
            MatchingAnimatedView(availabilityViewModel: availabilityViewModel)
                .environmentObject(authService)
                .tag(3)
            
            // Écran 5 - Offres
            OffersView()
                .tag(4)
        }
        .accentColor(AppColors.primaryRed)
    }
    
    private var homeScreen: some View {
        VStack {
            // ... votre contenu dashboard ...
            
            // Bouton pour accéder au matching
            Button(action: {
                selectedTab = 3 // Aller au tab Matching
            }) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Trouver des offres avec l'IA")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [AppColors.primaryRed, AppColors.primaryRed.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding()
        }
    }
}

// ============================================
// EXEMPLE 2 : Modal Sheet
// ============================================

struct OffersView_WithMatchingButton: View {
    @State private var showMatching = false
    @StateObject private var availabilityViewModel = AvailabilityViewModel()
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            VStack {
                // ... votre liste d'offres ...
                
                Text("Liste des offres")
            }
            .navigationTitle("Offres")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showMatching = true
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Matching IA")
                        }
                    }
                }
            }
            .sheet(isPresented: $showMatching) {
                MatchingAnimatedView(availabilityViewModel: availabilityViewModel)
                    .environmentObject(authService)
            }
        }
    }
}

// ============================================
// EXEMPLE 3 : Navigation Push
// ============================================

struct AvailabilityView_WithMatchingNavigation: View {
    @StateObject private var viewModel = AvailabilityViewModel()
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            VStack {
                // ... votre gestion de disponibilités ...
                
                List {
                    ForEach(viewModel.disponibilites) { dispo in
                        Text("\(dispo.jour): \(dispo.heureDebut) - \(dispo.heureFin ?? "Fin de journée")")
                    }
                }
                
                // Bouton pour lancer le matching
                NavigationLink(destination: MatchingAnimatedView(availabilityViewModel: viewModel)) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Analyser avec l'IA")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.primaryRed)
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Disponibilités")
        }
    }
}

// ============================================
// EXEMPLE 4 : Utilisation du ViewModel
// ============================================

struct CustomMatchingView: View {
    @StateObject private var viewModel: MatchingViewModel
    @State private var showFilters = false
    
    init(availabilityViewModel: AvailabilityViewModel) {
        _viewModel = StateObject(wrappedValue: MatchingViewModel(availabilityViewModel: availabilityViewModel))
    }
    
    var body: some View {
        VStack {
            // Header personnalisé
            HStack {
                Text("Mes Matches")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Filtres") {
                    showFilters.toggle()
                }
            }
            .padding()
            
            // Statistiques
            HStack {
                VStack {
                    Text("\(viewModel.matches.count)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Matches")
                        .font(.caption)
                }
                
                Spacer()
                
                VStack {
                    Text(String(format: "%.0f%%", viewModel.averageScore))
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Score Moyen")
                        .font(.caption)
                }
            }
            .padding()
            
            // Liste des matches
            List(viewModel.filteredMatches) { match in
                VStack(alignment: .leading) {
                    Text(match.titre)
                        .font(.headline)
                    Text(match.recommendation)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Score: \(match.scorePercentage)")
                        .foregroundColor(match.matchLevel.color)
                }
            }
        }
        .task {
            // Lancer l'analyse au chargement
            await viewModel.analyzeMatching()
        }
    }
}

// ============================================
// EXEMPLE 5 : Avec Préférences Personnalisées
// ============================================

struct MatchingWithPreferences: View {
    @StateObject private var viewModel: MatchingViewModel
    @State private var selectedJobType = "stage"
    @State private var minSalary = "1000"
    @State private var location = "Tunis"
    
    init(availabilityViewModel: AvailabilityViewModel) {
        _viewModel = StateObject(wrappedValue: MatchingViewModel(availabilityViewModel: availabilityViewModel))
    }
    
    var body: some View {
        VStack {
            // Formulaire de préférences
            Form {
                Section("Préférences") {
                    Picker("Type de job", selection: $selectedJobType) {
                        Text("Stage").tag("stage")
                        Text("Temps partiel").tag("temps-partiel")
                        Text("Freelance").tag("freelance")
                    }
                    
                    TextField("Salaire minimum", text: $minSalary)
                    TextField("Localisation", text: $location)
                }
            }
            .frame(height: 250)
            
            // Bouton de lancement
            Button(action: {
                Task {
                    let prefs = MatchingRequest.MatchingPreferences(
                        jobType: selectedJobType,
                        salary: minSalary,
                        location: location
                    )
                    await viewModel.analyzeMatching(preferences: prefs)
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("Lancer l'analyse")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.primaryRed)
                .cornerRadius(12)
            }
            .padding()
            .disabled(viewModel.isLoading)
            
            // Résultats
            if !viewModel.matches.isEmpty {
                List(viewModel.matches) { match in
                    NavigationLink(destination: MatchDetailView(match: match)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(match.titre)
                                    .font(.headline)
                                Text(match.company ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text(match.scorePercentage)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(match.matchLevel.color)
                        }
                    }
                }
            }
        }
    }
}

// ============================================
// EXEMPLE 6 : Menu Item
// ============================================

struct MenuView_WithMatching: View {
    @Binding var selectedTab: Int
    @StateObject private var availabilityViewModel = AvailabilityViewModel()
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // ... autres items du menu ...
                
                Section("Intelligence Artificielle") {
                    NavigationLink(destination: MatchingAnimatedView(availabilityViewModel: availabilityViewModel)) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(AppColors.primaryRed)
                            Text("Matching IA")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Menu")
        }
    }
}

// ============================================
// EXEMPLE 7 : Quick Action Card (Dashboard)
// ============================================

struct MatchingQuickActionCard: View {
    @Binding var showMatching: Bool
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(style: .medium)
            showMatching = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.gray)
                }
                
                Text("Matching IA")
                    .font(.headline)
                    .foregroundColor(AppColors.black)
                
                Text("Trouvez les meilleures offres adaptées à vos disponibilités")
                    .font(.caption)
                    .foregroundColor(AppColors.mediumGray)
                    .lineLimit(2)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [
                        .yellow.opacity(0.1),
                        .orange.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

