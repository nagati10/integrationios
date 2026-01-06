//
//  MatchingService.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import Foundation
import Combine

/// Service pour gérer les opérations de matching IA
/// Communique avec le backend NestJS pour analyser les correspondances entre disponibilités et offres
class MatchingService: ObservableObject {
    // MARK: - Properties
    
    /// URL de base de l'API (configurée dans APIConfig.swift)
    private var baseURL: String {
        return APIConfig.baseURL
    }
    
    /// Session URL pour les requêtes réseau
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60.0 // Plus long pour l'IA
        configuration.timeoutIntervalForResource = 60.0
        configuration.waitsForConnectivity = true
        configuration.allowsCellularAccess = true
        return URLSession(configuration: configuration)
    }()
    
    /// Token d'authentification (récupéré depuis AuthService)
    private var authToken: String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    /// ID de l'utilisateur connecté (récupéré depuis UserDefaults)
    private var currentUserId: String? {
        guard let userData = UserDefaults.standard.data(forKey: "currentUser") else {
            return nil
        }
        // Utiliser le même decoder que dans AuthService pour la cohérence
        let decoder = makeJSONDecoder()
        if let user = try? decoder.decode(User.self, from: userData) {
            return user.id
        }
        return nil
    }
    
    // MARK: - Helper Methods
    
    /// Crée une requête avec les headers appropriés
    private func createRequest(url: URL, method: String) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = authToken else {
            throw MatchingError.notAuthenticated
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func makeJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            if let date = formatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Format de date invalide: \(dateString)"
            )
        }
        return decoder
    }
    
    // MARK: - API Methods
    
    /// Analyse le matching entre les disponibilités de l'utilisateur et les offres disponibles
    /// 
    /// - Parameters:
    ///   - disponibilites: Liste des disponibilités de l'utilisateur
    ///   - preferences: Préférences de recherche (optionnel)
    /// - Returns: Résultat du matching avec les offres correspondantes
    /// - Throws: MatchingError en cas d'erreur
    func analyzeMatching(
        disponibilites: [Disponibilite],
        preferences: MatchingRequest.MatchingPreferences? = nil
    ) async throws -> MatchingResponse {
        // Construire l'URL de l'endpoint
        guard let url = URL(string: "\(baseURL)/ai-matching/analyze") else {
            throw MatchingError.networkError
        }
        
        // Créer la requête HTTP
        var httpRequest = try createRequest(url: url, method: "POST")
        
        // Vérifier que l'utilisateur est connecté et récupérer son ID
        guard let studentId = currentUserId else {
            print("❌ Matching Analyze - Aucun utilisateur connecté")
            throw MatchingError.notAuthenticated
        }
        
        // Préparer le body de la requête
        let requestBody = MatchingRequest(
            studentId: studentId,
            disponibilites: disponibilites.map { MatchingRequest.DisponibiliteInput(from: $0) },
            preferences: preferences
        )
        
        // Encoder le body en JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let requestData = try encoder.encode(requestBody)
        httpRequest.httpBody = requestData
        
        // Log de la requête pour le débogage
        print("🔵 Matching Analyze - URL: \(url.absoluteString)")
        if let bodyString = String(data: requestData, encoding: .utf8) {
            print("🔵 Matching Analyze - Body: \(bodyString)")
        }
        print("🔵 Matching Analyze - Headers: \(httpRequest.allHTTPHeaderFields ?? [:])")
        
        do {
            // Envoyer la requête
            let (data, response) = try await session.data(for: httpRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Matching Analyze - Réponse invalide")
                throw MatchingError.invalidResponse
            }
            
            print("🔵 Matching Analyze - Status Code: \(httpResponse.statusCode)")
            
            // Log de la réponse
            if let responseString = String(data: data, encoding: .utf8) {
                print("🔵 Matching Analyze - Response: \(responseString)")
            }
            
            // Vérifier le code de statut
            guard (200...299).contains(httpResponse.statusCode) else {
                // Essayer de décoder le message d'erreur
                var errorMessage: String? = nil
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    errorMessage = json["message"] as? String ?? json["error"] as? String
                }
                
                if let message = errorMessage {
                    print("🔴 Matching Analyze - Erreur serveur: \(message)")
                    throw MatchingError.serverErrorWithMessage(message)
                }
                
                if httpResponse.statusCode == 401 {
                    throw MatchingError.notAuthenticated
                } else if httpResponse.statusCode == 400 {
                    throw MatchingError.invalidData
                }
                throw MatchingError.serverError(httpResponse.statusCode)
            }
            
            // Décoder la réponse
            let decoder = makeJSONDecoder()
            let matchingResponse = try decoder.decode(MatchingResponse.self, from: data)
            
            print("✅ Matching Analyze - Success: \(matchingResponse.matches.count) matches trouvés")
            
            return matchingResponse
            
        } catch let error as MatchingError {
            throw error
        } catch let urlError as URLError {
            print("❌ Matching Analyze - Network Error: \(urlError.localizedDescription)")
            throw MatchingError.networkError
        } catch let decodingError as DecodingError {
            print("❌ Matching Analyze - Decoding Error: \(decodingError)")
            throw MatchingError.invalidResponse
        } catch {
            print("❌ Matching Analyze - Unknown Error: \(error.localizedDescription)")
            throw MatchingError.unknownError(error.localizedDescription)
        }
    }
}

// MARK: - Matching Errors

enum MatchingError: LocalizedError {
    case invalidData
    case invalidResponse
    case serverError(Int)
    case serverErrorWithMessage(String)
    case networkError
    case notAuthenticated
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Données invalides"
        case .invalidResponse:
            return "Réponse invalide du serveur"
        case .serverError(let code):
            return "Erreur serveur: \(code)"
        case .serverErrorWithMessage(let message):
            return message
        case .networkError:
            return "Erreur de connexion réseau"
        case .notAuthenticated:
            return "Vous devez être connecté pour effectuer cette action"
        case .unknownError(let message):
            return "Erreur inconnue: \(message)"
        }
    }
}

