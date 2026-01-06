//
//  ScheduleService.swift
//  Taleb_5edma
//
//  Created by Apple on 07/12/2025.
//

import Foundation
import UIKit

/// Service pour gérer l'upload et le traitement des emplois du temps PDF
/// Communique avec le backend NestJS pour extraire les cours via IA et créer les événements
class ScheduleService {
    // MARK: - Properties
    
    /// URL de base de l'API (configurée dans APIConfig.swift)
    private var baseURL: String {
        return APIConfig.baseURL
    }
    
    /// Session URL pour les requêtes réseau
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60.0  // 60 secondes pour l'upload de fichiers
        configuration.timeoutIntervalForResource = 60.0
        configuration.waitsForConnectivity = true
        configuration.allowsCellularAccess = true
        return URLSession(configuration: configuration)
    }()
    
    /// Token d'authentification (récupéré depuis AuthService)
    private var authToken: String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    // MARK: - Helper Methods
    
    /// Crée une requête avec les headers appropriés
    private func createRequest(url: URL, method: String, requiresAuth: Bool = true) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            guard let token = authToken else {
                throw ScheduleError.notAuthenticated
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    /// Crée une requête multipart/form-data pour l'upload de fichiers
    private func createMultipartRequest(url: URL, method: String, boundary: String, requiresAuth: Bool = true) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            guard let token = authToken else {
                throw ScheduleError.notAuthenticated
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
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
    
    // MARK: - Public Methods
    
    /// Upload un PDF d'emploi du temps et extrait les cours via IA
    /// - Parameter pdfData: Les données du fichier PDF
    /// - Returns: Liste des cours extraits
    func uploadSchedulePDF(_ pdfData: Data) async throws -> [Course] {
        guard let url = URL(string: APIConfig.scheduleProcessEndpoint) else {
            throw ScheduleError.networkError
        }
        
        let boundary = UUID().uuidString
        var httpRequest = try createMultipartRequest(url: url, method: "POST", boundary: boundary, requiresAuth: false)
        
        // Construire le body multipart/form-data
        var body = Data()
        
        // Ajouter le fichier PDF
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"schedule.pdf\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)
        body.append(pdfData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Fermer le boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        httpRequest.httpBody = body
        
        // Log de la requête
        print("📄 Upload Schedule PDF - URL: \(url.absoluteString)")
        print("📄 Upload Schedule PDF - File size: \(pdfData.count) bytes")
        print("📄 Upload Schedule PDF - Headers: \(httpRequest.allHTTPHeaderFields ?? [:])")
        
        let (data, response) = try await session.data(for: httpRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ScheduleError.invalidResponse
        }
        
        print("📄 Upload Schedule PDF - Status Code: \(httpResponse.statusCode)")
        
        // Log de la réponse
        if let responseString = String(data: data, encoding: .utf8) {
            print("📄 Upload Schedule PDF - Response: \(responseString)")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Essayer de décoder le message d'erreur
            var errorMessage: String? = nil
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                errorMessage = json["message"] as? String ?? json["error"] as? String
                
                if let errors = json["errors"] as? [String: Any] {
                    let allErrors = errors.compactMap { key, value -> String? in
                        if let array = value as? [String] {
                            return "\(key): \(array.joined(separator: ", "))"
                        } else if let str = value as? String {
                            return "\(key): \(str)"
                        }
                        return nil
                    }
                    if !allErrors.isEmpty {
                        errorMessage = allErrors.joined(separator: "; ")
                    }
                } else if let errorArray = json["errors"] as? [String] {
                    errorMessage = errorArray.joined(separator: ", ")
                }
            } else if let errorString = String(data: data, encoding: .utf8) {
                errorMessage = errorString
            }
            
            if let message = errorMessage {
                print("🔴 Upload Schedule PDF - Erreur serveur: \(message)")
                if httpResponse.statusCode == 400 {
                    throw ScheduleError.invalidPDF(message)
                }
            }
            
            if httpResponse.statusCode == 401 {
                throw ScheduleError.notAuthenticated
            } else if httpResponse.statusCode == 400 {
                throw ScheduleError.invalidPDF(errorMessage ?? "PDF invalide ou illisible")
            }
            throw ScheduleError.serverError(httpResponse.statusCode)
        }
        
        let processedResponse = try makeJSONDecoder().decode(ProcessedScheduleResponse.self, from: data)
        print("✅ Upload Schedule PDF - Success: \(processedResponse.courses.count) cours extraits")
        
        return processedResponse.courses
    }
    
    /// Crée automatiquement les événements dans le calendrier à partir des cours
    /// - Parameters:
    ///   - courses: Liste des cours à créer
    ///   - weekStartDate: Date de début de semaine (optionnel, format "yyyy-MM-dd")
    /// - Returns: Réponse avec le nombre d'événements créés
    func createEventsFromSchedule(courses: [Course], weekStartDate: String? = nil) async throws -> CreateEventsResponse {
        guard let url = URL(string: APIConfig.scheduleCreateEventsEndpoint) else {
            throw ScheduleError.networkError
        }
        
        var httpRequest = try createRequest(url: url, method: "POST", requiresAuth: true)
        
        // Créer la requête
        let request = CreateEventsFromScheduleRequest(courses: courses, weekStartDate: weekStartDate)
        
        // Encoder la requête
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let requestData = try encoder.encode(request)
        httpRequest.httpBody = requestData
        
        // Log de la requête
        print("📅 Create Events From Schedule - URL: \(url.absoluteString)")
        if let bodyString = String(data: requestData, encoding: .utf8) {
            print("📅 Create Events From Schedule - Body: \(bodyString)")
        }
        print("📅 Create Events From Schedule - Headers: \(httpRequest.allHTTPHeaderFields ?? [:])")
        
        let (data, response) = try await session.data(for: httpRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ScheduleError.invalidResponse
        }
        
        print("📅 Create Events From Schedule - Status Code: \(httpResponse.statusCode)")
        
        // Log de la réponse
        if let responseString = String(data: data, encoding: .utf8) {
            print("📅 Create Events From Schedule - Response: \(responseString)")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Essayer de décoder le message d'erreur
            var errorMessage: String? = nil
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                errorMessage = json["message"] as? String ?? json["error"] as? String
            }
            
            if let message = errorMessage {
                print("🔴 Create Events From Schedule - Erreur serveur: \(message)")
                if httpResponse.statusCode == 400 {
                    throw ScheduleError.invalidData(message)
                }
            }
            
            if httpResponse.statusCode == 401 {
                throw ScheduleError.notAuthenticated
            } else if httpResponse.statusCode == 400 {
                throw ScheduleError.invalidData(errorMessage ?? "Données invalides")
            }
            throw ScheduleError.serverError(httpResponse.statusCode)
        }
        
        let createResponse = try makeJSONDecoder().decode(CreateEventsResponse.self, from: data)
        print("✅ Create Events From Schedule - Success: \(createResponse.eventsCreated) événements créés")
        
        return createResponse
    }
}

// MARK: - Schedule Errors
enum ScheduleError: LocalizedError {
    case invalidPDF(String)
    case invalidData(String)
    case invalidResponse
    case serverError(Int)
    case networkError
    case notAuthenticated
    case fileReadError
    
    var errorDescription: String? {
        switch self {
        case .invalidPDF(let message):
            return "PDF invalide: \(message)"
        case .invalidData(let message):
            return "Données invalides: \(message)"
        case .invalidResponse:
            return "Réponse invalide du serveur"
        case .serverError(let code):
            return "Erreur serveur: \(code)"
        case .networkError:
            return "Erreur de connexion réseau"
        case .notAuthenticated:
            return "Vous devez être connecté pour effectuer cette action"
        case .fileReadError:
            return "Impossible de lire le fichier PDF"
        }
    }
}

