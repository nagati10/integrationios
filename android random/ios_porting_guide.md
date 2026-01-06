# iOS Porting Guide: AI Interview System

This document outlines the complete logic and implementation details required to replicate the AI Interview feature on the iOS version of the app.

## 📱 1. The Full User Scenario (The Story)

### **Phase 1: Pre-Interview (Chat Screen)**
1.  **Student** applies for an offer.
2.  **Student** and **Enterprise** (Recruiter) chat in the `ChatScreen`.
3.  **Enterprise** decides to interview the student and clicks the "Accept" button.
4.  Once accepted, an **AI Icon** appears in the top bar for both users.

### **Phase 2: The Invitation (The Trigger)**
*   **Student Logic**: If the Student clicks the AI Icon, they go directly to "Coaching Mode" (Practice).
*   **Enterprise Logic**: If the Enterprise clicks the AI Icon, a dialog appears: "Send Interview Invitation?".
    *   **Action**: Enterprise clicks "Send".
    *   **System**: Sends an invitation via API/WebSocket.
    *   **Student UI**: A popup appears on the Student's screen: "You have been invited to an AI Interview. Accept?".
    *   **Action**: Student clicks "Accept".
    *   **Result**: Student is navigated to the `AiInterviewScreen` in **"Interview Mode"**.

### **Phase 3: The Interview (AiInterviewScreen)**
1.  **Visuals**: The screen looks like a voice call UI.
2.  **Timer**: A **10-minute countdown timer** appears at the top (e.g., "09:59").
    *   It auto-starts immediately.
    *   Color changes to RED when < 2 minutes remain.
3.  **Interaction**:
    *   **AI (Voice)**: "Hello [Name], I see you applied for [Position] at [Company]. Tell me about yourself." (Uses TTS).
    *   **Student (Voice)**: Speaks their answer.
    *   **AI**: Analyzes text, responds, and asks the next question.
4.  **Completion**:
    *   **Scenario A**: Timer hits `00:00`.
    *   **Scenario B**: Student clicks "End Interview" or "Back".
    *   **Action**: The app **silently triggers the Analysis API** in the background and closes the screen.

### **Phase 4: The Results (Chat Screen)**
1.  Student is returned to the `ChatScreen`.
2.  **Magic Moment**: A few seconds later, a new message bubble appears from the Student (sent automatically).
3.  **The Bubble**: It's a "Summary Card" showing:
    *   Overall Score (e.g., 85/100).
    *   Recommendation (HIRE / NO_HIRE).
    *   Key Strengths.
4.  **Visibility Rule**: **Only the Enterprise sees this bubble.** The Student does NOT see their own evaluation.
5.  **Details**: Enterprise taps the bubble → Full screen dialog opens with detailed question-by-question feedback.

---

## 🛠 2. Technical Implementation Steps

### **Step 1: Data Models**
You need equivalent Swift structs for these JSON objects.

**1. Interview Analysis Data (Embedded in Chat Message)**
```json
{
  "type": "interview_result",
  "interviewAnalysis": {
    "candidateName": "John Doe",
    "position": "iOS Developer",
    "completionPercentage": 100,
    "overallScore": 85,
    "strengths": ["Clear communication", "Technical depth"],
    "weaknesses": ["Talks too fast"],
    "recommendation": "HIRE",
    "summary": "Candidate showed strong skills...",
    "interviewDuration": "3 exchanges",
    "questionAnalysis": [
      {
        "question": "Tell me about yourself",
        "answer": "I am a...",
        "score": 8,
        "feedback": "Good intro."
      }
    ]
  }
}
```

### **Step 2: API Integration (Python Backend)**

**Endpoint**: `POST https://your-python-backend.com/api/analyze-interview`

**Payload to Send (when interview ends):**
```json
{
  "session_id": "unique_session_id",
  "chat_id": "current_chat_id", 
  "duration_seconds": 600,
  "user_details": {
    "name": "Student Name",
    "id": "student_id"
  },
  "offer_details": {
    "company": "Company Name",
    "position": "Job Title"
  }
}
```

**What Happens:**
1.  iOS sends this request on interview end.
2.  Python backend fetches chat history from its database.
3.  Python sends prompt to Gemini AI.
4.  Python gets JSON result.
5.  Python forwards result to **NestJS Backend**.
6.  NestJS saves it as a chat message.

### **Step 3: UI Rules (Critical)**

#### **A. The Timer**
*   **Must** start automatically.
*   **Must** trigger the API call even if user exits early.
*   *Swift Tip*: Use `DispatchQueue.global().async` to ensure the API call survives the view controller dismissal.

#### **B. The Result Bubble (Chat Function)**
*   **Logic**:
    ```swift
    if message.type == .interviewResult {
        if isCurrentUserSender { // Current user is Student
            return nil // Hide view, return height 0
        } else { // Current user is Enterprise
            return InterviewResultCell(message: message)
        }
    }
    ```
*   **Alignment**: Align to the **Left** (Received side).

#### **C. The Full Details View**
*   Create a modal view controller that parses the `questionAnalysis` array.
*   Show specific colors for scores:
    *   **Green**: Score >= 70 or "HIRE"
    *   **Red**: Score < 50 or "NO_HIRE"

## 🤖 3. The "Secret Sauce" (AI Tuning)

**You don't need to do this on iOS**, but know that the Python backend has been tuned with these rules:
1.  **Strict Scoring**: Unprofessional/short answers get a score < 40.
2.  **Format**: The AI returns **Strict JSON** only.

## ✅ Checklist for iOS Developer
1.  [ ] Add "AI Icon" to Chat Navigation Bar (visible if `isAccepted == true`).
2.  [ ] Implement `InterviewInvitation` popup handling.
3.  [ ] Build `AiInterviewViewController`:
    *   [ ] Add 10-minute countdown logic.
    *   [ ] Add `triggerAnalysis()` function that calls the Python API.
    *   [ ] Call `triggerAnalysis()` on `viewWillDisappear` or Timer finish.
4.  [ ] Update `ChatViewController`:
    *   [ ] Handle `INTERVIEW_RESULT` message type.
    *   [ ] **Hide** the cell if `currentUser.id == message.senderId` (Student).
    *   [ ] **Show** the cell if `currentUser.id != message.senderId` (Enterprise).
    *   [ ] Add tap gesture to open "Detailed Analysis" modal.
5.  [ ] Test with a "bad" interview to verify low scores!
