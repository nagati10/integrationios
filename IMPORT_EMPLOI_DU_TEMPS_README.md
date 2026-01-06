# 📄 Import emploi du temps PDF avec IA

## 🚀 Fonctionnalité

Importez votre emploi du temps au format PDF et laissez l'IA extraire automatiquement tous vos cours pour les ajouter à votre calendrier.

## 📱 Comment utiliser

### 1. Accéder à l'import
- Ouvrez le menu (☰ en haut à gauche)
- Sélectionnez **"Importer emploi du temps PDF"**

### 2. Sélectionner votre PDF
- Cliquez sur **"Sélectionner un PDF"**
- Choisissez votre fichier emploi du temps
- Attendez quelques secondes pendant le traitement

### 3. Vérifier les cours extraits
L'IA affichera tous les cours trouvés avec :
- 📅 Jour de la semaine
- ⏰ Horaires (début - fin)
- 📚 Matière
- 🏫 Salle (si disponible)
- 👨‍🏫 Professeur (si disponible)

### 4. Ajuster si nécessaire
- Glissez un cours vers la gauche pour le supprimer
- Changez la date de début de semaine avec les flèches ◀️ ▶️

### 5. Créer les événements
- Cliquez sur **"Créer les événements"**
- Tous les cours seront ajoutés à votre calendrier
- ✅ Confirmez le succès

## 🎯 Avantages

- ⚡ **Rapide** : Quelques secondes au lieu de plusieurs minutes
- 🤖 **Intelligent** : L'IA comprend différents formats
- ✏️ **Flexible** : Supprimez les cours indésirables avant création
- 📆 **Automatique** : Tous les cours ajoutés d'un coup

## ⚙️ Configuration backend

Le backend NestJS doit exposer ces endpoints :

```
POST /schedule/process          - Traitement du PDF
POST /schedule/create-events    - Création des événements
```

### Développement local
```
Base URL: http://127.0.0.1:3005
```

### Production
```
Base URL: https://talleb-5edma.onrender.com
```

## 🔧 Configuration dans l'app

Modifier `APIConfig.swift` :

```swift
// Mode développement
static let isDevelopment: Bool = true

// OU mode production
static let isDevelopment: Bool = false
```

## 📋 Format des cours extraits

```json
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

## 🛡️ Sécurité

- ✅ Authentification JWT requise
- ✅ Validation côté serveur
- ✅ Types de fichiers vérifiés (PDF uniquement)

## 🐛 Résolution des problèmes

### Le PDF n'est pas reconnu
- Vérifiez que c'est bien un PDF (pas une image)
- Le format doit être un emploi du temps standard
- Essayez avec un autre PDF

### Les cours ne sont pas tous extraits
- L'IA fait de son mieux mais peut manquer certains cours
- Vous pouvez les ajouter manuellement après

### Erreur d'authentification
- Assurez-vous d'être connecté
- Reconnectez-vous si nécessaire

### Erreur réseau
- Vérifiez votre connexion internet
- Vérifiez que le backend est démarré (développement)

## 📱 Captures d'écran

### Étape 1 : Sélection du PDF
[Interface avec bouton "Sélectionner un PDF"]

### Étape 2 : Traitement en cours
[Indicateur de chargement "Traitement en cours..."]

### Étape 3 : Cours extraits
[Liste des cours avec informations détaillées]

### Étape 4 : Création des événements
[Bouton "Créer les événements" + sélecteur de date]

### Étape 5 : Succès
[Message "X événements créés avec succès"]

## 🎓 Exemple d'utilisation

```
1. Menu → "Importer emploi du temps PDF"
2. Sélectionner "emploi_du_temps_2024.pdf"
3. ⏳ Traitement... (5-10 secondes)
4. ✅ 15 cours extraits
5. Supprimer "Réunion" (glisser à gauche)
6. Changer date de début : 02/12/2024
7. "Créer les événements"
8. ✅ 14 événements créés avec succès
```

## 🔄 Mise à jour de l'emploi du temps

Pour mettre à jour votre emploi du temps :
1. Importez le nouveau PDF
2. L'IA détectera les changements
3. Les nouveaux cours seront ajoutés
4. Les anciens cours restent inchangés (à supprimer manuellement si nécessaire)

## 💡 Conseils

- **Format PDF** : Utilisez le PDF officiel de votre établissement
- **Qualité** : Un PDF de bonne qualité donne de meilleurs résultats
- **Vérification** : Vérifiez toujours les cours extraits avant création
- **Sauvegarde** : Gardez une copie de votre PDF original

## 📞 Support

Pour toute question ou problème :
- Consultez la documentation complète : `INTEGRATION_IA_EMPLOI_DU_TEMPS.md`
- Vérifiez les logs dans la console Xcode (🔴 pour erreurs, ✅ pour succès)
- Contactez l'équipe de développement

## 🚧 Développements futurs

- [ ] Support de plusieurs formats d'emploi du temps
- [ ] Édition des cours avant création
- [ ] Import récurrent automatique
- [ ] Export vers d'autres formats
- [ ] OCR amélioré pour manuscrits

