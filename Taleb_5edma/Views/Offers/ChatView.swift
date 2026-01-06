//
//  ChatView.swift
//  Taleb_5edma
//
//  Created by Apple on 10/11/2025.
//

//
//  ChatView.swift
//  Taleb_5edma
//

import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService
    let job: Job?
    let offre: Offre?
    
    // Service de chat
    @StateObject private var chatService = ChatService()
    
    // Service d'offres pour récupérer l'offre complète
    private let offreService = OffreService()
    
    // État du chat
    @State private var currentChat: Chat?
    @State private var messages: [Message] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Offre complète avec userId
    @State private var completeOffre: Offre?
    
    // Contenu du champ de texte situé en bas de l'écran
    @State private var messageText = ""
    // Présente la feuille d'appel audio
    @State private var showingCall = false
    // Présente la feuille d'appel vidéo
    @State private var showingVideoCall = false
    
    init(job: Job? = nil, offre: Offre? = nil) {
        self.job = job
        self.offre = offre
    }
    
    // Propriétés calculées pour obtenir l'ID du créateur de l'offre et de l'offre
    /// L'ID du créateur de l'offre (userId) est utilisé comme "entreprise" dans CreateChatRequest
    /// Le champ "entreprise" dans l'API correspond à l'ID de l'utilisateur qui a créé l'offre
    private var entrepriseId: String? {
        // Utiliser l'offre complète si disponible (avec userId), sinon utiliser l'offre initiale
        let offreToUse = completeOffre ?? offre
        if let offre = offreToUse {
            // offre.userId est l'ID de l'utilisateur créateur de l'offre
            // C'est cet ID qui doit être utilisé comme "entreprise" dans CreateChatRequest
            return offre.userId
        }
        // Pour Job, on n'a pas l'ID du créateur directement
        // On pourrait le récupérer depuis le backend si nécessaire
        return nil
    }
    
    private var offerId: String? {
        return offre?.id ?? job?.id
    }
    
    private var companyName: String {
        return offre?.company ?? job?.company ?? "Employeur"
    }
    
    var body: some View {
        ZStack {
            AppColors.backgroundGray.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                ChatTopBar(
                    companyName: companyName,
                    onBack: { dismiss() },
                    onCall: { showingCall = true },
                    onVideoCall: { showingVideoCall = true }
                )
                
                // Messages
                if isLoading && messages.isEmpty {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryRed))
                    Spacer()
                } else if let error = errorMessage {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.primaryRed)
                        Text(error)
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.mediumGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Réessayer") {
                            loadChat()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(AppColors.primaryRed)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    Spacer()
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(messages) { message in
                                    ChatMessageBubble(message: message)
                                        .id(message.id)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 16)
                        }
                        .onChange(of: messages.count) { _, _ in
                            // Scroll vers le dernier message
                            if let lastMessage = messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                // Input Bar
                ChatInputBar(
                    text: $messageText,
                    onSend: sendMessage,
                    isLoading: isLoading
                )
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Si l'offre n'a pas de userId, récupérer l'offre complète depuis le backend
            if let offre = offre, offre.userId == nil {
                loadCompleteOffre()
            } else {
                loadChat()
            }
        }
        .sheet(isPresented: $showingCall) {
            CallView(isVideoCall: false)
        }
        .sheet(isPresented: $showingVideoCall) {
            CallView(isVideoCall: true)
        }
    }
    
    // MARK: - Methods
    
    /// Charge l'offre complète depuis le backend pour obtenir le userId
    private func loadCompleteOffre() {
        guard let offerId = offerId else {
            errorMessage = "Impossible de charger l'offre. ID manquant."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        print("🟢 ChatView - Chargement de l'offre complète pour obtenir userId...")
        print("   - Offre ID: \(offerId)")
        
        Task {
            do {
                let fullOffre = try await offreService.getOffreById(offerId)
                await MainActor.run {
                    self.completeOffre = fullOffre
                    self.isLoading = false
                    print("✅ ChatView - Offre complète chargée")
                    print("   - userId (créateur): \(fullOffre.userId ?? "nil")")
                    
                    // Maintenant que nous avons l'offre complète, charger le chat
                    loadChat()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Erreur lors du chargement de l'offre: \(error.localizedDescription)"
                    self.isLoading = false
                    print("🔴 ChatView - Erreur lors du chargement de l'offre: \(error)")
                }
            }
        }
    }
    
    /// Charge ou crée le chat avec le créateur de l'offre
    /// Le champ "entreprise" dans CreateChatRequest doit être l'ID de l'utilisateur créateur de l'offre (offre.userId)
    private func loadChat() {
        // Vérifier que nous avons l'ID du créateur de l'offre (offre.userId)
        guard let creatorId = entrepriseId else {
            errorMessage = "Impossible de créer le chat. L'ID du créateur de l'offre (userId) est manquant."
            print("🔴 ChatView - Erreur: offre.userId est nil")
            if let offre = offre {
                print("🔴 ChatView - Détails de l'offre:")
                print("   - Offre ID: \(offre.id)")
                print("   - Offre title: \(offre.title)")
                print("   - Offre userId (créateur): \(offre.userId ?? "nil - MANQUANT")")
                print("   - Offre company: \(offre.company)")
            }
            return
        }
        
        // Vérifier que nous avons l'ID de l'offre
        guard let offerId = offerId else {
            errorMessage = "Impossible de créer le chat. L'ID de l'offre est manquant."
            print("🔴 ChatView - Erreur: offerId est nil")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        print("🟢 ChatView - Création du chat avec:")
        print("   - entreprise (ID du créateur): \(creatorId) <- offre.userId")
        print("   - offer (ID de l'offre): \(offerId) <- offre.id")
        
        Task {
            do {
                // Créer ou obtenir le chat existant
                // IMPORTANT: Le champ "entreprise" dans CreateChatRequest doit être l'ID de l'utilisateur créateur de l'offre
                // C'est-à-dire offre.userId, pas l'ID d'une entreprise séparée
                let chatRequest = CreateChatRequest(
                    entreprise: creatorId,  // ID de l'utilisateur créateur (offre.userId)
                    offer: offerId          // ID de l'offre (offre.id)
                )
                let chat = try await chatService.createOrGetChat(chatRequest)
                
                await MainActor.run {
                    self.currentChat = chat
                    self.isLoading = false
                    print("✅ ChatView - Chat créé/récupéré avec succès: \(chat.id)")
                }
                
                // Charger les messages
                await loadMessages()
            } catch {
                await MainActor.run {
                    self.errorMessage = "Erreur lors de la création du chat: \(error.localizedDescription)"
                    self.isLoading = false
                    print("🔴 ChatView - Erreur lors de la création du chat: \(error)")
                    if let chatError = error as? ChatError {
                        print("🔴 ChatView - Type d'erreur: \(chatError)")
                    }
                }
            }
        }
    }
    
    /// Charge les messages du chat
    private func loadMessages() async {
        guard let chatId = currentChat?.id else { return }
        
        do {
            let response = try await chatService.getChatMessages(chatId: chatId, page: 1, limit: 50)
            await MainActor.run {
                self.messages = response.messages
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Erreur lors du chargement des messages: \(error.localizedDescription)"
            }
        }
    }
    
    /// Envoie un message
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let chatId = currentChat?.id else { return }
        
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        messageText = ""
        isLoading = true
        
        Task {
            do {
                let messageRequest = SendMessageRequest(content: text, type: .text)
                let newMessage = try await chatService.sendMessage(chatId: chatId, messageRequest)
                
                await MainActor.run {
                    self.messages.append(newMessage)
                    self.isLoading = false
                }
                
                // Marquer les messages comme lus
                try? await chatService.markMessagesAsRead(chatId: chatId)
            } catch {
                await MainActor.run {
                    self.errorMessage = "Erreur lors de l'envoi: \(error.localizedDescription)"
                    self.isLoading = false
                    // Remettre le texte dans le champ
                    self.messageText = text
                }
            }
        }
    }
}

