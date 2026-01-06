//
//  HorizontalCalendarView.swift
//  Taleb_5edma
//
//  Created for displaying a horizontal calendar in home view
//

import SwiftUI

struct HorizontalCalendarView: View {
    @Binding var selectedDate: Date
    @State private var currentMonth: Date = Date()
    @EnvironmentObject var authService: AuthService
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        dateFormatter.locale = Locale(identifier: "fr_FR")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header avec nom utilisateur et icône calendrier
            headerSection
            
            // Sélecteur de mois
            monthSelectorSection
            
            // Liste horizontale des jours
            daysListSection
        }
        .background(
            LinearGradient(
                colors: [
                    Color(hex: 0x9333ea).opacity(0.12),
                    Color(hex: 0x7c3aed).opacity(0.06),
                    Color.white.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24, corners: [.bottomLeft, .bottomRight])
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack(spacing: 12) {
            // Photo de profil ou initiales
            if let imageURL = authService.currentUser?.image, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color(hex: 0xFF69B4))
                        .overlay(
                            Text(getUserInitials())
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(hex: 0xFF69B4))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(getUserInitials())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            
            Spacer()
            
            // Icône calendrier
            Button(action: {
                // TODO: Action pour ouvrir le calendrier complet
            }) {
                Image(systemName: "calendar")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: 0x9333ea))
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.6))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Month Selector Section
    
    private var monthSelectorSection: some View {
        HStack {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    changeMonth(by: -1)
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.black)
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.5))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text(formatMonthYear(currentMonth))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.black)
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    changeMonth(by: 1)
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.black)
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    // MARK: - Days List Section
    
    private var daysListSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(daysInMonth, id: \.self) { date in
                    DayChip(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        onTap: {
                            selectedDate = date
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Computed Properties
    
    private var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }
        
        // Obtenir le premier jour du mois
        let firstDay = monthInterval.start
        
        // Obtenir le nombre de jours dans le mois
        guard let daysCount = calendar.range(of: .day, in: .month, for: currentMonth)?.count else {
            return []
        }
        
        // Créer un tableau de dates pour tous les jours du mois
        var dates: [Date] = []
        for day in 0..<daysCount {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDay) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    // MARK: - Helper Methods
    
    private func formatMonthYear(_ date: Date) -> String {
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date).capitalized
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func getUserName() -> String {
        return authService.currentUser?.nom ?? "Utilisateur"
    }
    
    private func getUserInitials() -> String {
        let name = getUserName()
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1)) + String(components[1].prefix(1))
        }
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - Day Chip Component

struct DayChip: View {
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    init(date: Date, isSelected: Bool, onTap: @escaping () -> Void) {
        self.date = date
        self.isSelected = isSelected
        self.onTap = onTap
        dateFormatter.locale = Locale(identifier: "fr_FR")
    }
    
    private var dayNumber: String {
        let day = calendar.component(.day, from: date)
        return "\(day)"
    }
    
    private var dayName: String {
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: date).capitalized
    }
    
    private var dayDisplayText: String {
        // Format: "6 Mar." (numéro + jour abrégé avec point)
        return "\(dayNumber) \(dayName)."
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onTap()
            }
        }) {
            VStack(spacing: 8) {
                Text(dayDisplayText)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : AppColors.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                // Point blanc en dessous pour le jour sélectionné
                if isSelected {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 5, height: 5)
                } else {
                    Spacer()
                        .frame(height: 5)
                }
            }
            .frame(width: 65, height: 75)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isSelected ? Color(hex: 0x9333ea) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isSelected ? Color.clear : Color(hex: 0xE5E7EB),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSelected ? Color(hex: 0x9333ea).opacity(0.4) : Color.black.opacity(0.06),
                radius: isSelected ? 10 : 3,
                x: 0,
                y: isSelected ? 5 : 2
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HorizontalCalendarView(selectedDate: .constant(Date()))
        .padding()
}

