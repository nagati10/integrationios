//
//  EnhancedRoutineService.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import Foundation
import Combine

/// Service pour gérer l'analyse de routine améliorée
class EnhancedRoutineService {
    // MARK: - Properties
    
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60.0
        configuration.timeoutIntervalForResource = 60.0
        configuration.waitsForConnectivity = true
        configuration.allowsCellularAccess = true
        return URLSession(configuration: configuration)
    }()
    
    private var authToken: String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    // MARK: - Cache
    
    private let cacheKey = "enhanced_routine_analysis_cache"
    
    /// Sauvegarde l'analyse dans le cache
    private func saveToCache(_ response: EnhancedRoutineAnalysisResponse) {
        let cached = CachedRoutineAnalysis(data: response, timestamp: Date())
        if let encoded = try? JSONEncoder().encode(cached) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
            print("💾 Analyse sauvegardée dans le cache")
        }
    }
    
    /// Récupère l'analyse depuis le cache
    func loadFromCache() -> EnhancedRoutineAnalysisResponse? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let cached = try? JSONDecoder().decode(CachedRoutineAnalysis.self, from: data) else {
            return nil
        }
        
        if cached.isValid {
            print("✅ Cache valide - Utilisation des données en cache")
            return cached.data
        } else {
            print("⚠️ Cache expiré")
            return nil
        }
    }
    
    /// Vide le cache
    func clearCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        print("🗑️ Cache vidé")
    }
    
    // MARK: - API Methods
    
    /// Analyse la routine de l'utilisateur avec l'IA améliorée
    func analyzeRoutineEnhanced(
        evenements: [Evenement],
        disponibilites: [Disponibilite],
        dateDebut: String,
        dateFin: String
    ) async throws -> EnhancedRoutineAnalysisResponse {
        // Vérifier l'authentification
        guard let token = authToken else {
            throw RoutineServiceError.notAuthenticated
        }
        
        // Construire l'URL
        guard let url = URL(string: APIConfig.analyzeRoutineEnhancedEndpoint) else {
            throw RoutineServiceError.invalidURL
        }
        
        // Créer la requête
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Préparer le body
        let requestBody = EnhancedRoutineAnalysisRequest(
            evenements: evenements.map { event in
                EnhancedRoutineAnalysisRequest.EvenementInput(
                    id: event.id,
                    titre: event.titre,
                    type: event.type,
                    date: event.date,
                    heureDebut: event.heureDebut,
                    heureFin: event.heureFin
                )
            },
            disponibilites: disponibilites.map { dispo in
                EnhancedRoutineAnalysisRequest.DisponibiliteInput(
                    id: dispo.id,
                    jour: dispo.jour,
                    heureDebut: dispo.heureDebut,
                    heureFin: dispo.heureFin ?? "23:59"
                )
            },
            dateDebut: dateDebut,
            dateFin: dateFin
        )
        
        // Encoder le body
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        request.httpBody = try encoder.encode(requestBody)
        
        // Log de la requête
        print("🔵 Enhanced Routine Analyze - URL: \(url.absoluteString)")
        print("🔵 Enhanced Routine Analyze - Compte: \(evenements.count) événements / \(disponibilites.count) disponibilités")
        if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
            print("🔵 Enhanced Routine Analyze - Payload JSON:\n\(bodyString)")
        }
        
        do {
            // Envoyer la requête
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Enhanced Routine Analyze - Réponse invalide")
                throw RoutineServiceError.invalidResponse
            }
            
            print("🔵 Enhanced Routine Analyze - Status Code: \(httpResponse.statusCode)")
            
            // Log de la réponse
            if let responseString = String(data: data, encoding: .utf8) {
                print("🔵 Enhanced Routine Analyze - Response: \(responseString)")
            }
            
            // Vérifier le code de statut
            guard (200...299).contains(httpResponse.statusCode) else {
                // Essayer de décoder le message d'erreur
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["message"] as? String {
                    print("🔴 Enhanced Routine Analyze - Erreur serveur: \(message)")
                    throw RoutineServiceError.serverErrorWithMessage(message)
                }
                
                if httpResponse.statusCode == 401 {
                    throw RoutineServiceError.notAuthenticated
                }
                throw RoutineServiceError.serverError(httpResponse.statusCode)
            }
            
            // Décoder la réponse
            let decoder = JSONDecoder()
            let analysisResponse = try decoder.decode(EnhancedRoutineAnalysisResponse.self, from: data)
            
            // Sauvegarder dans le cache
            saveToCache(analysisResponse)
            
            print("✅ Enhanced Routine Analyze - Success: Score = \(analysisResponse.data.scoreEquilibre)")
            
            return analysisResponse
            
        } catch let error as RoutineServiceError {
            throw error
        } catch let urlError as URLError {
            print("❌ Enhanced Routine Analyze - Network Error: \(urlError.localizedDescription)")
            throw RoutineServiceError.networkError
        } catch let decodingError as DecodingError {
            print("❌ Enhanced Routine Analyze - Decoding Error: \(decodingError)")
            throw RoutineServiceError.decodingError
        } catch {
            print("❌ Enhanced Routine Analyze - Unknown Error: \(error.localizedDescription)")
            throw RoutineServiceError.unknownError(error.localizedDescription)
        }
    }
}

// MARK: - Errors

enum RoutineServiceError: LocalizedError {
    case notAuthenticated
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case serverErrorWithMessage(String)
    case networkError
    case decodingError
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Vous devez être connecté pour effectuer cette action"
        case .invalidURL:
            return "URL invalide"
        case .invalidResponse:
            return "Réponse invalide du serveur"
        case .serverError(let code):
            return "Erreur serveur: \(code)"
        case .serverErrorWithMessage(let message):
            return message
        case .networkError:
            return "Erreur de connexion réseau"
        case .decodingError:
            return "Erreur de décodage des données"
        case .unknownError(let message):
            return "Erreur inconnue: \(message)"
        }
    }
}

