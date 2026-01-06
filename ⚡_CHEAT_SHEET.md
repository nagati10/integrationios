# ⚡ CHEAT SHEET - Cute Design Taleb 5edma

## 🚀 Quick Reference Guide

---

## 📱 LANCER L'APP

```bash
open Taleb_5edma.xcodeproj
# Puis: Cmd+B → Cmd+R
```

---

## 🔄 MIGRER (1 ligne)

```swift
// Dans ContentView.swift
CuteDashboardView()  // au lieu de DashboardView()
```

---

## 🎨 COULEURS

```swift
AppColors.primaryWine      // #5A0E24 Titres
AppColors.warmBurgundy     // #76153C Gradients
AppColors.accentRed        // #BF124D Buttons
AppColors.softBlue         // #67B2D8 Calme
AppColors.softPastelBlue   // #E8F4F8 Background
AppColors.softPastelPink   // #FFF0F5 Background
AppColors.softPastelGreen  // #E8F5E9 Success
AppColors.softPastelYellow // #FFFDE7 Warning
```

---

## 🧩 COMPOSANTS TOP 10

```swift
1. CuteCard { ... }
2. CuteGradientButton(title: "", emoji: "") { }
3. AnimatedProgressCircle(score: 85, emoji: "⭐")
4. EmojiProgressBar(emoji: "💼", label: "", value: 75, color: .red)
5. CuteEmptyState(emoji: "", title: "", message: "", buttonTitle: "", action: {})
6. CuteSectionHeader(emoji: "", title: "", subtitle: "")
7. EmojiIconCircle(emoji: "", size: 60)
8. CuteTag(text: "", color: .blue, icon: "")
9. CuteInfoCard(emoji: "", title: "", description: "")
10. CuteLoadingView(emoji: "🤖", message: "")
```

---

## ✨ ANIMATION STANDARD

```swift
@State private var animateContent = false

.opacity(animateContent ? 1 : 0)
.offset(y: animateContent ? 0 : -20)

.onAppear {
    withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
        animateContent = true
    }
}
```

---

## 💪 HAPTIC FEEDBACK

```swift
HapticManager.shared.impact(style: .light)    // Tap
HapticManager.shared.impact(style: .medium)   // Button
HapticManager.shared.notification(type: .success) // Success
```

---

## 🎯 VUES PRINCIPALES

```swift
CuteDashboardView()           // Home
CuteCalendarView()            // Calendar
CuteAvailabilityView()        // Availability
CuteMatchingView(viewModel)   // Matching
CuteRoutineBalanceView(vm1, vm2) // Planning
CuteProfileView(authService)  // Profile
CuteOnboardingView()          // Onboarding
```

---

## 🔍 RECHERCHE & FILTRES

```swift
CuteSearchBar(text: $searchText, placeholder: "...")
CuteFilterButton(filterCount: 2) { }
CuteSortMenu(selectedSort: $sort)
CuteSegmentControl(options: ["A", "B"], selectedIndex: $index)
```

---

## ✅ FORMS & INPUTS

```swift
CuteCheckbox(isChecked: $bool, label: "", emoji: "")
CuteRadioButton(option: "", isSelected: true, emoji: "") { }
TextField("", text: $text)
    .padding(12)
    .background(AppColors.softPastelBlue.opacity(0.3))
    .cornerRadius(12)
```

---

## 📊 STATS & PROGRESS

```swift
CuteStatRow(emoji: "💼", label: "Travail", value: "15h", percentage: 75, color: .red)
CuteStatsBadge(emoji: "💼", value: "12", label: "Jobs", color: .red)
EmojiProgressBar(emoji: "📚", label: "Études", value: 60, color: .blue)
AnimatedProgressCircle(score: 85, size: 120, emoji: "⭐")
```

---

## 💬 ALERTS & MESSAGES

```swift
CuteSuccessBanner(message: "Succès !", isShowing: $show)
CuteErrorBanner(message: "Erreur", isShowing: $show)
CuteAlertCard(emoji: "ℹ️", title: "", message: "", type: .info)
```

---

## 🎨 LAYOUTS

```swift
// Vertical spacing
VStack(spacing: 20) { }

// Padding standard
.padding(20)           // Card interior
.padding(.horizontal)  // View sides

// Corner radius
.cornerRadius(16)      // Cards
.cornerRadius(12)      // Buttons small
.cornerRadius(20)      // Cards large

// Shadow standard
.shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
```

---

## 🎯 QUICK TEMPLATES

