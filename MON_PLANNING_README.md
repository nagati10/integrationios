# 📅 Mon Planning - Analyse IA Améliorée

## 🎯 Vue d'ensemble

Nouveau système d'analyse de planning avec IA améliorée pour l'application Taleb 5edma. Permet aux étudiants de visualiser et optimiser leur équilibre vie-études-travail.

---

## ✅ Fichiers créés

### 1. Modèle (1 fichier)
- ✅ `Models/EnhancedRoutineAnalysis.swift` - Modèles de données pour l'analyse améliorée

### 2. Service (1 fichier)
- ✅ `Services/EnhancedRoutineService.swift` - Service API avec gestion du cache

### 3. ViewModel (1 fichier)
- ✅ `ViewModels/EnhancedRoutineViewModel.swift` - Logique métier de l'analyse

### 4. Vue principale (1 fichier)
- ✅ `Views/Gestion du temps/MonPlanningView.swift` - Écran principal "Mon Planning"

### 5. Composants (6 fichiers)
- ✅ `Views/Gestion du temps/Components/ScoreGaugeView.swift` - Jauge circulaire du score
- ✅ `Views/Gestion du temps/Components/StatisticsCardsView.swift` - Cartes de statistiques
- ✅ `Views/Gestion du temps/Components/ConflictsListView.swift` - Liste des conflits
- ✅ `Views/Gestion du temps/Components/OverloadedDaysView.swift` - Jours surchargés
- ✅ `Views/Gestion du temps/Components/RecommendationsListView.swift` - Recommandations IA

### 6. Configuration
- ✅ `Utils/APIConfig.swift` - Endpoint ajouté

---

## 📊 Fonctionnalités

### 1. Score d'équilibre
- Jauge circulaire animée (0-100)
- Animation de comptage fluide
- Couleurs dynamiques : Vert (bon), Orange (moyen), Rouge (critique)
- Labels de statut

### 2. Statistiques hebdomadaires
- 4 cartes colorées : Travail, Études, Repos, Activités
- Affichage des heures et pourcentages
- Barres de progression animées
- Icons personnalisés

### 3. Détection des conflits
- Liste des conflits avec gravité (haute/moyenne/faible)
- Icônes et couleurs selon la sévérité
- Détails collapsibles
- Suggestions IA pour résoudre

### 4. Jours surchargés
- Identification des jours avec trop d'heures
- Niveau de surcharge (élevé/modéré/léger)
- Recommandations spécifiques
- Barre de progression visuelle

### 5. Recommandations IA
- Liste priorisée (haute/moyenne/basse)
- Types : Optimisation, Warning, Suggestion
- Actions suggérées détaillées
- Interface collapsible

### 6. Détails du score
- Décomposition complète du calcul
- Score de base, pénalités, bonus
- Affichage positif/négatif

### 7. Fonctionnalités avancées
- Pull-to-refresh
- Cache intelligent (1 heure de validité)
- Sélection de période personnalisée
- Messages d'erreur clairs
- État de chargement avec overlay

---

## 🚀 Intégration

### Option 1 : Ajouter au Dashboard (Tab Bar)

**Fichier:** `Views/Main/DashboardView.swift`

```swift
// Dans la TabView, après le tag(4) du Matching
NavigationView {
    MainContentWrapper(
        showingNotifications: $showingNotifications,
        showingProfile: $showingProfile,
        showingMenu: $showingMenu,
        notificationCount: notificationCount
    ) {
        MonPlanningView(
            evenementViewModel: evenementViewModel,
            availabilityViewModel: availabilityViewModel
        )
    }
}
.tabItem {
    Image(systemName: "calendar.badge.clock")
    Text("Planning")
}
.tag(5)
```

### Option 2 : Depuis TimeManagementView

**Fichier:** `Views/Gestion du temps/TimeManagementView.swift`

