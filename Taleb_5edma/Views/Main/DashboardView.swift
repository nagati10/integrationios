
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authService: AuthService
    
    // Navigation & UI State
    @State private var selectedTab = 0
    @State private var showingNotifications = false
    @State private var showingProfile = false
    @State private var showingMenu = false
    
    // Sheet States
    @State private var showingCreateOffer = false
    @State private var showingFaceVerification = false
    @State private var showingMaps = false
    @State private var selectedOffre: Offre?
    
    // Search & Filter
    @State private var searchText = ""
    @State private var selectedType: OfferTypeToggle.OfferType = .occasionnel
    
    // Data
    @StateObject private var offreViewModel = OffreViewModel()
    
    var filteredOffres: [Offre] {
        var filtered = offreViewModel.offres
        
        // Filter by Type logic
        switch selectedType {
        case .professionnel:
            // User requested: Professional -> freelance and stage
            filtered = filtered.filter { 
                let type = $0.jobType?.lowercased() ?? ""
                return type == "freelance" || type == "stage"
            }
        case .occasionnel:
            // Implied: Occasionnel -> job
            filtered = filtered.filter { 
                let type = $0.jobType?.lowercased() ?? ""
                return type == "job"
            }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { offre in
                offre.title.localizedCaseInsensitiveContains(searchText) ||
                offre.company.localizedCaseInsensitiveContains(searchText) ||
                offre.location.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: 0xF9F9F9).ignoresSafeArea()
            
            // Content based on Tab
            Group {
                switch selectedTab {
                case 0:
                    if authService.currentUser?.is_Organization == true {
                        EnterpriseHomeView()
                    } else {
                        homeFeedView
                    }
                case 1:
                    FavoritesView(onBrowseOffers: { selectedTab = 0 })
                case 2:
                    MyOffresView()
                case 3:
                    ProfileView(authService: authService)
                default:
                    homeFeedView
                }
            }
            .padding(.bottom, 80) // Space for bottom bar
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab, onAddTapped: {
                // Instead of directly showing CreateOffer, show FaceVerification
                showingFaceVerification = true
            })
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            Task {
                await offreViewModel.loadOffres()
            }
        }
        .sheet(isPresented: $showingMenu) {
            MenuView(selectedTab: $selectedTab)
        }
        .sheet(isPresented: $showingCreateOffer, onDismiss: {
            Task {
                await offreViewModel.loadOffres()
            }
        }) {
            CreateOfferView()
        }
        .sheet(item: $selectedOffre) { offre in
            OffreDetailView(offre: offre, viewModel: offreViewModel)
        }
        .sheet(isPresented: $showingMaps) {
            MapsViewWrapper()
        }
        .sheet(isPresented: $showingFaceVerification) {
            FaceVerificationView {
                // On Success
                showingFaceVerification = false
                // Delay slightly to allow dismissal animation before presenting new sheet
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingCreateOffer = true
                }
            }
        }
    }
    
    // MARK: - Home Feed View
    private var homeFeedView: some View {
        VStack(spacing: 0) {
            // Header
            HomeHeaderView(
                showingMenu: $showingMenu,
                showingNotifications: $showingNotifications,
                showingProfile: $showingProfile,
                notificationCount: 3
            )
            
            ScrollView {
                VStack(spacing: 20) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Rechercher un job, stage, freelance...", text: $searchText)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Filters (Chips)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            HomeFilterChip(title: "Tous les types", isSelected: false, action: {})
                            HomeFilterChip(title: "Toutes les villes", isSelected: false, action: {})
                            
                            // Map Button
                            Button(action: {
                                showingMaps = true
                            }) {
                                HStack {
                                    Image(systemName: "map.fill")
                                        .font(.system(size: 12))
                                    Text("Map")
                                        .font(.system(size: 14))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .cornerRadius(20)
                                .foregroundColor(AppColors.primaryRed)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }

                            Text("Filtre")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                    }
                }
                    
                    // Promo Banner
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color(hex: 0x6A4C93), Color(hex: 0x8D6E63)]), startPoint: .leading, endPoint: .trailing))
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.white)
                                    Text("Nouvelles opportunités")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                Text("\(offreViewModel.offres.count) offres pour vous")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.white)
                                .onTapGesture {
                                    Task { await offreViewModel.loadOffres() }
                                }
                        }
                        .padding()
                    }
                    .frame(height: 80)
                    .padding(.horizontal)
                    
                    // "Type d'offre" with Toggle
                    VStack(spacing: 12) {
                        Text("Type d'offre")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.top, 8)
                        
                        OfferTypeToggle(selectedType: $selectedType)
                    }
                    
                    // Offers List
                    LazyVStack(spacing: 16) {
                        ForEach(filteredOffres) { offre in
                            OffreCardView(offre: offre, onCardClick: {
                                selectedOffre = offre
                            })
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20) 
                }
                .padding(.top, 16)
            }
        }
    }


// Simple Chip for this view if not already global
struct HomeFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 14))
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(20)
            .foregroundColor(.black)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}
