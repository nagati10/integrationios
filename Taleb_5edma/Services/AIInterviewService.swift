//
//  AIInterviewService.swift
//  Taleb_5edma
//
//  Service for AI interview training API communication
//

import Foundation
import AVFoundation

/// Service to communicate with Flask AI interview backend
class AIInterviewService {
    
    // MARK: - Properties
    
    /// Base URL for AI interview backend
    private let baseURL = "https://voice-chatbot-k3fe.onrender.com"
    
    /// Shared URL session
    private let session = URLSession.shared
    
    /// Audio playback manager
    private var audioPlayer: AVPlayer?
    
    /// Audio playback state
    var isPlayingAudio = false
    
    // MARK: - Initialization
    
    init() {
        print("Ai_Debug: AIInterviewService initialized with baseURL: \(baseURL)")
    }
    
    // MARK: - API Methods
    
    /// Send text message to AI
    func sendTextMessage(
        text: String,
        userDetails: AIUserDetails,
        offerDetails: AIOfferDetails,
        chatHistory: [AIChatHistoryItem],
        mode: AITrainingMode,
        sessionId: String
    ) async throws -> AIChatResponse {
        
        let endpoint = "\(baseURL)/api/text-chat"
        guard let url = URL(string: endpoint) else {
            print("Ai_Debug: ❌ Invalid URL: \(endpoint)")
            throw AIInterviewError.invalidURL
        }
        
        print("Ai_Debug: 📤 Sending text message to: \(endpoint)")
        print("Ai_Debug:    Text: \(text)")
        print("Ai_Debug:    Mode: \(mode.rawValue)")
        print("Ai_Debug:    SessionId: \(sessionId)")
        if let userDetailsData = try? JSONEncoder().encode(userDetails),
           let userDetailsString = String(data: userDetailsData, encoding: .utf8) {
            print("Ai_Debug:    User details: \(userDetailsString)")
        } else {
            print("Ai_Debug:    User details: encoding failed")
        }
        if let offerDetailsData = try? JSONEncoder().encode(offerDetails),
           let offerDetailsString = String(data: offerDetailsData, encoding: .utf8) {
            print("Ai_Debug:    Offer details: \(offerDetailsString)")
        } else {
            print("Ai_Debug:    Offer details: encoding failed")
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Build request body
        let requestBody = AITextChatRequest(
            text: text,
            sessionId: sessionId,
            mode: mode,
            userDetails: userDetails,
            offerDetails: offerDetails,
            chatHistory: chatHistory
        )
        
        // Encode to JSON
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(requestBody)
        
        // Log request body for debugging
        if let bodyData = request.httpBody,
           let bodyString = String(data: bodyData, encoding: .utf8) {
            print("Ai_Debug:    Request body size: \(bodyData.count) bytes")
            print("Ai_Debug:    Request body preview: \(String(bodyString.prefix(200)))...")
        }
        
        // Send request
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Ai_Debug: ❌ Invalid response type")
            throw AIInterviewError.invalidResponse
        }
        
        print("Ai_Debug: 📥 Response status: \(httpResponse.statusCode)")
        
        // Log response for debugging
        if let responseString = String(data: data, encoding: .utf8) {
            print("Ai_Debug:    Response size: \(data.count) bytes")
            print("Ai_Debug:    Response preview: \(String(responseString.prefix(200)))...")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to decode error message
            if let errorResponse = try? JSONDecoder().decode(AIChatResponse.self, from: data),
               let error = errorResponse.error {
                print("Ai_Debug: ❌ Server error: \(error)")
                throw AIInterviewError.serverError(error)
            }
            print("Ai_Debug: ❌ HTTP error: \(httpResponse.statusCode)")
            throw AIInterviewError.httpError(httpResponse.statusCode)
        }
        
        // Log raw response for debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Ai_Debug:    Raw JSON: \(jsonString.prefix(200))...")
        }
        
        // Decode response (model has custom decoder with explicit CodingKeys)
        let decoder = JSONDecoder()
        let chatResponse = try decoder.decode(AIChatResponse.self, from: data)
        
        if chatResponse.success {
            print("Ai_Debug: ✅ Text message sent successfully")
            print("Ai_Debug:    AI response: \(chatResponse.aiResponse?.prefix(100) ?? "nil")...")
            print("Ai_Debug:    Language: \(chatResponse.language ?? "nil")")
        } else {
            print("Ai_Debug: ⚠️ Response success=false, error: \(chatResponse.error ?? "unknown")")
        }
        
