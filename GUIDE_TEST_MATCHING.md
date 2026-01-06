# 🧪 Guide de Test - Système de Matching IA

## 📋 Table des Matières

1. [Prérequis](#prérequis)
2. [Intégration Rapide](#intégration-rapide)
3. [Test sans Backend (Mode Mock)](#test-sans-backend-mode-mock)
4. [Test avec Backend](#test-avec-backend)
5. [Scénarios de Test](#scénarios-de-test)
6. [Débogage](#débogage)

---

## ✅ Prérequis

### 1. Compiler le Projet
```bash
# Dans Xcode
Cmd + B  # Build
```

Vérifiez qu'il n'y a **aucune erreur de compilation**.

### 2. Backend (Optionnel)
Si vous voulez tester avec le backend réel :
- Backend NestJS démarré sur `http://127.0.0.1:3005`
- Endpoint `/ai-matching/analyze` implémenté
- Token d'authentification valide

### 3. Compte Utilisateur
- Utilisateur connecté dans l'app
- Au moins une disponibilité créée

---

## 🚀 Intégration Rapide

### Étape 1 : Ajouter le Tab Matching

**Ouvrir :** `Taleb_5edma/Views/Main/DashboardView.swift`

**Trouver la ligne 31** (où `availabilityViewModel` est déclaré) :
```swift
@StateObject private var availabilityViewModel = AvailabilityViewModel()
```
✅ Cette ligne existe déjà !

**Trouver la ligne 126** (après `.tag(3)`) et **ajouter** :

```swift
// Écran 5 - Matching IA
NavigationView {
    MainContentWrapper(
        showingNotifications: $showingNotifications,
        showingProfile: $showingProfile,
        showingMenu: $showingMenu,
        notificationCount: notificationCount
    ) {
        MatchingAnimatedView(availabilityViewModel: availabilityViewModel)
    }
}
.tabItem {
    Image(systemName: "sparkles")
    Text("Matching")
}
.tag(4)
```

### Étape 2 : Compiler et Lancer

```bash
Cmd + B  # Build
Cmd + R  # Run sur simulateur ou appareil
```

### Étape 3 : Vérifier l'Intégration

Vous devriez voir :
- ✅ Un nouveau tab "Matching" avec l'icône ✨
- ✅ 5 tabs au total dans la barre de navigation

---

## 🧪 Test sans Backend (Mode Mock)

Si le backend n'est pas prêt, vous pouvez tester l'interface avec des données mockées.

### Option 1 : Modifier Temporairement MatchingViewModel

**Ouvrir :** `Taleb_5edma/ViewModels/MatchingViewModel.swift`

**Dans la fonction `analyzeMatching()`**, remplacer temporairement par :

```swift
func analyzeMatching(preferences: MatchingRequest.MatchingPreferences? = nil) async {
    guard !availabilityViewModel.disponibilites.isEmpty else {
        DispatchQueue.main.async {
            self.showError(message: "Veuillez d'abord définir vos disponibilités")
        }
        return
    }
    
    DispatchQueue.main.async {
        self.isLoading = true
        self.errorMessage = nil
    }
    
    // Simulation d'un délai réseau
    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 secondes
    
    // Données mockées pour tester
    DispatchQueue.main.async {
        self.matches = [
            MatchResult(
                id: "1",
                titre: "Développeur iOS",
                description: "Développement d'applications mobiles iOS avec Swift et SwiftUI",
                company: "Tech Corp",
                location: "Tunis",
                salary: "1200 DT/mois",
                jobType: "Stage",
                scores: MatchResult.MatchScores(
                    score: 92,
                    timeCompatibility: 95,
                    skillsMatch: 88,
                    locationMatch: 90,
                    salaryMatch: 85
                ),
                recommendation: "Excellente opportunité pour développer vos compétences en iOS !",
                strengths: [
                    "Horaires flexibles qui correspondent à vos disponibilités",
                    "Proche de votre localisation",
                    "Technologies alignées avec vos compétences"
                ],
                warnings: [],
                details: MatchResult.MatchDetails(
                    availableHours: 20,
                    requiredHours: 20,
                    matchedSkills: ["Swift", "SwiftUI", "Xcode"],
                    missingSkills: []
                )
            ),
            MatchResult(
                id: "2",
                titre: "Développeur Web Full Stack",
                description: "Développement web avec React et Node.js",
                company: "Web Solutions",
                location: "Sfax",
                salary: "1500 DT/mois",
                jobType: "CDI",
                scores: MatchResult.MatchScores(
                    score: 75,
                    timeCompatibility: 80,
                    skillsMatch: 70,
                    locationMatch: 60,
                    salaryMatch: 90
                ),
                recommendation: "Bon match global, mais localisation éloignée",
                strengths: [
                    "Salaire attractif",
                    "Technologies modernes"
                ],
                warnings: [
                    "Localisation éloignée de votre position",
                    "Quelques compétences manquantes"
                ],
                details: MatchResult.MatchDetails(
                    availableHours: 20,
                    requiredHours: 25,
                    matchedSkills: ["JavaScript", "React"],
                    missingSkills: ["Node.js", "MongoDB"]
                )
            ),
            MatchResult(
                id: "3",
                titre: "Assistant Marketing Digital",
                description: "Gestion des réseaux sociaux et campagnes publicitaires",
                company: "Marketing Pro",
                location: "Tunis",
                salary: "800 DT/mois",
                jobType: "Stage",
                scores: MatchResult.MatchScores(
                    score: 65,
                    timeCompatibility: 70,
                    skillsMatch: 60,
                    locationMatch: 85,
                    salaryMatch: 50
                ),
                recommendation: "Match moyen - convient si vous cherchez une première expérience",
                strengths: [
                    "Localisation proche",
                    "Horaires flexibles"
                ],
                warnings: [
                    "Salaire en dessous de vos attentes",
                    "Compétences marketing limitées"
                ],
                details: MatchResult.MatchDetails(
                    availableHours: 20,
                    requiredHours: 20,
                    matchedSkills: [],
                    missingSkills: ["Marketing", "Réseaux sociaux"]
                )
            )
        ]
        
        self.summary = MatchingResponse.MatchingSummary(
            totalMatches: 3,
            averageScore: 77.3,
            bestMatchScore: 92
        )
        
        self.isLoading = false
        print("✅ Matching mock terminé - \(self.matches.count) résultats")
    }
}
```

### Option 2 : Créer des Disponibilités

1. **Lancer l'app**
2. **Aller dans le tab "Dispo"**
3. **Ajouter des disponibilités** :
   - Exemple : Lundi 09:00-17:00
   - Mardi 09:00-17:00
   - Mercredi 09:00-13:00

4. **Aller dans le tab "Matching"**
5. **Observer** :
   - ✅ Skeleton loading (2 secondes)
   - ✅ Résultats avec animations
   - ✅ Cartes avec scores
   - ✅ Statistiques en haut

---

## 🔌 Test avec Backend

### 1. Vérifier la Configuration API

**Ouvrir :** `Taleb_5edma/Utils/APIConfig.swift`

Vérifier que :
```swift
static let isDevelopment: Bool = true
static let localBaseURL = "http://127.0.0.1:3005"
```

### 2. Démarrer le Backend

```bash
cd /chemin/vers/backend
npm run start:dev  # ou yarn dev
```

Vérifier que le backend tourne sur le port 3005.

### 3. Vérifier l'Endpoint

L'endpoint doit être accessible :
```
POST http://127.0.0.1:3005/ai-matching/analyze
Authorization: Bearer <token>
Content-Type: application/json
```

**Format de requête attendu :**
```json
{
  "disponibilites": [
    {
      "jour": "Lundi",
      "heureDebut": "09:00",
      "heureFin": "17:00"
    }
  ],
  "preferences": {
    "jobType": "stage"
  }
}
```

**Format de réponse attendu :**
```json
{
  "matches": [
    {
      "_id": "123",
      "titre": "Développeur iOS",
      "description": "...",
      "company": "Tech Corp",
      "location": "Tunis",
      "salary": "1200 DT/mois",
      "jobType": "Stage",
      "scores": {
        "score": 92,
        "timeCompatibility": 95,
        "skillsMatch": 88,
        "locationMatch": 90,
        "salaryMatch": 85
      },
      "recommendation": "Excellente opportunité !",
      "strengths": ["Horaires flexibles"],
      "warnings": [],
      "details": {
        "availableHours": 20,
        "requiredHours": 20,
        "matchedSkills": ["Swift"],
        "missingSkills": []
      }
    }
  ],
  "summary": {
    "totalMatches": 1,
    "averageScore": 92,
    "bestMatchScore": 92
  }
}
```

### 4. Tester dans l'App

1. **Créer des disponibilités** dans l'app
2. **Aller dans le tab "Matching"**
3. **Observer le chargement**
4. **Vérifier les résultats** du backend

---

## 🎯 Scénarios de Test

### Test 1 : Première Ouverture (Sans Disponibilités)

**Actions :**
1. Ouvrir l'app
2. Aller dans "Matching"
3. Ne pas avoir créé de disponibilités

**Résultat attendu :**
- ✅ Message d'erreur : "Veuillez d'abord définir vos disponibilités"
- ✅ Bouton pour créer des disponibilités

### Test 2 : Chargement Initial

**Actions :**
1. Créer au moins une disponibilité
2. Aller dans "Matching"

**Résultat attendu :**
- ✅ Skeleton loading visible (2-3 secondes)
- ✅ Animation fluide
- ✅ Résultats apparaissent avec fade + slide

### Test 3 : Affichage des Résultats

**Actions :**
1. Attendre le chargement
2. Observer les résultats

**Résultat attendu :**
- ✅ Header avec statistiques (nombre de matches, score moyen)
- ✅ Cartes de résultats avec :
  - Score circulaire animé (count up 0 → 100)
  - Titre, entreprise, localisation
  - Tags colorés
  - Gradient selon le score (vert > 80, orange 60-80, rouge < 60)
- ✅ Banner "Meilleur match" en haut

### Test 4 : Animations

**Actions :**
1. Observer les animations lors du chargement

**Résultat attendu :**
- ✅ Fade in + slide des cartes
- ✅ Score qui monte de 0 à la valeur finale
- ✅ Parallax scroll sur le header
- ✅ Confetti si score > 90% (bonus)

### Test 5 : Filtres

**Actions :**
1. Cliquer sur le bouton filtre (icône en haut à droite)
2. Utiliser les filtres :
   - Recherche textuelle
   - Niveau de matching (Excellent, Bon, Moyen, Faible)
   - Tri (Score décroissant, Score croissant, Titre A-Z)
3. Appliquer les filtres

**Résultat attendu :**
- ✅ Panel de filtres slide depuis le haut
- ✅ Haptic feedback sur chaque interaction
- ✅ Résultats filtrés dynamiquement
- ✅ Animation de fermeture

### Test 6 : Recherche

**Actions :**
1. Ouvrir les filtres
2. Taper dans la barre de recherche (ex: "iOS")
3. Observer les résultats

**Résultat attendu :**
- ✅ Résultats filtrés en temps réel
- ✅ Recherche dans titre, entreprise, localisation

### Test 7 : Détails d'un Match

**Actions :**
1. Cliquer sur une carte de résultat

**Résultat attendu :**
- ✅ Sheet avec vue détaillée
- ✅ Score circulaire en haut
- ✅ Détails du poste
- ✅ Scores détaillés (time, skills, location, salary)
- ✅ Points forts
- ✅ Avertissements (si présents)
- ✅ Bouton "Postuler maintenant"

### Test 8 : Swipe to Delete

**Actions :**
1. Swiper vers la droite sur une carte

**Résultat attendu :**
- ✅ Animation de suppression
- ✅ Carte disparaît avec animation
- ✅ Haptic feedback
- ✅ Liste mise à jour

### Test 9 : Pull to Refresh

**Actions :**
1. Scroll vers le haut
2. Tirer vers le bas pour rafraîchir

**Résultat attendu :**
- ✅ Animation de refresh
- ✅ Haptic feedback
- ✅ Nouvelle analyse lancée
- ✅ Résultats rechargés

### Test 10 : Confetti (Bonus)

**Actions :**
1. Avoir un résultat avec score > 90%
2. Observer lors du chargement

**Résultat attendu :**
- ✅ Animation de confetti
- ✅ Haptic feedback success
- ✅ Confetti disparaît après 3 secondes

### Test 11 : Dark Mode

**Actions :**
1. Activer le dark mode iOS
2. Ouvrir "Matching"

**Résultat attendu :**
- ✅ Toutes les couleurs s'adaptent
- ✅ Bon contraste
- ✅ Lisibilité optimale

### Test 12 : État Vide

**Actions :**
1. Simuler une réponse vide du backend (ou modifier mock)

**Résultat attendu :**
- ✅ Message "Aucun résultat"
- ✅ Illustration animée
- ✅ Bouton "Relancer l'analyse"

### Test 13 : Gestion d'Erreur

**Actions :**
1. Désactiver le backend
2. Essayer d'analyser

**Résultat attendu :**
- ✅ Message d'erreur affiché
- ✅ Alerte avec message détaillé
- ✅ Bouton "OK" pour fermer

---

## 🐛 Débogage

### Problème : "Veuillez d'abord définir vos disponibilités"

**Solution :**
1. Aller dans le tab "Dispo"
2. Créer au moins une disponibilité
3. Retourner dans "Matching"

### Problème : Network Error

**Vérifications :**
1. Backend démarré sur port 3005
2. URL correcte dans `APIConfig.swift`
3. Token d'authentification valide
4. Appareil/simulateur sur le même réseau

**Test rapide :**
```bash
# Dans le terminal
curl -X POST http://127.0.0.1:3005/ai-matching/analyze \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"disponibilites":[{"jour":"Lundi","heureDebut":"09:00","heureFin":"17:00"}],"preferences":{}}'
```

### Problème : Pas de Résultats

**Vérifications :**
1. Backend retourne des données ?
2. Format JSON correct ?
3. Logs dans la console Xcode

**Console Xcode :**
- Chercher : `✅ Matching terminé` ou `❌ Matching - Erreur`
- Vérifier les messages de debug

### Problème : Animations Lag

**Solution :**
1. Tester sur un appareil réel (plus rapide)
2. Réduire le nombre de résultats si nécessaire
3. Vérifier la performance dans Instruments

### Problème : Token Expiré

**Solution :**
1. Se déconnecter puis reconnecter
2. Vérifier que le token est sauvegardé dans UserDefaults

---

## 📊 Checklist de Test Complète

### Interface
- [ ] Tab "Matching" visible dans la navigation
- [ ] Skeleton loading fonctionne
- [ ] Résultats s'affichent avec animations
- [ ] Cartes ont les bonnes couleurs (gradients)
- [ ] Scores circulaires s'animent correctement
- [ ] Statistiques en haut correctes

### Fonctionnalités
- [ ] Filtres s'ouvrent et se ferment
- [ ] Recherche fonctionne
- [ ] Tri fonctionne
- [ ] Swipe to delete fonctionne
- [ ] Pull to refresh fonctionne
- [ ] Détails d'un match s'ouvrent
- [ ] Confetti apparaît pour score > 90

### États
- [ ] État vide affiché correctement
- [ ] Erreurs affichées correctement
- [ ] Loading state fonctionne

### Performance
- [ ] Animations fluides (60 FPS)
- [ ] Pas de lag lors du scroll
- [ ] Chargement rapide

### Dark Mode
- [ ] Couleurs s'adaptent
- [ ] Lisibilité optimale

---

## 🔧 Commandes Utiles

### Nettoyer le Build
```bash
# Dans Xcode
Cmd + Shift + K  # Clean Build Folder
Cmd + B          # Build
```

### Voir les Logs
```bash
# Dans Xcode
Cmd + Shift + Y  # Ouvrir la console
# Filtrer par "Matching" ou "✅" / "❌"
```

### Reset Simulateur
```bash
# Dans Xcode
Device → Erase All Content and Settings
```

---

## 💡 Astuces

### Tester Rapidement avec Mock

Si vous voulez tester rapidement l'interface sans backend, utilisez le code mock dans `MatchingViewModel.analyzeMatching()`.

### Simuler un Score > 90%

Modifier les données mockées pour avoir un score de 92 ou plus, puis observer la confetti animation.

### Tester le Dark Mode

Dans le simulateur : **Settings → Developer → Dark Appearance**

---

## 📞 Besoin d'Aide ?

1. Consulter `INTEGRATION_RAPIDE.md` pour l'intégration
2. Consulter `CHECKLIST.md` pour l'installation
3. Vérifier les logs dans la console Xcode
4. Tester avec le mode mock d'abord

---

**Bon test ! 🚀**

