# 💻 Snippets de Code Cute - Taleb 5edma

## 🚀 Code Prêt à Copier-Coller

Guide pratique avec des exemples de code pour utiliser le nouveau design system cute.

---

## 📱 Remplacements Rapides

### 1. Dashboard Principal

**Dans `ContentView.swift` ou `DashboardView.swift`** :

```swift
// ❌ ANCIEN CODE
struct ContentView: View {
    var body: some View {
        DashboardView()
            .environmentObject(authService)
    }
}

// ✅ NOUVEAU CODE
struct ContentView: View {
    var body: some View {
        CuteDashboardView()
            .environmentObject(authService)
    }
}
```

---

### 2. Écran Calendrier

**Dans `DashboardView.swift`, TabView, tag(1)** :

```swift
// ❌ ANCIEN CODE
NavigationView {
    CalendarView()
}
.tabItem {
    Image(systemName: "calendar")
    Text("Calendrier")
}

// ✅ NOUVEAU CODE
NavigationView {
    CuteCalendarView()
}
.tabItem {
    Label("Calendrier", systemImage: "calendar")
}
```

---

### 3. Écran Disponibilités

**Dans `DashboardView.swift`, TabView, tag(2)** :

```swift
// ❌ ANCIEN CODE
NavigationView {
    AvailabilityView()
}

// ✅ NOUVEAU CODE
NavigationView {
    CuteAvailabilityView()
}
```

---

### 4. Écran Matching IA

**Dans `DashboardView.swift`, TabView, tag(3)** :

```swift
// ❌ ANCIEN CODE
MatchingAnimatedView(availabilityViewModel: availabilityViewModel)

// ✅ NOUVEAU CODE
CuteMatchingView(availabilityViewModel: availabilityViewModel)
```

---

### 5. Écran Mon Planning

**Dans `DashboardView.swift`, TabView, tag(4)** :

```swift
// ❌ ANCIEN CODE
MonPlanningView(
    evenementViewModel: evenementViewModel,
    availabilityViewModel: availabilityViewModel
)

// ✅ NOUVEAU CODE
CuteRoutineBalanceView(
    evenementViewModel: evenementViewModel,
    availabilityViewModel: availabilityViewModel
)
```

---

## 🎨 Utilisation des Composants

### Créer une Card Simple

```swift
CuteCard {
    VStack(spacing: 16) {
        Text("Mon Titre")
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundColor(AppColors.primaryWine)
        
        Text("Mon contenu ici")
            .font(.system(size: 15, design: .rounded))
            .foregroundColor(AppColors.mediumGray)
    }
    .padding(20)
}
```

**Résultat :**
```
┌─────────────────────┐
│ Mon Titre           │
│ Mon contenu ici     │
└─────────────────────┘
```

---

### Créer un Bouton Gradient

```swift
CuteGradientButton(
    title: "Enregistrer",
    emoji: "✅"
) {
    // Votre action ici
    print("Bouton tapé !")
}
.padding(.horizontal)
```

**Résultat :**
```
┌─────────────────────────┐
│ ✅ Enregistrer         │ ← Gradient rouge
└─────────────────────────┘
```

---

### Afficher un Score Circulaire

```swift
AnimatedProgressCircle(
    score: 85,
    size: 120,
    lineWidth: 12,
    emoji: "⭐"
)
```

**Résultat :**
```
    ⭕
  ⭐ 85%
```

---

### Créer une Barre de Progression

```swift
EmojiProgressBar(
    emoji: "💼",
    label: "Travail",
    value: 75,
    color: AppColors.accentRed
)
```

**Résultat :**
```
💼 Travail              75%
███████████████░░░░░░░░░
```

---

### Afficher un État Vide

```swift
CuteEmptyState(
    emoji: "📅",
    title: "Aucun événement",
    message: "Ajoute ton premier événement pour commencer !",
    buttonTitle: "Ajouter",
    action: {
        // Action
    }
)
```

