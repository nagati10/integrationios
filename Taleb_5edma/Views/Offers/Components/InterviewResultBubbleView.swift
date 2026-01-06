//
//  InterviewResultBubbleView.swift
//  Taleb_5edma
//
//  Created for AI Interview Features
//

import SwiftUI

struct InterviewResultBubbleView: View {
    let analysis: ChatModels.AiInterviewAnalysis
    let isSent: Bool // Is sent by the current user (Student sends results to Enterprise)
    
    @State private var showFullDetails = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if isSent { // Sender alignment (Right) -> Spacer First
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 0) {
                // Main Card
                Button(action: { showFullDetails.toggle() }) {
                    VStack(alignment: .leading, spacing: 12) {
                        
                        // Header
                        HStack {
                            Text("📊 AI Analysis")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppColors.primaryRed)
                            
                            Spacer()
                            
                            Text("\(analysis.overallScore ?? 0)%")
                                .font(.system(size: 18, weight: .black))
                                .foregroundColor(scoreColor)
                        }
                        
                        // Candidate Name
                        Text("Candidat: \(analysis.candidateName ?? "Unknown")")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.black)
                        
                        // Recommendation
                        Text("Rec: \(formatRecommendation(analysis.recommendation ?? "N/A"))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(recommendationColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(recommendationColor.opacity(0.1))
                            .cornerRadius(4)
                            .frame(maxWidth: .infinity)
                        
                        // Strengths
                        if let strengths = analysis.strengths, !strengths.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("✅ Points forts:")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppColors.black)
                                
                                ForEach(strengths.prefix(3), id: \.self) { strength in
                                    Text("• \(strength)")
                                        .font(.system(size: 11))
                                        .foregroundColor(AppColors.mediumGray)
                                        .lineLimit(1)
                                }
                            }
                        }
                        
                        // Hint
                        HStack {
                            Spacer()
                            Text("👆 Tap for full details")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(AppColors.primaryRed)
                            Spacer()
                        }
                    }
                    .padding(16)
                    .background(Color(hex: "#F5F7FA"))
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(AppColors.primaryRed.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: 300)
            
            if !isSent { // Receiver alignment (Left) -> Spacer Last
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .sheet(isPresented: $showFullDetails) {
            InterviewAnalysisDetailView(analysis: analysis)
        }
    }
    
    // MARK: - Helpers
    
    private var scoreColor: Color {
        (analysis.overallScore ?? 0) >= 70 ? Color(hex: "#2E7D32") : Color(hex: "#C62828")
    }
    
    private var recommendationColor: Color {
        switch analysis.recommendation {
        case "STRONG_HIRE": return Color(hex: "#00C853")
        case "HIRE": return Color(hex: "#2E7D32")
        case "MAYBE": return Color(hex: "#F9A825")
        case "NO_HIRE": return Color(hex: "#C62828")
        default: return .gray
        }
    }
    
    private func formatRecommendation(_ rec: String) -> String {
        rec.replacingOccurrences(of: "_", with: " ")
    }
}

// MARK: - Detail View

struct InterviewAnalysisDetailView: View {
    let analysis: ChatModels.AiInterviewAnalysis
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Score Circle
                    ZStack {
                        Circle()
                            .stroke(
                                Color.gray.opacity(0.2),
                                lineWidth: 20
                            )
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(analysis.overallScore ?? 0) / 100)
                            .stroke(
                                scoreColor,
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 4) {
                            Text("\(analysis.overallScore ?? 0)%")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(scoreColor)
                            Text("Score Global")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: 200, height: 200)
                    .padding(.top, 20)
                    
                    // Recommendation Banner
                    Text(formatRecommendation(analysis.recommendation ?? "N/A"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(recommendationColor)
                        .cornerRadius(12)
                    
                    // Strengths Section
                    if let strengths = analysis.strengths, !strengths.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Points Forts", systemImage: "hand.thumbsup.fill")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#2E7D32"))
                            
                            ForEach(strengths, id: \.self) { strength in
                                HStack(alignment: .top) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(hex: "#2E7D32"))
                                    Text(strength)
                                        .font(.body)
                                }
                            }
                        }
                        .padding()
                        .background(Color(hex: "#E8F5E9"))
                        .cornerRadius(12)
                    }
                    
                    // Weaknesses Section (Added)
                    if let weaknesses = analysis.weaknesses, !weaknesses.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Points à Améliorer", systemImage: "hand.thumbsdown.fill")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#C62828"))
                            
                            ForEach(weaknesses, id: \.self) { weakness in
                                HStack(alignment: .top) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(Color(hex: "#C62828"))
                                    Text(weakness)
                                        .font(.body)
                                }
                            }
                        }
                        .padding()
                        .background(Color(hex: "#FFEBEE"))
                        .cornerRadius(12)
                    }
                    
                    // Summary Section (Added)
                    if let summary = analysis.summary {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Résumé", systemImage: "text.alignleft")
                                .font(.headline)
                                .foregroundColor(AppColors.black)
                            
                            Text(summary)
                                .font(.body)
                                .foregroundColor(AppColors.black)
                        }
                        .padding()
                        .background(Color(hex: "#F5F5F5"))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Détails de l'Analyse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
    
    private var scoreColor: Color {
        (analysis.overallScore ?? 0) >= 70 ? Color(hex: "#2E7D32") : Color(hex: "#C62828")
    }
    
    private var recommendationColor: Color {
        switch analysis.recommendation {
        case "STRONG_HIRE": return Color(hex: "#00C853")
        case "HIRE": return Color(hex: "#2E7D32")
        case "MAYBE": return Color(hex: "#F9A825")
        case "NO_HIRE": return Color(hex: "#C62828")
        default: return .gray
        }
    }
    
    private func formatRecommendation(_ rec: String) -> String {
        rec.replacingOccurrences(of: "_", with: " ")
    }
}
