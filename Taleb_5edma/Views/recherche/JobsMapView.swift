//
//  JobsMapView.swift
//  Taleb_5edma
//
//  Created by Apple on 10/11/2025.
//

//
//  JobsMapView.swift
//  Taleb_5edma
//

import SwiftUI
import MapKit

struct JobsMapView: View {
    @Environment(\.presentationMode) var presentationMode
    let jobs: [Job]
    // Région affichée par la carte (pour l'intégration future de MapKit)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.8065, longitude: 10.1815),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Carte simulée
                Rectangle()
                    .fill(AppColors.lightGray.opacity(0.3))
                    .overlay(
                        VStack {
                            Image(systemName: "map")
                                .font(.system(size: 80))
                                .foregroundColor(AppColors.primaryRed)
                            
                            Text("Carte des offres d'emploi")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.primaryRed)
                                .padding(.top, 8)
                            
                            Text("Visualisez les entreprises et offres proches de vous")
                                .font(.subheadline)
                                .foregroundColor(AppColors.mediumGray)
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                        }
                        .padding()
                    )
                
                // Liste des offres sur la carte
                VStack {
                    Spacer()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(jobs) { job in
                                MapJobCard(job: job)
                            }
                        }
                        .padding()
                    }
                    .background(Color.white.opacity(0.95))
                }
            }
            .ignoresSafeArea()
            .navigationTitle("Carte des Jobs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.primaryRed)
                }
            }
        }
    }
}

struct MapJobCard: View {
    let job: Job
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(job.title)
                .font(.headline)
                .foregroundColor(AppColors.black)
            
            Text(job.company)
                .font(.subheadline)
                .foregroundColor(AppColors.mediumGray)
            
            Text("\(Int(job.salary)) DT")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppColors.primaryRed)
            
            HStack {
                Image(systemName: "location.fill")
                    .font(.caption)
                Text(job.location)
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
    JobsMapView(jobs: [
        Job(
            id: "1",
            title: "Assistant de chantier",
            company: "BTP Tunis",
            location: "Centre ville Tunis",
            salary: 105,
            duration: "7j",
            schedule: "Jour",
            shareCount: 20,
            isPopular: true,
            isFavorite: false,
            latitude: 36.8065,
            longitude: 10.1815
        )
    ])
}
