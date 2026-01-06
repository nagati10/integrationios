//
//  SkeletonLoadingView.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import SwiftUI

/// Vue de chargement avec skeleton (placeholders animés)
struct SkeletonLoadingView: View {
    @State private var isAnimating = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Statistics skeleton
                HStack(spacing: 16) {
                    SkeletonCard()
                    SkeletonCard()
                }
                
                // Match cards skeleton
                ForEach(0..<5) { _ in
                    SkeletonMatchCard()
                }
            }
            .padding()
        }
    }
}

// MARK: - Skeleton Card

struct SkeletonCard: View {
    @State private var isAnimating = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(skeletonColor)
                .frame(width: 50, height: 50)
            
            Rectangle()
                .fill(skeletonColor)
                .frame(height: 24)
                .frame(maxWidth: 80)
            
            Rectangle()
                .fill(skeletonColor)
                .frame(height: 14)
                .frame(maxWidth: 60)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(cardBackground)
        .cornerRadius(20)
        .shimmer(isAnimating: $isAnimating)
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
    
    private var skeletonColor: Color {
        colorScheme == .dark ? Color(uiColor: .systemGray4) : Color(uiColor: .systemGray5)
    }
    
    private var cardBackground: Color {
        colorScheme == .dark ? Color(uiColor: .systemGray6) : .white
    }
}

// MARK: - Skeleton Match Card

struct SkeletonMatchCard: View {
    @State private var isAnimating = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Rectangle()
                        .fill(skeletonColor)
                        .frame(height: 20)
                        .frame(maxWidth: 180)
                    
                    Rectangle()
                        .fill(skeletonColor)
                        .frame(height: 14)
                        .frame(maxWidth: 120)
                }
                
                Spacer()
                
                Circle()
                    .fill(skeletonColor)
                    .frame(width: 70, height: 70)
            }
            
            HStack(spacing: 10) {
                Rectangle()
                    .fill(skeletonColor)
                    .frame(width: 80, height: 30)
                    .cornerRadius(8)
                
                Rectangle()
                    .fill(skeletonColor)
                    .frame(width: 100, height: 30)
                    .cornerRadius(8)
            }
            
            Rectangle()
                .fill(skeletonColor)
                .frame(height: 40)
                .cornerRadius(8)
            
            Rectangle()
                .fill(skeletonColor)
                .frame(height: 48)
                .cornerRadius(12)
        }
        .padding(20)
        .background(cardBackground)
        .cornerRadius(20)
        .shimmer(isAnimating: $isAnimating)
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
    
    private var skeletonColor: Color {
        colorScheme == .dark ? Color(uiColor: .systemGray4) : Color(uiColor: .systemGray5)
    }
    
    private var cardBackground: Color {
        colorScheme == .dark ? Color(uiColor: .systemGray6) : .white
    }
}

// MARK: - Shimmer Modifier

struct ShimmerModifier: ViewModifier {
    @Binding var isAnimating: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.3),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                }
            )
            .mask(content)
    }
}

extension View {
    func shimmer(isAnimating: Binding<Bool>) -> some View {
        self.modifier(ShimmerModifier(isAnimating: isAnimating))
    }
}

#Preview {
    SkeletonLoadingView()
}

