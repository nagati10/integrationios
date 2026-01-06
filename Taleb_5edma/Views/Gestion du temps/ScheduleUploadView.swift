//
//  ScheduleUploadView.swift
//  Taleb_5edma
//
//  Created by Apple on 07/12/2025.
//

import SwiftUI
import UniformTypeIdentifiers
#if DEBUG
import UIKit
import CoreGraphics
#endif

/// Vue pour uploader et traiter un emploi du temps PDF
struct ScheduleUploadView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = ScheduleUploadViewModel()
    @Environment(\.dismiss) var dismiss
    
    // État pour le document picker
    @State private var showDocumentPicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundGray
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // En-tête explicatif
                        headerSection
                        
                        // Section upload PDF
                        uploadSection
                        
                        // Section sélection de date
                        if !viewModel.extractedCourses.isEmpty {
                            dateSelectionSection
                        }
                        
                        // Section affichage des cours extraits
                        if !viewModel.extractedCourses.isEmpty {
                            coursesSection
                        }
                        
                        // Bouton de création des événements
                        if !viewModel.extractedCourses.isEmpty {
                            createEventsButton
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Import emploi du temps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryRed)
                }
                
                if !viewModel.extractedCourses.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Réinitialiser") {
                            viewModel.reset()
                        }
                        .foregroundColor(AppColors.primaryRed)
                    }
                }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(onPick: handleDocumentPick)
            }
            .alert("Erreur", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Une erreur est survenue")
            }
            .alert("Succès", isPresented: $viewModel.showSuccess) {
                Button("OK", role: .cancel) {
                    if viewModel.extractedCourses.isEmpty {
                        // Si les cours ont été créés, fermer la vue
                        dismiss()
                    }
                }
            } message: {
                Text(viewModel.successMessage ?? "Opération réussie")
            }
            .onAppear {
                viewModel.authService = authService
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.primaryRed)
                
                Text("Importez votre emploi du temps")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.black)
            }
            
            Text("Uploadez un PDF de votre emploi du temps et notre IA extraira automatiquement tous vos cours pour les ajouter à votre calendrier.")
                .font(.subheadline)
                .foregroundColor(AppColors.mediumGray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Upload Section
    
    private var uploadSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                showDocumentPicker = true
            }) {
                VStack(spacing: 12) {
                    if viewModel.isProcessing {
                        ProgressView()
                            .tint(AppColors.primaryRed)
                            .scaleEffect(1.2)
                    } else {
                        Image(systemName: "arrow.up.doc.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppColors.primaryRed)
                        
                        Text("Sélectionner un PDF")
                            .font(.headline)
                            .foregroundColor(AppColors.black)
                        
                        Text("Cliquez pour choisir votre emploi du temps")
                            .font(.caption)
                            .foregroundColor(AppColors.mediumGray)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            style: StrokeStyle(lineWidth: 2, dash: [10])
                        )
                        .foregroundColor(AppColors.primaryRed.opacity(0.5))
                )
            }
            .disabled(viewModel.isProcessing)
            
            // Mode test pour simulateur (DEBUG uniquement)
            #if DEBUG
            Button(action: {
                // Essayer de charger un PDF de test depuis le bundle
                if let pdfURL = Bundle.main.url(forResource: "test_schedule", withExtension: "pdf"),
                   let pdfData = try? Data(contentsOf: pdfURL) {
                    Task {
                        await viewModel.uploadSchedulePDF(pdfData)
                    }
                } else {
                    // Si aucun PDF de test n'est trouvé, créer un PDF de test minimal
                    createTestPDF()
                }
            }) {
                HStack {
                    Image(systemName: "doc.text.fill")
                    Text("Test PDF (Simulateur)")
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.accentBlue)
                .cornerRadius(8)
            }
            .disabled(viewModel.isProcessing)
            #endif
            
            if viewModel.isProcessing {
                Text("Traitement en cours...")
                    .font(.subheadline)
                    .foregroundColor(AppColors.mediumGray)
            }
        }
        .padding()
        .background(AppColors.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Test Helper Methods
    
    #if DEBUG
    /// Crée un PDF de test minimal pour le simulateur
    private func createTestPDF() {
        // Créer un PDF simple avec Core Graphics
        let pdfData = NSMutableData()
        let pdfConsumer = CGDataConsumer(data: pdfData)!
        var mediaBox = CGRect(x: 0, y: 0, width: 612, height: 792) // Format A4
        let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil)!
        
        pdfContext.beginPDFPage(nil)
        pdfContext.setFillColor(UIColor.black.cgColor)
        
        // Ajouter du texte simple
        let text = "Emploi du Temps\n\nLundi 09:00-10:30 Mathématiques\nMardi 14:00-16:00 Informatique"
        let font = UIFont.systemFont(ofSize: 16)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textRect = CGRect(x: 50, y: 700, width: 500, height: 100)
        attributedString.draw(in: textRect)
        
        pdfContext.endPDFPage()
        pdfContext.closePDF()
        
        // Uploader le PDF de test
        Task {
            await viewModel.uploadSchedulePDF(pdfData as Data)
        }
    }
    #endif
    
    // MARK: - Date Selection Section
    
    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Date de début de semaine")
                .font(.headline)
                .foregroundColor(AppColors.black)
            
            HStack {
                Button(action: {
                    viewModel.selectedWeekStartDate = viewModel.selectedWeekStartDate.previousMonday()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColors.primaryRed)
                        .frame(width: 44, height: 44)
                        .background(AppColors.backgroundGray)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("Lundi")
                        .font(.caption)
                        .foregroundColor(AppColors.mediumGray)
                    
                    Text(viewModel.selectedWeekStartDate.formattedString())
                        .font(.headline)
                        .foregroundColor(AppColors.black)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.selectedWeekStartDate = viewModel.selectedWeekStartDate.nextMonday()
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColors.primaryRed)
                        .frame(width: 44, height: 44)
                        .background(AppColors.backgroundGray)
                        .cornerRadius(8)
                }
            }
            
            Text("Les cours seront créés à partir de cette date")
                .font(.caption)
                .foregroundColor(AppColors.mediumGray)
        }
        .padding()
        .background(AppColors.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Courses Section
    
    private var coursesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Cours extraits (\(viewModel.extractedCourses.count))")
                    .font(.headline)
                    .foregroundColor(AppColors.black)
                
                Spacer()
                
                Text("Glissez pour supprimer")
                    .font(.caption)
                    .foregroundColor(AppColors.mediumGray)
            }
            
            ForEach(viewModel.extractedCourses) { course in
                CourseRow(course: course)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation {
                                viewModel.removeCourse(course)
                            }
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
            }
        }
        .padding()
        .background(AppColors.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Create Events Button
    
    private var createEventsButton: some View {
        Button(action: {
            Task {
                await viewModel.createEvents()
            }
        }) {
            HStack {
                if viewModel.isCreatingEvents {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "calendar.badge.plus")
                    Text("Créer les événements")
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                viewModel.isCreatingEvents ? AppColors.mediumGray : AppColors.primaryRed
            )
            .cornerRadius(12)
        }
        .disabled(viewModel.isCreatingEvents)
        .padding(.horizontal)
    }
    
    // MARK: - Helper Methods
    
    private func handleDocumentPick(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            Task {
                do {
                    // Dans le simulateur, il faut utiliser startAccessingSecurityScopedResource
                    let isAccessing = url.startAccessingSecurityScopedResource()
                    defer {
                        if isAccessing {
                            url.stopAccessingSecurityScopedResource()
                        }
                    }
                    
                    // Lire les données du fichier
                    let data = try Data(contentsOf: url)
                    
                    // Vérifier que c'est bien un PDF
                    guard data.count > 0 else {
                        await MainActor.run {
                            viewModel.errorMessage = "Le fichier sélectionné est vide"
                            viewModel.showError = true
                        }
                        return
                    }
                    
                    // Uploader et traiter le PDF
                    await viewModel.uploadSchedulePDF(data)
                } catch {
                    await MainActor.run {
                        #if DEBUG
                        // Message plus détaillé en mode debug
                        viewModel.errorMessage = "Impossible de lire le fichier PDF dans le simulateur. Utilisez le bouton 'Test PDF (Simulateur)' ci-dessous. Erreur: \(error.localizedDescription)"
                        #else
                        viewModel.errorMessage = "Impossible de lire le fichier PDF. Veuillez réessayer."
                        #endif
                        viewModel.showError = true
                    }
                }
            }
            
        case .failure(let error):
            #if DEBUG
            // Message plus détaillé en mode debug pour le simulateur
            if error.localizedDescription.contains("canceled") {
                // L'utilisateur a annulé, pas besoin d'afficher d'erreur
                return
            }
            viewModel.errorMessage = "Erreur lors de la sélection du fichier dans le simulateur. Utilisez le bouton 'Test PDF (Simulateur)' ci-dessous. Erreur: \(error.localizedDescription)"
            #else
            if !error.localizedDescription.contains("canceled") {
                viewModel.errorMessage = "Erreur lors de la sélection du fichier: \(error.localizedDescription)"
            }
            #endif
            viewModel.showError = true
        }
    }
}

