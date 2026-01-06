//
//  MapsViewWrapper.swift
//  Taleb_5edma
//
//  Created by Apple on 10/11/2025.
//

import SwiftUI

/// Wrapper pour JobsMapView qui charge les offres depuis le ViewModel
struct MapsViewWrapper: View {
    @StateObject private var viewModel = OffreViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Chargement des offres...")
                        .foregroundColor(AppColors.mediumGray)
                }
            } else {
                JobsMapView(offres: viewModel.offres)
            }
        }
        .onAppear {
            Task {
                await viewModel.loadOffres()
            }
        }
    }
}
