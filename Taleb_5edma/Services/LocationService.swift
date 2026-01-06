//
//  LocationService.swift
//  Taleb_5edma
//
//  Created by Apple on 10/11/2025.
//

import Foundation
import CoreLocation

/// Structure contenant les détails d'une localisation
struct LocationDetails {
    let address: String
    let city: String
    let country: String
    let coordinates: Coordinates
}

/// Service pour gérer le géocodage inversé (coordonnées → adresse)
class LocationService {
    private let geocoder = CLGeocoder()
    
    /// Effectue un géocodage inversé pour obtenir l'adresse depuis les coordonnées GPS
    /// - Parameters:
    ///   - latitude: Latitude de la position
    ///   - longitude: Longitude de la position
    /// - Returns: Détails de la localisation incluant adresse, ville, pays et coordonnées
    /// - Throws: Erreur si le géocodage échoue
    func reverseGeocode(latitude: Double, longitude: Double) async throws -> LocationDetails {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        // Essayer d'abord le géocodage Apple
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            
            guard let placemark = placemarks.first else {
                // Si Apple échoue, essayer OpenStreetMap
                return try await reverseGeocodeWithNominatim(latitude: latitude, longitude: longitude)
            }
            
            // Extraire les informations d'adresse
            let address = formatAddress(from: placemark)
            let city = placemark.locality ?? placemark.administrativeArea ?? "Ville inconnue"
            let country = placemark.country ?? "Pays inconnu"
            
            return LocationDetails(
                address: address,
                city: city,
                country: country,
                coordinates: Coordinates(lat: latitude, lng: longitude)
            )
        } catch {
            // Si Apple échoue, essayer OpenStreetMap comme fallback
            return try await reverseGeocodeWithNominatim(latitude: latitude, longitude: longitude)
        }
    }
    
    /// Géocodage inversé avec OpenStreetMap Nominatim (fallback)
    private func reverseGeocodeWithNominatim(latitude: Double, longitude: Double) async throws -> LocationDetails {
        let urlString = "https://nominatim.openstreetmap.org/reverse?format=json&lat=\(latitude)&lon=\(longitude)&zoom=18&addressdetails=1"
        
        guard let url = URL(string: urlString) else {
            throw LocationError.geocodingFailed
        }
        
        var request = URLRequest(url: url)
        request.setValue("TalebApp/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try JSONDecoder().decode(NominatimResponse.self, from: data)
        
        // Extraire l'adresse formatée
        let address = response.address
        var addressComponents: [String] = []
        
        if let road = address.road {
            if let houseNumber = address.house_number {
                addressComponents.append("\(houseNumber) \(road)")
            } else {
                addressComponents.append(road)
            }
        } else if let suburb = address.suburb {
            addressComponents.append(suburb)
        } else if let neighbourhood = address.neighbourhood {
            addressComponents.append(neighbourhood)
        }
        
        let finalAddress = addressComponents.isEmpty ? response.display_name : addressComponents.joined(separator: ", ")
        let city = address.city ?? address.town ?? address.village ?? address.state ?? "Ville inconnue"
        let country = address.country ?? "Pays inconnu"
        
        return LocationDetails(
            address: finalAddress,
            city: city,
            country: country,
            coordinates: Coordinates(lat: latitude, lng: longitude)
        )
    }
    
    /// Formate l'adresse depuis un placemark
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var addressComponents: [String] = []
        
        // Numéro de rue
        if let streetNumber = placemark.subThoroughfare {
            addressComponents.append(streetNumber)
        }
        
        // Nom de rue
        if let street = placemark.thoroughfare {
            addressComponents.append(street)
        }
        
        // Si aucune adresse de rue, utiliser le quartier ou la sous-localité
        if addressComponents.isEmpty {
            if let subLocality = placemark.subLocality {
                addressComponents.append(subLocality)
            } else if let locality = placemark.locality {
                addressComponents.append(locality)
            }
        }
        
        return addressComponents.isEmpty ? "Adresse inconnue" : addressComponents.joined(separator: " ")
    }
}

/// Erreurs possibles du service de localisation
enum LocationError: Error, LocalizedError {
    case noPlacemarkFound
    case geocodingFailed
    
    var errorDescription: String? {
        switch self {
        case .noPlacemarkFound:
            return "Aucune adresse trouvée pour cette position"
        case .geocodingFailed:
            return "Échec du géocodage"
        }
    }
}

// MARK: - Nominatim Response Models

/// Réponse de l'API Nominatim (OpenStreetMap)
private struct NominatimResponse: Codable {
    let display_name: String
    let address: NominatimAddress
}

/// Détails d'adresse de Nominatim
private struct NominatimAddress: Codable {
    let house_number: String?
    let road: String?
    let suburb: String?
    let neighbourhood: String?
    let city: String?
    let town: String?
    let village: String?
    let state: String?
    let country: String?
}
