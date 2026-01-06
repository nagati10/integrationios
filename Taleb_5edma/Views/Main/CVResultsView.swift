//
//  CVResultsView.swift
//  Taleb_5edma
//
//  Created for displaying saved CV analysis results from user profile
//

import SwiftUI

struct CVResultsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var user: User?
    
    var body: some View {
        ZStack {
            // Background
            AppColors.backgroundGray
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(AppColors.primaryRed)
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        if let user = user {
                            // Check if user has any CV data
                            if hasAnyCVData(user) {
                                cvContentView(user: user)
                            } else {
                                emptyStateView
                            }
                        } else {
                            emptyStateView
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Mon CV Analysé")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    loadUserProfile()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(AppColors.primaryRed)
                }
            }
        }
        .alert("Erreur", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Une erreur est survenue")
        }
        .onAppear {
            loadUserProfile()
        }
    }
    
    // MARK: - CV Content View
    
    @ViewBuilder
    private func cvContentView(user: User) -> some View {
        // Header with user info
        VStack(alignment: .leading, spacing: 8) {
            Text(user.nom)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.black)
            
            if !user.email.isEmpty {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(AppColors.primaryRed)
                        .font(.caption)
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(AppColors.mediumGray)
                }
            }
            
            if !user.contact.isEmpty {
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(AppColors.primaryRed)
                        .font(.caption)
                    Text(user.contact)
                        .font(.subheadline)
                        .foregroundColor(AppColors.mediumGray)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColors.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        
        // Experience Section
        if let experience = user.cvExperience, !experience.isEmpty {
            cvSection(title: "EXPÉRIENCE PROFESSIONNELLE", icon: "briefcase.fill") {
                ForEach(experience, id: \.self) { item in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(AppColors.primaryRed)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        
                        Text(item)
                            .font(.subheadline)
                            .foregroundColor(AppColors.darkGray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        
        // Education Section
        if let education = user.cvEducation, !education.isEmpty {
            cvSection(title: "FORMATION", icon: "graduationcap.fill") {
                ForEach(education, id: \.self) { item in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(AppColors.primaryRed)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        
                        Text(item)
                            .font(.subheadline)
                            .foregroundColor(AppColors.darkGray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        
        // Skills Section
        if let skills = user.cvSkills, !skills.isEmpty {
            cvSection(title: "COMPÉTENCES", icon: "star.fill") {
                FlowLayout(spacing: 8) {
                    ForEach(skills, id: \.self) { skill in
                        Text(skill)
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.primaryRed)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColors.primaryRed.opacity(0.1))
                            .cornerRadius(16)
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(AppColors.mediumGray)
            
            Text("Aucun CV Analysé")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.darkGray)
            
            Text("Vous n'avez pas encore analysé de CV.\nUtilisez l'outil d'analyse IA pour extraire les informations de votre CV.")
                .font(.subheadline)
                .foregroundColor(AppColors.mediumGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 60)
    }
    
    // MARK: - Section Builder
    
    @ViewBuilder
    private func cvSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(AppColors.primaryRed)
                    .font(.headline)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryRed)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                content()
            }
        }
        .padding()
        .background(AppColors.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Helper Methods
    
    private func loadUserProfile() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedUser = try await authService.getUserProfile()
                await MainActor.run {
                    self.user = fetchedUser
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Impossible de charger le profil: \(error.localizedDescription)"
                    self.showError = true
                    self.isLoading = false
                }
            }
        }
    }
    
    private func hasAnyCVData(_ user: User) -> Bool {
        let hasExperience = user.cvExperience?.isEmpty == false
        let hasEducation = user.cvEducation?.isEmpty == false
        let hasSkills = user.cvSkills?.isEmpty == false
        return hasExperience || hasEducation || hasSkills
    }
}

// MARK: - Flow Layout for Skills
// A simple flow layout to wrap skills tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    NavigationView {
        CVResultsView()
            .environmentObject(AuthService())
    }
}
