
import SwiftUI

struct EnterpriseHomeView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var offreViewModel = OffreViewModel()
    
    // Pour les chats, on utilise directement le service
    @State private var userChats: [Chat] = []
    private let chatService = ChatService()
    
    @State private var appearAnimation = false
    @State private var showingMenu = false
    @State private var showingNotifications = false
    @State private var showingProfile = false
    @State private var showingLogoutConfirmation = false
    @State private var selectedTab = 0
    @State private var showingCreateOffer = false
    
    // Computed properties for stats
    private var offersCount: Int {
        offreViewModel.offres.count
    }
    
    private var candidatesCount: Int {
        userChats.count
    }
    
    private var interviewsCount: Int {
        // Pour l'instant, on peut utiliser le nombre de chats acceptés comme interviews
        // ou simplement 0 si pas encore implémenté
        userChats.filter { chat in
            chat.isAccepted == true
        }.count
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background principal
            Color(hex: 0xFDFDFD)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Topbar (HomeHeaderView)
                HomeHeaderView(
                    showingMenu: $showingMenu,
                    showingNotifications: $showingNotifications,
                    showingProfile: $showingProfile,
                    notificationCount: 3
                )
                .environmentObject(authService)
                .background(Color.white)
                
                // MARK: - Premium Header (uniquement sur l'accueil)
                if selectedTab == 0 {
                    ZStack(alignment: .bottom) {
                        // Background Gradient with Blur circles - sans rose/rouge
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: 0x9333ea).opacity(0.9),
                                Color(hex: 0x7c3aed).opacity(0.8),
                                Color(hex: 0x6366f1).opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()
                        
                        // Abstract decorative circles
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 200, height: 200)
                            .offset(x: -100, y: -50)
                        
                        Circle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 150, height: 150)
                            .offset(x: 120, y: 20)
                        
                        VStack(spacing: 12) {
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Espace")
                                        .font(.system(size: 14, weight: .medium))
                                        .textCase(.uppercase)
                                        .tracking(2)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    HStack(spacing: 8) {
                                        Text("Entreprise")
                                            .font(.system(size: 32, weight: .black))
                                            .foregroundColor(.white)
                                        
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 20))
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            .padding(.bottom, 24)
                        }
                    }
                    .frame(height: 180)
                    .cornerRadius(40, corners: [.bottomLeft, .bottomRight])
                    .shadow(color: Color(hex: 0x9333ea).opacity(0.2), radius: 20, x: 0, y: 10)
                }
                
                // MARK: - Main Content (selon l'onglet sélectionné)
                Group {
                    switch selectedTab {
                    case 0:
                        // Accueil - Page d'accueil entreprise
                        ScrollView {
                            VStack(spacing: 28) {
                                // Welcome Card with Glassmorphism
                                VStack(spacing: 20) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: 0x9333ea).opacity(0.1))
                                            .frame(width: 80, height: 80)
                                        
                                        Image(systemName: "hand.wave.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color(hex: 0x7c3aed))
                                            .rotationEffect(.degrees(appearAnimation ? 0 : -20))
                                            .animation(Animation.easeInOut(duration: 0.6).repeatCount(3, autoreverses: true), value: appearAnimation)
                                    }
                                    
                                    VStack(spacing: 8) {
                                        Text("Bonjour, \(authService.currentUser?.nom ?? "Entreprise")")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(AppColors.black)
                                        
                                        Text("Gérez vos offres et trouvez les talents qui feront grandir votre projet.")
                                            .font(.system(size: 15))
                                            .foregroundColor(AppColors.darkGray)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 30)
                                            .lineSpacing(4)
                                    }
                                }
                                .padding(.vertical, 36)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 32)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 10)
                                )
                                .padding(.horizontal)
                                .padding(.top, 24)
                                .offset(y: appearAnimation ? 0 : 30)
                                .opacity(appearAnimation ? 1 : 0)
                                
                                // MARK: - Quick Stats Grid
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("VOTRE ACTIVITÉ")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.gray)
                                        .tracking(1.5)
                                        .padding(.leading, 24)
                                    
                                    HStack(spacing: 16) {
                                        EnhancedStatCard(title: "Offres", value: "\(offersCount)", icon: "briefcase.fill", color: Color(hex: 0x4f46e5))
                                        EnhancedStatCard(title: "Candidats", value: "\(candidatesCount)", icon: "person.2.fill", color: Color(hex: 0x10b981))
                                        EnhancedStatCard(title: "Interviews", value: "\(interviewsCount)", icon: "video.fill", color: Color(hex: 0xf59e0b))
                                    }
                                    .padding(.horizontal)
                                }
                                .offset(y: appearAnimation ? 0 : 50)
                                .opacity(appearAnimation ? 1 : 0)
                                
                                // MARK: - Activité récente
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Text("Activité récente")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(AppColors.black)
                                        
                                        Spacer()
                                        
                                        Button("Voir tout") {
                                            selectedTab = 2 // Naviguer vers "Mes offres"
                                        }
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: 0x9333ea))
                                    }
                                    .padding(.horizontal, 24)
                                    
                                    // Liste des activités récentes
                                    VStack(spacing: 12) {
                                        if !offreViewModel.offres.isEmpty {
                                            ForEach(offreViewModel.offres.prefix(5)) { offre in
                                                ActivityRowItem(offre: offre)
                                            }
                                        } else {
                                            VStack(spacing: 12) {
                                                Image(systemName: "clock.fill")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(AppColors.mediumGray.opacity(0.5))
                                                
                                                Text("Aucune activité récente")
                                                    .font(.subheadline)
                                                    .foregroundColor(AppColors.mediumGray)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 40)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
                                    .padding(.horizontal, 24)
                                }
                                .offset(y: appearAnimation ? 0 : 60)
                                .opacity(appearAnimation ? 1 : 0)
                                
                                // Espace en bas pour la bottom bar
                                Spacer()
                                    .frame(height: 100)
                            }
                        }
                        .background(Color(hex: 0xFDFDFD))
                        .onAppear {
                            // Recharger les données quand on revient sur l'accueil
                            Task {
                                await offreViewModel.loadMyOffres()
                                do {
                                    let chats = try await chatService.getMyChats()
                                    await MainActor.run {
                                        userChats = chats
                                    }
                                } catch {
                                    print("⚠️ Erreur chargement chats: \(error.localizedDescription)")
                                }
                            }
                        }
                    case 1:
                        // Contacts - Messages des candidats
                        EnterpriseContactsView()
                            .environmentObject(authService)
                    case 2:
                        // Mes offres - Afficher les offres créées par l'entreprise
                        MyOffresView()
                    case 3:
                        // Statistiques
                        EnterpriseStatisticsView()
                            .environmentObject(authService)
                    default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // MARK: - Bottom Bar (CustomTabBar avec menu profil) - Toujours visible
            EnterpriseCustomTabBar(
                selectedTab: $selectedTab,
                onAddTapped: {
                    showingCreateOffer = true
                },
                showingLogoutConfirmation: $showingLogoutConfirmation
            )
            .environmentObject(authService)
        }
            .sheet(isPresented: $showingCreateOffer, onDismiss: {
                // Recharger les données après création d'offre
                Task {
                    await offreViewModel.loadMyOffres()
                    // Recharger aussi les chats
                    do {
                        let chats = try await chatService.getMyChats()
                        await MainActor.run {
                            userChats = chats
                        }
                    } catch {
                        print("⚠️ Erreur chargement chats: \(error.localizedDescription)")
                    }
                }
            }) {
                // Créer une offre professionnelle (freelance ou stage)
                CreateOfferView(initialJobType: "freelance")
                    .environmentObject(authService)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                    appearAnimation = true
                }
                
                // Charger les données
                Task {
                    await offreViewModel.loadMyOffres()
                    // Charger les chats de l'utilisateur
                    do {
                        let chats = try await chatService.getMyChats()
                        await MainActor.run {
                            userChats = chats
                        }
                    } catch {
                        print("⚠️ Erreur chargement chats: \(error.localizedDescription)")
                    }
                }
            }
            .sheet(isPresented: $showingMenu) {
                MenuView(selectedTab: .constant(0))
            }
            .sheet(isPresented: $showingNotifications) {
                // TODO: Vue des notifications
                Text("Notifications")
            }
            .sheet(isPresented: $showingProfile) {
                ProfileMenuView(
                    showingLogoutConfirmation: $showingLogoutConfirmation,
                    onViewProfile: {
                        showingProfile = false
                        // TODO: Naviguer vers la page de profil
                    }
                )
                .environmentObject(authService)
            }
            .alert("Déconnexion", isPresented: $showingLogoutConfirmation) {
                Button("Annuler", role: .cancel) { }
                Button("Se déconnecter", role: .destructive) {
                    authService.logout()
                }
            } message: {
                Text("Êtes-vous sûr de vouloir vous déconnecter ?")
            }
    }
}

