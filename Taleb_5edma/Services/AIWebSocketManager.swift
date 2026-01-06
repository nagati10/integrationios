import Foundation
import Combine
import SocketIO

/// WebSocket manager for connecting to the Python AI backend for interview invitations
class AIWebSocketManager: ObservableObject {
    static let shared = AIWebSocketManager()
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    
    private let serverURL = "https://voice-chatbot-k3fe.onrender.com"
    
    @Published var isConnected = false
    @Published var pendingInvitation: InterviewInvitation?
    
    private var userId: String?
    
    private init() {}
    
    // MARK: - Connection Management
    
    func connect(userId: String) {
        guard !userId.isEmpty else {
            print("❌ AIWebSocketManager: Cannot connect with empty userId")
            return
        }
        
        self.userId = userId
        
        guard let url = URL(string: serverURL) else {
            print("❌ AIWebSocketManager: Invalid server URL")
            return
        }
        
        let config: SocketIOClientConfiguration = [
            .log(false),
            .compress,
            .forceNew(true),
            .reconnects(true),
            .reconnectAttempts(10),
            .reconnectWait(1),
            .connectParams(["userId": userId])
        ]
        
        manager = SocketManager(socketURL: url, config: config)
        socket = manager?.defaultSocket
        
        setupEventHandlers()
        
        socket?.connect()
        print("🔌 AIWebSocketManager: Connecting to \(serverURL) for user: \(userId)")
    }
    
    func disconnect() {
        if let userId = userId {
            socket?.emit("leave", ["userId": userId])
        }
        
        socket?.disconnect()
        socket?.removeAllHandlers()
        socket = nil
        manager = nil
        
        DispatchQueue.main.async {
            self.isConnected = false
            self.pendingInvitation = nil
        }
        
        print("🔌 AIWebSocketManager: Disconnected and cleaned up")
    }
    
    // MARK: - Event Handlers
    
    private func setupEventHandlers() {
        // Connection events
        socket?.on(clientEvent: .connect) { [weak self] data, ack in
            print("✅ AIWebSocketManager: Connected to AI server")
            DispatchQueue.main.async {
                self?.isConnected = true
            }
            self?.joinUserRoom()
        }
        
        socket?.on(clientEvent: .disconnect) { [weak self] data, ack in
            print("❌ AIWebSocketManager: Disconnected from AI server")
            DispatchQueue.main.async {
                self?.isConnected = false
            }
        }
        
        socket?.on(clientEvent: .error) { data, ack in
            print("❌ AIWebSocketManager: Connection error: \(data)")
        }
        
        socket?.on(clientEvent: .reconnect) { data, ack in
            print("🔄 AIWebSocketManager: Reconnected")
        }
        
        // Custom events
        socket?.on("connect_response") { data, ack in
            print("📥 AIWebSocketManager: Server acknowledged connection")
        }
        
        socket?.on("join_response") { data, ack in
            guard let responseData = data.first as? [String: Any] else { return }
            let success = responseData["success"] as? Bool ?? false
            let message = responseData["message"] as? String ?? ""
            print("📥 AIWebSocketManager: Join response - Success: \(success), Message: \(message)")
        }
        
        // ✨ INVITATION RECEIVED EVENT ✨
        socket?.on("invitation_received") { [weak self] data, ack in
            print("🎉 AIWebSocketManager: INVITATION RECEIVED: \(data)")
            
            guard let invitationData = data.first as? [String: Any] else {
                print("❌ AIWebSocketManager: Invalid invitation data format")
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: invitationData)
                let invitation = try JSONDecoder().decode(InterviewInvitation.self, from: jsonData)
                
                DispatchQueue.main.async {
                    self?.pendingInvitation = invitation
                    print("📬 AIWebSocketManager: Invitation set - From: \(invitation.fromUserName ?? "Unknown")")
                }
            } catch {
                print("❌ AIWebSocketManager: Failed to parse invitation: \(error)")
            }
        }
        
        // Heartbeat
        socket?.on("pong") { data, ack in
            print("💓 AIWebSocketManager: Heartbeat received")
        }
    }
    
    private func joinUserRoom() {
        guard let userId = userId else { return }
        
        socket?.emit("join", ["userId": userId])
        print("📝 AIWebSocketManager: Joining room for user: \(userId)")
    }
    
    // MARK: - Public Methods
    
    func clearPendingInvitation() {
        DispatchQueue.main.async {
            self.pendingInvitation = nil
        }
    }
    
    func sendPing() {
        socket?.emit("ping")
    }
}

// MARK: - Interview Invitation Model

struct InterviewInvitation: Codable {
    let invitationId: Int
    let chatId: String
    let fromUserId: String
    let toUserId: String?
    let fromUserName: String?
    let offerId: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case invitationId = "invitation_id"
        case chatId = "chat_id"
        case fromUserId = "from_user_id"
        case toUserId = "to_user_id"
        case fromUserName = "from_user_name"
        case offerId = "offer_id"
        case createdAt = "created_at"
    }
}
