//
//  GoogleCalendarService.swift
//  Taleb_5edma
//
//  Created by Apple on 06/12/2025.
//

import Foundation

/// Modèles et service pour la synchronisation Google Calendar.
/// Implémentation minimaliste pour permettre la compilation en attendant
/// l'intégration complète avec le backend.

// MARK: - Models

struct GoogleCalendarStatus: Codable {
    let connected: Bool
    let email: String?
    let isEnabled: Bool
}

struct SyncStats: Codable {
    let synced: Int
    let created: Int
    let updated: Int
}

struct SyncResult: Codable {
    let fromGoogle: SyncStats
    let toGoogle: SyncStats
}

enum GoogleCalendarError: LocalizedError {
    case networkError
    case invalidResponse
    case authFailed
    case notConnected
    case syncFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Erreur réseau Google Calendar"
        case .invalidResponse:
            return "Réponse invalide du service Google Calendar"
        case .authFailed:
            return "Échec d'authentification Google Calendar"
        case .notConnected:
            return "Google Calendar n'est pas connecté"
        case .syncFailed(let message):
            return "La synchronisation a échoué: \(message)"
        }
    }
}

// MARK: - Service

final class GoogleCalendarService {
    
    private let userDefaults = UserDefaults.standard
    
    // Clés de persistance locale pour simuler un état
    private enum Keys {
        static let connected = "googleCalendarConnected"
        static let email = "googleCalendarEmail"
        static let autoSync = "googleCalendarAutoSync"
    }
    
    /// Récupère le statut actuel de connexion/synchronisation.
    func getStatus() async throws -> GoogleCalendarStatus {
        let connected = userDefaults.bool(forKey: Keys.connected)
        let email = userDefaults.string(forKey: Keys.email)
        let isEnabled = userDefaults.bool(forKey: Keys.autoSync)
        
        return GoogleCalendarStatus(
            connected: connected,
            email: email,
            isEnabled: isEnabled
        )
    }
    
    /// Retourne l'URL d'authentification OAuth à ouvrir dans ASWebAuthenticationSession.
    /// À remplacer par l'URL réelle renvoyée par le backend.
    func getAuthUrl() async throws -> String {
        // URL de placeholder en attendant l'intégration backend.
        return "https://accounts.google.com/o/oauth2/v2/auth"
    }
    
    /// Finalise l'authentification avec le code obtenu via OAuth.
    /// Ici on simule une connexion réussie.
    func connect(code: String) async throws {
        guard !code.isEmpty else { throw GoogleCalendarError.authFailed }
        
        // Simulation: on considère que la connexion est réussie et on persiste l'état
        userDefaults.set(true, forKey: Keys.connected)
        userDefaults.set("user@example.com", forKey: Keys.email)
    }
    
    /// Déclenche une synchronisation bidirectionnelle simulée.
    func sync() async throws -> SyncResult {
        let isConnected = userDefaults.bool(forKey: Keys.connected)
        guard isConnected else { throw GoogleCalendarError.notConnected }
        
        // Simulation d'un résultat de synchronisation
        return SyncResult(
            fromGoogle: SyncStats(synced: 3, created: 1, updated: 1),
            toGoogle: SyncStats(synced: 2, created: 1, updated: 0)
        )
    }
    
    /// Déconnecte le compte et efface l'état local.
    func disconnect() async throws {
        userDefaults.removeObject(forKey: Keys.connected)
        userDefaults.removeObject(forKey: Keys.email)
        userDefaults.removeObject(forKey: Keys.autoSync)
    }
}

