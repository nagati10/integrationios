//
//  FiltersOverlay.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import SwiftUI

struct FiltersOverlay: View {
    @ObservedObject var viewModel: MatchingViewModel
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }
            
            // Filters panel
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Text("Filtres")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                    
                    Spacer()
                    
                    Button(action: {
                        HapticManager.shared.impact(style: .light)
                        viewModel.resetFilters()
                    }) {
                        Text("Réinitialiser")
                            .font(.subheadline)
                            .foregroundColor(AppColors.primaryRed)
                    }
                    
                    Button(action: {
                        HapticManager.shared.impact(style: .light)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(secondaryTextColor)
                    }
                }
                
                Divider()
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(secondaryTextColor)
                    
                    TextField("Rechercher...", text: $viewModel.searchText)
                        .foregroundColor(textColor)
                }
                .padding()
                .background(searchBarBackground)
                .cornerRadius(12)
                
                // Match level filter
                VStack(alignment: .leading, spacing: 12) {
                    Text("Niveau de matching")
                        .font(.headline)
                        .foregroundColor(textColor)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            MatchingFilterChip(
                                title: "Tous",
                                isSelected: viewModel.selectedMatchLevel == nil,
                                color: AppColors.mediumGray
                            ) {
                                HapticManager.shared.impact(style: .light)
                                viewModel.selectedMatchLevel = nil
                            }
                            
                            ForEach([MatchLevel.excellent, .good, .average, .poor], id: \.self) { level in
                                MatchingFilterChip(
                                    title: level.rawValue,
                                    isSelected: viewModel.selectedMatchLevel == level,
                                    color: level.color
                                ) {
                                    HapticManager.shared.impact(style: .light)
                                    viewModel.selectedMatchLevel = level
                                }
                            }
                        }
                    }
                }
                
                // Sort options
                VStack(alignment: .leading, spacing: 12) {
                    Text("Trier par")
                        .font(.headline)
                        .foregroundColor(textColor)
                    
                    VStack(spacing: 8) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            SortOptionRow(
                                option: option,
                                isSelected: viewModel.sortOption == option,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                action: {
                                    HapticManager.shared.impact(style: .light)
                                    viewModel.sortOption = option
                                }
                            )
                        }
                    }
                }
                
                Spacer()
                
                // Apply button
                Button(action: {
                    HapticManager.shared.impact(style: .medium)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Appliquer les filtres")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
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
            }
            .padding(24)
            .background(panelBackground)
            .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .frame(maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(edges: .top)
        }
    }
    
    private var textColor: Color {
        colorScheme == .dark ? .white : AppColors.black
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? .gray : AppColors.mediumGray
    }
    
    private var searchBarBackground: some View {
        Group {
            if colorScheme == .dark {
                Color(uiColor: .systemGray5)
            } else {
                Color(uiColor: .systemGray6)
            }
        }
    }
    
    private var panelBackground: some View {
        Group {
            if colorScheme == .dark {
                Color(uiColor: .systemGray6)
            } else {
                Color.white
            }
        }
    }
}

// MARK: - Matching Filter Chip (avec couleur personnalisée)

struct MatchingFilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? color : color.opacity(0.15))
                .cornerRadius(20)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Sort Option Row

struct SortOptionRow: View {
    let option: SortOption
    let isSelected: Bool
    let textColor: Color
    let secondaryTextColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: option.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? AppColors.primaryRed : secondaryTextColor)
                
                Text(option.rawValue)
                    .font(.body)
                    .foregroundColor(textColor)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.primaryRed)
                }
            }
            .padding()
            .background(isSelected ? AppColors.primaryRed.opacity(0.1) : Color.clear)
            .cornerRadius(12)
        }
    }
}

// Note: cornerRadius(_:corners:) est déjà défini dans Utils/ViewExtensions.swift
