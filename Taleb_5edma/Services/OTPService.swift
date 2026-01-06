//
//  OTPService.swift
//  Taleb_5edma
//
//  Created for OTP email sending functionality
//

import Foundation
import Combine

/// Service pour gérer l'envoi d'OTP par email via EmailJS
class OTPService: ObservableObject {
    
    // MARK: - Properties
    
    /// Mode test - si true, simule l'envoi sans faire de vraie requête
    var testMode: Bool = true
    
    /// Configuration EmailJS
    private let emailJSEndpoint = "https://api.emailjs.com/api/v1.0/email/send"
    private let serviceId = "service_3gjaqxq"
    private let templateId = "template_nl0r1z6"
    private let userId = "2z8qOtomdqeaLx0uB"
    
    // MARK: - OTP Generation
    
    /// Génère un code OTP à 4 chiffres
    func generateOTP() -> String {
        return String(format: "%04d", Int.random(in: 1000...9999))
    }
    
    /// Calcule le temps d'expiration (15 minutes à partir de maintenant)
    func getExpiryTime() -> String {
        let calendar = Calendar.current
        guard let expiryDate = calendar.date(byAdding: .minute, value: 15, to: Date()) else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: expiryDate)
    }
    
    // MARK: - OTP Storage
    
    /// Sauvegarde l'OTP localement
    func saveOTPLocally(_ otp: String) {
        UserDefaults.standard.set(otp, forKey: "forgotPasswordOTP")
        print("💾 OTP sauvegardé localement: \(otp)")
    }
    
    /// Récupère l'OTP sauvegardé localement
    func getSavedOTP() -> String? {
        return UserDefaults.standard.string(forKey: "forgotPasswordOTP")
    }
    
    /// Supprime l'OTP sauvegardé
    func clearSavedOTP() {
        UserDefaults.standard.removeObject(forKey: "forgotPasswordOTP")
    }
    
    /// Sauvegarde l'email localement
    func saveEmailLocally(_ email: String) {
        UserDefaults.standard.set(email, forKey: "forgotPasswordEmail")
        print("💾 Email sauvegardé localement: \(email)")
    }
    
    /// Récupère l'email sauvegardé localement
    func getSavedEmail() -> String? {
        return UserDefaults.standard.string(forKey: "forgotPasswordEmail")
    }
    
    /// Supprime l'email sauvegardé
    func clearSavedEmail() {
        UserDefaults.standard.removeObject(forKey: "forgotPasswordEmail")
    }
    
    // MARK: - Send OTP
    
    /// Envoie un OTP par email
    /// - Parameters:
    ///   - email: L'adresse email du destinataire
    ///   - completion: Callback avec le résultat (succès ou erreur)
    func sendOTPEmail(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let otp = generateOTP()
        let expiryTime = getExpiryTime()
        
        print("🟣 sendOTPEmail: Starting with email: \(email)")
        print("🟣 Generated OTP: \(otp)")
        print("🟣 Test Mode: \(testMode)")
        
        // Sauvegarder localement
        saveOTPLocally(otp)
        saveEmailLocally(email)
        
        if testMode {
            print("🟡 TEST MODE - Simulating OTP send to \(email)")
            // Simuler un délai de 2 secondes
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                print("🟢 TEST MODE - Success (simulated)")
                completion(.success(()))
            }
        } else {
            sendRealOTPEmail(email: email, otp: otp, expiryTime: expiryTime, completion: completion)
        }
    }
    
    /// Envoie réellement l'OTP via EmailJS API
    private func sendRealOTPEmail(email: String, otp: String, expiryTime: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("🔵 REAL MODE - Sending actual OTP to \(email)")
        
        guard let url = URL(string: emailJSEndpoint) else {
            completion(.failure(OTPError.invalidURL))
            return
        }
        
        // Préparer le body JSON
        let requestBody: [String: Any] = [
            "service_id": serviceId,
            "template_id": templateId,
            "user_id": userId,
            "template_params": [
                "to_send": email,
                "passcode": otp,
                "time": expiryTime
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(OTPError.jsonEncodingError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("🔴 REAL MODE - Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(OTPError.networkError(error.localizedDescription)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("🔴 REAL MODE - Invalid response")
                DispatchQueue.main.async {
                    completion(.failure(OTPError.invalidResponse))
                }
                return
            }
            
            print("🔵 HTTP Status: \(httpResponse.statusCode)")
            
            let statusCode = httpResponse.statusCode
            let responseString = String(data: data ?? Data(), encoding: .utf8) ?? ""
            print("🔵 REAL MODE - Response: \(responseString)")
            
            // Vérifier le succès
            let success = (200...299).contains(statusCode) ||
                         responseString.contains("\"status\":\"success\"") ||
                         responseString.contains("\"status\":200") ||
                         responseString.contains("200") ||
                         responseString.contains("OK")
            
            if success {
                print("🟢 REAL MODE - Email sent successfully")
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } else {
                print("🔴 REAL MODE - Email failed. Response: \(responseString)")
                DispatchQueue.main.async {
                    completion(.failure(OTPError.emailSendFailed(responseString)))
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Verify OTP
    
    /// Vérifie si le code OTP entré correspond à celui sauvegardé
    func verifyOTP(_ enteredOTP: String) -> Bool {
        guard let savedOTP = getSavedOTP() else {
            print("⚠️ Aucun OTP sauvegardé")
            return false
        }
        
        let isValid = enteredOTP == savedOTP
        print("🔍 Vérification OTP: \(enteredOTP) == \(savedOTP) ? \(isValid)")
        return isValid
    }
    
    /// Valide un OTP pour un email donné (méthode async pour OTPVerificationViewModel)
    func validateOTP(_ code: String, for email: String) async throws {
        guard let savedEmail = getSavedEmail(), savedEmail == email else {
            throw OTPError.invalidResponse
        }
        
        guard verifyOTP(code) else {
            throw OTPError.invalidResponse
        }
    }
    
    /// Demande un nouveau OTP pour un email (méthode async pour OTPVerificationViewModel)
    func requestOTP(for email: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            sendOTPEmail(email: email) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - OTP Errors

/// Erreurs possibles lors de l'envoi ou de la vérification d'OTP
public enum OTPError: LocalizedError {
    case invalidURL
    case jsonEncodingError
    case networkError(String)
    case invalidResponse
    case emailSendFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL invalide"
        case .jsonEncodingError:
            return "Erreur d'encodage JSON"
        case .networkError(let message):
            return "Erreur réseau: \(message)"
        case .invalidResponse:
            return "Réponse invalide du serveur"
        case .emailSendFailed(let message):
            return "Échec de l'envoi de l'email: \(message)"
        }
    }
}
