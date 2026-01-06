//
//  EnterpriseContactsView.swift
//  Taleb_5edma
//
//  Created for displaying all candidate messages/contacts
//

import SwiftUI

struct EnterpriseContactsView: View {
    @EnvironmentObject var authService: AuthService
    @State private var userChats: [ChatModels.GetUserChatsResponse] = []
    @State private var isLoading = false
    @State private var selectedChat: ChatModels.GetUserChatsResponse?
    @State private var showingChatDetail = false
    private let chatService = ChatService()
    
    var body: some View {
        ZStack {
            AppColors.backgroundGray
                .ignoresSafeArea()
            
            if isLoading && userChats.isEmpty {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color(hex: 0x9333ea))
            } else if userChats.isEmpty {
                emptyStateView
            } else {
                contactsListView
            }
        }
        .navigationTitle("Contacts")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadChats()
        }
        .sheet(isPresented: $showingChatDetail) {
            if let chat = selectedChat {
                ChatView(
                    offre: nil,
                    currentUserId: authService.currentUser?.id,
                    chatId: chat.id,
                    candidateInfo: chat.candidate
                )
                .environmentObject(authService)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.mediumGray.opacity(0.5))
            
            Text("Aucun contact")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.black)
            
            Text("Les messages des candidats apparaîtront ici")
                .font(.system(size: 14))
                .foregroundColor(AppColors.mediumGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Contacts List
    
    private var contactsListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(userChats, id: \.id) { chat in
                    ContactItemView(chat: chat) {
                        selectedChat = chat
                        showingChatDetail = true
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Load Data
    
    private func loadChats() {
        isLoading = true
        
        Task {
            do {
                let chats = try await chatService.getMyChatsDetailed()
                await MainActor.run {
                    userChats = chats
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    print("⚠️ Erreur chargement chats: \(error.localizedDescription)")
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Contact Item View

struct ContactItemView: View {
    let chat: ChatModels.GetUserChatsResponse
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color(hex: 0x9333ea).opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    if let candidateImage = chat.candidate?.image, !candidateImage.isEmpty {
                        AsyncImage(url: URL(string: candidateImage)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.fill")
                                .foregroundColor(Color(hex: 0x9333ea))
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    } else {
                        Text(getInitials(from: chat.candidate?.nom ?? "C"))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: 0x9333ea))
                    }
                    
                    // Badge non lu
                    if let unreadCount = chat.unreadEntreprise, unreadCount > 0 {
                        Circle()
                            .fill(Color(hex: 0x9333ea))
                            .frame(width: 20, height: 20)
                            .overlay(
                                Text("\(min(unreadCount, 9))")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 18, y: -18)
                    }
                }
                
                // Informations
                VStack(alignment: .leading, spacing: 6) {
                    Text(chat.candidate?.nom ?? "Candidat inconnu")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.black)
                        .lineLimit(1)
                    
                    if let offerTitle = chat.offer?.title {
                        Text(offerTitle)
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.mediumGray)
                            .lineLimit(1)
                    }
                    
                    if let lastMessage = chat.lastMessage, !lastMessage.isEmpty {
                        Text(lastMessage)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.mediumGray)
                            .lineLimit(2)
                    } else {
                        Text("Aucun message")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.mediumGray.opacity(0.5))
                            .italic()
                    }
                }
                
                Spacer()
                
                // Indicateur de type de message et date
                VStack(alignment: .trailing, spacing: 4) {
                    if let lastActivity = chat.lastActivity {
                        Text(formatLastActivity(lastActivity))
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.mediumGray)
                    }
                    
                    if let messageType = chat.lastMessageType {
                        Image(systemName: getMessageTypeIcon(messageType))
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.mediumGray)
                    }
                }
            }
            .padding()
            .background(AppColors.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1)) + String(components[1].prefix(1))
        }
        return String(name.prefix(2)).uppercased()
    }
    
    private func getMessageTypeIcon(_ messageType: String) -> String {
        switch messageType {
        case "image": return "photo.fill"
        case "video": return "video.fill"
        case "audio": return "mic.fill"
        case "emoji": return "face.smiling.fill"
        default: return "text.bubble.fill"
        }
    }
    
    private func formatLastActivity(_ isoDate: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: isoDate) else {
            return ""
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Hier"
        } else if calendar.dateInterval(of: .weekOfYear, for: now)?.contains(date) == true {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date).capitalized
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    NavigationView {
        EnterpriseContactsView()
            .environmentObject(AuthService())
    }
}