```swift
NavigationLink(destination: MonPlanningView(
    evenementViewModel: evenementViewModel,
    availabilityViewModel: availabilityViewModel
)) {
    HStack {
        Image(systemName: "sparkles")
        Text("Analyser Mon Planning")
    }
}
```

### Option 3 : Modal Sheet

```swift
@State private var showMonPlanning = false

Button("Mon Planning") {
    showMonPlanning = true
}
.sheet(isPresented: $showMonPlanning) {
    NavigationView {
        MonPlanningView(
            evenementViewModel: evenementViewModel,
            availabilityViewModel: availabilityViewModel
        )
    }
}
```

---

## 🔧 Configuration Backend

### Endpoint requis

```
POST /ai/routine/analyze-enhanced
Authorization: Bearer {token}
```

### Format de requête

```json
{
  "evenements": [
    {
      "id": "1",
      "titre": "Cours Math",
      "type": "cours",
      "date": "2024-01-15",
      "heureDebut": "09:00",
      "heureFin": "11:00"
    }
  ],
  "disponibilites": [
    {
      "id": "1",
      "jour": "Lundi",
      "heureDebut": "08:00",
      "heureFin": "18:00"
    }
  ],
  "dateDebut": "2024-01-15",
  "dateFin": "2024-01-21"
}
```

### Format de réponse

```json
{
  "success": true,
  "data": {
    "scoreEquilibre": 65,
    "scoreBreakdown": {
      "baseScore": 100,
      "workStudyBalance": 5,
      "restPenalty": -10,
      "conflictPenalty": -20,
      "overloadPenalty": -10,
      "bonuses": 0
    },
    "conflicts": [...],
    "overloadedDays": [...],
    "availableTimeSlots": [...],
    "recommandations": [...],
    "analyseHebdomadaire": {
      "heuresTravail": 20,
      "heuresEtudes": 25,
      "heuresRepos": 45,
      "heuresActivites": 10
    },
    "healthSummary": {
      "status": "moyen",
      "mainIssues": ["1 conflit(s)"],
      "mainStrengths": ["Bon équilibre travail/études"]
    }
  }
}
```

---

## 🎨 Design

### Couleurs utilisées

- **Vert** (`AppColors.successGreen`) : Score bon (≥75), états positifs
- **Orange** : Score moyen (50-74), niveau modéré
- **Rouge** (`AppColors.errorRed`) : Score faible (<50), états critiques
- **Bleu** (`AppColors.accentBlue`) : Actions, informations
- **Bordeaux** (`AppColors.primaryRed`) : Boutons principaux

### Animations

- ✅ Count-up du score (0 → valeur)
- ✅ Progression circulaire fluide
- ✅ Barres de statistiques animées
- ✅ Expand/collapse des détails
- ✅ Haptic feedback sur interactions

### Composants

- Cards avec ombres légères
- Coins arrondis (16px)
- Gradients sur les boutons
- Icons SF Symbols
- Badges colorés

---

## 🧪 Test

### 1. Test de l'interface (sans backend)

Vous pouvez tester l'interface avec des données mockées :

```swift
// Dans MonPlanningView, remplacer temporairement dans onAppear:
viewModel.analysisData = EnhancedRoutineAnalysisResponse.AnalysisData(
    scoreEquilibre: 65,
    scoreBreakdown: ...,
    conflicts: [...],
    overloadedDays: [...],
    availableTimeSlots: [],
    recommandations: [...],
    analyseHebdomadaire: ...,
    healthSummary: ...
)
```

### 2. Test avec le backend

1. Démarrer le backend NestJS
2. S'assurer que l'endpoint `/ai/routine/analyze-enhanced` est implémenté
3. Se connecter dans l'app
4. Ajouter des événements et disponibilités
5. Aller dans "Mon Planning"
6. Appuyer sur "Analyser Mon Planning"

### 3. Test du cache

