# Intégration IA - Import emploi du temps PDF

## Vue d'ensemble

Cette fonctionnalité permet aux étudiants d'importer leur emploi du temps au format PDF. L'IA (backend NestJS) extrait automatiquement tous les cours et les ajoute au calendrier de l'application.

## Architecture

### Backend NestJS (déjà disponible)

Base URL: `http://localhost:3005` (ou production sur Render)

#### Endpoints

1. **POST /schedule/process** - Traitement du PDF
   - Upload multipart/form-data
   - Champ: `file` (PDF)
   - Réponse: `{ "courses": [...] }`

2. **POST /schedule/create-events** - Création automatique des événements
   - Authentification requise (JWT Bearer token)
   - Body: `{ "courses": [...], "weekStartDate": "2024-12-01" }`
   - Réponse: `{ "message": "...", "eventsCreated": 5, "events": [...] }`

### iOS (Swift/SwiftUI)

#### Fichiers créés

1. **Models/Course.swift**
   - `Course`: Modèle représentant un cours extrait
   - `ProcessedScheduleResponse`: Réponse du traitement PDF
   - `CreateEventsFromScheduleRequest`: Requête de création d'événements
   - `CreateEventsResponse`: Réponse de création

2. **Services/ScheduleService.swift**
   - `uploadSchedulePDF()`: Upload et traitement du PDF
   - `createEventsFromSchedule()`: Création automatique des événements
   - Gestion des erreurs avec `ScheduleError`

3. **ViewModels/ScheduleUploadViewModel.swift**
   - Gestion de l'état (loading, erreurs, succès)
   - Liste des cours extraits
   - Sélection de la date de début de semaine
   - Suppression de cours avant création

4. **Views/Gestion du temps/ScheduleUploadView.swift**
   - Interface utilisateur complète
   - Sélection de fichier PDF (DocumentPicker)
   - Affichage des cours extraits
   - Sélection de la semaine de début
   - Bouton de création des événements

5. **Utils/APIConfig.swift** (modifié)
   - Ajout des endpoints schedule

6. **Views/Components/MenuView.swift** (modifié)
   - Nouvelle section "Emploi du temps"
   - Option "Importer emploi du temps PDF"

## Flux d'utilisation

1. **Ouverture du menu**
   - L'utilisateur clique sur ☰ dans le header
   - Sélectionne "Importer emploi du temps PDF"

2. **Sélection du PDF**
   - L'utilisateur clique sur "Sélectionner un PDF"
   - Un DocumentPicker s'ouvre
   - Sélection du fichier emploi du temps

3. **Traitement IA**
   - Upload automatique du PDF vers le backend
   - L'IA extrait les cours (jour, horaires, matière, salle, prof)
   - Affichage de la liste des cours extraits

4. **Vérification et ajustement**
   - L'utilisateur peut supprimer des cours (glisser à gauche)
   - Sélectionner la date de début de semaine (par défaut: lundi actuel)

5. **Création des événements**
   - Clic sur "Créer les événements"
   - Création automatique de tous les cours dans le calendrier
   - Message de succès avec nombre d'événements créés

## Fonctionnalités clés

### 1. Upload de fichier PDF
```swift
// Utilisation de UIDocumentPickerViewController
// Support du type PDF uniquement
let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
```

### 2. Traitement multipart/form-data
```swift
// Construction du body multipart
var body = Data()
body.append("--\(boundary)\r\n".data(using: .utf8)!)
body.append("Content-Disposition: form-data; name=\"file\"; filename=\"schedule.pdf\"\r\n")
body.append("Content-Type: application/pdf\r\n\r\n")
body.append(pdfData)
```

### 3. Authentification JWT
```swift
// Token récupéré depuis UserDefaults (même que AuthService)
request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
```

### 4. Gestion de la date de début
```swift
// Extension Date pour calculer le lundi de la semaine
static func mondayOfCurrentWeek() -> Date {
    let calendar = Calendar.current
    var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
    components.weekday = 2 // 2 = Lundi
    return calendar.date(from: components) ?? Date()
}
```

