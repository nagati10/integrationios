//
//  BioDataView.swift
//  Taleb_5edma
//

import SwiftUI

struct BioDataView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    @State private var showAICVAnalysis = false
    
    // Champs éditables
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var joinedAt: String = "08 novembre 2025"
    
    // Pour savoir si quelque chose a changé
    @State private var initialName: String = ""
    @State private var initialPhone: String = ""
    
    private var hasChanges: Bool {
        (name != initialName || phone != initialPhone)
        && !name.isEmpty
        && !phone.isEmpty
    }
    
    var body: some View {
        ZStack {
            // Background dégradé
            LinearGradient(
                colors: [AppColors.darkRed, AppColors.primaryRed],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    Spacer(minLength: 40)
                    
                    // Carte principale
                    VStack(spacing: 22) {
                        
                        // Titre
                        VStack(alignment: .leading, spacing: 4) {
                            Text(" profil" )
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundColor(AppColors.black)
                            
                            Text("Mettre à jour vos informations personnelles")
                                .font(.subheadline)
                                .foregroundColor(AppColors.mediumGray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Champs
                        VStack(spacing: 16) {
                            fieldRow(
                                label: "Name",
                                systemIcon: "person.fill",
                                text: $name,
                                editable: true
                            )
                            
                            fieldRow(
                                label: "Email",
                                systemIcon: "envelope.fill",
                                text: $email,
                                editable: false
                            )
                            
                            fieldRow(
                                label: "Phone Number",
                                systemIcon: "phone.fill",
                                text: $phone,
                                editable: true,
                                keyboardType: .phonePad
                            )
                            
                            // Joined at
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Joined at")
                                    .font(.caption)
                                    .foregroundColor(AppColors.mediumGray)
                                
                                Text(joinedAt)
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.black)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical)
                                    .background(
                                        Capsule()
                                            .fill(AppColors.white)
                                            .shadow(
                                                color: .black.opacity(0.05),
                                                radius: 3,
                                                x: 0,
                                                y: 1
                                            )
                                    )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // INFORMATIONS COMPLÈTES DU PROFIL
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Informations du Compte")
                                    .font(.headline)
                                    .foregroundColor(AppColors.black)
                                    .padding(.top, 8)
                                
                                // Role
                                if let role = viewModel.currentUser?.role {
                                    infoRow(icon: "person.badge.shield.checkmark", label: "Rôle", value: role.capitalized)
                                }
                                
                                // Status
                                if let status = viewModel.currentUser?.Currentstatus {
                                    infoRow(icon: "circle.fill", label: "Statut", value: status, iconColor: status == "active" ? .green : .gray)
                                }
                                
                                // Trust XP
                                if let trustXP = viewModel.currentUser?.TrustXP {
                                    infoRow(icon: "star.fill", label: "Trust XP", value: "\(trustXP) points", iconColor: .yellow)
                                }
                                
                                // Organization
                                if let isOrg = viewModel.currentUser?.is_Organization {
                                    infoRow(icon: "building.2", label: "Type de compte", value: isOrg ? "Organisation" : "Particulier")
                                }
                                
                                // Online Status
                                if let isOnline = viewModel.currentUser?.isOnline {
                                    infoRow(icon: "wifi", label: "Connexion", value: isOnline ? "En ligne" : "Hors ligne", iconColor: isOnline ? .green : .gray)
                                }
                                
                                // Exam Mode
                                if let examMode = viewModel.currentUser?.modeExamens {
                                    infoRow(icon: "graduationcap.fill", label: "Mode Examen", value: examMode ? "Activé" : "Désactivé", iconColor: examMode ? .purple : .gray)
                                }
                                
                                // Archived
                                if let archived = viewModel.currentUser?.is_archive {
                                    if archived {
                                        infoRow(icon: "archivebox.fill", label: "Archive", value: "Compte archivé", iconColor: .orange)
                                    }
                                }
                                
                                // Activity Stats
                                Text("Statistiques")
                                    .font(.headline)
                                    .foregroundColor(AppColors.black)
                                    .padding(.top, 8)
                                
                                // Liked Offers
                                if let likedCount = viewModel.currentUser?.likedOffres?.count {
                                    infoRow(icon: "heart.fill", label: "Offres aimées", value: "\(likedCount)", iconColor: .red)
                                }
                                
                                // Chats
                                if let chatsCount = viewModel.currentUser?.chats?.count {
                                    infoRow(icon: "message.fill", label: "Conversations", value: "\(chatsCount)", iconColor: .blue)
                                }
                                
                                // Blocked Users
                                if let blockedCount = viewModel.currentUser?.blockedUsers?.count, blockedCount > 0 {
                                    infoRow(icon: "hand.raised.fill", label: "Utilisateurs bloqués", value: "\(blockedCount)", iconColor: .orange)
                                }
                                
                                // CV Data
                                Text("Données CV")
                                    .font(.headline)
                                    .foregroundColor(AppColors.black)
                                    .padding(.top, 8)
                                
                                if let expCount = viewModel.currentUser?.cvExperience?.count {
                                    infoRow(icon: "briefcase.fill", label: "Expériences", value: "\(expCount) entrée(s)", iconColor: .indigo)
                                }
                                
                                if let eduCount = viewModel.currentUser?.cvEducation?.count {
                                    infoRow(icon: "graduationcap.fill", label: "Formations", value: "\(eduCount) entrée(s)", iconColor: .cyan)
                                }
                                
                                if let skillsCount = viewModel.currentUser?.cvSkills?.count {
                                    infoRow(icon: "star.fill", label: "Compétences", value: "\(skillsCount) compétence(s)", iconColor: .orange)
                                }
                                
                                // Timestamps
                                Text("Dates")
                                    .font(.headline)
                                    .foregroundColor(AppColors.black)
                                    .padding(.top, 8)
                                
                                if let lastSeen = viewModel.currentUser?.lastSeen {
                                    infoRow(icon: "clock.fill", label: "Dernière activité", value: formatDate(lastSeen))
                                }
                                
                                if let updatedAt = viewModel.currentUser?.updatedAt {
                                    infoRow(icon: "arrow.clockwise", label: "Dernière mise à jour", value: formatDate(updatedAt))
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                            .background(AppColors.backgroundGray.opacity(0.3))
                            .cornerRadius(12)
                        }
                        
                        // Boutons
                        VStack(spacing: 14) {
                            Button {
                                showAICVAnalysis = true
                            } label: {
                                Text("Analyser mon CV avec l'IA")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [AppColors.primaryRed, AppColors.darkRed],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(14)
                            }
                            
                           
                            
                            Button {
                                saveChanges()
                            } label: {
                                Text("Save Changes")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        AppColors.lightGray.opacity(hasChanges ? 1.0 : 0.7)
                                    )
                                    .foregroundColor(
                                        hasChanges ? AppColors.black : AppColors.mediumGray
                                    )
                                    .cornerRadius(14)
                            }
                            .disabled(!hasChanges)
                        }
                    }
                    .padding(24)
                    .background(
                        AppColors.white
                            .opacity(0.96)
                            .cornerRadius(26)
                    )
                    .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 6)
                    .padding(.horizontal, 20)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding( .leading, 16)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.15))
                        )
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            loadUserData()
        }
        .fullScreenCover(isPresented: $showAICVAnalysis) {
            AICVAnalysisView()
                .environmentObject(authService)
        }
    }
    
    // MARK: - Sous-vues
    
    private func fieldRow(
        label: String,
        systemIcon: String,
        text: Binding<String>,
        editable: Bool,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.mediumGray)
            
            HStack(spacing: 10) {
                Image(systemName: systemIcon)
                    .foregroundColor(AppColors.black)
                    .frame(width: 24)
                
                if editable {
                    TextField(label, text: text)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled(true)
                } else {
                    Text(text.wrappedValue)
                        .foregroundColor(AppColors.mediumGray)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppColors.white)
            )
        }
    }
    
    // MARK: - Logic
    
    private func loadUserData() {
        if let user = viewModel.currentUser {
            name = user.nom
            email = user.email
            phone = user.contact
            
            initialName = user.nom
            initialPhone = user.contact
        }
    }
    
    private func saveChanges() {
        viewModel.updateUserProfile(nom: name, contact: phone)
    }
    
    /// Helper view for displaying read-only profile information
    private func infoRow(icon: String, label: String, value: String, iconColor: Color = AppColors.primaryRed) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.caption)
                .frame(width: 20)
            
            Text(label + ":")
                .font(.caption)
                .foregroundColor(AppColors.mediumGray)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppColors.black)
        }
        .padding(.vertical, 4)
    }
    
    /// Format date to relative time string
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    let auth = AuthService()
    let vm = ProfileViewModel(authService: auth)
    
    return NavigationStack {
        BioDataView(viewModel: vm)
            .environmentObject(auth)
    }
}
