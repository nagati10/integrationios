//
//  FallbackAsyncImage.swift
//  Taleb_5edma
//
//  Created to handle image loading with multiple URL fallbacks
//

import SwiftUI

/// Composant AsyncImage qui essaie plusieurs URLs en cascade si la première échoue
struct FallbackAsyncImage: View {
    let urls: [String]
    let placeholder: AnyView
    let failureView: AnyView
    
    @State private var currentIndex = 0
    
    init(
        urls: [String],
        placeholder: AnyView = AnyView(ProgressView()),
        failureView: AnyView = AnyView(Image(systemName: "photo"))
    ) {
        self.urls = urls.filter { !$0.isEmpty } // Filtrer les URLs vides
        self.placeholder = placeholder
        self.failureView = failureView
    }
    
    var body: some View {
        Group {
            if currentIndex < urls.count, let url = URL(string: urls[currentIndex]) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case .success(let image):
                        image
                            .resizable()
                    case .failure:
                        // Essayer l'URL suivante
                        if currentIndex < urls.count - 1 {
                            placeholder
                                .onAppear {
                                    // Essayer l'URL suivante après un court délai
                                    Task {
                                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 secondes
                                        await MainActor.run {
                                            if currentIndex < urls.count - 1 {
                                                print("⚠️ FallbackAsyncImage - URL \(currentIndex) échouée: \(urls[currentIndex])")
                                                print("   Essai de l'URL suivante...")
                                                currentIndex += 1
                                            }
                                        }
                                    }
                                }
                        } else {
                            // Toutes les URLs ont échoué
                            failureView
                                .onAppear {
                                    print("❌ FallbackAsyncImage - Toutes les URLs ont échoué")
                                    for (index, url) in urls.enumerated() {
                                        print("   URL[\(index)]: \(url)")
                                    }
                                }
                        }
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                failureView
            }
        }
    }
}

#Preview {
    FallbackAsyncImage(
        urls: [
            "https://example.com/image1.jpg",
            "https://example.com/image2.jpg"
        ]
    )
    .frame(width: 200, height: 200)
}