**Résultat :**
```
      📅
      
  Aucun événement
Ajoute ton premier
événement pour commencer !

[✨ Ajouter]
```

---

### Créer une Section avec Header

```swift
VStack(alignment: .leading, spacing: 16) {
    CuteSectionHeader(
        emoji: "📊",
        title: "Mes Statistiques",
        subtitle: "Vue d'ensemble de la semaine"
    )
    
    // Votre contenu ici
}
```

**Résultat :**
```
📊 Mes Statistiques
   Vue d'ensemble de la semaine
───────────────────────────────
```

---

### Créer une Card Info

```swift
CuteInfoCard(
    emoji: "💡",
    title: "Conseil du jour",
    description: "Prends une pause de 10 minutes toutes les heures pour rester concentré et productif !"
)
```

**Résultat :**
```
┌─────────────────────────────┐
│ 💡 Conseil du jour          │
│    Prends une pause de 10   │
│    minutes toutes les       │
│    heures...                │
└─────────────────────────────┘
```

---

### Créer un Tag

```swift
// Tag simple
CuteTag(
    text: "Stage",
    color: AppColors.softBlue
)

// Tag avec icône
CuteTag(
    text: "Urgent",
    color: AppColors.accentRed,
    icon: "exclamationmark.triangle.fill"
)
```

**Résultat :**
```
[Stage]  [⚠️ Urgent]
```

---

## 🎯 Snippets par Écran

### Dashboard Home

```swift
struct MyHomeView: View {
    let userName = "Sarah"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Welcome
                CuteWelcomeCard(userName: userName)
                
                // Stats
                CuteStatsDonutCard(
                    jobsHours: 15,
                    coursesHours: 12,
                    otherHours: 5,
                    totalHours: 32,
                    maxHours: 40
                )
                
                // Quick Actions
                CuteQuickActionsCard(
                    onCalendar: { /* Action */ },
                    onAvailability: { /* Action */ },
                    onMatching: { /* Action */ },
                    onPlanning: { /* Action */ }
                )
            }
            .padding()
        }
    }
}
```

---

### Matching List

```swift
struct MyMatchingView: View {
    let matches: [MatchResult]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stats
                CuteMatchStatsCard(
                    totalMatches: matches.count,
                    averageScore: 85,
                    bestMatch: matches.first
                )
                
                // Matches list
                ForEach(matches) { match in
                    CuteMatchCard(match: match) {
                        // Tap action
                    }
                }
            }
            .padding()
        }
    }
}
```

---

### Calendar Events

```swift
struct MyCalendarView: View {
    let events: [Evenement]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(events) { event in
                    CuteEventCard(
                        evenement: event,
                        onTap: { /* Edit */ },
                        onDelete: { /* Delete */ }
                    )
                }
            }
            .padding()
        }
    }
}
```

---

### Availability Days

```swift
struct MyAvailabilityView: View {
    let days = ["Lundi", "Mardi", "Mercredi"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(days, id: \.self) { day in
                    CuteDayRow(
                        jour: day,
                        emoji: dayEmoji(day),
                        disponibilites: [],
                        onAdd: { /* Add */ },
                        onDelete: { _ in },
                        onEdit: { _ in }
                    )
                }
            }
            .padding()
        }
    }
    
    func dayEmoji(_ day: String) -> String {
        switch day {
        case "Lundi": return "1️⃣"
        case "Mardi": return "2️⃣"
        default: return "📅"
        }
    }
}
```

---

## 🎨 Personnalisation

### Changer les Couleurs d'un Composant

```swift
// Bouton avec gradient custom
CuteGradientButton(
    title: "Mon Bouton",
    emoji: "🚀",
    gradient: LinearGradient(
        colors: [.purple, .blue],
        startPoint: .leading,
        endPoint: .trailing
    )
) {
    // Action
}
```

