//
//  LoginViewModel.swift
//  Taleb5edma-cursor
//
//  Created by Apple on 08/11/2025.
//

import Foundation
import SwiftUI
import Combine
import UIKit

// MARK: - LoginViewModel

/// ViewModel pour gérer la logique métier de l'authentification (login, signup, vérification)
/// Suit le pattern MVVM : sépare la logique métier de la vue
///
/// **Responsabilités:**
/// - Validation des champs de formulaire (email, mot de passe, etc.)
/// - Gestion des états de chargement et d'erreur
/// - Appels aux services d'authentification
/// - Navigation entre les différents écrans d'authentification
///
/// **Utilisation:**
/// Utilisé par `AuthCoordinatorView`, `LoginView`, `SignUpView`, et `VerificationView`
@MainActor
class LoginViewModel: ObservableObject {
    // MARK: - Published Properties (Propriétés observables par la vue)
    
    // État de connexion
    /// Adresse email pour la connexion
    @Published var email: String = ""
    
    /// Mot de passe pour la connexion
    @Published var password: String = ""
    
    /// Indique si le mot de passe doit être visible (pour toggle visibilité)
    @Published var isPasswordVisible: Bool = false
    
    // État d'inscription
    /// Adresse email pour l'inscription
    @Published var signUpEmail: String = ""
    
    /// Nom d'utilisateur pour l'inscription (correspond au champ "nom" du backend)
    @Published var signUpUsername: String = ""
    
    /// Numéro de contact pour l'inscription (correspond au champ "contact" du backend)
    @Published var signUpContactNumber: String = ""
    
    /// Mot de passe pour l'inscription
    @Published var signUpPassword: String = ""
    
    /// Confirmation du mot de passe pour l'inscription
    @Published var signUpConfirmPassword: String = ""
    
    /// Indique si le mot de passe d'inscription est visible
    @Published var isSignUpPasswordVisible: Bool = false
    
    /// Indique si la confirmation du mot de passe est visible
    @Published var isSignUpConfirmPasswordVisible: Bool = false
    
    /// Rôle sélectionné pour l'inscription ("user" ou "entreprise")
    @Published var signUpRole: String = "user"
    
    // État de vérification
    /// Code OTP saisi par l'utilisateur
    @Published var verificationCode: String = ""
    
    /// Email utilisé pour l'envoi du code de vérification
    @Published var verificationEmail: String = ""
    
    /// Numéro de téléphone masqué pour l'affichage (ex: "+216***123")
    @Published var maskedPhoneNumber: String = ""
    
    // États de l'application
    /// Indicateur de chargement pendant les opérations réseau
    @Published var isLoading: Bool = false
    
    /// Message d'erreur à afficher à l'utilisateur
    @Published var errorMessage: String?
    
    /// Indique si une alerte d'erreur doit être affichée
    @Published var showError: Bool = false
    
    // Navigation
    /// Écran d'authentification actuellement affiché
    @Published var currentScreen: AuthScreen = .login {
        didSet {
            resetLoginFields()
            resetSignUpFields()
        }
    }
    
    /// Indique si l'utilisateur est authentifié avec succès
    @Published var isAuthenticated: Bool = false
    
    // MARK: - Dependencies
    
    // Service d'authentification injecté pour réaliser les appels réseau
    var authService: AuthService
    
    // MARK: - Initialization
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    /// Initialiseur par défaut qui crée un nouveau AuthService
    /// Utilisé quand aucun AuthService n'est fourni
    convenience init() {
        self.init(authService: AuthService())
    }
    
    // MARK: - Login Methods
    
    /// Valide les champs de connexion
    func validateLoginFields() -> Bool {
        guard !email.isEmpty else {
            showError(message: "Veuillez entrer votre email")
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            showError(message: "Email invalide")
            return false
        }
        
        guard !password.isEmpty else {
            showError(message: "Veuillez entrer votre mot de passe")
            return false
        }
        
        guard password.count >= 6 else {
            showError(message: "Le mot de passe doit contenir au moins 6 caractères")
            return false
        }
        
        return true
    }
    
