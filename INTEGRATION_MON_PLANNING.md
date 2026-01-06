# 🚀 Intégration Rapide - Mon Planning

## ⚡ Installation en 5 minutes

### Étape 1 : Vérifier les fichiers

Tous les fichiers suivants doivent être présents dans votre projet Xcode :

```
✅ Models/EnhancedRoutineAnalysis.swift
✅ Services/EnhancedRoutineService.swift
✅ ViewModels/EnhancedRoutineViewModel.swift
✅ Views/Gestion du temps/MonPlanningView.swift
✅ Views/Gestion du temps/Components/ScoreGaugeView.swift
✅ Views/Gestion du temps/Components/StatisticsCardsView.swift
✅ Views/Gestion du temps/Components/ConflictsListView.swift
✅ Views/Gestion du temps/Components/OverloadedDaysView.swift
✅ Views/Gestion du temps/Components/RecommendationsListView.swift
✅ Utils/APIConfig.swift (mis à jour)
```

### Étape 2 : Compiler le projet

```bash
Cmd + B
```

Si des erreurs apparaissent, consultez la section "Résolution d'erreurs" ci-dessous.

### Étape 3 : Intégrer dans le Dashboard

**Ouvrir :** `Views/Main/DashboardView.swift`

**Ajouter après la ligne 31** (où `availabilityViewModel` est déclaré) :

```swift
@StateObject private var evenementViewModel = EvenementViewModel()
```

> **Note :** Cette ligne existe peut-être déjà. Vérifiez d'abord.

**Ajouter dans la TabView, après `.tag(4)` :**