---

### Modifier les Animations

```swift
// Animation plus rapide
.onAppear {
    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
        animateContent = true
    }
}

// Animation plus lente
.onAppear {
    withAnimation(.spring(response: 1.5, dampingFraction: 0.8)) {
        animateContent = true
    }
}
```

---

### Changer les Emojis

```swift
// Dans n'importe quel composant
EmojiIconCircle(
    emoji: "🎯",  // ← Changez ici
    size: 80,
    backgroundColor: AppColors.softPastelGreen
)
```

---

## 📊 Composants Interactifs

### Search Bar avec Filtres

```swift
struct MySearchView: View {
    @State private var searchText = ""
    @State private var filterCount = 0
    @State private var sortOption = SortOption.scoreDescending
    
    var body: some View {
        VStack(spacing: 12) {
            // Search bar
            CuteSearchBar(
                text: $searchText,
                placeholder: "Rechercher..."
            )
            
            // Filters row
            HStack {
                CuteFilterButton(filterCount: filterCount) {
                    // Open filters
                }
                
                Spacer()
                
                CuteSortMenu(selectedSort: $sortOption)
            }
        }
        .padding()
    }
}
```

---

### Form avec Checkboxes

```swift
struct MyFormView: View {
    @State private var option1 = false
    @State private var option2 = true
    
    var body: some View {
        VStack(spacing: 12) {
            CuteCheckbox(
                isChecked: $option1,
                label: "Notifications push",
                emoji: "🔔"
            )
            
            CuteCheckbox(
                isChecked: $option2,
                label: "Emails hebdomadaires",
                emoji: "📧"
            )
        }
        .padding()
    }
}
```

---

### Radio Buttons pour Sélection Unique

```swift
struct MySelectionView: View {
    @State private var selectedOption = 0
    
    let options = [
        ("Option 1", "1️⃣"),
        ("Option 2", "2️⃣"),
        ("Option 3", "3️⃣")
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                CuteRadioButton(
                    option: option.0,
                    isSelected: selectedOption == index,
                    emoji: option.1
                ) {
                    selectedOption = index
                }
            }
        }
        .padding()
    }
}
```

---

### Segment Control

```swift
struct MySegmentView: View {
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack {
            CuteSegmentControl(
                options: ["Jour", "Semaine", "Mois"],
                selectedIndex: $selectedIndex
            )
            
            // Contenu selon la sélection
            switch selectedIndex {
            case 0: Text("Vue Jour")
            case 1: Text("Vue Semaine")
            case 2: Text("Vue Mois")
            default: EmptyView()
            }
        }
        .padding()
    }
}
```

---

## 🎊 États & Messages

### Success Banner

```swift
struct MyView: View {
    @State private var showSuccess = false
    
    var body: some View {
        VStack {
            CuteSuccessBanner(
                message: "Enregistré avec succès !",
                isShowing: $showSuccess
            )
            
            // Votre contenu
        }
    }
}
```

---

### Error Banner

```swift
struct MyView: View {
    @State private var showError = false
    
    var body: some View {
        VStack {
            CuteErrorBanner(
                message: "Une erreur est survenue",
                isShowing: $showError
            )
            
            // Votre contenu
        }
    }
}
```

---

### Alert Cards Inline

```swift
VStack(spacing: 12) {
    // Info
    CuteAlertCard(
        emoji: "ℹ️",
        title: "Info",
        message: "Message informatif",
        type: .info
    )
    
    // Success
    CuteAlertCard(
        emoji: "✅",
        title: "Bravo !",
        message: "Opération réussie",
        type: .success
    )
    
    // Warning
    CuteAlertCard(
        emoji: "⚠️",
        title: "Attention",
        message: "Vérifie bien",
        type: .warning
    )
    
    // Error
    CuteAlertCard(
        emoji: "❌",
        title: "Erreur",
        message: "Problème détecté",
        type: .error
    )
}
```