// MARK: - Chat Message Bubble

struct ChatMessageBubble: View {
    let message: Message
    @EnvironmentObject var authService: AuthService
    
    private var isSent: Bool {
        message.senderId == authService.currentUser?.id
    }
    
    private var timestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: message.createdAt ?? Date())
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !isSent {
                Circle()
                    .fill(AppColors.mediumGray)
                    .frame(width: 28, height: 28)
            }
            
            VStack(alignment: isSent ? .trailing : .leading, spacing: 4) {
                // Contenu du message selon le type
                if message.type == .text {
                    Text(message.content)
                        .font(.system(size: 16))
                        .foregroundColor(isSent ? AppColors.white : AppColors.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isSent ? AppColors.primaryRed : AppColors.lightGray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                } else if message.type == .image, let mediaUrl = message.mediaUrl {
                    AsyncImage(url: URL(string: mediaUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: 200, maxHeight: 200)
                    .cornerRadius(12)
                } else {
                    // Autres types de messages (audio, video, file)
                    HStack {
                        Image(systemName: iconForMessageType(message.type))
                            .foregroundColor(isSent ? AppColors.white : AppColors.primaryRed)
                        Text(message.content)
                            .font(.system(size: 14))
                            .foregroundColor(isSent ? AppColors.white : AppColors.black)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isSent ? AppColors.primaryRed : AppColors.lightGray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                
                Text(timestamp)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.mediumGray)
            }
            .frame(maxWidth: .infinity, alignment: isSent ? .trailing : .leading)
            
            if isSent {
                Spacer().frame(width: 28)
            }
        }
        .padding(.horizontal, 8)
    }
    
    private func iconForMessageType(_ type: MessageType) -> String {
        switch type {
        case .audio: return "waveform"
        case .video: return "video.fill"
        case .file: return "doc.fill"
        default: return "paperclip"
        }
    }
}

