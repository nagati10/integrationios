//
//  EnterpriseStatisticsView.swift
//  Taleb_5edma
//
//  Created for displaying enterprise statistics
//

import SwiftUI

struct EnterpriseStatisticsView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var offreViewModel = OffreViewModel()
    
    // Pour les chats, on utilise directement le service
    @State private var userChats: [Chat] = []
    private let chatService = ChatService()
    
    @State private var isLoading = false
    @State private var selectedPeriod: String = "Mois"
    
    // Computed properties for stats
    private var offersCount: Int {
        offreViewModel.offres.count
    }
    
    private var candidatesCount: Int {
        userChats.count
    }
    
    private var interviewsCount: Int {
        userChats.filter { chat in
            chat.isAccepted == true
        }.count
    }
    
    private var activeOffersCount: Int {
        offreViewModel.offres.filter { $0.isActive == true }.count
    }
    
    private var inactiveOffersCount: Int {
        offreViewModel.offres.filter { $0.isActive == false }.count
    }
    
    // Segments pour le graphique en donut
    private var donutSegments: [DonutSegment] {
        var segments: [DonutSegment] = []
        
        if activeOffersCount > 0 {
            segments.append(DonutSegment(
                value: Double(activeOffersCount),
                color: Color(hex: 0x9333ea),
                label: "Offres actives"
            ))
        }
        
        if inactiveOffersCount > 0 {
            segments.append(DonutSegment(
                value: Double(inactiveOffersCount),
                color: Color(hex: 0x6366f1),
                label: "Offres inactives"
            ))
        }
        
        if candidatesCount > 0 {
            segments.append(DonutSegment(
                value: Double(candidatesCount),
                color: Color(hex: 0x10b981),
                label: "Candidats"
            ))
        }
        
        if interviewsCount > 0 {
            segments.append(DonutSegment(
                value: Double(interviewsCount),
                color: Color(hex: 0xf59e0b),
                label: "Interviews"
            ))
        }
        
        return segments
    }
    
    private var totalActivity: Double {
        Double(offersCount + candidatesCount + interviewsCount)
    }
    
    var body: some View {
        ZStack {
            // Background avec gradient subtil
            LinearGradient(
                colors: [
                    Color(hex: 0xFDFDFD),
                    Color(hex: 0xF5F5F5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color(hex: 0x9333ea))
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header avec balance et sélecteur
                        balanceHeaderSection
                        
                        // Graphique en donut
                        donutChartSection
                        
                        // Menu rapide
                        quickMenuSection
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Statistiques")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadData()
        }
    }
    
    // MARK: - Balance Header Section
    
    private var balanceHeaderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Vue d'ensemble")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: 0x9333ea).opacity(0.8))
                    
                    Text("\(offersCount)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(AppColors.black)
                }
                
                Spacer()
                
                // Sélecteur de période
                Menu {
                    Button("Semaine") { selectedPeriod = "Semaine" }
                    Button("Mois") { selectedPeriod = "Mois" }
                    Button("Trimestre") { selectedPeriod = "Trimestre" }
                    Button("Année") { selectedPeriod = "Année" }
                } label: {
                    HStack(spacing: 6) {
                        Text(selectedPeriod)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.black)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.black)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: 0x9333ea).opacity(0.1),
                    Color(hex: 0x7c3aed).opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24)
        .shadow(color: Color(hex: 0x9333ea).opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Donut Chart Section
    
    private var donutChartSection: some View {
        VStack(spacing: 20) {
            if !donutSegments.isEmpty {
                ZStack {
                    // Graphique en donut
                    DonutChartView(
                        segments: donutSegments,
                        centerText: "\(offersCount)",
                        centerSubtext: "Total offres",
                        lineWidth: 35
                    )
                    .frame(height: 220)
                    
                    // Légende autour du graphique
                    VStack(spacing: 16) {
                        ForEach(donutSegments) { segment in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(segment.color)
                                    .frame(width: 14, height: 14)
                                
                                Text(segment.label)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(AppColors.darkGray)
                                
                                Spacer()
                                
                                Text("\(Int(segment.value))")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AppColors.black)
                            }
                        }
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 240)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: 0x9333ea).opacity(0.3))
                    
                    Text("Aucune donnée disponible")
                        .font(.subheadline)
                        .foregroundColor(AppColors.mediumGray)
                }
                .frame(height: 220)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Quick Menu Section
    
    private var quickMenuSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Menu rapide")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.black)
                
                Spacer()
                
                Button("Voir tout") {
                    // TODO: Naviguer vers le menu complet
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: 0x9333ea))
            }
            
            HStack(spacing: 16) {
                QuickMenuButton(
                    icon: "briefcase.fill",
                    title: "Créer une offre",
                    color: Color(hex: 0x4f46e5)
                ) {
                    // TODO: Action pour créer une offre
                }
                
                QuickMenuButton(
                    icon: "person.2.fill",
                    title: "Voir candidats",
                    color: Color(hex: 0x10b981)
                ) {
                    // TODO: Action pour voir les candidats
                }
                
                QuickMenuButton(
                    icon: "chart.bar.fill",
                    title: "Analyses",
                    color: Color(hex: 0xf59e0b)
                ) {
                    // TODO: Action pour analyses
                }
            }
        }
    }
    
    
    // MARK: - Helper Methods
    
    private func loadData() {
        isLoading = true
        
        Task {
            await offreViewModel.loadMyOffres()
            
            do {
                let chats = try await chatService.getMyChats()
                await MainActor.run {
                    userChats = chats
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    print("⚠️ Erreur chargement chats: \(error.localizedDescription)")
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Quick Menu Button Component

struct QuickMenuButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Activity Row Item Component

struct ActivityRowItem: View {
    let offre: Offre
    
    var body: some View {
        HStack(spacing: 16) {
            // Icône
            ZStack {
                Circle()
                    .fill(Color(hex: 0x9333ea).opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: 0x9333ea))
            }
            
            // Informations
            VStack(alignment: .leading, spacing: 4) {
                Text(offre.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.black)
                    .lineLimit(1)
                
                Text(offre.company)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.mediumGray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Statut
            if let isActive = offre.isActive {
                HStack(spacing: 4) {
                    Circle()
                        .fill(isActive ? Color(hex: 0x10b981) : Color(hex: 0xef4444))
                        .frame(width: 8, height: 8)
                    
                    Text(isActive ? "Active" : "Inactive")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isActive ? Color(hex: 0x10b981) : Color(hex: 0xef4444))
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        EnterpriseStatisticsView()
            .environmentObject(AuthService())
    }
}