---

## 🎯 Layouts Communs

### Liste avec Empty State

```swift
struct MyListView: View {
    let items: [Item]
    
    var body: some View {
        if items.isEmpty {
            CuteEmptyState(
                emoji: "📦",
                title: "Liste vide",
                message: "Ajoute ton premier élément",
                buttonTitle: "Ajouter",
                action: { }
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(items) { item in
                        CuteCard {
                            Text(item.name)
                                .padding()
                        }
                    }
                }
                .padding()
            }
        }
    }
}
```

---

### Loading State

```swift
struct MyView: View {
    @State private var isLoading = true
    
    var body: some View {
        if isLoading {
            CuteLoadingView(
                emoji: "🤖",
                message: "Chargement en cours..."
            )
        } else {
            // Contenu
        }
    }
}
```

---

### Grid d'Actions

```swift
CuteCard {
    LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible())
    ], spacing: 12) {
        // Action 1
        Button(action: { }) {
            VStack(spacing: 8) {
                Text("📅")
                    .font(.system(size: 32))
                Text("Calendrier")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(AppColors.softPastelBlue.opacity(0.5))
            .cornerRadius(16)
        }
        
        // Action 2
        Button(action: { }) {
            VStack(spacing: 8) {
                Text("💼")
                    .font(.system(size: 32))
                Text("Jobs")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(AppColors.softPastelGreen.opacity(0.5))
            .cornerRadius(16)
        }
    }
    .padding(20)
}
```

---

## 📝 Formulaires

### Formulaire d'Édition Simple

```swift
struct MyEditForm: View {
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    
    var body: some View {
        CuteCard {
            VStack(spacing: 16) {
                CuteSectionHeader(
                    emoji: "✏️",
                    title: "Modifier les infos"
                )
                
                // Name field
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("👤")
                        Text("Nom")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(AppColors.mediumGray)
                    }
                    
                    TextField("", text: $name)
                        .padding(12)
                        .background(AppColors.softPastelBlue.opacity(0.3))
                        .cornerRadius(12)
                }
                
                // Repeat for other fields...
                
                CuteGradientButton(
                    title: "Enregistrer",
                    emoji: "✅"
                ) {
                    // Save action
                }
            }
            .padding(20)
        }
    }
}
```

---

## 🎬 Animations

### Animation d'Apparition Standard

```swift
struct MyAnimatedView: View {
    @State private var animateContent = false
    
    var body: some View {
        VStack(spacing: 20) {
            CuteCard {
                Text("Card 1")
                    .padding()
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : -20)
            
            CuteCard {
                Text("Card 2")
                    .padding()
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : -20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
                animateContent = true
            }
        }
    }
}
```

---

### Animation de Transition

```swift
struct MyTransitionView: View {
    @State private var showDetails = false
    
    var body: some View {
        VStack {
            Button("Voir détails") {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showDetails.toggle()
                }
            }
            
            if showDetails {
                CuteCard {
                    Text("Détails")
                        .padding()
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}
```

---

## 🎯 Templates Complets

### Vue Liste Complète

```swift
struct MyCompleteListView: View {
    @State private var items: [Item] = []
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var animateContent = false
    
    var filteredItems: [Item] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { $0.name.contains(searchText) }
    }
    
    var body: some View {
        ZStack {
            AppColors.softPastelBlue.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                CuteCard {
                    HStack {
                        EmojiIconCircle(
                            emoji: "📋",
                            size: 60
                        )
                        
                        VStack(alignment: .leading) {
                            Text("Ma Liste")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.primaryWine)
                            
                            Text("\(items.count) élément(s)")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(AppColors.mediumGray)
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                }
                .padding()
                .opacity(animateContent ? 1 : 0)
                
                // Search
                CuteSearchBar(text: $searchText)
                    .padding(.horizontal)
                    .opacity(animateContent ? 1 : 0)
                
                // Content
                if isLoading {
                    CuteLoadingView()
                        .padding()
                } else if filteredItems.isEmpty {
                    CuteEmptyState(
                        emoji: "🔍",
                        title: "Aucun résultat",
                        message: "Modifie ta recherche",
                        buttonTitle: "Réinitialiser",
                        action: { searchText = "" }
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredItems) { item in
                                CuteCard {
                                    Text(item.name)
                                        .padding()
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
                animateContent = true
            }
        }
    }
}
```