struct ChatTopBar: View {
    let companyName: String
    let onBack: () -> Void
    let onCall: () -> Void
    let onVideoCall: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .foregroundColor(AppColors.white)
                    .frame(width: 24, height: 24)
            }
            
            Circle()
                .fill(AppColors.mediumGray)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(companyName)
                    .font(.headline)
                    .foregroundColor(AppColors.white)
                
                Text("En ligne")
                    .font(.subheadline)
                    .foregroundColor(AppColors.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: onCall) {
                Image(systemName: "phone")
                    .foregroundColor(AppColors.white)
                    .frame(width: 44, height: 44)
            }
            
            Button(action: onVideoCall) {
                Image(systemName: "video")
                    .foregroundColor(AppColors.white)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [AppColors.primaryRed, AppColors.accentPink]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}

struct ChatInputBar: View {
    @Binding var text: String
    let onSend: () -> Void
    let isLoading: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: { /* Ajouter fichier */ }) {
                Image(systemName: "plus.circle")
                    .foregroundColor(AppColors.primaryRed)
                    .font(.title2)
            }
            
            Button(action: { /* Camera */ }) {
                Image(systemName: "camera")
                    .foregroundColor(AppColors.primaryRed)
                    .font(.title2)
            }
            
            Button(action: { /* Micro */ }) {
                Image(systemName: "mic")
                    .foregroundColor(AppColors.primaryRed)
                    .font(.title2)
            }
            
            TextField("Aa", text: $text)
                .padding(.horizontal, 12)
                .frame(height: 36)
                .background(AppColors.lightGray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .disabled(isLoading)
                .onSubmit {
                    if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        onSend()
                    }
                }
            
            Button(action: onSend) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryRed))
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(AppColors.primaryRed)
                        .font(.title2)
                }
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppColors.white)
    }
}

#Preview {
    ChatView()
}
