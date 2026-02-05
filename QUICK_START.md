# Quick Start Guide - layou_user_avatar

## 5-Minute Setup

### 1. Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  layou_user_avatar: ^0.1.0

  # Required peer dependencies
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  firebase_storage: ^11.6.0
  flutter_riverpod: ^2.5.0
```

### 2. Initialize Firebase

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

### 3. Configure the Package

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:layou_user_avatar/layou_user_avatar.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ProviderScope(
      overrides: [
        avatarConfigProvider.overrideWithValue(
          AvatarConfig(
            storageProvider: FirebaseStorageProviderWithProgress(
              FirebaseStorage.instance,
            ),
            localCacheProvider: HiveCacheProvider(),
            identityProvider: FirebaseIdentityProvider(
              FirebaseAuth.instance,
            ),
            imageConverter: WebPImageConverter(),
            pathBuilder: (userId) => 'avatars/$userId/avatar.webp',
            cacheTtl: const Duration(hours: 24),
            webpQuality: 80,
            maxImageSize: 512,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: const HomeScreen(),
    );
  }
}
```

### 4. Use in Your UI

#### Simple Avatar Editor
```dart
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(
        child: AvatarEditor(
          size: 120,
          onUploadSuccess: (url) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Avatar updated!')),
            );
          },
        ),
      ),
    );
  }
}
```

#### Display User Avatar (Read-Only)
```dart
class UserListItem extends ConsumerWidget {
  final String userId;
  final String userName;

  const UserListItem({
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarAsync = ref.watch(externalUserAvatarProvider(userId));

    return ListTile(
      leading: avatarAsync.when(
        data: (url) => AvatarDisplay(
          avatarUrl: url,
          userId: userId,
          size: 48,
        ),
        loading: () => const CircularProgressIndicator(),
        error: (_, __) => const Icon(Icons.person),
      ),
      title: Text(userName),
    );
  }
}
```

## Firebase Security Rules

```javascript
// Storage rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow users to read/write their own avatar
    match /avatars/{userId}/avatar.webp {
      allow read: if true; // Anyone can view avatars
      allow write: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Common Patterns

### Profile Screen with All Features
```dart
class CompleteProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarState = ref.watch(currentUserAvatarProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar editor
            AvatarEditor(
              size: 120,
              layout: AvatarEditorLayout.vertical,
              onUploadSuccess: (url) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ Avatar uploaded')),
                );
              },
              onUploadError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✗ Error: $error')),
                );
              },
              onProgress: (progress) {
                print('Upload: ${(progress * 100).toStringAsFixed(0)}%');
              },
            ),

            const SizedBox(height: 32),

            // User info
            const TextField(
              decoration: InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Custom Upload Button
```dart
class CustomUploadExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AvatarUploadButton(
      icon: const Icon(Icons.camera),
      buttonText: 'Change Photo',
      showProgress: true,
      onUploadSuccess: (url) {
        print('New avatar: $url');
      },
    );
  }
}
```

### Multiple Avatar Sizes
```dart
class AvatarSizesExample extends ConsumerWidget {
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarAsync = ref.watch(externalUserAvatarProvider(userId));

    return avatarAsync.when(
      data: (url) => Row(
        children: [
          AvatarDisplay(avatarUrl: url, size: 32),  // Small
          const SizedBox(width: 8),
          AvatarDisplay(avatarUrl: url, size: 48),  // Medium
          const SizedBox(width: 8),
          AvatarDisplay(avatarUrl: url, size: 64),  // Large
        ],
      ),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Icon(Icons.error),
    );
  }
}
```

## Customization

### Custom Storage Path
```dart
AvatarConfig(
  // ... other config
  pathBuilder: (userId) => 'users/$userId/photos/profile.webp',
)
```

### Custom Quality Settings
```dart
AvatarConfig(
  // ... other config
  webpQuality: 85,      // Higher quality (larger files)
  maxImageSize: 1024,   // Larger images
)
```

### Disable Caching
```dart
AvatarConfig(
  // ... other config
  localCacheProvider: null,  // No local cache
  enableCacheBusting: false, // No timestamps
)
```

### Custom Placeholder
```dart
AvatarDisplay(
  avatarUrl: url,
  size: 64,
  placeholder: Container(
    color: Colors.grey[300],
    child: const Icon(Icons.person, size: 32),
  ),
)
```

## Testing

### Unit Test Example
```dart
void main() {
  test('avatar config validates quality', () {
    expect(
      () => AvatarConfig(
        storageProvider: MockStorageProvider(),
        identityProvider: MockIdentityProvider(),
        imageConverter: MockImageConverter(),
        webpQuality: 150,  // Invalid
      ),
      throwsAssertionError,
    );
  });
}
```

### Widget Test Example
```dart
testWidgets('shows avatar display', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AvatarDisplay(
        avatarUrl: 'https://example.com/avatar.webp',
        size: 64,
      ),
    ),
  );

  expect(find.byType(AvatarDisplay), findsOneWidget);
});
```

## Troubleshooting

### "UnimplementedError: AvatarConfig must be overridden"
**Solution**: Add `avatarConfigProvider.overrideWithValue(...)` in your `ProviderScope`

### Avatar not updating after upload
**Solution**: The package uses streams, so it should update automatically. Check that you're using `ConsumerWidget` and watching the provider.

### Upload fails silently
**Solution**: Add error callbacks to see what's happening:
```dart
AvatarUploadButton(
  onUploadError: (error) => print('Error: $error'),
)
```

### Firebase permission denied
**Solution**: Check your Firebase Storage security rules allow the user to write to their path.

## Next Steps

- ✅ Set up Firebase Storage security rules
- ✅ Customize avatar sizes and quality for your needs
- ✅ Add error handling and user feedback
- ✅ Test on real devices
- ✅ Monitor storage usage in Firebase Console

## Need Help?

- 📖 [Full Documentation](README.md)
- 🔧 [API Reference](https://pub.dev/documentation/layou_user_avatar)
- 💡 [Example App](example/)
- 🐛 [Report Issues](https://github.com/layou/layou_user_avatar/issues)

---

**That's it!** You now have a complete avatar management system with WebP compression, caching, and Firebase integration.
