//
//  CallCoordinator.swift
//  Taleb_5edma
//
//  Coordinates global call notifications and navigation
//

import SwiftUI
import Combine

/// Global coordinator for managing call UI across the entire app
class CallCoordinator: ObservableObject {
    // MARK: - Singleton
    
    static let shared = CallCoordinator()
    
    // MARK: - Published Properties
    
    @Published var showIncomingCallOverlay = false
    @Published var showCallView = false
    @Published var incomingCallData: CallData?
    @Published var outgoingCallData: (userId: String, userName: String, isVideo: Bool, chatId: String?)?
    @Published var pendingInvitation: InterviewInvitation?
    @Published var activeInterviewData: ActiveInterviewData?
    
    struct ActiveInterviewData: Identifiable {
        let id = UUID()
        let user: User
        let offre: Offre
        let mode: AITrainingMode
        let chatId: String?
    }
    
    // MARK: - Private Properties
    
    private let callManager = CallManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Monitor call state changes
        callManager.$callState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleCallStateChange(state)
            }
            .store(in: &cancellables)
            
        // Monitor interview invitations
        callManager.$pendingInvitation
            .receive(on: DispatchQueue.main)
            .assign(to: &$pendingInvitation)
    }
    
    // MARK: - Call State Handling
    
    private func handleCallStateChange(_ state: CallState) {
        switch state {
        case .incomingCall(let callData):
            // Show incoming call overlay globally
            incomingCallData = callData
            showIncomingCallOverlay = true
            print("📞 Showing incoming call overlay for: \(callData.fromUserName)")
            
        case .outgoingCall:
            // Navigate to call view for outgoing call
            if let data = callManager.currentCallData {
                outgoingCallData = (
                    data.toUserId ?? "unknown",
                    "Calling...", // Will be updated in CallView
                    data.isVideoCall,
                    data.chatId
                )
                showCallView = true
                print("📞 Navigating to call view for outgoing call")
            }
            
        case .idle, .ended, .callFailed:
            // Dismiss overlays
            showIncomingCallOverlay = false
            // Don't auto-dismiss call view here - let it handle its own dismissal
            
        default:
            break
        }
    }
    
    // MARK: - Public Actions
    
    /// Accept incoming call
    func acceptCall() {
        guard let callData = incomingCallData else { return }
        
        print("✅ Accepting call from: \(callData.fromUserName)")
        
        // Hide incoming call overlay
        showIncomingCallOverlay = false
        
        // Accept the call
        callManager.acceptCall()
        
        // Navigate to call view
        outgoingCallData = (
            callData.fromUserId,
            callData.fromUserName,
            callData.isVideoCall,
            callData.chatId
        )
        showCallView = true
    }
    
    /// Reject incoming call
    func rejectCall() {
        print("❌ Rejecting call")
        
        callManager.rejectCall()
        showIncomingCallOverlay = false
        incomingCallData = nil
    }
    
    /// Dismiss call view
    func dismissCallView() {
        showCallView = false
        outgoingCallData = nil
    }
    
    /// Connect to call server (should be called when user logs in)
    func connectToCallServer(userId: String, userName: String) {
        print("🔌 Connecting to call server for user: \(userName)")
        callManager.connect(userId: userId, userName: userName)
        
        // Also connect to AI WebSocket for interview invitations
        print("🔌 Connecting to AI WebSocket server...")
        AIWebSocketManager.shared.connect(userId: userId)
    }
    
    /// Disconnect from call server (should be called when user logs out)
    func disconnectFromCallServer() {
        print("🔌 Disconnecting from call server")
        callManager.disconnect()
        
        // Also disconnect from AI WebSocket
        AIWebSocketManager.shared.disconnect()
    }
    
    // MARK: - Interview Invitations
    
    func acceptInvitation(completion: @escaping (String, String) -> Void) {
        guard let invitation = pendingInvitation else { return }
        
        // Clear invitation first
        callManager.acceptInvitation()
        
        // Fetch details and start interview
        Task {
            await startInterviewSession(invitation: invitation)
        }
    }
    
    func rejectInvitation() {
        callManager.rejectInvitation()
    }
    
    // MARK: - AI Interview Session Helper
    
    private func startInterviewSession(invitation: InterviewInvitation) async {
        print("Ai_Debug: 🚀 Preparing interview session...")
        
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("Ai_Debug: ❌ Missing auth token")
            return
        }
        
        do {
            // 1. Fetch Current User
            let userUrl = URL(string: APIConfig.getUserProfileEndpoint)!
            var userRequest = URLRequest(url: userUrl)
            userRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (userData, _) = try await URLSession.shared.data(for: userRequest)
            if let userString = String(data: userData, encoding: .utf8) {
                print("Ai_Debug: User JSON: \(userString)")
            }
            // let userResponse = try JSONDecoder().decode(User.self, from: userData) 
            // The JSON might be wrapped or User might need specific decoding options. 
            // Let's use AuthService's decoder logic or simpler one. 
            // For now, let's verify printing.
            let userResponse = try makeJSONDecoder().decode(User.self, from: userData)

            // 2. Fetch Offer
            guard let offerId = invitation.offerId else {
                print("Ai_Debug: ❌ Invitation missing offerId")
                return
            }
            
            let offerUrl = URL(string: APIConfig.getOffreByIdEndpoint(id: offerId))!
            var offerRequest = URLRequest(url: offerUrl)
            offerRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (offerData, _) = try await URLSession.shared.data(for: offerRequest)
            if let offerString = String(data: offerData, encoding: .utf8) {
                print("Ai_Debug: Offer JSON: \(offerString)")
            }
            let offer = try makeJSONDecoder().decode(Offre.self, from: offerData)
            
            // 3. Set Active Data
            await MainActor.run {
                self.activeInterviewData = ActiveInterviewData(
                    user: userResponse,
                    offre: offer,
                    mode: .employerInterview, // Invited mode
                    chatId: invitation.chatId
                )
                print("Ai_Debug: ✅ Interview session ready. Launching view.")
            }
            
        } catch {
            print("Ai_Debug: ❌ Failed to fetch interview details: \(error.localizedDescription)")
        }
    }
    
    private func makeJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = formatter.date(from: dateString) { return date }
            
            let stdFormatter = ISO8601DateFormatter()
            stdFormatter.formatOptions = [.withInternetDateTime]
            stdFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            if let date = stdFormatter.date(from: dateString) { return date }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(dateString)")
        }
        return decoder
    }
}
