
import SwiftUI

struct OffreCardView: View {
    let offre: Offre
    let onCardClick: (() -> Void)?
    @ObservedObject private var favoritesService = FavoritesService.shared
    
    init(offre: Offre, onCardClick: (() -> Void)? = nil) {
        self.offre = offre
        self.onCardClick = onCardClick
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Section
            if let images = offre.images, let firstImage = images.first, !firstImage.isEmpty {
                let imageURL = buildImageURL(from: firstImage)
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 160)
                            .overlay(
                                ProgressView()
                                    .tint(.gray)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 160)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 160)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray.opacity(0.3))
                            )
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 160)
                    }
                }
            } else {
                // Default placeholder pattern or gradient if no image
                Rectangle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color(hex: 0xF5F7FA), Color(hex: 0xE4E7EB)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 120)
                    .overlay(
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color.gray.opacity(0.2))
                    )
            }
            
            VStack(alignment: .leading, spacing: 12) {
                // Header: Title and Job Badge
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(offre.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .lineLimit(2)
                        
                        Text(offre.company)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Job Type Badge
                    Text(offre.jobType?.uppercased() ?? "JOB")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: 0x4CAF50))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(hex: 0xE8F5E9))
                        .cornerRadius(8)
                }
                
                // Details Row: Location, Salary
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text(offre.location.address)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: 0x455A64))
                            .lineLimit(1)
                    }
                    
                    if let salary = offre.salary {
                        HStack(spacing: 4) {
                            Image(systemName: "banknote")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Text(salary)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: 0x263238))
                        }
                    }
                }
                
                // Tags Scroll
                if let tags = offre.tags, !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(tags.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 12))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color(hex: 0xF3F4F6))
                                    .foregroundColor(Color(hex: 0x616161))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Footer: Date and Actions
                HStack {
                    Text(formatTimeAgo(from: offre.createdAt))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            favoritesService.toggleFavorite(jobId: offre.id)
                        }) {
                            Image(systemName: favoritesService.isFavorite(jobId: offre.id) ? "heart.fill" : "heart")
                                .font(.system(size: 20))
                                .foregroundColor(favoritesService.isFavorite(jobId: offre.id) ? AppColors.primaryRed : Color(hex: 0x90A4AE))
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: 0x90A4AE))
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .contentShape(RoundedRectangle(cornerRadius: 20)) // Defines the clickable area
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
        .onTapGesture {
            onCardClick?()
        }
        .padding(.horizontal, 4) // Margin outside the clickable area
    }
    
    private func formatTimeAgo(from date: Date?) -> String {
        guard let date = date else { return "Récemment" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    /// Construit l'URL complète de l'image à partir du chemin retourné par le backend
    private func buildImageURL(from urlString: String) -> String {
        // Si c'est déjà une URL complète, la retourner telle quelle
        if urlString.starts(with: "http://") || urlString.starts(with: "https://") {
            return urlString
        }
        
        // Si le chemin commence par "/", l'ajouter directement à baseURL
        if urlString.starts(with: "/") {
            return APIConfig.baseURL + urlString
        }
        
        // Si le chemin commence par "uploads/", ajouter "/" avant
        if urlString.starts(with: "uploads/") {
            return APIConfig.baseURL + "/" + urlString
        }
        
        // Par défaut, traiter comme un chemin relatif
        return APIConfig.baseURL + "/" + urlString
    }
}