### Empty State
```swift
CuteEmptyState(
    emoji: "📅",
    title: "Vide",
    message: "Ajoute quelque chose",
    buttonTitle: "Ajouter"
) { }
```

### Loading
```swift
if isLoading {
    CuteLoadingView(emoji: "🤖", message: "Loading...")
}
```

### Card avec Header
```swift
CuteCard {
    VStack(spacing: 16) {
        CuteSectionHeader(emoji: "📊", title: "Stats")
        // Content
    }
    .padding(20)
}
```

---

## 🔗 DOCS RAPIDES

| Besoin | Doc |
|--------|-----|
| 🚀 Start | `🎨_CUTE_DESIGN_START_HERE.md` |
| 📖 Guide | `CUTE_DESIGN_GUIDE.md` |
| 💻 Code | `CUTE_CODE_SNIPPETS.md` |
| 🔄 Migrer | `MIGRATION_CUTE_DESIGN.md` |
| ✅ Check | `CUTE_FILES_CHECKLIST.md` |
| 👀 Voir | `CUTE_VISUAL_GUIDE.md` |

---

## ⚠️ TROUBLESHOOTING

### Erreur: Cannot find 'CuteCard'
```
→ Ajouter CuteComponents.swift au target
```

### Erreur: Cannot find 'primaryWine'
```
→ Vérifier AppColors.swift mis à jour
```

### Animations ne marchent pas
```
→ Vérifier @State animateContent = false
→ Vérifier .onAppear avec withAnimation
```

### Haptic ne marche pas
```
→ Tester sur device physique (pas simulator)
```

---

## 🎯 EMOJIS PAR CONTEXTE

```
Calendrier: 📅 📆 📋 📝
Travail: 💼 👔 🏢
Études: 📚 📖 🎓 ✏️
IA: 🤖 🧠 ✨
Temps: ⏰ ⏱️ 🕐
Succès: ⭐ ✅ 🎉 🎊
Conseils: 💡 🌟
Actions: 🚀 ⚡ 🎯
Jours: 1️⃣ 2️⃣ 3️⃣ 4️⃣ 5️⃣ 6️⃣ 7️⃣
```

---

## 📊 CHECKLIST EXPRESS

```
[ ] Fichiers dans target
[ ] AppColors.swift updated
[ ] Build successful (Cmd+B)
[ ] Run successful (Cmd+R)
[ ] Design looks cute
[ ] Animations smooth
[ ] Colors match palette
[ ] Emojis display
[ ] 🎉 DONE!
```

---

## 🎁 FICHIERS CLÉS

```
Must Have:
├── Utils/AppColors.swift
├── Views/Components/CuteComponents.swift
└── Views/Main/CuteDashboardView.swift

Nice to Have:
├── Toutes les autres vues Cute
└── Tous les autres composants
```

---

## 💻 COMMANDES ESSENTIELLES

```bash
# Clean
Cmd + Shift + K

# Build
Cmd + B

# Run
Cmd + R

# Stop
Cmd + .
```

---

## 🎨 GRADIENT QUICK

```swift
AppColors.cuteButtonGradient   // Red → Burgundy
AppColors.cuteSoftGradient     // Blue → White
AppColors.cuteAccentGradient   // Blue → Pink

// Custom
LinearGradient(
    colors: [.red, .blue],
    startPoint: .leading,
    endPoint: .trailing
)
```

---

## ⚡ SPACING GUIDE

```swift
VStack(spacing: 20)   // Between cards
.padding(20)          // Card padding
.padding(.horizontal) // View padding
.padding()            // All sides (16)
```

---

## 🎯 CORNER RADIUS

```swift
.cornerRadius(12)  // Small buttons, tags
.cornerRadius(16)  // Cards, inputs
.cornerRadius(20)  // Large cards
```

---

## ✨ SHADOW STANDARD

```swift
.shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
```

---

## 🚀 TEMPLATE ULTRA-RAPIDE

```swift
struct MyView: View {
    @State private var animateContent = false
    
    var body: some View {
        ZStack {
            AppColors.softPastelBlue.opacity(0.3)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    CuteCard {
                        Text("Contenu")
                            .padding()
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : -20)
                }
                .padding()
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

## 🎊 C'EST TOUT !

**Vous avez maintenant toutes les clés en main ! 🔑**

**Bon code ! 🚀✨**

---

**Cheat Sheet v1.0**  
**Taleb 5edma**  
**Décembre 2024** ⚡