        return chatResponse
    }
    
    /// Send voice message to AI
    func sendVoiceMessage(
        audioData: Data,
        userDetails: AIUserDetails,
        offerDetails: AIOfferDetails,
        mode: AITrainingMode,
        sessionId: String
    ) async throws -> AIChatResponse {
        
        let endpoint = "\(baseURL)/api/voice-chat"
        guard let url = URL(string: endpoint) else {
            print("Ai_Debug: ❌ Invalid URL: \(endpoint)")
            throw AIInterviewError.invalidURL
        }
        
        print("Ai_Debug: 📤 Sending voice message to: \(endpoint)")
        print("Ai_Debug:    Audio size: \(audioData.count) bytes")
        print("Ai_Debug:    Mode: \(mode.rawValue)")
        print("Ai_Debug:    SessionId: \(sessionId)")
        
        // Log the details being sent
        if let userJson = try? JSONEncoder().encode(userDetails),
           let userStr = String(data: userJson, encoding: .utf8) {
            print("Ai_Debug:    User details: \(userStr)")
        }
        
        if let offerJson = try? JSONEncoder().encode(offerDetails),
           let offerStr = String(data: offerJson, encoding: .utf8) {
            print("Ai_Debug:    Offer details: \(offerStr)")
        }
        
        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Helper to append form fields
        func appendField(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add audio file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"audio\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add other fields
        appendField("session_id", sessionId)
        appendField("mode", mode.rawValue)
        
        // Encode user and offer details as JSON strings
        let encoder = JSONEncoder()
        if let userDetailsData = try? encoder.encode(userDetails),
           let userDetailsString = String(data: userDetailsData, encoding: .utf8) {
            appendField("user_details", userDetailsString)
            print("Ai_Debug:    User details: \(userDetailsString.prefix(100))...")
        }
        
        if let offerDetailsData = try? encoder.encode(offerDetails),
           let offerDetailsString = String(data: offerDetailsData, encoding: .utf8) {
            appendField("offer_details", offerDetailsString)
            print("Ai_Debug:    Offer details: \(offerDetailsString.prefix(100))...")
        }
        
        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        print("Ai_Debug:    Multipart body size: \(body.count) bytes")
        
        // Send request
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Ai_Debug: ❌ Invalid response type")
            throw AIInterviewError.invalidResponse
        }
        
        print("Ai_Debug: 📥 Response status: \(httpResponse.statusCode)")
        
        // Log response for debugging
        if let responseString = String(data: data, encoding: .utf8) {
            print("Ai_Debug:    Response size: \(data.count) bytes")
            print("Ai_Debug:    Response preview: \(String(responseString.prefix(200)))...")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to decode error message
            if let errorResponse = try? JSONDecoder().decode(AIChatResponse.self, from: data),
               let error = errorResponse.error {
                print("Ai_Debug: ❌ Server error: \(error)")
                throw AIInterviewError.serverError(error)
            }
            print("Ai_Debug: ❌ HTTP error: \(httpResponse.statusCode)")
            throw AIInterviewError.httpError(httpResponse.statusCode)
        }
        
        // Log raw response for debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Ai_Debug:    Raw JSON: \(jsonString.prefix(300))...")
        }
        
        // Decode response (model has custom decoder with explicit CodingKeys)
        let decoder = JSONDecoder()
        let chatResponse = try decoder.decode(AIChatResponse.self, from: data)
        
        if chatResponse.success {
            print("Ai_Debug: ✅ Voice message sent successfully")
            print("Ai_Debug:    Transcribed: \(chatResponse.transcribedText ?? "nil")")
            print("Ai_Debug:    AI response: \(chatResponse.aiResponse?.prefix(100) ?? "nil")...")
            print("Ai_Debug:    Audio response size: \(chatResponse.audioResponse?.count ?? 0) bytes (base64)")
        } else {
            print("Ai_Debug: ⚠️ Response success=false, error: \(chatResponse.error ?? "unknown")")
        }
        
        return chatResponse
    }
    
    // MARK: - Audio Playback
    
    /// Play AI audio response from base64 string
    func playAudioResponse(base64Audio: String) async throws {
        print("Ai_Debug: 🔊 Attempting to play audio response")
        print("Ai_Debug:    Base64 length: \(base64Audio.count) characters")
        
        // Decode base64 to Data
        guard let audioData = Data(base64Encoded: base64Audio) else {
            print("Ai_Debug: ❌ Failed to decode base64 audio")
            throw AIInterviewError.audioDecodingFailed
        }
        
        print("Ai_Debug:    Decoded audio size: \(audioData.count) bytes")
        
        // Write to temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let audioFileName = "ai_response_\(Date().timeIntervalSince1970).mp3"
        let audioURL = tempDir.appendingPathComponent(audioFileName)
        
        do {
            try audioData.write(to: audioURL)
            print("Ai_Debug:    Saved audio to: \(audioURL.path)")
        } catch {
            print("Ai_Debug: ❌ Failed to write audio file: \(error.localizedDescription)")
            throw AIInterviewError.audioPlaybackFailed
        }
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default)
        try audioSession.setActive(true)
        
        // Create player
        let playerItem = AVPlayerItem(url: audioURL)
        audioPlayer = AVPlayer(playerItem: playerItem)
        
        print("Ai_Debug:    Starting playback...")
        isPlayingAudio = true
        audioPlayer?.play()
        
        // Wait for playback to finish
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: playerItem,
                queue: .main
            ) { [weak self] _ in
                print("Ai_Debug: ✅ Audio playback completed")
                self?.isPlayingAudio = false
                self?.audioPlayer = nil
                
                // Clean up temp file
                try? FileManager.default.removeItem(at: audioURL)
                
                continuation.resume()
            }
        }
    }
    
    /// Stop audio playback
    func stopAudioPlayback() {
        print("Ai_Debug: ⏹ Stopping audio playback")
        audioPlayer?.pause()
        audioPlayer = nil
        isPlayingAudio = false
    }
}

