//
//  MatchingAnimatedView.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import SwiftUI

/// Vue moderne et animée pour afficher les résultats du matching IA
struct MatchingAnimatedView: View {
    @StateObject private var viewModel: MatchingViewModel
    @EnvironmentObject var authService: AuthService
    @Environment(\.colorScheme) var colorScheme
    
    // Animation states
    @State private var showFilters = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showConfetti = false
    @State private var selectedMatch: MatchResult?
    
    init(availabilityViewModel: AvailabilityViewModel) {
        _viewModel = StateObject(wrappedValue: MatchingViewModel(availabilityViewModel: availabilityViewModel))
    }
    
    var body: some View {
        ZStack {
            // Background
            backgroundColor
                .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Custom navigation bar
                customNavigationBar
                
                // Content
                if viewModel.isLoading {
                    SkeletonLoadingView()
                        .transition(.opacity)
                } else if viewModel.matches.isEmpty {
                    emptyStateView
                        .transition(.scale.combined(with: .opacity))
                } else {
                    matchesContent
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            
            // Confetti overlay
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            
            // Filters overlay
            if showFilters {
                FiltersOverlay(
                    viewModel: viewModel,
                    isPresented: $showFilters
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.isLoading)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.matches.isEmpty)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showFilters)
        .task {
            await viewModel.analyzeMatching()
            checkForConfetti()
        }
        .alert("Erreur", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Une erreur est survenue")
        }
    }
    
    // MARK: - Background
    
    private var backgroundColor: some View {
        Group {
            if colorScheme == .dark {
                Color.black
            } else {
                AppColors.backgroundGray
            }
        }
    }
    
    // MARK: - Custom Navigation Bar
    
    private var customNavigationBar: some View {
        HStack {
            Text("Matching IA")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(primaryTextColor)
            
            Spacer()
            
            HStack(spacing: 16) {
                // Filters button
                Button(action: {
                    HapticManager.shared.impact(style: .light)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showFilters.toggle()
                    }
                }) {
                    Image(systemName: showFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .font(.title2)
                        .foregroundColor(AppColors.primaryRed)
                        .rotationEffect(.degrees(showFilters ? 180 : 0))
                }
                
                // Refresh button
                Button(action: {
                    HapticManager.shared.impact(style: .medium)
                    Task {
                        await viewModel.analyzeMatching()
                        checkForConfetti()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(AppColors.primaryRed)
                        .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            navigationBarBackground
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var navigationBarBackground: some View {
        Group {
            if colorScheme == .dark {
                Color(uiColor: .systemGray6)
            } else {
                Color.white
            }
        }
    }
    
    private var primaryTextColor: Color {
        colorScheme == .dark ? .white : AppColors.black
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? .gray : AppColors.mediumGray
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            // Animated illustration
            ZStack {
                Circle()
                    .fill(AppColors.primaryRed.opacity(0.1))
                    .frame(width: 150, height: 150)
                    .scaleEffect(1.0)
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                        value: UUID()
                    )
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.primaryRed)
            }
            .padding(.top, 60)
            
            VStack(spacing: 12) {
                Text("Aucun résultat")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(primaryTextColor)
                
                Text("Aucune offre ne correspond à vos disponibilités pour le moment")
                    .font(.body)
                    .foregroundColor(secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                HapticManager.shared.impact(style: .medium)
                Task {
                    await viewModel.analyzeMatching()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Relancer l'analyse")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [AppColors.primaryRed, AppColors.primaryRed.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: AppColors.primaryRed.opacity(0.4), radius: 10, x: 0, y: 5)
            }
            .padding(.top, 20)
            
            Spacer()
        }
    }
    
    // MARK: - Matches Content
    
    private var matchesContent: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Parallax header with statistics
                    parallaxHeader(geometry: geometry)
                        .offset(y: min(0, scrollOffset))
                    
                    // Matches list
                    ForEach(Array(viewModel.filteredMatches.enumerated()), id: \.element.id) { index, match in
                        AnimatedMatchCard(
                            match: match,
                            index: index,
                            onRemove: {
                                HapticManager.shared.notification(type: .success)
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    viewModel.removeMatch(match)
                                }
                            },
                            onTap: {
                                HapticManager.shared.impact(style: .light)
                                selectedMatch = match
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geo.frame(in: .named("scroll")).minY
                            )
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            .refreshable {
                HapticManager.shared.impact(style: .medium)
                await viewModel.refresh()
                checkForConfetti()
            }
        }
        .sheet(item: $selectedMatch) { match in
            MatchDetailView(match: match)
        }
    }
    
    // MARK: - Parallax Header
    
    private func parallaxHeader(geometry: GeometryProxy) -> some View {
        let offset = scrollOffset
        let scale = max(1.0, 1.0 + (offset / 1000.0))
        
        return VStack(spacing: 20) {
            // Statistics cards
            HStack(spacing: 16) {
                AnimatedStatCard(
                    title: "Matches",
                    value: "\(viewModel.matches.count)",
                    icon: "checkmark.circle.fill",
                    color: AppColors.successGreen,
                    delay: 0.0
                )
                
                AnimatedStatCard(
                    title: "Score Moyen",
                    value: String(format: "%.0f%%", viewModel.averageScore),
                    icon: "chart.bar.fill",
                    color: AppColors.accentBlue,
                    delay: 0.1
                )
            }
            
            // Best match banner
            if let bestMatch = viewModel.bestMatch {
                bestMatchBanner(match: bestMatch, delay: 0.2)
            }
        }
        .scaleEffect(scale)
        .opacity(1.0 - min(1.0, abs(offset) / 200.0))
    }
    
    private func bestMatchBanner(match: MatchResult, delay: Double) -> some View {
        HStack {
            // Animated star
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.title2)
                .rotationEffect(.degrees(360))
                .animation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: false)
                    .delay(delay),
                    value: UUID()
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Meilleur match")
                    .font(.caption)
                    .foregroundColor(secondaryTextColor)
                
                Text(match.titre)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(primaryTextColor)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Animated score
            AnimatedScoreText(score: match.scores.score, delay: delay)
        }
        .padding()
        .background(
            ZStack {
                if colorScheme == .dark {
                    Color(uiColor: .systemGray6)
                } else {
                    Color.white
                }
                
                LinearGradient(
                    colors: [
                        .yellow.opacity(0.1),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Helper Methods
    
    private func checkForConfetti() {
        if let bestMatch = viewModel.bestMatch, bestMatch.scores.score >= 90 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                HapticManager.shared.notification(type: .success)
                withAnimation {
                    showConfetti = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation {
                        showConfetti = false
                    }
                }
            }
        }
    }
}

// MARK: - Scroll Offset Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    MatchingAnimatedView(availabilityViewModel: AvailabilityViewModel())
        .environmentObject(AuthService())
}