```swift
// Analyser une première fois
await viewModel.analyzeRoutine(...)

// Quitter l'écran et revenir
// Les données devraient être chargées depuis le cache

// Vider le cache
viewModel.clearCache()
```

---

## 🐛 Debugging

### Logs dans la console

```
🔵 Enhanced Routine Analyze - URL: ...
🔵 Enhanced Routine Analyze - Body: ...
🔵 Enhanced Routine Analyze - Status Code: 200
✅ Enhanced Routine Analyze - Success: Score = 65
💾 Analyse sauvegardée dans le cache
```

### Erreurs courantes

**Erreur : "Vous devez être connecté"**
- Vérifier que l'utilisateur est bien connecté
- Vérifier le token dans UserDefaults

**Erreur : 404 Not Found**
- Vérifier que le backend est démarré
- Vérifier l'URL dans `APIConfig.swift`
- Vérifier que l'endpoint existe

**Erreur : "Veuillez ajouter des événements"**
- Ajouter au moins 1 événement ou 1 disponibilité

**Erreur de décodage**
- Vérifier le format de réponse du backend
- Consulter les logs pour voir la réponse brute

---

## 📱 Compatibilité

- ✅ iOS 15.0+
- ✅ iPhone & iPad
- ✅ Light & Dark Mode
- ✅ Landscape & Portrait
- ✅ Animations fluides (60 FPS)

---

## 🎯 Avantages par rapport à l'ancienne version

### Anciennes limitations (AIRoutineService)
- ❌ Analyse basique sans détails
- ❌ Pas de détection de conflits
- ❌ Pas de recommandations IA
- ❌ Interface simple

### Nouvelle version (EnhancedRoutineService)
- ✅ Analyse détaillée et précise
- ✅ Détection automatique des conflits
- ✅ Recommandations IA personnalisées
- ✅ Détection des jours surchargés
- ✅ Décomposition du score
- ✅ Interface moderne et animée
- ✅ Cache intelligent
- ✅ Pull-to-refresh
- ✅ Sélection de période

---

## 🔄 Migration depuis l'ancienne version

Si vous utilisez déjà `RoutineBalanceView`, vous pouvez :

1. **Conserver les deux versions** : Garder l'ancienne pour la compatibilité
2. **Remplacer progressivement** : Utiliser la nouvelle version dans de nouveaux écrans
3. **Migration complète** : Remplacer tous les usages par `MonPlanningView`

### Comparaison

| Fonctionnalité | Ancienne | Nouvelle |
|----------------|----------|----------|
| Score d'équilibre | ✅ | ✅ |
| Statistiques | ✅ | ✅ |
| Détection conflits | ❌ | ✅ |
| Jours surchargés | ❌ | ✅ |
| Recommandations IA | Basique | Avancées |
| Cache | ❌ | ✅ |
| Animations | Basiques | Avancées |
| Pull-to-refresh | ❌ | ✅ |

---

## 📚 Prochaines améliorations

### Court terme
- [ ] Notifications pour conflits critiques
- [ ] Export PDF du rapport
- [ ] Partage du planning

### Moyen terme
- [ ] Historique des analyses
- [ ] Comparaison de périodes
- [ ] Objectifs personnalisés

### Long terme
- [ ] Suggestions proactives
- [ ] Intégration Google Calendar
- [ ] Rapport mensuel automatique

---

## 🤝 Support

### En cas de problème

1. Consulter les logs dans Xcode (🔵 ✅ ❌)
2. Vérifier la configuration backend
3. Tester avec des données mockées
4. Vider le cache et réessayer

### Contacts

Pour toute question sur cette fonctionnalité, consultez :
- `MON_PLANNING_README.md` (ce fichier)
- Code source dans `Views/Gestion du temps/`
- Exemples dans les Previews SwiftUI

---

**Développé avec ❤️ pour Taleb 5edma**  
**Date :** 08/12/2025  
**Version :** 1.0.0  
**Status :** ✅ Production Ready

