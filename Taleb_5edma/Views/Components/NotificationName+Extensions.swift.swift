//
//  NotificationName+Extensions.swift.swift
//  Taleb_5edma
//
//  Created by Apple on 09/11/2025.
//

import Foundation

extension Notification.Name {
    // Notifications internes utilisées pour piloter la navigation modale dans les écrans d'authentification
    static let showSignup = Notification.Name("showSignup")
    static let showLogin = Notification.Name("showLogin")
    static let showForgot = Notification.Name("showForgot")
    static let showOTPReset = Notification.Name("showOTPReset")
    static let showResetPassword = Notification.Name("showResetPassword")
}
