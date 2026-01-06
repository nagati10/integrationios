//
//  TimeManagementView.swift
//  Taleb_5edma
//
//  Created by Apple on 10/11/2025.
//

import SwiftUI

struct TimeManagementView: View {
    // Date sélectionnée pour laquelle afficher les événements et les statistiques
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header avec stats
                    headerSection
                    
                    // Calendrier
                    calendarSection
                    
                    // Événements du jour
                    dailyEventsSection
                }
                .padding()
            }
            .navigationTitle("Gestion du temps")
            .background(AppColors.backgroundGray)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cette semaine")
                .font(.headline)
                .foregroundColor(AppColors.mediumGray)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Heures de job effectuées")
                        .font(.subheadline)
                    Text("1h/20h")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primaryRed)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Jobs effectués: 1h")
                    Text("Cours planifiés: 18h")
                }
                .font(.caption)
                .foregroundColor(AppColors.mediumGray)
            }
        }
        .padding()
        .background(AppColors.white)
        .cornerRadius(12)
    }
    
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aujourd'hui - \(formattedDate)")
                .font(.headline)
                .foregroundColor(AppColors.primaryRed)
            
            // Ici vous ajouterez un vrai calendrier plus tard
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.white)
                .frame(height: 100)
                .overlay(
                    Text("Calendrier intégré")
                        .foregroundColor(AppColors.mediumGray)
                )
        }
        .padding()
        .background(AppColors.white)
        .cornerRadius(12)
    }
    
    private var dailyEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Événements du jour")
                .font(.headline)
                .foregroundColor(AppColors.primaryRed)
            
            EventRow(title: "Cours Math", location: "Amphi A", time: "09:00 - 09:45")
            EventRow(title: "Job Café X", location: "12Dt/h", time: "14:00 - 18:00")
            EventRow(title: "Deadline DM", location: nil, time: "19:00")
        }
        .padding()
        .background(AppColors.white)
        .cornerRadius(12)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMM"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: selectedDate)
    }
}

struct EventRow: View {
    let title: String
    let location: String?
    let time: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                if let location = location {
                    Text(location)
                        .font(.caption)
                        .foregroundColor(AppColors.mediumGray)
                }
            }
            Spacer()
            Text(time)
                .font(.caption)
                .foregroundColor(AppColors.mediumGray)
        }
        .padding()
        .background(AppColors.backgroundGray)
        .cornerRadius(8)
    }
}
