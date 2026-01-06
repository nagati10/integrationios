//
//  AIInterviewViewModel.swift
//  Taleb_5edma
//
//  ViewModel for AI Interview Training
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

@MainActor
class AIInterviewViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var messages: [AIConversationMessage] = []
    @Published var isLoading = false
    @Published var isRecording = false
    @Published var isPlayingAudio = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var currentMode: AITrainingMode = .coaching
    @Published var errorMessage: String?
    @Published var sessionId: String
    
    // MARK: - Private Properties
    
    private let service = AIInterviewService()
    private let audioRecorder = AudioRecordingManager()
    private var userDetails: AIUserDetails
    private var offerDetails: AIOfferDetails
    private var chatHistory: [AIChatHistoryItem] = []
    private var recordingTimer: Timer?
    private var realChatId: String?
    
    // MARK: - Initialization
    
    init(user: User, offre: Offre, initialMode: AITrainingMode = .coaching, chatId: String? = nil) {
        self.realChatId = chatId
        // Set initial mode
        if initialMode == .employerInterview {
            self.currentMode = .employerInterview
        } else {
             self.currentMode = .coaching
        }
        
        // Extract user and offer details first
        self.userDetails = AIUserDetails(from: user)
        self.offerDetails = AIOfferDetails(from: offre)
        
        // Generate session ID or restore from UserDefaults
        let sessionKey = AITrainingSession.sessionKey(userId: user.id, offerId: offre.id)
        if let savedSessionId = UserDefaults.standard.string(forKey: sessionKey) {
            self.sessionId = savedSessionId
            print("Ai_Debug: 🔄 Restored session: \(savedSessionId)")
        } else {
            let newSessionId = "session_\(Date().timeIntervalSince1970)"
            self.sessionId = newSessionId
            UserDefaults.standard.set(newSessionId, forKey: sessionKey)
            print("Ai_Debug: 🆕 Created new session: \(newSessionId)")
        }
        
        print("Ai_Debug: ✅ AIInterviewViewModel initialized")
        print("Ai_Debug:    User: \(userDetails.name)")
        print("Ai_Debug:    Position: \(offerDetails.position)")
        print("Ai_Debug:    Company: \(offerDetails.company)")
    }
    
    // MARK: - Public Methods
    
    /// Initialize with welcome message
    func initialize() {
        print("Ai_Debug: 🎬 Initializing AI training session")
        
        // Add welcome message
        let welcomeMessage = currentMode == .coaching
            ? "Hello! I'm your AI interview coach. I'm here to help you prepare for your interview at \(offerDetails.company) for the \(offerDetails.position) position. Ready to practice?"
            : "Hello, welcome to your interview at \(offerDetails.company). I'll be conducting this mock interview for the \(offerDetails.position) position. Shall we begin?"
        
        let aiMessage = AIConversationMessage(
            content: welcomeMessage,
            isUser: false,
            isVoice: false
        )
        messages.append(aiMessage)
        
        print("Ai_Debug: 👋 Added welcome message")
        
        // Start timer if in employer interview mode
        if currentMode == .employerInterview {
            startInterviewTimer()
        }
    }
    
    // MARK: - Timer Logic
    
    @Published var timeRemaining: Int = 600 // 10 minutes
    private var interviewTimer: Timer?
    private var startTime: Date?
    private var hasAnalyzed = false
    
    private func startInterviewTimer() {
        print("Ai_Debug: ⏱ Starting interview timer")
        startTime = Date()
        interviewTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.endInterview()
                }
            }
        }
    }
    
    private func stopInterviewTimer() {
        interviewTimer?.invalidate()
        interviewTimer = nil
    }
    
    func endInterview() {
        stopInterviewTimer()
        Task {
            await triggerAnalysis()
        }
    }
    
    func triggerAnalysis() async {
        guard !hasAnalyzed else { return }
        hasAnalyzed = true
        
        guard messages.count > 2 else {
            print("Ai_Debug: ⚠️ Not enough messages for analysis")
            return
        }
        
        isLoading = true
        let duration = Int(Date().timeIntervalSince(startTime ?? Date()))
        
        do {
            let chatIdToUse = realChatId ?? "ios_session_\(sessionId)"
            
            let result = try await service.analyzeInterview(
                sessionId: sessionId,
                chatId: chatIdToUse,
                userDetails: userDetails,
                offerDetails: offerDetails,
                durationSeconds: duration
            )
            
            await MainActor.run {
                self.isLoading = false
            }
            
            if result.success {
                print("Ai_Debug: ✅ Interview analysis completed")
                // Handle success (e.g. show result bubble locally if we want, or just exit)
                // In this flow, the result is sent to the chat.
            } else {
                await MainActor.run {
                    self.errorMessage = result.error ?? "Analysis failed"
                }
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    /// Send text message to AI
    func sendTextMessage(_ text: String) {
        guard !text.isEmpty else { return }
        
        print("Ai_Debug: 📝 Sending text message: \(text)")
        
        // Add user message to UI
        let userMessage = AIConversationMessage(
            content: text,
            isUser: true,
            isVoice: false
        )
        messages.append(userMessage)
        
        // Send to API
        Task {
            await sendToAI(userText: text, isVoice: false)
        }
    }
    
    /// Start voice recording
    func startVoiceRecording() {
        print("Ai_Debug: 🎤 Starting voice recording")
        
        // Request permission first
        audioRecorder.requestPermission { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                do {
                    let started = try self.audioRecorder.startRecording()
                    if started {
                        DispatchQueue.main.async {
                            self.isRecording = true
                            self.recordingDuration = 0
                            self.startRecordingTimer()
                        }
                        print("Ai_Debug: ✅ Recording started successfully")
                    } else {
                        print("Ai_Debug: ❌ Failed to start recording")
                        DispatchQueue.main.async {
                            self.errorMessage = "Failed to start recording"
                        }
                    }
                } catch {
                    print("Ai_Debug: ❌ Recording error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.errorMessage = "Recording error: \(error.localizedDescription)"
                    }
                }
            } else {
                print("Ai_Debug: ❌ Microphone permission denied")
                DispatchQueue.main.async {
                    self.errorMessage = "Microphone permission required"
                }
            }
        }
    }
    
    /// Stop recording and send to AI
    func stopAndSendVoice() {
        print("Ai_Debug: ⏹ Stopping voice recording")
        
        stopRecordingTimer()
        isRecording = false
        
        guard let result = audioRecorder.stopRecording() else {
            print("Ai_Debug: ❌ No recording to stop")
            errorMessage = "Recording failed"
            return
        }
        
        print("Ai_Debug: ✅ Recording stopped: \(result.duration)s, file: \(result.url.lastPathComponent)")
        
        // Read audio file
        do {
            let audioData = try Data(contentsOf: result.url)
            print("Ai_Debug:    Audio data size: \(audioData.count) bytes")
            
            // Send to API
            Task {
                await sendVoiceToAI(audioData: audioData)
            }
        } catch {
            print("Ai_Debug: ❌ Failed to read audio file: \(error.localizedDescription)")
            errorMessage = "Failed to read audio file"
        }
    }
    

    
    /// Clear conversation and start fresh
    func clearConversation() {
        print("Ai_Debug: 🗑 Clearing conversation")
        messages.removeAll()
        chatHistory.removeAll()
        sessionId = "session_\(Date().timeIntervalSince1970)"
        initialize()
    }
    
    // MARK: - Private Methods
    
    private func sendToAI(userText: String, isVoice: Bool) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await service.sendTextMessage(
                text: userText,
                userDetails: userDetails,
                offerDetails: offerDetails,
                chatHistory: chatHistory,
                mode: currentMode,
                sessionId: sessionId
            )
            
            guard response.success, let aiResponse = response.aiResponse else {
                print("Ai_Debug: ⚠️ AI response not successful")
                errorMessage = response.error ?? "Failed to get AI response"
                isLoading = false
                return
            }
            
            // Add AI message to UI
            let aiMessage = AIConversationMessage(
                content: aiResponse,
                isUser: false,
                isVoice: false
            )
            messages.append(aiMessage)
            
            // Update chat history for context
            let historyItem = AIChatHistoryItem(
                userMessage: userText,
                aiResponse: aiResponse
            )
            chatHistory.append(historyItem)
            
            // Keep only last 10 exchanges for context
            if chatHistory.count > 10 {
                chatHistory.removeFirst()
            }
            
            isLoading = false
            print("Ai_Debug: ✅ Message processed successfully")
            
        } catch {
            print("Ai_Debug: ❌ Error sending message: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    private func sendVoiceToAI(audioData: Data) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await service.sendVoiceMessage(
                audioData: audioData,
                userDetails: userDetails,
                offerDetails: offerDetails,
                mode: currentMode,
                sessionId: sessionId
            )
            
            guard response.success else {
                print("Ai_Debug: ⚠️ Voice response not successful")
                errorMessage = response.error ?? "Failed to process voice"
                isLoading = false
                return
            }
            
            // Add transcribed user message to UI
            if let transcribedText = response.transcribedText {
                let userMessage = AIConversationMessage(
                    content: "🎤 You: \(transcribedText)",
                    isUser: true,
                    isVoice: true
                )
                messages.append(userMessage)
            }
            
            // Add AI response
            if let aiResponse = response.aiResponse {
                let aiMessage = AIConversationMessage(
                    content: aiResponse,
                    isUser: false,
                    isVoice: true
                )
                messages.append(aiMessage)
                
                // Update chat history
                if let transcribed = response.transcribedText {
                    let historyItem = AIChatHistoryItem(
                        userMessage: transcribed,
                        aiResponse: aiResponse
                    )
                    chatHistory.append(historyItem)
                    
                    if chatHistory.count > 10 {
                        chatHistory.removeFirst()
                    }
                }
                
                // Play audio response if available
                if let audioBase64 = response.audioResponse, !audioBase64.isEmpty {
                    print("Ai_Debug: 🔊 Playing AI audio response")
                    isPlayingAudio = true
                    
                    Task {
                        do {
                            try await service.playAudioResponse(base64Audio: audioBase64)
                            isPlayingAudio = false
                        } catch {
                            print("Ai_Debug: ❌ Audio playback error: \(error.localizedDescription)")
                            isPlayingAudio = false
                        }
                    }
                }
            }
            
            isLoading = false
            print("Ai_Debug: ✅ Voice message processed successfully")
            
        } catch {
            print("Ai_Debug: ❌ Error sending voice: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    private func startRecordingTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let duration = self.audioRecorder.recordingDuration
            Task { @MainActor [weak self] in
                self?.recordingDuration = duration
            }
        }
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingDuration = 0
    }
}
