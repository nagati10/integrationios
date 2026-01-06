# 🧪 Guide de Test - Mon Planning

## 📋 Prérequis

Avant de tester, assurez-vous que :
- ✅ Tous les fichiers ont été créés
- ✅ Le projet compile sans erreur (`Cmd + B`)
- ✅ Vous avez un compte utilisateur connecté dans l'app
- ✅ Vous avez créé quelques événements et disponibilités

---

## 🚀 Méthode 1 : Test avec données mockées (SANS backend)

Cette méthode permet de tester l'interface avant que le backend soit prêt.

### Étape 1 : Intégrer dans le Dashboard

**Ouvrir :** `Views/Main/DashboardView.swift`

**Ajouter après `.tag(4)` du Matching :**

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

### Étape 2 : Ajouter des données mockées

**Ouvrir :** `Views/Gestion du temps/MonPlanningView.swift`

**Dans le `.onAppear` (ligne ~379), ajouter temporairement :**

```swift
.onAppear {
    viewModel.evenementViewModel = evenementViewModel
    viewModel.availabilityViewModel = availabilityViewModel
    viewModel.initialize()
    
    // ⚠️ TEMPORAIRE : Données mockées pour test
    #if DEBUG
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.viewModel.analysisData = EnhancedRoutineAnalysisResponse.AnalysisData(
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
                    suggestion: "Contactez votre employeur pour décaler votre horaire de 2 heures",
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
                        "Prévoyez des pauses de 15 minutes entre vos cours"
                    ]
                )
            ],
            availableTimeSlots: [
                EnhancedRoutineAnalysisResponse.AvailableTimeSlot(
                    jour: "Mercredi",
                    heureDebut: "14:00",
                    heureFin: "18:00",
                    duration: 4
                )
            ],
            recommandations: [
                EnhancedRoutineAnalysisResponse.Recommendation(
                    id: "1",
                    type: "optimisation",
                    titre: "Résoudre le conflit du lundi",
                    description: "Vous avez un conflit entre votre cours de mathématiques et votre travail au restaurant. Il est important de résoudre ce conflit rapidement.",
                    priorite: "haute",
                    actionSuggeree: "Contactez votre employeur pour décaler votre horaire"
                ),
                EnhancedRoutineAnalysisResponse.Recommendation(
                    id: "2",
                    type: "suggestion",
                    titre: "Optimiser votre temps de repos",
                    description: "Votre temps de repos pourrait être mieux réparti dans la semaine.",
                    priorite: "moyenne",
                    actionSuggeree: "Ajoutez une pause de 30 minutes après vos cours"
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
    }
    #endif
}
```

### Étape 3 : Tester

1. **Compiler** : `Cmd + B`
2. **Lancer** : `Cmd + R`
3. **Navigator** : Aller dans l'onglet "Planning" (dernier tab)
4. **Observer** : L'écran devrait afficher toutes les données mockées

### ✅ Checklist de test (données mockées)

- [ ] L'onglet "Planning" apparaît dans la TabBar
- [ ] La jauge circulaire affiche 72%
- [ ] Le score est coloré en orange (moyen)
- [ ] Animation de count-up du score (0 → 72)
- [ ] Les 4 cartes statistiques s'affichent
- [ ] Les barres de progression sont animées
- [ ] La carte "Conflits" affiche 1 conflit
- [ ] Le conflit est marqué "URGENT" en rouge
- [ ] Tap sur le conflit pour expand/collapse
- [ ] La carte "Jours surchargés" affiche 1 jour
- [ ] Les recommandations s'affichent avec priorités
- [ ] Le résumé de santé affiche "Moyen"
- [ ] Pull-to-refresh fonctionne
- [ ] Sélection de période fonctionne
- [ ] Dark mode fonctionne bien

---

## 🌐 Méthode 2 : Test avec backend (Production)

### Prérequis Backend

