# Examples - layou_user_avatar

## Configuration Minimale

```dart
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:layou_user_avatar/layou_user_avatar.dart';

// Dans votre main.dart
ProviderScope(
  overrides: [
    avatarConfigProvider.overrideWithValue(
      AvatarConfig(
        storageProvider: FirebaseStorageProviderWithProgress(
          FirebaseStorage.instance,
        ),
        identityProvider: FirebaseIdentityProvider(
          FirebaseAuth.instance,
        ),
        imageConverter: WebPImageConverter(),
        // Optionnel: cache local
        localCacheProvider: HiveCacheProvider(),
      ),
    ),
  ],
  child: MyApp(),
)
```

## Utilisation Simple - Avatar Editor

```dart
// Widget tout-en-un pour profil utilisateur
AvatarEditor(
  size: 120,
  onUploadSuccess: (url) {
    print('Avatar uploadé: $url');
  },
)
```

## Configuration Avancée

```dart
AvatarConfig(
  storageProvider: FirebaseStorageProviderWithProgress(
    FirebaseStorage.instance,
  ),
  identityProvider: FirebaseIdentityProvider(
    FirebaseAuth.instance,
  ),
  imageConverter: WebPImageConverter(),
  localCacheProvider: HiveCacheProvider(),

  // Path personnalisé
  pathBuilder: (userId) => 'users/$userId/profile/avatar.webp',

  // Cache TTL
  cacheTtl: Duration(days: 7),

  // Qualité WebP
  webpQuality: 85,

  // Taille max
  maxImageSize: 1024,

  // Cache busting
  enableCacheBusting: true,
)
```

## Display Avatar (Read-Only)

```dart
// Pour afficher l'avatar d'un autre utilisateur
final avatarAsync = ref.watch(externalUserAvatarProvider(userId));

avatarAsync.when(
  data: (url) => AvatarDisplay(
    avatarUrl: url,
    userId: userId,
    size: 64,
  ),
  loading: () => CircularProgressIndicator(),
  error: (_, __) => Icon(Icons.person),
)
```

## Upload Manuel

```dart
AvatarUploadButton(
  onUploadSuccess: (url) => print('Upload OK: $url'),
  onUploadError: (error) => print('Erreur: $error'),
  showProgress: true,
)
```

## Delete Avatar

```dart
AvatarDeleteButton(
  confirmDelete: true,
  onDeleteSuccess: () => print('Avatar supprimé'),
)
```

## Layouts Différents

```dart
// Vertical (par défaut)
AvatarEditor(
  size: 120,
  layout: AvatarEditorLayout.vertical,
)

// Horizontal
AvatarEditor(
  size: 100,
  layout: AvatarEditorLayout.horizontal,
)

// Overlay (badge sur l'avatar)
AvatarEditor(
  size: 120,
  layout: AvatarEditorLayout.overlay,
)
```

## Gestion d'Erreurs

```dart
AvatarEditor(
  size: 120,
  onUploadError: (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: ${error.toString()}')),
    );
  },
  onDeleteSuccess: () {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Avatar supprimé')),
    );
  },
)
```

## Progress Tracking

```dart
AvatarEditor(
  size: 120,
  showProgress: true,
  onProgress: (progress) {
    print('Upload: ${(progress * 100).toInt()}%');
  },
)
```

## Custom Placeholder

```dart
AvatarDisplay(
  avatarUrl: url,
  size: 64,
  placeholder: Container(
    color: Colors.grey,
    child: Icon(Icons.camera_alt),
  ),
)
```

## Firebase Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /avatars/{userId}/avatar.webp {
      allow read: if true;
      allow write, delete: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Erreurs Courantes

### 1. UnimplementedError: avatarConfigProvider must be overridden
**Solution:** Ajouter l'override dans `ProviderScope`

### 2. No user is currently authenticated
**Solution:** L'utilisateur doit être connecté avant d'uploader

### 3. Permission denied
**Solution:** Vérifier les règles Firebase Storage