```swift
// Écran 6 - Mon Planning
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

### Étape 4 : Tester

```bash
Cmd + R
```

Vous devriez voir :
- ✅ Un nouveau tab "Planning" dans la barre de navigation
- ✅ 6 tabs au total
- ✅ L'écran "Mon Planning" accessible

---

## 🧪 Test rapide (sans backend)

Pour tester l'interface sans le backend, ajoutez temporairement dans `MonPlanningView.swift` :

**Dans la fonction `onAppear` (ligne ~379), ajouter :**

```swift
.onAppear {
    viewModel.evenementViewModel = evenementViewModel
    viewModel.availabilityViewModel = availabilityViewModel
    
    // TEMPORAIRE : Données mockées pour test
    #if DEBUG
    viewModel.analysisData = EnhancedRoutineAnalysisResponse.AnalysisData(
        scoreEquilibre: 72,
        scoreBreakdown: EnhancedRoutineAnalysisResponse.ScoreBreakdown(
            baseScore: 100,
            workStudyBalance: 5,
            restPenalty: -10,
            conflictPenalty: -15,
            overloadPenalty: -8,
            bonuses: 0
        ),
        conflicts: [
            EnhancedRoutineAnalysisResponse.Conflict(
                date: "2024-12-09",
                event1: EnhancedRoutineAnalysisResponse.Conflict.ConflictEvent(
                    titre: "Cours Math",
                    heureDebut: "09:00"
                ),
                event2: EnhancedRoutineAnalysisResponse.Conflict.ConflictEvent(
                    titre: "Job Restaurant",
                    heureDebut: "10:30"
                ),
                severity: "high",
                suggestion: "Contactez votre employeur pour décaler votre horaire",
                overlapDuration: 30
            )
        ],
        overloadedDays: [
            EnhancedRoutineAnalysisResponse.OverloadedDay(
                date: "2024-12-10",
                jour: "Mardi",
                totalHours: 13.5,
                level: "élevé",
                recommendations: [
                    "Déplacez 1-2h d'activités vers mercredi",
                    "Prévoyez des pauses de 15 minutes"
                ]
            )
        ],
        availableTimeSlots: [],
        recommandations: [
            EnhancedRoutineAnalysisResponse.Recommendation(
                id: "1",
                type: "optimisation",
                titre: "Résoudre le conflit du lundi",
                description: "Vous avez un conflit entre votre cours et votre travail",
                priorite: "haute",
                actionSuggeree: "Contactez votre employeur"
            )
        ],
        analyseHebdomadaire: EnhancedRoutineAnalysisResponse.WeeklyAnalysis(
            heuresTravail: 20,
            heuresEtudes: 25,
            heuresRepos: 45,
            heuresActivites: 10
        ),
        healthSummary: EnhancedRoutineAnalysisResponse.HealthSummary(
            status: "moyen",
            mainIssues: ["1 conflit critique", "1 jour surchargé"],
            mainStrengths: ["Bon équilibre travail/études", "Repos suffisant"]
        )
    )
    #endif
}
```

> **N'oubliez pas de retirer ce code de test quand le backend sera prêt !**

---

## 🔧 Configuration Backend

### Backend local (développement)

**Vérifier dans `APIConfig.swift` :**

```swift
static let isDevelopment: Bool = true
static let localBaseURL: String = "http://127.0.0.1:3005"
```

### Backend production (Render)

```swift
static let isDevelopment: Bool = false
static let productionBaseURL: String = "https://talleb-5edma.onrender.com"
```

### Endpoint requis

Votre backend NestJS doit exposer :

```
POST /ai/routine/analyze-enhanced
```

Avec le format exact décrit dans `MON_PLANNING_README.md`.

---

## 🐛 Résolution d'erreurs

### Erreur : "Cannot find 'Evenement' in scope"

**Solution :**
- Vérifiez que `Models/Evenement.swift` existe
- Clean Build Folder : `Cmd + Shift + K`
- Rebuild : `Cmd + B`

### Erreur : "Cannot find 'AppColors' in scope"

**Solution :**
- Vérifiez que `Utils/AppColors.swift` existe
- Vérifiez les imports dans les fichiers

### Erreur : "Cannot find 'HapticManager' in scope"

**Solution :**
- Vérifiez que `Utils/HapticManager.swift` existe
- Si non, le créer (voir `MATCHING_IA_README.md` pour le code)

### Erreur : "evenementViewModel not found"

**Solution :**
Dans `DashboardView.swift`, ajouter :

```swift
@StateObject private var evenementViewModel = EvenementViewModel()
```

### Erreur de compilation dans Calendar Extension

**Solution :**
L'extension `Calendar` dans `MonPlanningView.swift` pourrait entrer en conflit.
Renommer les fonctions ou les déplacer dans un fichier séparé.

---

## ✅ Checklist finale

Avant de considérer l'intégration terminée :

- [ ] ✅ Tous les fichiers ajoutés à Xcode
- [ ] ✅ Compilation sans erreur (Cmd + B)
- [ ] ✅ Tab "Planning" visible dans la barre
- [ ] ✅ Écran s'affiche correctement
- [ ] ✅ Backend démarré (ou test avec données mockées)
- [ ] ✅ Bouton "Analyser" fonctionne
- [ ] ✅ Animations fluides
- [ ] ✅ Pull-to-refresh fonctionne
- [ ] ✅ Sélection de période fonctionne

---

## 📱 Test sur appareil

1. Connecter votre iPhone/iPad
2. Sélectionner l'appareil dans Xcode
3. `Cmd + R` pour lancer
4. Tester toutes les fonctionnalités

### Checklist de test

- [ ] Score s'affiche correctement
- [ ] Statistiques animées
- [ ] Conflits listés (si présents)
- [ ] Jours surchargés affichés
- [ ] Recommandations visibles
- [ ] Tap sur les cartes pour expand/collapse
- [ ] Pull-to-refresh fonctionne
- [ ] Changement de période fonctionne
- [ ] Messages d'erreur clairs
- [ ] Loading overlay s'affiche

---

## 🎯 Prochaines étapes

Une fois l'intégration terminée :

1. **Tester avec des données réelles** du backend
2. **Ajuster les couleurs** si nécessaire (`AppColors.swift`)
3. **Personnaliser les messages** dans les vues
4. **Ajouter des analytics** pour mesurer l'usage
5. **Recueillir les feedbacks** des utilisateurs

---

## 📚 Documentation complète

Pour plus de détails, consultez :
- `MON_PLANNING_README.md` - Documentation complète
- Code source commenté dans chaque fichier
- Previews SwiftUI pour chaque composant

---

## 🎉 Félicitations !

Vous avez maintenant un système d'analyse de planning moderne et intelligent avec :

- ✨ Interface inspirée de Notion
- 🎨 Design coloré et animé
- 🤖 Analyse IA avancée
- 💾 Cache intelligent
- 🔄 Pull-to-refresh
- 📊 Statistiques détaillées
- ⚠️ Détection de conflits
- 💡 Recommandations personnalisées

**Bon développement ! 🚀**

---

**Date :** 08/12/2025  
**Version :** 1.0.0