---

## 🎨 Best Practices

### 1. Toujours Animer l'Apparition

```swift
@State private var animateContent = false

// Dans body
.onAppear {
    withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
        animateContent = true
    }
}
```

---

### 2. Utiliser Haptic Feedback

```swift
Button("Action") {
    HapticManager.shared.impact(style: .medium)
    // Action
}
```

---

### 3. Respecter les Espacements

```swift
VStack(spacing: 20) {  // Entre cards principales
    CuteCard {
        VStack(spacing: 16) {  // À l'intérieur d'une card
            // Contenu
        }
        .padding(20)  // Padding de card
    }
}
.padding()  // Padding de vue
```

---

### 4. Grouper par Couleur Pastel

```swift
// Succès/Positif → Green
.background(AppColors.softPastelGreen.opacity(0.5))

// Info/Neutre → Blue
.background(AppColors.softPastelBlue.opacity(0.5))

// Attention → Yellow
.background(AppColors.softPastelYellow.opacity(0.5))

// Erreur/Important → Pink
.background(AppColors.softPastelPink.opacity(0.5))
```

---

## 🚀 Quick Start Template

### Vue Complète Prête à l'Emploi

```swift
import SwiftUI

struct MyNewCuteView: View {
    @State private var animateContent = false
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    AppColors.softPastelBlue.opacity(0.3),
                    AppColors.softPastelPink.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if isLoading {
                CuteLoadingView(
                    emoji: "🤖",
                    message: "Chargement..."
                )
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        CuteCard {
                            HStack {
                                EmojiIconCircle(
                                    emoji: "✨",
                                    size: 60
                                )
                                
                                VStack(alignment: .leading) {
                                    Text("Mon Écran")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundColor(AppColors.primaryWine)
                                    
                                    Text("Sous-titre")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(AppColors.mediumGray)
                                }
                                
                                Spacer()
                            }
                            .padding(20)
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : -20)
                        
                        // Contenu principal
                        CuteCard {
                            VStack(spacing: 16) {
                                CuteSectionHeader(
                                    emoji: "📊",
                                    title: "Ma Section"
                                )
                                
                                // Votre contenu ici
                                Text("Contenu...")
                            }
                            .padding(20)
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : -20)
                        
                        // Bouton d'action
                        CuteGradientButton(
                            title: "Action Principale",
                            emoji: "🚀"
                        ) {
                            // Action
                        }
                        .padding(.horizontal)
                        .opacity(animateContent ? 1 : 0)
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
                animateContent = true
            }
        }
    }
}
```

**Copiez ce template et modifiez selon vos besoins !** 🎨

---

## 📚 Ressources

### Fichiers à Consulter

- `CuteComponents.swift` - Composants de base
- `CuteMatchingComponents.swift` - Composants matching
- `CuteDashboardComponents.swift` - Composants dashboard
- `CuteSearchComponents.swift` - Composants recherche

### Documentation

- `CUTE_DESIGN_README.md` - Introduction
- `CUTE_DESIGN_GUIDE.md` - Guide complet
- `MIGRATION_CUTE_DESIGN.md` - Migration
- `CUTE_DESIGN_SHOWCASE.md` - Aperçu visuel

---

## 🎉 Prêt à Coder !

Vous avez maintenant tous les outils pour créer des vues **cute et modernes** ! 🚀

**Bon développement ! 🎨✨**
