//
//  MonPlanningView.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import SwiftUI

/// Écran principal "Mon Planning" avec analyse IA améliorée
struct MonPlanningView: View {
    @StateObject private var viewModel = EnhancedRoutineViewModel()
    @ObservedObject var evenementViewModel: EvenementViewModel
    @ObservedObject var availabilityViewModel: AvailabilityViewModel
    
    @State private var isRefreshing = false
    @State private var showingDatePicker = false
    @State private var dateDebut = Calendar.current.startOfWeek(for: Date())
    @State private var dateFin = Calendar.current.endOfWeek(for: Date())
    
    var body: some View {
        ZStack {
            AppColors.backgroundGray
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header avec période
                    periodHeader
                    
                    if viewModel.hasData {
                        // Score d'équilibre
                        if let data = viewModel.analysisData {
                            ScoreGaugeView(
                                score: data.scoreEquilibre,
                                label: "Score d'équilibre",
                                color: viewModel.scoreColor
                            )
                            .padding(.vertical, 8)
                            
                            // Résumé de santé
                            healthSummaryCard(data.healthSummary)
                            
                            // Statistiques hebdomadaires
                            StatisticsCardsView(weeklyAnalysis: data.analyseHebdomadaire)
                            
                            // Conflits
                            ConflictsListView(conflicts: data.conflicts)
                            
                            // Jours surchargés
                            OverloadedDaysView(overloadedDays: data.overloadedDays)
                            
                            // Recommandations IA
                            RecommendationsListView(recommendations: data.recommandations)
                            
                            // Détails du score (décomposition)
                            scoreBreakdownCard(data.scoreBreakdown)
                        }
                    } else {
                        // État vide
                        emptyStateView
                    }
                }
                .padding()
                .padding(.bottom, 80)
            }
            .refreshable {
                await refreshData()
            }
            
            // Bouton flottant "Analyser"
            VStack {
                Spacer()
                analyzeButton
            }
        }
        .navigationTitle("Mon Planning")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingDatePicker) {
            datePickerSheet
        }
        .alert("Erreur", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Une erreur s'est produite")
        }
        .alert("Succès", isPresented: $viewModel.showSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Analyse terminée avec succès !")
        }
        .onAppear {
            viewModel.evenementViewModel = evenementViewModel
            viewModel.availabilityViewModel = availabilityViewModel
            viewModel.initialize()
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(AppColors.primaryRed)
                            
                            Text("Analyse en cours...")
                                .font(.headline)
                                .foregroundColor(AppColors.white)
                        }
                        .padding(32)
                        .background(AppColors.white)
                        .cornerRadius(20)
                        .shadow(radius: 20)
                    }
                }
            }
        )
    }
    
    // MARK: - Subviews
    
    private var periodHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Période analysée")
                    .font(.caption)
                    .foregroundColor(AppColors.mediumGray)
                
                Text("\(formatDate(dateDebut)) - \(formatDate(dateFin))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.black)
            }
            
            Spacer()
            
            Button(action: {
                showingDatePicker = true
                HapticManager.light()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                    Text("Changer")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.primaryRed)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppColors.primaryRed.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(AppColors.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func healthSummaryCard(_ summary: EnhancedRoutineAnalysisResponse.HealthSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: summary.statusIcon)
                    .foregroundColor(summary.statusColor)
                    .font(.title2)
                
                Text("État de santé du planning")
                    .font(.headline)
                    .foregroundColor(AppColors.black)
                
                Spacer()
                
                Text(summary.status.capitalized)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(summary.statusColor)
                    .cornerRadius(12)
            }
            
            if !summary.mainIssues.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Problèmes principaux")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.mediumGray)
                    
                    ForEach(summary.mainIssues, id: \.self) { issue in
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(AppColors.errorRed)
                                .font(.caption)
                            
                            Text(issue)
                                .font(.caption)
                                .foregroundColor(AppColors.darkGray)
                        }
                    }
                }
            }
            
            if !summary.mainStrengths.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Points forts")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.mediumGray)
                    
                    ForEach(summary.mainStrengths, id: \.self) { strength in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColors.successGreen)
                                .font(.caption)
                            
                            Text(strength)
                                .font(.caption)
                                .foregroundColor(AppColors.darkGray)
                        }
                    }
                }
            }
        }
        .padding()
        .background(AppColors.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func scoreBreakdownCard(_ breakdown: EnhancedRoutineAnalysisResponse.ScoreBreakdown) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Détails du calcul du score")
                .font(.headline)
                .foregroundColor(AppColors.black)
            
            VStack(spacing: 8) {
                breakdownRow(label: "Score de base", value: breakdown.baseScore, isPositive: true)
                breakdownRow(label: "Équilibre travail/études", value: breakdown.workStudyBalance, isPositive: breakdown.workStudyBalance >= 0)
                breakdownRow(label: "Pénalité repos", value: breakdown.restPenalty, isPositive: breakdown.restPenalty >= 0)
                breakdownRow(label: "Pénalité conflits", value: breakdown.conflictPenalty, isPositive: breakdown.conflictPenalty >= 0)
                breakdownRow(label: "Pénalité surcharge", value: breakdown.overloadPenalty, isPositive: breakdown.overloadPenalty >= 0)
                breakdownRow(label: "Bonus", value: breakdown.bonuses, isPositive: breakdown.bonuses >= 0)
            }
        }
        .padding()
        .background(AppColors.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func breakdownRow(label: String, value: Double, isPositive: Bool) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppColors.darkGray)
            
            Spacer()
            
            Text(String(format: "%+.0f", value))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isPositive ? AppColors.successGreen : AppColors.errorRed)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 80))
                .foregroundColor(AppColors.mediumGray)
            
            Text("Aucune analyse disponible")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.black)
            
            Text("Appuyez sur le bouton ci-dessous pour analyser votre planning")
                .font(.subheadline)
                .foregroundColor(AppColors.mediumGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
    
    private var analyzeButton: some View {
        Button(action: {
            Task {
                await analyze()
            }
            HapticManager.impact()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title3)
                
                Text("Analyser Mon Planning")
                    .font(.headline)
            }
            .foregroundColor(AppColors.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [AppColors.primaryRed, AppColors.darkRed],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: AppColors.primaryRed.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
    
    private var datePickerSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                DatePicker(
                    "Date de début",
                    selection: $dateDebut,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                
                DatePicker(
                    "Date de fin",
                    selection: $dateFin,
                    in: dateDebut...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Choisir la période")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        showingDatePicker = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("OK") {
                        showingDatePicker = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Methods
    
    private func analyze() async {
        await viewModel.analyzeRoutine(
            evenements: evenementViewModel.evenements,
            disponibilites: availabilityViewModel.disponibilites,
            dateDebut: dateDebut,
            dateFin: dateFin
        )
    }
    
    private func refreshData() async {
        isRefreshing = true
        await viewModel.refresh()
        isRefreshing = false
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

// MARK: - Calendar Extension

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
    
    func endOfWeek(for date: Date) -> Date {
        let startOfWeek = startOfWeek(for: date)
        return self.date(byAdding: .day, value: 6, to: startOfWeek) ?? date
    }
}

#Preview {
    NavigationView {
        MonPlanningView(
            evenementViewModel: EvenementViewModel(),
            availabilityViewModel: AvailabilityViewModel()
        )
    }
}