    /// Connecte l'utilisateur
    func login() async {
        guard validateLoginFields() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let authResponse = try await authService.login(email: email, password: password)
            // Succès - l'utilisateur est maintenant connecté
            // Vérifier que le token et l'utilisateur sont bien présents
            guard authService.authToken != nil,
                  authService.currentUser != nil else {
                showError(message: "Erreur lors de la connexion. Veuillez réessayer.")
                isLoading = false
                return
            }
            
            // Mettre à jour l'état d'authentification
            isAuthenticated = authService.isAuthenticated
            
            print("✅ Login réussi - Utilisateur: \(authResponse.user.email), Token présent: \(authService.authToken != nil)")
            print("🏢 Login - is_Organization from response: \(authResponse.user.is_Organization ?? false)")
            
            // Fetch complete user profile to get is_Organization and other fields
            // The login response might not include all user fields
            Task {
                do {
                    let fullProfile = try await authService.getUserProfile()
                    print("✅ Profile complet récupéré - is_Organization: \(fullProfile.is_Organization ?? false)")
                } catch {
                    print("⚠️ Erreur lors de la récupération du profil: \(error.localizedDescription)")
                }
            }
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - Sign Up Methods
    
    /// Valide les champs d'inscription
    func validateSignUpFields() -> Bool {
        guard !signUpEmail.isEmpty else {
            showError(message: "Veuillez entrer votre email")
            return false
        }
        
        guard signUpEmail.contains("@") && signUpEmail.contains(".") else {
            showError(message: "Email invalide")
            return false
        }
        
        guard !signUpUsername.isEmpty else {
            showError(message: "Veuillez entrer un nom d'utilisateur")
            return false
        }
        
        guard signUpUsername.count >= 3 else {
            showError(message: "Le nom d'utilisateur doit contenir au moins 3 caractères")
            return false
        }
        
        guard !signUpContactNumber.isEmpty else {
            showError(message: "Veuillez entrer votre numéro de téléphone")
            return false
        }
        
        guard !signUpPassword.isEmpty else {
            showError(message: "Veuillez entrer un mot de passe")
            return false
        }
        
        guard signUpPassword.count >= 6 else {
            showError(message: "Le mot de passe doit contenir au moins 6 caractères")
            return false
        }
        
        guard signUpPassword == signUpConfirmPassword else {
            showError(message: "Les mots de passe ne correspondent pas")
            return false
        }
        
        return true
    }
    
    /// Inscrit un nouvel utilisateur
    func signUp() async {
        guard validateSignUpFields() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // ⚠️ Le backend attend "nom" au lieu de "username" et "contact" au lieu de "contactNumber"
            let request = SignUpRequest(
                nom: signUpUsername,  // Le champ "nom" correspond au nom d'utilisateur
                email: signUpEmail,
                password: signUpPassword,
                contact: signUpContactNumber,  // Le champ "contact" correspond au numéro de téléphone
                role: "user",                  // On force le rôle "user" pour passer la validation backend
                is_Organization: signUpRole == "entreprise", // On utilise ce champ pour les entreprises
                image: nil  // Optionnel
            )
            
            _ = try await authService.signUp(request)
            
            // Après inscription réussie, l'utilisateur est automatiquement connecté
            isAuthenticated = authService.isAuthenticated
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - Verification Methods (Stub - Non implémenté dans le backend actuel)
    
    /// Envoie le code de vérification
    /// ⚠️ Cette fonctionnalité n'est pas encore disponible dans le backend
    func sendVerificationCode() async {
        showError(message: "La vérification par code n'est pas encore disponible. L'inscription vous connecte automatiquement.")
    }
    
    /// Vérifie le code de vérification
    /// ⚠️ Cette fonctionnalité n'est pas encore disponible dans le backend
    func verifyCode() async {
        showError(message: "La vérification par code n'est pas encore disponible. L'inscription vous connecte automatiquement.")
    }
    
    // MARK: - Helper Methods
    
    /// Masque le numéro de téléphone pour l'affichage
    private func maskPhoneNumber(_ number: String) -> String {
        guard number.count > 4 else { return number }
        let prefix = String(number.prefix(3))
        let suffix = String(number.suffix(3))
        let masked = String(repeating: "*", count: number.count - 6)
        return "+\(prefix)\(masked)\(suffix)"
    }
    
    /// Affiche une erreur
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    /// Gère les erreurs
    private func handleError(_ error: Error) {
        if let authError = error as? AuthError {
            errorMessage = authError.errorDescription
        } else {
            errorMessage = error.localizedDescription
        }
        showError = true
    }
    
    /// Réinitialise les champs de connexion
    func resetLoginFields() {
        email = ""
        password = ""
        errorMessage = nil
        showError = false
    }
    
    /// Réinitialise les champs d'inscription
    func resetSignUpFields() {
        signUpEmail = ""
        signUpUsername = ""
        signUpContactNumber = ""
        signUpPassword = ""
        signUpConfirmPassword = ""
        signUpRole = "user"
        errorMessage = nil
        showError = false
    }
    
    // MARK: - Google Sign-In Methods
    
    /// Connecte l'utilisateur avec Google
    /// - Parameter presentingViewController: Le ViewController qui présente la vue
}

// MARK: - Auth Screen Enum
enum AuthScreen {
    case login
    case signUp
    case verification
}
