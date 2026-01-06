//
//  AnimatedComponents.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import SwiftUI

// MARK: - Animated Stat Card

struct AnimatedStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let delay: Double
    
    @State private var isVisible = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .scaleEffect(isVisible ? 1.0 : 0.5)
                    .opacity(isVisible ? 1.0 : 0.0)
            }
            
            // Animated value
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(textColor)
                .opacity(isVisible ? 1.0 : 0.0)
                .offset(y: isVisible ? 0 : 20)
            
            Text(title)
                .font(.caption)
                .foregroundColor(secondaryTextColor)
                .opacity(isVisible ? 1.0 : 0.0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 10, x: 0, y: 5)
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(delay)) {
                isVisible = true
            }
        }
    }
    
    private var textColor: Color {
        colorScheme == .dark ? .white : AppColors.black
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? .gray : AppColors.mediumGray
    }
    
    private var cardBackground: some View {
        Group {
            if colorScheme == .dark {
                Color(uiColor: .systemGray6)
            } else {
                Color.white
            }
        }
    }
}

// MARK: - Animated Match Card

struct AnimatedMatchCard: View {
    let match: MatchResult
    let index: Int
    let onRemove: () -> Void
    let onTap: () -> Void
    
    @State private var isVisible = false
    @State private var offset: CGSize = .zero
    @Environment(\.colorScheme) var colorScheme
    
    private let deleteThreshold: CGFloat = 100
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete background
            if abs(offset.width) > 50 {
                deleteBackground
            }
            
            // Card content
            cardContent
                .offset(x: offset.width)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if gesture.translation.width < 0 {
                                offset = gesture.translation
                            }
                        }
                        .onEnded { gesture in
                            if gesture.translation.width < -deleteThreshold {
                                HapticManager.shared.notification(type: .warning)
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    offset = CGSize(width: -300, height: 0)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onRemove()
                                }
                            } else {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    offset = .zero
                                }
                            }
                        }
                )
        }
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 50)
        .scaleEffect(isVisible ? 1.0 : 0.9)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.1)) {
                isVisible = true
            }
        }
        .onTapGesture {
            onTap()
        }
    }
    
    private var deleteBackground: some View {
        HStack {
            Spacer()
            
            VStack {
                Image(systemName: "trash.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text("Supprimer")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity)
        .background(Color.red)
        .cornerRadius(20)
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .top, spacing: 16) {
                // Left content
                VStack(alignment: .leading, spacing: 8) {
                    Text(match.titre)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(textColor)
                        .lineLimit(2)
                    
                    if let company = match.company {
                        HStack(spacing: 6) {
                            Image(systemName: "building.2.fill")
                                .font(.caption)
                            Text(company)
                                .font(.subheadline)
                        }
                        .foregroundColor(secondaryTextColor)
                    }
                }
                
                Spacer()
                
                // Animated circular progress
                AnimatedCircularProgress(
                    score: match.scores.score,
                    color: match.matchLevel.color,
                    delay: Double(index) * 0.1
                )
                .frame(width: 70, height: 70)
            }
            
            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    if let location = match.location {
                        AnimatedTag(
                            text: location,
                            icon: "mappin.circle.fill",
                            color: AppColors.accentBlue,
                            delay: Double(index) * 0.1 + 0.1
                        )
                    }
                    
                    if let jobType = match.jobType {
                        AnimatedTag(
                            text: jobType,
                            icon: "briefcase.fill",
                            color: .purple,
                            delay: Double(index) * 0.1 + 0.2
                        )
                    }
                    
                    if let salary = match.salary {
                        AnimatedTag(
                            text: salary,
                            icon: "banknote.fill",
                            color: .green,
                            delay: Double(index) * 0.1 + 0.3
                        )
                    }
                }
            }
            
            // Recommendation with gradient background
            HStack(spacing: 12) {
                Text(match.matchLevel.emoji)
                    .font(.title3)
                
                Text(match.recommendation)
                    .font(.subheadline)
                    .foregroundColor(textColor)
                    .lineLimit(2)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [
                        match.matchLevel.color.opacity(0.15),
                        match.matchLevel.color.opacity(0.05)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            
            // Action button
            Button(action: {
                HapticManager.shared.impact(style: .medium)
                onTap()
            }) {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("Postuler")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [AppColors.primaryRed, AppColors.primaryRed.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: AppColors.primaryRed.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .padding(20)
        .background(cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.4 : 0.1), radius: 15, x: 0, y: 8)
    }
    
    private var textColor: Color {
        colorScheme == .dark ? .white : AppColors.black
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? .gray : AppColors.mediumGray
    }
    
    private var cardBackground: some View {
        Group {
            if colorScheme == .dark {
                Color(uiColor: .systemGray6)
            } else {
                Color.white
            }
        }
    }
}

// MARK: - Animated Circular Progress

struct AnimatedCircularProgress: View {
    let score: Double
    let color: Color
    let delay: Double
    
    @State private var progress: CGFloat = 0
    @State private var displayScore: Double = 0
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 6)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            // Score text
            VStack(spacing: 0) {
                Text(String(format: "%.0f", displayScore))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                
                Text("%")
                    .font(.caption2)
                    .foregroundColor(color.opacity(0.7))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(delay)) {
                progress = CGFloat(score / 100)
            }
            
            // Animate score count up
            let steps = 30
            let stepDuration = 1.0 / Double(steps)
            for i in 0...steps {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay + (stepDuration * Double(i))) {
                    displayScore = (score / Double(steps)) * Double(i)
                }
            }
        }
    }
}

// MARK: - Animated Tag

struct AnimatedTag: View {
    let text: String
    let icon: String
    let color: Color
    let delay: Double
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.15))
        .cornerRadius(10)
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(delay)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Animated Score Text

struct AnimatedScoreText: View {
    let score: Double
    let delay: Double
    
    @State private var displayScore: Double = 0
    
    var body: some View {
        Text(String(format: "%.0f%%", displayScore))
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(AppColors.primaryRed)
            .onAppear {
                let steps = 20
                let stepDuration = 0.8 / Double(steps)
                for i in 0...steps {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay + (stepDuration * Double(i))) {
                        displayScore = (score / Double(steps)) * Double(i)
                    }
                }
            }
    }
}