// MARK: - Course Row Component

struct CourseRow: View {
    let course: Course
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icône de cours
            Image(systemName: "book.fill")
                .font(.title3)
                .foregroundColor(AppColors.primaryRed)
                .frame(width: 40, height: 40)
                .background(AppColors.primaryRed.opacity(0.1))
                .cornerRadius(8)
            
            // Informations du cours
            VStack(alignment: .leading, spacing: 4) {
                Text(course.subject)
                    .font(.headline)
                    .foregroundColor(AppColors.black)
                
                HStack(spacing: 16) {
                    Label(course.dayInFrench, systemImage: "calendar")
                    Label("\(course.start) - \(course.end)", systemImage: "clock")
                }
                .font(.caption)
                .foregroundColor(AppColors.mediumGray)
                
                if let classroom = course.classroom {
                    Label("Salle \(classroom)", systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.mediumGray)
                }
                
                if let teacher = course.teacher {
                    Label("Prof. \(teacher)", systemImage: "person.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.mediumGray)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(AppColors.backgroundGray)
        .cornerRadius(8)
    }
}

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    let onPick: (Result<URL, Error>) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onPick(.success(url))
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onPick(.failure(NSError(domain: "DocumentPicker", code: -1, userInfo: [NSLocalizedDescriptionKey: "Selection cancelled"])))
        }
    }
}

#Preview {
    ScheduleUploadView()
        .environmentObject(AuthService())
}