// MARK: - Enterprise Custom Tab Bar

struct EnterpriseCustomTabBar: View {
    @Binding var selectedTab: Int
    var onAddTapped: () -> Void
    @Binding var showingLogoutConfirmation: Bool
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack {
                        // Tab 0: Accueil
                        TabBarButton(imageName: "house.fill", text: "Accueil", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        
                        Spacer()
                        
                        // Tab 1: Contact
                        TabBarButton(imageName: "person.2.fill", text: "Contact", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                        
                        Spacer()
                        
                        // Center Space for Floating Button
                        Spacer()
                            .frame(width: 60)
                        
                        Spacer()
                        
                        // Tab 2: Mes offres
                        TabBarButton(imageName: "clock", text: "Mes offres", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }
                        
                        Spacer()
                        
                        // Tab 3: Statistiques
                        TabBarButton(imageName: "chart.bar.fill", text: "Statistiques", isSelected: selectedTab == 3) {
                            selectedTab = 3
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 60)
                    .padding(.bottom, 20)
                    .background(Color.white)
                }
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
                
                // Floating + Button
                Button(action: onAddTapped) {
                    ZStack {
                        LinearGradient(gradient: Gradient(colors: [Color(hex: 0xB042FF), Color(hex: 0x8A2BE2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .shadow(color: Color.purple.opacity(0.4), radius: 8, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(Color.white, lineWidth: 4)
                            )
                        
                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -30)
            }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Profile Menu View

struct ProfileMenuView: View {
    @EnvironmentObject var authService: AuthService
    @Binding var showingLogoutConfirmation: Bool
    var onViewProfile: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Avatar
                if let imageURL = authService.currentUser?.image, !imageURL.isEmpty {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color(hex: 0x7c3aed))
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    ZStack {
                        Circle()
                            .fill(Color(hex: 0xFF69B4))
                            .frame(width: 100, height: 100)
                        
                        if let nom = authService.currentUser?.nom, !nom.isEmpty {
                            Text(String(nom.prefix(2)).uppercased())
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                        }
                    }
                }
                
                // Nom et email
                VStack(spacing: 4) {
                    Text(authService.currentUser?.nom ?? "Entreprise")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text(authService.currentUser?.email ?? "")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                
                Divider()
                    .padding(.vertical, 20)
                
                // Options
                VStack(spacing: 16) {
                    Button(action: {
                        onViewProfile()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "person.circle")
                                .font(.title3)
                            Text("Voir le profil")
                                .font(.system(size: 18))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Button(role: .destructive, action: {
                        dismiss()
                        showingLogoutConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.title3)
                            Text("Se déconnecter")
                                .font(.system(size: 18))
                            Spacer()
                        }
                        .foregroundColor(Color(hex: 0x9333ea))
                        .padding()
                        .background(Color(hex: 0x9333ea).opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Subviews

struct EnhancedStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(AppColors.black)
                
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Previews

#Preview {
    EnterpriseHomeView()
        .environmentObject(AuthService())
}
