//
//  JobsMapView.swift
//  Taleb_5edma
//
//  Created by Apple on 10/11/2025.
//

import SwiftUI
import MapKit

struct JobsMapView: View {
    @Environment(\.presentationMode) var presentationMode
    let offres: [Offre]
    // Région affichée par la carte (pour l'intégration future de MapKit)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.8065, longitude: 10.1815),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    /// Offre sélectionnée pour afficher les détails
    @State private var selectedOffre: Offre?
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // OpenStreetMap via Leaflet.js
                MapWebView(htmlString: generateMapHTML()) { offreId in
                    // Handle marker click - find the offre by ID and show details
                    if let offre = offres.first(where: { $0.id == offreId }) {
                        selectedOffre = offre
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                // Liste des offres sur la carte
                VStack {
                    Spacer()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(offres) { offre in
                                MapOffreCard(offre: offre)
                                    .onTapGesture {
                                        selectedOffre = offre
                                    }
                            }
                        }
                        .padding()
                    }
                    .background(Color.white.opacity(0.95))
                }
            }
            .ignoresSafeArea()
            .navigationTitle("Carte des Offres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.primaryRed)
                }
            }
            .sheet(item: $selectedOffre) { offre in
                OffreDetailView(offre: offre, viewModel: OffreViewModel())
            }
        }
    }
    
    // MARK: - Map HTML Generation
    
    /// Génère le HTML avec Leaflet.js pour afficher OpenStreetMap et les marqueurs d'offres
    private func generateMapHTML() -> String {
        // Créer les marqueurs pour chaque offre
        let markers = offres.enumerated().map { index, offre in
            let lat = offre.location.coordinates?.lat ?? 36.8065
            let lng = offre.location.coordinates?.lng ?? 10.1815
            let offreId = offre.id
            return """
            var marker\(index) = L.marker([\(lat), \(lng)]).addTo(map);
            marker\(index).bindPopup("<b>\(offre.title.replacingOccurrences(of: "\"", with: "&quot;"))</b><br>\(offre.company.replacingOccurrences(of: "\"", with: "&quot;"))<br>\(offre.location.address.replacingOccurrences(of: "\"", with: "&quot;"))");
            marker\(index).on('click', function() {
                window.webkit.messageHandlers.markerClicked.postMessage('\(offreId)');
            });
            """
        }.joined(separator: "\n")
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
            <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
            <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
            <style>
                body {
                    margin: 0;
                    padding: 0;
                }
                #map {
                    width: 100%;
                    height: 100vh;
                }
            </style>
        </head>
        <body>
            <div id="map"></div>
            <script>
                // Initialiser la carte centrée sur la Tunisie
                var map = L.map('map').setView([36.8065, 10.1815], 11);
                
                // Ajouter les tuiles OpenStreetMap
                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
                    maxZoom: 19
                }).addTo(map);
                
                // Ajouter les marqueurs pour chaque offre
                \(markers)
            </script>
        </body>
        </html>
        """
    }
}

struct MapOffreCard: View {
    let offre: Offre
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(offre.title)
                .font(.headline)
                .foregroundColor(AppColors.black)
            
            Text(offre.company)
                .font(.subheadline)
                .foregroundColor(AppColors.mediumGray)
            
            if let salary = offre.salary {
                Text(salary)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryRed)
            }
            
            HStack {
                Image(systemName: "location.fill")
                    .font(.caption)
                Text(offre.location.address)
                    .font(.caption)
            }
            .foregroundColor(AppColors.mediumGray)
        }
        .padding()
        .frame(width: 200)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    JobsMapView(offres: [
        Offre(
            id: "1",
            title: "Assistant de chantier",
            description: "Description",
            location: OffreLocation(
                address: "Centre ville Tunis",
                city: "Tunis",
                country: "Tunisie",
                coordinates: Coordinates(lat: 36.8065, lng: 10.1815)
            ),
            salary: "105 DT",
            company: "BTP Tunis"
        )
    ])
}
