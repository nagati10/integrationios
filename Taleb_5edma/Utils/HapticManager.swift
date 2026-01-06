//
//  HapticManager.swift
//  Taleb_5edma
//
//  Created by Apple on 08/12/2025.
//

import UIKit

/// Gestionnaire de feedback haptique pour améliorer l'expérience utilisateur
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    /// Génère un impact haptique
    /// - Parameter style: Style de l'impact (léger, moyen, lourd)
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    /// Génère une notification haptique
    /// - Parameter type: Type de notification (succès, avertissement, erreur)
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    /// Génère un feedback de sélection
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // MARK: - Méthodes de convenance
    
    /// Impact léger
    static func light() {
        shared.impact(style: .light)
    }
    
    /// Impact moyen
    static func medium() {
        shared.impact(style: .medium)
    }
    
    /// Impact fort
    static func heavy() {
        shared.impact(style: .heavy)
    }
    
    /// Impact pour les actions importantes
    static func impact() {
        shared.impact(style: .medium)
    }
    
    /// Notification de succès
    static func success() {
        shared.notification(type: .success)
    }
    
    /// Notification d'avertissement
    static func warning() {
        shared.notification(type: .warning)
    }
    
    /// Notification d'erreur
    static func error() {
        shared.notification(type: .error)
    }
}

