# layou_user_avatar

A customizable Flutter package for user avatar management with Firebase, Riverpod, image optimization, and caching.

## Features

- Upload and delete user avatars
- Automatic WebP conversion for optimal file size (25-35% smaller than PNG/JPEG)
- Image resizing with aspect ratio preservation
- Local and memory caching with configurable TTL
- Customizable widgets for display, upload, and deletion
- Riverpod integration for state management
- Firebase Storage integration (with extensible storage provider interface)
- Configurable storage paths
- Progress callbacks and error handling
- Cache busting support
- Native WebP support on Android and iOS

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  layou_user_avatar: ^0.1.0
```

## Quick Start

### 1. Configure the package at app startup

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layou_user_avatar/layou_user_avatar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ProviderScope(
      overrides: [
        avatarConfigProvider.overrideWithValue(
          AvatarConfig(
            storageProvider: FirebaseStorageProvider(FirebaseStorage.instance),
            localCacheProvider: HiveCacheProvider(),
            identityProvider: FirebaseIdentityProvider(FirebaseAuth.instance),
            imageConverter: WebPImageConverter(),
            pathBuilder: (userId) => 'avatars/$userId/avatar.webp',
            cacheTtl: Duration(hours: 24),
            webpQuality: 85,
            maxImageSize: 512,
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}
```

### 2. Display and edit current user's avatar

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layou_user_avatar/layou_user_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(
        child: AvatarEditor(
          size: 120,
          onUploadSuccess: (url) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Avatar uploaded!')),
            );
          },
          onUploadError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Upload failed: $error')),
            );
          },
          onProgress: (progress) {
            print('Upload progress: ${(progress * 100).toStringAsFixed(0)}%');
          },
        ),
      ),
    );
  }
}
```

### 3. Display external user avatar (read-only)

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
        loading: () => CircularProgressIndicator(),
        error: (err, stack) => Icon(Icons.error),
      ),
      title: Text(userName),
    );
  }
}
```

## Widgets

### AvatarEditor

All-in-one widget combining avatar display, upload, and delete functionality.

```dart
AvatarEditor(
  size: 120,
  showUploadButton: true,
  showDeleteButton: true,
  onUploadSuccess: (url) => print('Uploaded: $url'),
  onUploadError: (error) => print('Error: $error'),
  onDeleteSuccess: () => print('Deleted'),
  onProgress: (progress) => print('Progress: $progress'),
)
```

### AvatarDisplay

Read-only avatar display with placeholder support.

```dart
AvatarDisplay(
  avatarUrl: 'https://example.com/avatar.webp',
  userId: 'user123',
  size: 64,
  enableCaching: true,
  onError: () => print('Failed to load avatar'),
)
```

### AvatarUploadButton

Standalone upload button with image picker.

```dart
AvatarUploadButton(
  currentAvatarUrl: currentUrl,
  onUploadSuccess: (url) => print('Uploaded: $url'),
  onUploadError: (error) => print('Error: $error'),
  onProgress: (progress) => print('Progress: $progress'),
  showProgress: true,
)
```

### AvatarDeleteButton

Standalone delete button with optional confirmation dialog.

```dart
AvatarDeleteButton(
  onDeleteSuccess: () => print('Deleted'),
  onDeleteError: (error) => print('Error: $error'),
  confirmDelete: true,
)
```

## Configuration Options

### AvatarConfig

```dart
AvatarConfig(
  // Required
  storageProvider: StorageProvider,      // Cloud storage implementation
  identityProvider: IdentityProvider,    // User identity provider
  imageConverter: ImageConverter,        // Image conversion implementation

  // Optional
  localCacheProvider: LocalCacheProvider?, // Local cache (null = no cache)
  pathBuilder: String Function(String userId), // Custom path builder
  cacheTtl: Duration?,                   // Cache expiration (null = no expiry)
  enableCacheBusting: bool,              // Add timestamp to URLs
  webpQuality: int,                      // WebP quality (0-100, default: 80)
  maxImageSize: int?,                    // Max size in pixels (null = no limit)
  placeholderAssetPath: String?,         // Custom placeholder asset
  customLoader: Widget?,                 // Custom loading widget
)
```

## Extensibility

The package is designed to be storage-agnostic. You can implement custom providers:

### Custom Storage Provider

```dart
class MyStorageProvider implements StorageProvider {
  @override
  Future<String> uploadFile(String path, File file, {String? contentType}) {
    // Your implementation
  }

  @override
  Future<String> getDownloadUrl(String path) {
    // Your implementation
  }

  @override
  Future<void> deleteFile(String path) {
    // Your implementation
  }

  @override
  Future<bool> fileExists(String path) {
    // Your implementation
  }

  @override
  Stream<double> getUploadProgress(String path) {
    // Your implementation
  }
}
```

## Publishing to pub.dev

For package maintainers:

### 1. Update version in pubspec.yaml

```yaml
version: 0.1.3  # Increment according to semver
```

### 2. Update CHANGELOG.md

Add entry for the new version with changes.

### 3. Dry run

```bash
dart pub publish --dry-run
```

Verify the package analysis and check warnings.

### 4. Publish

```bash
dart pub publish
```

Follow the prompts to complete publication.

### 5. Create git tag

```bash
git tag v0.1.3
git push origin v0.1.3
```

## Repository Structure

This package is maintained in a parent repository structure:

- **Public repo** (this repo): https://github.com/yelkamel/layou_user_avatar
- **Private parent repo**: Contains development tools and prompts

Updates are pushed from the parent repo using git subtree.

## License

MIT License - see LICENSE file for details.