// MARK: - Errors

enum AIInterviewError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case serverError(String)
    case audioDecodingFailed
    case audioPlaybackFailed
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code):
            return "HTTP error \(code)"
        case .serverError(let message):
            return message
        case .audioDecodingFailed:
            return "Failed to decode audio data"
        case .audioPlaybackFailed:
            return "Failed to play audio"
        case .networkError:
            return "Network connection error"
        }
    }
}

// MARK: - Interview Invitation

extension AIInterviewService {
    /// Send interview invitation to student
    func sendInterviewInvitation(
        chatId: String,
        fromUserId: String,
        toUserId: String,
        fromUserName: String,
        offerId: String? = nil
    ) async throws -> SendInvitationResponse {
        
        let endpoint = "\(baseURL)/api/send-interview-invitation"
        guard let url = URL(string: endpoint) else {
            print("Ai_Debug: ❌ Invalid URL: \(endpoint)")
            throw AIInterviewError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "chat_id": chatId,
            "from_user_id": fromUserId,
            "to_user_id": toUserId,
            "from_user_name": fromUserName,
            "offer_id": offerId ?? NSNull()
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        print("Ai_Debug: 📨 Sending interview invitation")
        print("Ai_Debug:    - From: \(fromUserName) (\(fromUserId))")
        print("Ai_Debug:    - To: \(toUserId)")
        print("Ai_Debug:    - Chat: \(chatId)")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIInterviewError.invalidResponse
        }
        
        print("Ai_Debug: 📥 Invitation response status: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw AIInterviewError.httpError(httpResponse.statusCode)
        }
        
        let invitationResponse = try JSONDecoder().decode(SendInvitationResponse.self, from: data)
        
        if invitationResponse.success {
            print("Ai_Debug: ✅ Invitation sent successfully: ID \(invitationResponse.invitationId ?? 0)")
        } else {
            print("Ai_Debug: ❌ Invitation failed: \(invitationResponse.error ?? "Unknown error")")
        }
        
        return invitationResponse
    }
}

// MARK: - Send Invitation Response

struct SendInvitationResponse: Codable {
    let success: Bool
    let message: String?
    let invitationId: Int?
    let error: String?
    let websocketNotified: Bool?
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case invitationId = "invitation_id"
        case error
        case websocketNotified = "websocket_notified"
    }
}

// MARK: - Interview Analysis Models

struct AnalyzeInterviewRequest: Codable {
    let sessionId: String
    let chatId: String
    let userDetails: AIUserDetails
    let offerDetails: AIOfferDetails
    let durationSeconds: Int
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case chatId = "chat_id"
        case userDetails = "user_details"
        case offerDetails = "offer_details"
        case durationSeconds = "duration_seconds"
    }
}

struct AnalyzeInterviewResponse: Codable {
    let success: Bool
    let analysis: ChatModels.AiInterviewAnalysis?
    let messageSent: Bool?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case analysis
        case messageSent = "message_sent"
        case error
    }
}

extension AIInterviewService {
    /// Trigger AI interview analysis
    func analyzeInterview(
        sessionId: String,
        chatId: String,
        userDetails: AIUserDetails,
        offerDetails: AIOfferDetails,
        durationSeconds: Int
    ) async throws -> AnalyzeInterviewResponse {
        
        let endpoint = "\(baseURL)/api/analyze-interview"
        guard let url = URL(string: endpoint) else {
            print("Ai_Debug: ❌ Invalid URL: \(endpoint)")
            throw AIInterviewError.invalidURL
        }
        
        print("Ai_Debug: 📊 Requesting interview analysis")
        print("Ai_Debug:    Session: \(sessionId)")
        print("Ai_Debug:    Duration: \(durationSeconds)s")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = AnalyzeInterviewRequest(
            sessionId: sessionId,
            chatId: chatId,
            userDetails: userDetails,
            offerDetails: offerDetails,
            durationSeconds: durationSeconds
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIInterviewError.invalidResponse
        }
        
        print("Ai_Debug: 📥 Analysis response status: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw AIInterviewError.httpError(httpResponse.statusCode)
        }
        
        let analysisResponse = try JSONDecoder().decode(AnalyzeInterviewResponse.self, from: data)
        
        if analysisResponse.success {
            print("Ai_Debug: ✅ Analysis successful")
            if let score = analysisResponse.analysis?.overallScore {
                print("Ai_Debug:    Score: \(score)")
            }
        } else {
            print("Ai_Debug: ❌ Analysis failed: \(analysisResponse.error ?? "Unknown error")")
        }
        
        return analysisResponse
    }
}
