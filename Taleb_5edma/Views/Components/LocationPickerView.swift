//
//  LocationPickerView.swift
//  Taleb_5edma
//
//  Created by Apple on 10/11/2025.
//

import SwiftUI
import MapKit

/// Vue pour sélectionner une position sur une carte interactive
/// Permet de choisir des coordonnées GPS et obtenir l'adresse par géocodage inversé
struct LocationPickerView: View {
    @Environment(\.dismiss) var dismiss
    
    /// Callback appelé quand une position est enregistrée
    let onLocationSelected: (LocationDetails) -> Void
    
    // État de la carte
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.8065, longitude: 10.1815), // Tunis par défaut
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    private let locationService = LocationService()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Carte avec zoom et interactions activés
                Map(coordinateRegion: $region, annotationItems: selectedCoordinate.map { [MapPin(coordinate: $0)] } ?? []) { pin in
                    MapMarker(coordinate: pin.coordinate, tint: .red)
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                .edgesIgnoringSafeArea(.all)
                .gesture(
                    // Permettre tous les gestes: zoom, pan, rotation
                    MagnificationGesture()
                        .simultaneously(with: DragGesture())
                )
                
                // Crosshair au centre pour indiquer la position sélectionnée
                VStack {
                    Spacer()
                    Image(systemName: "scope")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.primaryRed)
                        .shadow(color: .black.opacity(0.3), radius: 3)
                    Spacer()
                }
                .allowsHitTesting(false)
                
                // Informations en bas
                VStack {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        // Coordonnées sélectionnées
                        VStack(spacing: 8) {
                            Text("Position sélectionnée")
                                .font(.caption)
                                .foregroundColor(AppColors.mediumGray)
                            
                            Text(coordinatesText)
                                .font(.footnote)
                                .foregroundColor(AppColors.black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppColors.lightGray.opacity(0.3))
                                .cornerRadius(8)
                        }
                        
                        // Boutons d'action
                        HStack(spacing: 12) {
                            Button("Annuler") {
                                dismiss()
                            }
                            .buttonStyle(LocationPickerSecondaryButtonStyle())
                            
                            Button(action: {
                                saveLocation()
                            }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .tint(AppColors.white)
                                    } else {
                                        Text("Enregistrer")
                                    }
                                }
                            }
                            .buttonStyle(LocationPickerPrimaryButtonStyle())
                            .disabled(isLoading)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 10)
                    )
                    .padding()
                }
            }
            .navigationTitle("Sélectionner la position")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: region.center.latitude) { _, _ in
                selectedCoordinate = region.center
            }
            .onChange(of: region.center.longitude) { _, _ in
                selectedCoordinate = region.center
            }
            .alert("Erreur", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Une erreur est survenue")
            }
        }
    }
    
    private var coordinatesText: String {
        let coord = selectedCoordinate ?? region.center
        return String(format: "%.6f, %.6f", coord.latitude, coord.longitude)
    }
    
    private func saveLocation() {
        let coord = selectedCoordinate ?? region.center
        
        isLoading = true
        Task {
            do {
                // Essayer le géocodage inversé
                let details = try await locationService.reverseGeocode(
                    latitude: coord.latitude,
                    longitude: coord.longitude
                )
                
                await MainActor.run {
                    isLoading = false
                    onLocationSelected(details)
                    dismiss()
                }
            } catch let clError as CLError where clError.code == .geocodeFoundNoResult || clError.code == .geocodeFoundPartialResult {
                // Si aucune adresse n'est trouvée, utiliser une détection intelligente
                await MainActor.run {
                    isLoading = false
                    
                    // Détecter la ville et le pays basé sur les coordonnées
                    let (city, country) = detectCityAndCountry(from: coord)
                    
                    // Créer un LocationDetails avec détection intelligente
                    let fallbackDetails = LocationDetails(
                        address: String(format: "%.6f, %.6f", coord.latitude, coord.longitude),
                        city: city,
                        country: country,
                        coordinates: Coordinates(lat: coord.latitude, lng: coord.longitude)
                    )
                    
                    onLocationSelected(fallbackDetails)
                    dismiss()
                }
            } catch let clError as CLError {
                await MainActor.run {
                    isLoading = false
                    
                    // Messages d'erreur pour les vraies erreurs
                    switch clError.code {
                    case .network:
                        errorMessage = "Erreur réseau. Veuillez vérifier votre connexion Internet."
                    case .denied:
                        errorMessage = "Permission de localisation refusée. Autorisez l'accès dans Réglages."
                    default:
                        errorMessage = "Erreur de géolocalisation: \(clError.localizedDescription)"
                    }
                    
                    showError = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Erreur: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    /// Détecte la ville et le pays basé sur les coordonnées GPS
    /// Utilisé comme fallback quand le géocodage inversé échoue
    private func detectCityAndCountry(from coordinate: CLLocationCoordinate2D) -> (city: String, country: String) {
        let lat = coordinate.latitude
        let lng = coordinate.longitude
        
        // Tunisie (approximativement 30°N-37°N, 7°E-12°E)
        if lat >= 30 && lat <= 37 && lng >= 7 && lng <= 12 {
            // Grandes villes de Tunisie avec leurs coordonnées approximatives
            if lat >= 36.7 && lat <= 36.9 && lng >= 10.0 && lng <= 10.3 {
                return ("Tunis", "Tunisie")
            } else if lat >= 35.7 && lat <= 35.9 && lng >= 10.5 && lng <= 10.7 {
                return ("Sousse", "Tunisie")
            } else if lat >= 36.4 && lat <= 36.6 && lng >= 10.7 && lng <= 10.9 {
                return ("Nabeul", "Tunisie")
            } else if lat >= 35.8 && lat <= 36.0 && lng >= 10.0 && lng <= 10.2 {
                return ("Kairouan", "Tunisie")
            } else if lat >= 34.7 && lat <= 34.9 && lng >= 10.7 && lng <= 10.9 {
                return ("Sfax", "Tunisie")
            } else {
                return ("Tunisie", "Tunisie")
            }
        }
        
        // Algérie (approximativement 18°N-37°N, -9°E-12°E)
        else if lat >= 18 && lat <= 37 && lng >= -9 && lng <= 12 {
            if lat >= 36.5 && lat <= 36.9 && lng >= 2.5 && lng <= 3.5 {
                return ("Alger", "Algérie")
            } else {
                return ("Algérie", "Algérie")
            }
        }
        
        // Maroc (approximativement 21°N-36°N, -17°W--1°W)
        else if lat >= 21 && lat <= 36 && lng >= -17 && lng <= -1 {
            if lat >= 33.4 && lat <= 33.7 && lng >= -7.8 && lng <= -7.4 {
                return ("Casablanca", "Maroc")
            } else if lat >= 33.9 && lat <= 34.1 && lng >= -7.0 && lng <= -6.6 {
                return ("Rabat", "Maroc")
            } else {
                return ("Maroc", "Maroc")
            }
        }
        
        // France (approximativement 41°N-51°N, -5°E-10°E)
        else if lat >= 41 && lat <= 51 && lng >= -5 && lng <= 10 {
            if lat >= 48.8 && lat <= 48.9 && lng >= 2.2 && lng <= 2.5 {
                return ("Paris", "France")
            } else {
                return ("France", "France")
            }
        }
        
        // Fallback: utiliser une description géographique
        else {
            return ("Position GPS", "")
        }
    }
}

// Structure auxiliaire pour les marqueurs
struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// Styles de boutons pour LocationPickerView
struct LocationPickerPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.primaryRed, AppColors.accentPink]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct LocationPickerSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(AppColors.primaryRed)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.primaryRed, lineWidth: 2)
            )
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
