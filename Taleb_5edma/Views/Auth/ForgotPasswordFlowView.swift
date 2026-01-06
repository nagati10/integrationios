//
//  ForgotPasswordFlowView.swift
//  Taleb_5edma
//
//  Created for forgot password flow with OTP verification
//

import SwiftUI

/// Vue principale pour le flux de réinitialisation de mot de passe
struct ForgotPasswordFlowView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authService: AuthService
    @StateObject private var otpService = OTPService()
    
    @State private var currentStep: ForgotPasswordStep = .enterEmail
    @State private var email: String = ""
    @State private var otp: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showError: Bool = false
    
    enum ForgotPasswordStep {
        case enterEmail
        case verifyOTP
        case resetPassword
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.redGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        AuthHeaderView()
                            .padding(.top, 40)
                            .padding(.bottom, 40)
                        
                        AuthCardView {
                            VStack(spacing: 30) {
                                // Titre selon l'étape
                                titleSection
                                
                                // Contenu selon l'étape
                                switch currentStep {
                                case .enterEmail:
                                    enterEmailView
                                case .verifyOTP:
                                    verifyOTPView
                                case .resetPassword:
                                    resetPasswordView
                                }
                            }
                            .padding(.vertical, 30)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .alert("Erreur", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Une erreur est survenue")
            }
        }
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        VStack(spacing: 12) {
            Text(titleText)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColors.black)
            
            Text(subtitleText)
                .font(.system(size: 14))
                .foregroundColor(AppColors.mediumGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.bottom, 20)
    }
    
    private var titleText: String {
        switch currentStep {
        case .enterEmail:
            return "Mot de passe oublié"
        case .verifyOTP:
            return "Vérification"
        case .resetPassword:
            return "Nouveau mot de passe"
        }
    }
    
    private var subtitleText: String {
        switch currentStep {
        case .enterEmail:
            return "Entrez votre adresse email pour recevoir un code de vérification"
        case .verifyOTP:
            return "Entrez le code à 4 chiffres envoyé à \(email)"
        case .resetPassword:
            return "Créez un nouveau mot de passe sécurisé"
        }
    }
    
    // MARK: - Enter Email View
    
    private var enterEmailView: some View {
        VStack(spacing: 25) {
            CustomTextField(
                placeholder: "Entrez votre email",
                text: $email,
                isPasswordVisible: .constant(false),
                keyboardType: .emailAddress
            )
            .padding(.horizontal, 24)
            
            GradientButton(
                title: "Envoyer le code",
                action: {
                    sendOTP()
                },
                isLoading: isLoading
            )
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Verify OTP View
    
    private var verifyOTPView: some View {
        VStack(spacing: 25) {
            OTPInputView(otp: $otp)
                .padding(.horizontal, 24)
            
            HStack {
                Text("Vous n'avez pas reçu le code ?")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.mediumGray)
                
                Button("Renvoyer") {
                    sendOTP()
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryRed)
            }
            .padding(.horizontal, 24)
            
            GradientButton(
                title: "Vérifier",
                action: {
                    verifyOTP()
                },
                isLoading: isLoading
            )
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Reset Password View
    
    private var resetPasswordView: some View {
        VStack(spacing: 25) {
            CustomTextField(
                placeholder: "Nouveau mot de passe",
                text: $newPassword,
                isPasswordVisible: $isPasswordVisible,
                isSecure: true,
                showPasswordToggle: true
            )
            .padding(.horizontal, 24)
            
            CustomTextField(
                placeholder: "Confirmer le mot de passe",
                text: $confirmPassword,
                isPasswordVisible: $isConfirmPasswordVisible,
                isSecure: true,
                showPasswordToggle: true
            )
            .padding(.horizontal, 24)
            
            GradientButton(
                title: "Réinitialiser",
                action: {
                    resetPassword()
                },
                isLoading: isLoading
            )
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Actions
    
    private func sendOTP() {
        guard !email.isEmpty else {
            showError(message: "Veuillez entrer votre adresse email")
            return
        }
        
        guard email.isValidEmail() else {
            showError(message: "Veuillez entrer une adresse email valide")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        otpService.sendOTPEmail(email: email) { result in
            Task { @MainActor in
                isLoading = false
                
                switch result {
                case .success:
                    withAnimation {
                        currentStep = .verifyOTP
                    }
                case .failure(let error):
                    showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func verifyOTP() {
        guard otp.count == 4 else {
            showError(message: "Veuillez entrer un code à 4 chiffres")
            return
        }
        
        if otpService.verifyOTP(otp) {
            withAnimation {
                currentStep = .resetPassword
            }
        } else {
            showError(message: "Code incorrect. Veuillez réessayer.")
        }
    }
    
    private func resetPassword() {
        guard !newPassword.isEmpty else {
            showError(message: "Veuillez entrer un nouveau mot de passe")
            return
        }
        
        guard newPassword.count >= 6 else {
            showError(message: "Le mot de passe doit contenir au moins 6 caractères")
            return
        }
        
        guard newPassword == confirmPassword else {
            showError(message: "Les mots de passe ne correspondent pas")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                guard let savedEmail = otpService.getSavedEmail() else {
                    await MainActor.run {
                        isLoading = false
                        showError(message: "Email non trouvé. Veuillez recommencer.")
                    }
                    return
                }
                
                // Appeler l'API pour réinitialiser le mot de passe
                try await authService.resetPassword(email: savedEmail, newPassword: newPassword)
                
                await MainActor.run {
                    isLoading = false
                    // Nettoyer les données locales
                    otpService.clearSavedOTP()
                    otpService.clearSavedEmail()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - OTP Input View

struct OTPInputView: View {
    @Binding var otp: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            // TextField caché pour la saisie
            TextField("", text: $otp)
                .keyboardType(.numberPad)
                .focused($isFocused)
                .opacity(0)
                .frame(width: 1, height: 1)
            
            // Affichage visuel des digits
            HStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { index in
                    OTPDigitView(
                        digit: index < otp.count ? String(otp[otp.index(otp.startIndex, offsetBy: index)]) : "",
                        isFocused: isFocused && index == otp.count
                    )
                }
            }
        }
        .onChange(of: otp) { oldValue, newValue in
            // Limiter à 4 chiffres
            if newValue.count > 4 {
                otp = String(newValue.prefix(4))
            }
            // Filtrer pour ne garder que les chiffres
            otp = newValue.filter { $0.isNumber }
        }
        .onTapGesture {
            isFocused = true
        }
        .onAppear {
            // Focus automatique au chargement
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
}

struct OTPDigitView: View {
    let digit: String
    let isFocused: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isFocused ? AppColors.primaryRed : AppColors.lightGray, lineWidth: 2)
                )
            
            if digit.isEmpty {
                Text("")
            } else {
                Text(digit)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.black)
            }
        }
    }
}

// MARK: - Email Validation Extension

extension String {
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
}

#Preview {
    ForgotPasswordFlowView(authService: AuthService())
}
