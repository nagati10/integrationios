//
//  AIInterviewModels.swift
//  Taleb_5edma
//
//  Created for AI Interview Training Feature
//

import Foundation

// MARK: - Training Mode

/// AI training mode: coaching vs employer interview simulation
enum AITrainingMode: String, Codable {
    case coaching = "coaching"
    case employerInterview = "employer_interview"
    
    var displayName: String {
        switch self {
        case .coaching:
            return "🧑‍🏫 Coaching Mode"
        case .employerInterview:
            return "👔 Employer Interview"
        }
    }
    
    var description: String {
        switch self {
        case .coaching:
            return "Practice with AI - Get tips & advice"
        case .employerInterview:
            return "Real mock interview simulation"
        }
    }
}

// MARK: - User Details DTO

/// User details for AI context
struct AIUserDetails: Codable {
    let name: String
    let experienceLevel: String?
    let education: String?
    let skills: [String]
    let country: String?
    let languages: [String]
    
    enum CodingKeys: String, CodingKey {
        case name
        case experienceLevel = "experience_level"
        case education
        case skills
        case country
        case languages
    }
    
    /// Initialize from User model
    init(from user: User) {
        self.name = user.nom
        
        // Extract experience level from CV experience
        // Take first line of first experience entry as summary
        if let experiences = user.cvExperience, !experiences.isEmpty {
            let firstExperience = experiences.first ?? ""
            // Clean and limit to first 150 characters
            let cleaned = firstExperience.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            self.experienceLevel = String(cleaned.prefix(150))
        } else {
            self.experienceLevel = nil
        }
        
        // Extract education from CV education
        // Take first line of first education entry
        if let educations = user.cvEducation, !educations.isEmpty {
            let firstEducation = educations.first ?? ""
            // Clean and limit to first 150 characters
            let cleaned = firstEducation.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            self.education = String(cleaned.prefix(150))
        } else {
            self.education = nil
        }
        
        // Extract skills from CV skills
        self.skills = user.cvSkills ?? []
        
        // Extract country from user contact if available, default to Tunisia
        self.country = "Tunisia"
        
        // Default languages based on Tunisia
        self.languages = ["Arabic", "French"]
    }
    
    /// Manual initializer for testing
    init(name: String, experienceLevel: String?, education: String?, skills: [String], country: String?, languages: [String]) {
        self.name = name
        self.experienceLevel = experienceLevel
        self.education = education
        self.skills = skills
        self.country = country
        self.languages = languages
    }
}

// MARK: - Offer Details DTO

/// Job offer details for AI context
struct AIOfferDetails: Codable {
    let position: String
    let company: String
    let requiredSkills: [String]
    let salaryRange: String?
    let location: String
    
    enum CodingKeys: String, CodingKey {
        case position
        case company
        case requiredSkills = "required_skills"
        case salaryRange = "salary_range"
        case location
    }
    
    /// Initialize from Offre model
    init(from offre: Offre) {
        self.position = offre.title
        self.company = offre.company
        
        // Combine tags and exigences for required skills
        var allRequiredSkills: [String] = []
        if let tags = offre.tags, !tags.isEmpty {
            allRequiredSkills.append(contentsOf: tags)
        }
        if let exigences = offre.exigences, !exigences.isEmpty {
            allRequiredSkills.append(contentsOf: exigences)
        }
        
        // If we have combined skills, use them; otherwise add job description info
        if !allRequiredSkills.isEmpty {
            self.requiredSkills = allRequiredSkills
        } else {
            // Fallback: extract keywords from description if no explicit skills
            self.requiredSkills = []
        }
        
        self.salaryRange = offre.salary
        self.location = offre.location.address
    }
    
    /// Manual initializer for testing
    init(position: String, company: String, requiredSkills: [String], salaryRange: String?, location: String) {
        self.position = position
        self.company = company
        self.requiredSkills = requiredSkills
        self.salaryRange = salaryRange
        self.location = location
    }
}

// MARK: - Chat History Item

/// Conversation history item for AI context
struct AIChatHistoryItem: Codable {
    let userMessage: String
    let aiResponse: String
    
    enum CodingKeys: String, CodingKey {
        case userMessage = "0"
        case aiResponse = "1"
    }
    
    init(userMessage: String, aiResponse: String) {
        self.userMessage = userMessage
        self.aiResponse = aiResponse
    }
    
    /// Convert to array format for backend
    func toArray() -> [String] {
        return [userMessage, aiResponse]
    }
}

// MARK: - Text Chat Request

/// Request for text-based chat with AI
struct AITextChatRequest: Codable {
    let text: String
    let sessionId: String
    let mode: String
    let userDetails: AIUserDetails
    let offerDetails: AIOfferDetails
    let chatHistory: [[String]]
    
    enum CodingKeys: String, CodingKey {
        case text
        case sessionId = "session_id"
        case mode
        case userDetails = "user_details"
        case offerDetails = "offer_details"
        case chatHistory = "chat_history"
    }
    
    init(text: String, sessionId: String, mode: AITrainingMode, userDetails: AIUserDetails, offerDetails: AIOfferDetails, chatHistory: [AIChatHistoryItem]) {
        self.text = text
        self.sessionId = sessionId
        self.mode = mode.rawValue
        self.userDetails = userDetails
        self.offerDetails = offerDetails
        self.chatHistory = chatHistory.map { $0.toArray() }
    }
}

// MARK: - Chat Response

/// Response from AI chat (text or voice)
struct AIChatResponse: Codable {
    let success: Bool
    let aiResponse: String?
    let transcribedText: String?
    let audioResponse: String?
    let language: String?
    let sessionId: String?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case aiResponse = "ai_response"
        case transcribedText = "transcribed_text"
        case audioResponse = "audio_response"
        case language
        case sessionId = "session_id"
        case error
    }
    
    // Custom initializer to handle decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Success defaults to true if not present
        success = (try? container.decode(Bool.self, forKey: .success)) ?? true
        
        // Try to decode all optional fields
        aiResponse = try? container.decodeIfPresent(String.self, forKey: .aiResponse)
        transcribedText = try? container.decodeIfPresent(String.self, forKey: .transcribedText)
        audioResponse = try? container.decodeIfPresent(String.self, forKey: .audioResponse)
        language = try? container.decodeIfPresent(String.self, forKey: .language)
        sessionId = try? container.decodeIfPresent(String.self, forKey: .sessionId)
        error = try? container.decodeIfPresent(String.self, forKey: .error)
    }
}

// MARK: - Conversation Message

/// Local message model for UI display
struct AIConversationMessage: Identifiable, Equatable {
    let id: String
    let content: String
    let isUser: Bool
    let isVoice: Bool
    let timestamp: Date
    let audioData: Data?
    
    init(id: String = UUID().uuidString, content: String, isUser: Bool, isVoice: Bool, timestamp: Date = Date(), audioData: Data? = nil) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.isVoice = isVoice
        self.timestamp = timestamp
        self.audioData = audioData
    }
    
    static func == (lhs: AIConversationMessage, rhs: AIConversationMessage) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Session Management

/// AI training session data
struct AITrainingSession: Codable {
    let sessionId: String
    let userId: String
    let offerId: String
    let createdAt: Date
    let lastActivity: Date
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case userId = "user_id"
        case offerId = "offer_id"
        case createdAt = "created_at"
        case lastActivity = "last_activity"
    }
    
    /// Generate session key for UserDefaults
    static func sessionKey(userId: String, offerId: String) -> String {
        return "ai_training_session_\(userId)_\(offerId)"
    }
}