1. **Backend NestJS démarré** sur le port 3005
2. **Endpoint implémenté** : `POST /ai/routine/analyze-enhanced`
3. **Token valide** dans l'app

### Étape 1 : Configuration

**Vérifier dans :** `Utils/APIConfig.swift`

```swift
static let isDevelopment: Bool = true  // Pour backend local
static let localBaseURL: String = "http://127.0.0.1:3005"
```

### Étape 2 : Créer des données test

1. **Lancer l'app**
2. **Aller dans "Calendrier"**
3. **Créer quelques événements** :
   - Lundi : Cours Math (09:00-11:00)
   - Lundi : Job Restaurant (10:30-14:00) ← Conflit volontaire
   - Mardi : Cours Physique (08:00-10:00)
   - Mardi : Étude (10:00-12:00)
   - Mardi : Job (14:00-18:00)
   - Mardi : Étude (18:00-21:00) ← Jour surchargé

4. **Aller dans "Disponibilités"**
5. **Créer des disponibilités** :
   - Lundi : 08:00-18:00
   - Mardi : 08:00-22:00
   - Mercredi : 09:00-17:00

### Étape 3 : Lancer l'analyse

1. **Aller dans "Planning"**
2. **Appuyer sur "Analyser Mon Planning"**
3. **Observer** : Loading overlay apparaît
4. **Attendre** : L'analyse se fait (quelques secondes)
5. **Résultat** : L'écran affiche les résultats

### ✅ Checklist de test (backend)

- [ ] Le bouton "Analyser" fonctionne
- [ ] Loading overlay s'affiche
- [ ] L'analyse se termine sans erreur
- [ ] Le score s'affiche correctement
- [ ] Les conflits sont détectés
- [ ] Les jours surchargés sont identifiés
- [ ] Les recommandations sont pertinentes
- [ ] Le cache fonctionne (quitter et revenir)
- [ ] Pull-to-refresh recharge les données
- [ ] Les erreurs sont gérées (si backend down)

---

## 🎬 Scénarios de test

### Scénario 1 : Planning équilibré

**Données :**
- Travail : 15h/semaine
- Études : 20h/semaine
- Repos : 50h/semaine

**Résultat attendu :**
- Score > 75 (vert)
- Aucun conflit
- Aucun jour surchargé
- Recommandations positives

### Scénario 2 : Conflits d'horaires

**Données :**
- 2 événements qui se chevauchent
- Exemple : Cours 09:00-11:00 et Job 10:00-14:00

**Résultat attendu :**
- Score diminué (pénalité conflits)
- Conflit affiché en rouge "URGENT"
- Suggestion de résolution
- Recommandation avec priorité "haute"

### Scénario 3 : Jour surchargé

**Données :**
- Plus de 12 heures d'activités un même jour

**Résultat attendu :**
- Jour identifié comme "surchargé"
- Niveau "élevé" affiché
- Recommandations de répartition
- Score pénalisé

### Scénario 4 : Planning vide

**Données :**
- Aucun événement
- Aucune disponibilité

**Résultat attendu :**
- Message "Veuillez ajouter des événements"
- État vide élégant
- Bouton "Analyser" désactivé ou message clair

---

## 🐛 Tests d'erreurs

### Test 1 : Backend indisponible

**Simulation :**
- Arrêter le backend
- Tenter une analyse

**Résultat attendu :**
- Message d'erreur clair : "Erreur de connexion réseau"
- Pas de crash
- Possibilité de réessayer

### Test 2 : Token expiré

**Simulation :**
- Attendre l'expiration du token
- Tenter une analyse

**Résultat attendu :**
- Message : "Vous devez être connecté"
- Redirection vers login (optionnel)

### Test 3 : Réponse invalide

**Simulation :**
- Backend renvoie un format incorrect

**Résultat attendu :**
- Message : "Réponse invalide du serveur"
- Logs dans la console Xcode

---

## 📊 Tests de performance

### Test 1 : Animation du score