### 5. Interface utilisateur SwiftUI
- Design cohérent avec l'app (AppColors)
- Animations fluides
- Gestion des états (loading, erreur, succès)
- Swipe actions pour supprimer des cours

## Gestion des erreurs

### Types d'erreurs
```swift
enum ScheduleError: LocalizedError {
    case invalidPDF(String)      // PDF illisible ou format incorrect
    case invalidData(String)     // Données invalides pour création
    case invalidResponse         // Réponse serveur invalide
    case serverError(Int)        // Erreur serveur (500, etc.)
    case networkError            // Erreur réseau
    case notAuthenticated        // Token manquant ou invalide
    case fileReadError           // Impossible de lire le fichier
}
```

### Messages d'erreur
- Messages en français
- Détails du serveur si disponibles
- Logs détaillés pour le débogage

## Sécurité

1. **Authentification**
   - JWT Bearer token requis pour création des événements
   - Token stocké de manière sécurisée dans UserDefaults
   - Vérification de l'authentification avant chaque appel

2. **Validation**
   - Type de fichier vérifié (PDF uniquement)
   - Taille de fichier gérée par le backend
   - Validation des données côté serveur

## Tests

### Test de base
1. Sélectionner un PDF d'emploi du temps
2. Vérifier l'extraction des cours
3. Ajuster la date de début si nécessaire
4. Créer les événements
5. Vérifier dans le calendrier

### Cas limites
- PDF vide ou illisible
- Format d'emploi du temps non standard
- Connexion réseau instable
- Token expiré
- Semaine déjà remplie avec des cours

## Configuration

### Développement local
```swift
// APIConfig.swift
static let isDevelopment: Bool = true
static let localBaseURL: String = "http://127.0.0.1:3005"
```

### Production
```swift
// APIConfig.swift
static let isDevelopment: Bool = false
static let productionBaseURL: String = "https://talleb-5edma.onrender.com"
```

## Améliorations futures

1. **Détection automatique du format**
   - Support de plusieurs formats d'emploi du temps
   - Apprentissage automatique des nouveaux formats

2. **Édition des cours**
   - Modifier un cours avant création
   - Ajouter des notes personnelles

3. **Import récurrent**
   - Sauvegarder le fichier PDF pour mise à jour automatique
   - Synchronisation hebdomadaire

4. **Export**
   - Exporter l'emploi du temps vers d'autres formats
   - Partage avec d'autres étudiants

5. **OCR amélioré**
   - Meilleure reconnaissance des caractères
   - Support des emplois du temps manuscrits

## Dépendances

- **SwiftUI**: Interface utilisateur
- **Foundation**: URLSession, Data, JSONEncoder/Decoder
- **UniformTypeIdentifiers**: Support des types de fichiers (UTType.pdf)
- **UIKit**: UIDocumentPickerViewController

## Logs et débogage

Tous les appels API sont loggés avec des émojis pour faciliter le débogage :
- 📄 Upload Schedule PDF
- 📅 Create Events From Schedule
- ✅ Succès
- 🔴 Erreur

```swift
print("📄 Upload Schedule PDF - URL: \(url)")
print("📄 Upload Schedule PDF - File size: \(pdfData.count) bytes")
```

## Intégration avec le reste de l'app

- Utilise `AuthService` pour l'authentification
- Utilise `APIConfig` pour les endpoints
- Suit le pattern MVVM comme le reste de l'app
- Design cohérent avec `AppColors` et composants existants
- Créé des événements dans le même format que `EvenementService`

## Documentation backend requise

Le backend doit exposer ces endpoints avec les formats suivants :

### POST /schedule/process
```json
// Requête: multipart/form-data avec champ "file"

// Réponse:
{
  "courses": [
    {
      "day": "Monday",
      "start": "09:00",
      "end": "10:30",
      "subject": "Mathématiques",
      "classroom": "G102",
      "teacher": "Prof. Dupont"
    }
  ]
}
```

### POST /schedule/create-events
```json
// Requête:
{
  "courses": [...],
  "weekStartDate": "2024-12-01"  // optionnel
}

// Réponse:
{
  "message": "5 événements créés avec succès",
  "eventsCreated": 5,
  "events": [...]  // format Evenement standard
}
```

