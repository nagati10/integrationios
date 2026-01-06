
//  AuthCoordinatorView.swift
//  Taleb5edma-cursor
//
//  Created by Apple on 08/11/2025.
//

import SwiftUI

/// Vue coordinatrice qui gère la navigation entre les écrans d'authentification
struct AuthCoordinatorView: View {
    @EnvironmentObject var authService: AuthService
    // Le ViewModel pilote la navigation entre les écrans d'authentification
    @StateObject private var viewModel: LoginViewModel
    
    init() {
        // Initialisation temporaire, sera remplacée par environmentObject
        _viewModel = StateObject(wrappedValue: LoginViewModel())
    }
    
    var body: some View {
        Group {
            switch viewModel.currentScreen {
            case .login:
                LoginView(viewModel: viewModel)
            case .signUp:
                SignUpView(viewModel: viewModel)
            case .verification:
                VerificationView(viewModel: viewModel)
            }
        }
        .onAppear {
            // Injection sécurisée du service d'authentification
            if viewModel.authService !== authService {
                viewModel.authService = authService
            }
        }
        .alert("Erreur", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Une erreur est survenue")
        }
    }
}

#Preview {
    AuthCoordinatorView()
}