**Observer :**
- Animation count-up fluide (0 → score)
- Durée : ~1.5 secondes
- 60 FPS constant

### Test 2 : Scroll performance

**Actions :**
- Scroller rapidement dans la liste
- Expand/collapse plusieurs cartes

**Résultat attendu :**
- Pas de lag
- Animations fluides
- 60 FPS maintenu

### Test 3 : Cache

**Actions :**
1. Lancer une analyse
2. Quitter l'écran
3. Revenir dans les 60 minutes

**Résultat attendu :**
- Données affichées instantanément
- Pas de rechargement
- Log : "✅ Cache valide"

---

## 🎨 Tests visuels

### Test Dark Mode

1. **Activer** : Settings > Appearance > Dark
2. **Vérifier** :
   - Tous les textes sont lisibles
   - Les couleurs s'adaptent
   - Les ombres sont visibles
   - Les contrastes sont bons

### Test Rotation

1. **Tourner** l'appareil en paysage
2. **Vérifier** :
   - Layout s'adapte
   - Pas de déformation
   - Tout est accessible

### Test Tailles de police

1. **Augmenter** : Settings > Accessibility > Text Size
2. **Vérifier** :
   - Textes restent lisibles
   - Pas de chevauchement
   - Layout s'adapte

---

## 📱 Tests sur différents appareils

### iPhone SE (petit écran)

- [ ] Cards visibles complètement
- [ ] Pas de texte coupé
- [ ] Boutons accessibles

### iPhone Pro Max (grand écran)

- [ ] Layout utilise bien l'espace
- [ ] Pas trop d'espaces vides
- [ ] Proportions correctes

### iPad

- [ ] Layout responsive
- [ ] Grille adaptée
- [ ] Navigation fluide

---

## 🔍 Logs à surveiller

Dans **Console Xcode**, cherchez :

```
🔵 Enhanced Routine Analyze - URL: ...
🔵 Enhanced Routine Analyze - Body: { ... }
🔵 Enhanced Routine Analyze - Status Code: 200
✅ Enhanced Routine Analyze - Success: Score = 72
💾 Analyse sauvegardée dans le cache
✅ Cache valide - Utilisation des données en cache
```

En cas d'erreur :

```
❌ Enhanced Routine Analyze - Erreur serveur: ...
🔴 Enhanced Routine Analyze - Erreur critique
```

---

## ✅ Checklist complète

### Interface
- [ ] Jauge circulaire animée
- [ ] Score avec couleur appropriée
- [ ] 4 cartes statistiques
- [ ] Barres de progression animées
- [ ] Liste des conflits
- [ ] Jours surchargés
- [ ] Recommandations IA
- [ ] Détails du score
- [ ] Résumé de santé

### Fonctionnalités
- [ ] Bouton "Analyser" fonctionne
- [ ] Loading overlay
- [ ] Pull-to-refresh
- [ ] Sélection de période
- [ ] Expand/collapse cards
- [ ] Haptic feedback
- [ ] Messages d'erreur
- [ ] Cache intelligent

### Performance
- [ ] Animations 60 FPS
- [ ] Pas de lag
- [ ] Mémoire stable
- [ ] Pas de crash

### Compatibilité
- [ ] Light mode ✅
- [ ] Dark mode ✅
- [ ] iPhone ✅
- [ ] iPad ✅
- [ ] Rotation ✅

---

## 🎯 Résultat final

Si tous les tests passent :
- ✅ Interface moderne et fluide
- ✅ Analyse IA fonctionnelle
- ✅ Gestion d'erreurs complète
- ✅ Performance optimale
- ✅ **Production Ready !** 🚀

---

## 📞 En cas de problème

1. Consultez la **Console Xcode** pour les logs
2. Vérifiez la **configuration** dans `APIConfig.swift`
3. Relisez `MON_PLANNING_README.md`
4. Vérifiez que le **backend** répond correctement

**Bon test ! 🧪**

