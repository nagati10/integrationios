//
//  GoogleCalendarViewModel.swift
//  Taleb_5edma
//
//  Created by Apple on 16/11/2025.
//

import Foundation
import SwiftUI
import AuthenticationServices
import UIKit
import Combine

/// ViewModel pour gérer la logique de synchronisation Google Calendar
@MainActor
class GoogleCalendarViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    /// Indique si Google Calendar est connecté
    @Published var isConnected: Bool = false
    
    /// Email du compte Google connecté
    @Published var email: String?
    
    /// Indique si la synchronisation est en cours
    @Published var isSyncing: Bool = false
    
    /// Indique si la synchronisation automatique est activée
    @Published var isAutoSyncEnabled: Bool = false
    
    /// Message d'erreur
    @Published var errorMessage: String?
    
    /// Indique si une alerte d'erreur doit être affichée
    @Published var showError: Bool = false
    
    /// Résultat de la dernière synchronisation
    @Published var lastSyncResult: SyncResult?
    
    /// Indique si le chargement du statut est en cours
    @Published var isLoadingStatus: Bool = false
    
    // MARK: - Dependencies
    
    private let googleCalendarService: GoogleCalendarService
    
    // MARK: - Initialization
    
    init(googleCalendarService: GoogleCalendarService = GoogleCalendarService()) {
        self.googleCalendarService = googleCalendarService
        super.init()
        
        // Charger la préférence de synchronisation automatique sur le main actor
        let savedAutoSync = UserDefaults.standard.bool(forKey: "googleCalendarAutoSync")
        
        // Initialiser les propriétés @Published sur le main actor
        Task { @MainActor [weak self] in
            self?.isAutoSyncEnabled = savedAutoSync
            await self?.loadStatus()
        }
    }
    
    // MARK: - Public Methods
    
    /// Charge le statut de connexion Google Calendar
    func loadStatus() async {
        isLoadingStatus = true
        errorMessage = nil
        
        do {
            let status = try await googleCalendarService.getStatus()
            isConnected = status.connected
            email = status.email
            isAutoSyncEnabled = status.isEnabled
            
            // Sauvegarder la préférence
            UserDefaults.standard.set(status.isEnabled, forKey: "googleCalendarAutoSync")
            
            print("✅ Google Calendar - Statut chargé: connected=\(status.connected), email=\(status.email ?? "nil")")
        } catch {
            print("⚠️ Google Calendar - Erreur lors du chargement du statut: \(error.localizedDescription)")
            // En cas d'erreur, on considère que ce n'est pas connecté
            isConnected = false
            email = nil
        }
        
        isLoadingStatus = false
    }
    
    /// Connecte Google Calendar via OAuth
    func connect() async {
        errorMessage = nil
        
        do {
            // 1. Obtenir l'URL d'authentification
            let authUrl = try await googleCalendarService.getAuthUrl()
            print("🔵 Google Calendar - Auth URL obtenue: \(authUrl)")
            
            // 2. Ouvrir Safari avec ASWebAuthenticationSession
            guard let url = URL(string: authUrl) else {
                throw GoogleCalendarError.networkError
            }
            
            // Utiliser ASWebAuthenticationSession pour l'OAuth flow
            let callbackUrlScheme = "taleb5edma"
            
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: callbackUrlScheme
            ) { [weak self] callbackURL, error in
                Task { @MainActor in
                    if let error = error {
                        // L'utilisateur a annulé ou une erreur s'est produite
                        if let authError = error as? ASWebAuthenticationSessionError,
                           authError.code == .canceledLogin {
                            print("⚠️ Google Calendar - Connexion annulée par l'utilisateur")
                            self?.errorMessage = "Connexion annulée"
                            self?.showError = true
                        } else {
                            print("❌ Google Calendar - Erreur OAuth: \(error.localizedDescription)")
                            self?.errorMessage = "Erreur lors de la connexion: \(error.localizedDescription)"
                            self?.showError = true
                        }
                        return
                    }
                    
                    guard let callbackURL = callbackURL else {
                        print("❌ Google Calendar - Pas de callback URL")
                        self?.errorMessage = "Erreur lors de la connexion"
                        self?.showError = true
                        return
                    }
                    
                    // Extraire le code depuis l'URL de callback
                    // Format attendu: taleb5edma://google-calendar-callback?code=XXX
                    guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                          let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                        print("❌ Google Calendar - Code OAuth non trouvé dans l'URL")
                        self?.errorMessage = "Code d'autorisation non trouvé"
                        self?.showError = true
                        return
                    }
                    
                    print("✅ Google Calendar - Code OAuth reçu: \(code.prefix(20))...")
                    
                    // 3. Appeler connect(code:) avec le code
                    do {
                        try await self?.googleCalendarService.connect(code: code)
                        print("✅ Google Calendar - Connecté avec succès")
                        
                        // Recharger le statut
                        await self?.loadStatus()
                    } catch {
                        print("❌ Google Calendar - Erreur lors de la connexion: \(error.localizedDescription)")
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                }
            }
            
            // Configurer la présentation
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            
            // Démarrer la session
            if !session.start() {
                errorMessage = "Impossible de démarrer la session d'authentification"
                showError = true
            }
            
        } catch {
            print("❌ Google Calendar - Erreur lors de la connexion: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    /// Synchronise les événements avec Google Calendar
    func sync() async {
        guard isConnected else {
            errorMessage = "Google Calendar n'est pas connecté"
            showError = true
            return
        }
        
        isSyncing = true
        errorMessage = nil
        
        do {
            let result = try await googleCalendarService.sync()
            lastSyncResult = result
            
            print("✅ Google Calendar - Synchronisation réussie")
            print("   From Google: \(result.fromGoogle.synced) synced, \(result.fromGoogle.created) created, \(result.fromGoogle.updated) updated")
            print("   To Google: \(result.toGoogle.synced) synced, \(result.toGoogle.created) created, \(result.toGoogle.updated) updated")
        } catch {
            print("❌ Google Calendar - Erreur lors de la synchronisation: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isSyncing = false
    }
    
    /// Déconnecte Google Calendar
    func disconnect() async {
        errorMessage = nil
        
        do {
            try await googleCalendarService.disconnect()
            isConnected = false
            email = nil
            isAutoSyncEnabled = false
            lastSyncResult = nil
            
            // Supprimer la préférence
            UserDefaults.standard.removeObject(forKey: "googleCalendarAutoSync")
            
            print("✅ Google Calendar - Déconnecté avec succès")
        } catch {
            print("❌ Google Calendar - Erreur lors de la déconnexion: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    /// Active ou désactive la synchronisation automatique
    func toggleAutoSync() {
        isAutoSyncEnabled.toggle()
        UserDefaults.standard.set(isAutoSyncEnabled, forKey: "googleCalendarAutoSync")
        
        // TODO: Envoyer la préférence au backend si nécessaire
        // await googleCalendarService.updateAutoSync(isEnabled: isAutoSyncEnabled)
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
extension GoogleCalendarViewModel: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Retourner la fenêtre principale de l'application
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
    }
}
