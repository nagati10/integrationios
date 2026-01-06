
import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    var onAddTapped: () -> Void
    
    var body: some View {
        ZStack(alignment: .top) {
            // Main Bar Background
            VStack(spacing: 0) {
                Divider() // Optional, for "Claire" separation
                
                HStack {
                    // Tab 0: Accueil
                    TabBarButton(imageName: "house.fill", text: "Accueil", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    
                    Spacer()
                    
                    // Tab 1: Calendrier
                    TabBarButton(imageName: "calendar", text: "Calendrier", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    
                    Spacer()
                    
                    // Center Space for Floating Button
                    Spacer()
                        .frame(width: 60)
                    
                    Spacer()
                    
                    // Tab 2: Mes offres
                    TabBarButton(imageName: "clock", text: "Mes offres", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                    
                    Spacer()
                    
                    // Tab 3: Profil
                    TabBarButton(imageName: "gearshape", text: "Profil", isSelected: selectedTab == 3) {
                        selectedTab = 3
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: 60) // Standard tab bar height
                .padding(.bottom, 20) // Safe area padding manually if ignore safe area
                .background(Color.white)
            }
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5) // Light shadow on top
            
            // Floating + Button
            Button(action: onAddTapped) {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color(hex: 0xB042FF), Color(hex: 0x8A2BE2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: Color.purple.opacity(0.4), radius: 8, x: 0, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white, lineWidth: 4)
                        )
                    
                    Image(systemName: "plus")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -30) // Positioned half-out
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct TabBarButton: View {
    let imageName: String
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if isSelected {
                    ZStack {
                       // Just Icon and Text colored for "Claire" look
                       // Or the rounded rect bg?
                       // Android screenshot has a purple rounded rect around the icon for active state?
                       // Let's stick to the previous active design which was a purple square + white icon.
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: 0x6200EE))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: imageName)
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                } else {
                    Image(systemName: imageName)
                        .font(.system(size: 24))
                        .foregroundColor(Color.gray)
                        .frame(width: 44, height: 44)
                }
                
                Text(text)
                    .font(.caption2)
                    .foregroundColor(isSelected ? Color(hex: 0x6200EE) : Color.gray)
            }
        }
    }
}
