
import SwiftUI

struct HomeHeaderView: View {
    @Binding var showingMenu: Bool
    @Binding var showingNotifications: Bool
    @Binding var showingProfile: Bool
    let notificationCount: Int
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        HStack {
            Button(action: { showingMenu = true }) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            // Logo
            HStack(spacing: 8) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .clipShape(Circle())
                
                Text("talleb 5edma")
                    .font(.system(size: 20, weight: .bold))
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                // Notification Bell
                Button(action: { showingNotifications = true }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                        
                        if notificationCount > 0 {
                            Text("\(notificationCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.orange)
                                .clipShape(Circle())
                                .offset(x: 6, y: -6)
                        }
                    }
                }
                
                // Profile Avatar - Affiche l'avatar de l'utilisateur connecté
                Button(action: { showingProfile = true }) {
                    if let imageURL = authService.currentUser?.image, !imageURL.isEmpty {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            profileAvatarPlaceholder
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    } else {
                        profileAvatarPlaceholder
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)
    }
    
    private var profileAvatarPlaceholder: some View {
        ZStack {
            Circle()
                .fill(Color(hex: 0xFF69B4))
                .frame(width: 40, height: 40)
            
            if let nom = authService.currentUser?.nom, !nom.isEmpty {
                Text(String(nom.prefix(2)).uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
        }
    }
}
