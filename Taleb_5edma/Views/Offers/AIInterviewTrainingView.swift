//
//  AIInterviewTrainingView.swift
//  Taleb_5edma
//
//  Main view for AI Interview Training
//

import SwiftUI

struct AIInterviewTrainingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: AIInterviewViewModel
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool
    
    init(user: User, offre: Offre, initialMode: AITrainingMode = .coaching, chatId: String? = nil) {
        _viewModel = StateObject(wrappedValue: AIInterviewViewModel(user: user, offre: offre, initialMode: initialMode, chatId: chatId))
    }
    
    var body: some View {
        ZStack {
            // Background
            AppColors.backgroundGray.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Job Details Card
                jobDetailsCard
                
                // Messages Area
                messagesArea
                
                // Error Message
                if let error = viewModel.errorMessage {
                    errorBanner(error)
                }
                
                // Input Area
                inputArea
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.initialize()
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            Button(action: { 
                if viewModel.currentMode == .employerInterview {
                    viewModel.endInterview()
                }
                dismiss() 
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("AI Interview Training")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text(viewModel.currentMode.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.85))
            }
            
            Spacer()
            
            // Timer for Interview Mode
            if viewModel.currentMode == .employerInterview {
                Text(formatTime(viewModel.timeRemaining))
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(viewModel.timeRemaining < 60 ? .red : .white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(8)
            }
            
            // Finish/Mode Button
            Button(action: {
                if viewModel.currentMode == .employerInterview {
                    // End interview action
                    viewModel.endInterview()
                    dismiss()
                } else {
                    // Just show mode info or toggle (currently just icon)
                }
            }) {
                if viewModel.currentMode == .employerInterview {
                    VStack(spacing: 2) {
                        Image(systemName: "flag.checkered")
                            .font(.system(size: 16))
                        Text("Finish")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(width: 50, height: 44)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(8)
                } else {
                    Image(systemName: "person.fill.questionmark")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#667eea"),
                    Color(hex: "#764ba2")
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    private func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Job Details Card
    
    private var jobDetailsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "briefcase.fill")
                    .foregroundColor(Color(hex: "#667eea"))
                    .font(.system(size: 16))
                
                Text("Interview Position")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.mediumGray)
            }
            
            Text(viewModel.currentMode.displayName)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppColors.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
    
    // MARK: - Messages Area
    
    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        AIMessageBubbleView(message: message)
                            .id(message.id)
                    }
                    
                    // Loading indicator
                    if viewModel.isLoading {
                        HStack(spacing: 8) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#667eea")))
                            Text("Thinking...")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.mediumGray)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Audio playback indicator
                    if viewModel.isPlayingAudio {
                        HStack(spacing: 8) {
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(Color(hex: "#667eea"))
                                .font(.system(size: 16))
                            Text("Playing AI response...")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.mediumGray)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Error Banner
    
    private func errorBanner(_ error: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)
            Text(error)
                .font(.system(size: 14))
                .foregroundColor(.white)
            Spacer()
            Button(action: { viewModel.errorMessage = nil }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
            }
        }
        .padding(12)
        .background(Color.red.opacity(0.9))
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .transition(.move(edge: .top))
    }
    
    // MARK: - Input Area
    
    private var inputArea: some View {
        VStack(spacing: 12) {
            // Recording indicator
            if viewModel.isRecording {
                recordingIndicator
            }
            
            HStack(spacing: 12) {
                // Voice button
                Button(action: {
                    if viewModel.isRecording {
                        viewModel.stopAndSendVoice()
                    } else {
                        viewModel.startVoiceRecording()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.isRecording ? Color.red : Color(hex: "#667eea"))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: viewModel.isRecording ? "stop.fill" : "mic.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                    }
                }
                .scaleEffect(viewModel.isRecording ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: viewModel.isRecording)
                
                // Text input
                HStack {
                    TextField("Type your message...", text: $messageText)
                        .font(.system(size: 16))
                        .focused($isInputFocused)
                        .disabled(viewModel.isRecording || viewModel.isLoading)
                        .onSubmit {
                            sendTextMessage()
                        }
                    
                    if !messageText.isEmpty {
                        Button(action: { messageText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppColors.mediumGray)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(AppColors.lightGray.opacity(0.3))
                .cornerRadius(22)
                
                // Send button
                if !messageText.isEmpty {
                    Button(action: sendTextMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                            .frame(width: 44, height: 44)
                            .background(Color(hex: "#667eea"))
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(AppColors.white)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
    }
    
    // MARK: - Recording Indicator
    
    private var recordingIndicator: some View {
        HStack {
            Circle()
                .fill(Color.red)
                .frame(width: 12, height: 12)
            
            Text(String(format: "Recording... %.1fs", viewModel.recordingDuration))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.red)
            
            Spacer()
            
            Text("Tap stop when done")
                .font(.system(size: 12))
                .foregroundColor(AppColors.mediumGray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Actions
    
    private func sendTextMessage() {
        guard !messageText.isEmpty else { return }
        viewModel.sendTextMessage(messageText)
        messageText = ""
        isInputFocused = false
    }
}

// MARK: - AI Message Bubble View

struct AIMessageBubbleView: View {
    let message: AIConversationMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !message.isUser {
                // AI avatar
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#667eea"),
                                Color(hex: "#764ba2")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    )
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                // Message bubble
                HStack {
                    if message.isVoice && !message.isUser {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 12))
                            .foregroundColor(message.isUser ? .white.opacity(0.8) : Color(hex: "#667eea"))
                    }
                    
                    Text(message.content)
                        .font(.system(size: 16))
                        .foregroundColor(message.isUser ? .white : AppColors.black)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    message.isUser
                        ? Color(hex: "#667eea")
                        : Color(hex: "#f0f0f0")
                )
                .cornerRadius(18)
                
                // Timestamp
                Text(formatTimestamp(message.timestamp))
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.mediumGray)
            }
            .frame(maxWidth: .infinity * 0.75, alignment: message.isUser ? .trailing : .leading)
            
            if message.isUser {
                Spacer()
            }
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
