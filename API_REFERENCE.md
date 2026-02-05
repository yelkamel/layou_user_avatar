# API Reference

Complete API documentation for `layou_user_avatar`.

## Table of Contents

- [Configuration](#configuration)
- [Services](#services)
- [Providers](#providers)
- [Widgets](#widgets)
- [Models](#models)
- [Interfaces](#interfaces)
- [Implementations](#implementations)

---

## Configuration

### AvatarConfig

Main configuration class for the package.

```dart
class AvatarConfig {
  AvatarConfig({
    required StorageProvider storageProvider,
    required IdentityProvider identityProvider,
    required ImageConverter imageConverter,
    LocalCacheProvider? localCacheProvider,
    String Function(String userId) pathBuilder = defaultPathBuilder,
    Duration? cacheTtl,
    bool enableCacheBusting = true,
    int webpQuality = 80,
    int? maxImageSize,
    String? placeholderAssetPath,
    Widget? customLoader,
  })
}
```

**Required Parameters:**
- `storageProvider`: Cloud storage implementation
- `identityProvider`: User authentication implementation
- `imageConverter`: Image conversion implementation

**Optional Parameters:**
- `localCacheProvider`: Local cache (null = no cache)
- `pathBuilder`: Function to build storage paths
- `cacheTtl`: Cache expiration duration (null = no expiration)
- `enableCacheBusting`: Add timestamps to URLs
- `webpQuality`: WebP compression quality (0-100, default: 80)
- `maxImageSize`: Maximum image dimension in pixels
- `placeholderAssetPath`: Custom placeholder image asset
- `customLoader`: Custom loading widget

---

## Services

### AvatarService

Main service for avatar operations.

#### Methods

##### `init()`
```dart
Future<void> init()
```
Initializes the service. Must be called before use.

##### `uploadCurrentUserAvatar()`
```dart
Future<UploadResult> uploadCurrentUserAvatar(
  File imageFile, {
  void Function(double progress)? onProgress,
  void Function(String url)? onSuccess,
  void Function(Object error)? onError,
})
```
Uploads avatar for the current authenticated user.

**Parameters:**
- `imageFile`: Image file to upload
- `onProgress`: Callback for progress (0.0 to 1.0)
- `onSuccess`: Callback when upload succeeds
- `onError`: Callback if upload fails

**Returns:** `UploadResult` with URL and file info

**Throws:** `Exception` if no user is authenticated

##### `deleteCurrentUserAvatar()`
```dart
Future<void> deleteCurrentUserAvatar()
```
Deletes the avatar of the current user.

**Throws:** `Exception` if no user is authenticated

##### `getAvatarUrl()`
```dart
Future<String?> getAvatarUrl(String userId)
```
Gets avatar URL for any user (with caching).

**Parameters:**
- `userId`: ID of the user

**Returns:** Avatar URL or null if no avatar exists

##### `invalidateCache()`
```dart
Future<void> invalidateCache(String userId)
```
Invalidates cached avatar for a specific user.

##### `clearAllCache()`
```dart
Future<void> clearAllCache()
```
Clears all cached avatars.

#### Properties

##### `currentUserAvatarStream`
```dart
Stream<AvatarState> get currentUserAvatarStream
```
Stream of current user's avatar state. Automatically updates when user changes or avatar is uploaded/deleted.

---

### AvatarCacheManager

Manages avatar caching (memory + local storage).

#### Methods

##### `init()`
```dart
Future<void> init()
```
Initializes the cache manager.

##### `get()`
```dart
Future<String?> get(String userId)
```
Gets cached avatar URL.

##### `set()`
```dart
Future<void> set(String userId, String url)
```
Caches an avatar URL.

##### `delete()`
```dart
Future<void> delete(String userId)
```
Deletes cached avatar.

##### `clear()`
```dart
Future<void> clear()
```
Clears all cached avatars.

---

## Providers

### avatarConfigProvider
```dart
final avatarConfigProvider = Provider<AvatarConfig>((ref) {
  throw UnimplementedError('Must override in ProviderScope');
});
```
**Must be overridden** in your app's `ProviderScope`.

### avatarServiceProvider
```dart
final avatarServiceProvider = Provider<AvatarService>((ref) { ... });
```
Provides initialized `AvatarService` instance.

### currentUserAvatarProvider
```dart
final currentUserAvatarProvider = StreamProvider<AvatarState>((ref) { ... });
```
Streams current user's avatar state.

**Usage:**
```dart
final avatarState = ref.watch(currentUserAvatarProvider);
avatarState.when(
  data: (state) => ...,
  loading: () => ...,
  error: (error, stack) => ...,
);
```

### externalUserAvatarProvider
```dart
final externalUserAvatarProvider = FutureProvider.family<String?, String>(
  (ref, userId) async { ... }
);
```
Fetches avatar URL for external users (with caching).

**Usage:**
```dart
final avatarAsync = ref.watch(externalUserAvatarProvider('userId'));
```

### avatarUploadStateProvider
```dart
final avatarUploadStateProvider =
  StateNotifierProvider<AvatarUploadNotifier, UploadState>((ref) { ... });
```
Manages upload state with progress tracking.

**Methods:**
- `uploadAvatar(File imageFile)`: Start upload
- `reset()`: Reset to idle state

---

## Widgets

### AvatarDisplay

Read-only avatar display widget.

```dart
class AvatarDisplay extends StatelessWidget {
  const AvatarDisplay({
    Key? key,
    String? avatarUrl,
    String? userId,
    double size = 48.0,
    Widget? placeholder,
    Widget? loader,
    bool enableCaching = true,
    VoidCallback? onError,
    Color? backgroundColor,
    Color? foregroundColor,
  });
}
```

**Parameters:**
- `avatarUrl`: Avatar image URL
- `userId`: User ID (for generating initials)
- `size`: Avatar size (width = height)
- `placeholder`: Custom placeholder widget
- `loader`: Custom loading widget
- `enableCaching`: Use cached network images
- `onError`: Callback on load error
- `backgroundColor`: Background color for placeholder
- `foregroundColor`: Text color for initials

**Example:**
```dart
AvatarDisplay(
  avatarUrl: 'https://example.com/avatar.webp',
  userId: 'user123',
  size: 64,
)
```

---

### AvatarUploadButton

Button to upload avatar with image picker.

```dart
class AvatarUploadButton extends ConsumerWidget {
  const AvatarUploadButton({
    Key? key,
    String? currentAvatarUrl,
    VoidCallback? onUploadStart,
    void Function(String url)? onUploadSuccess,
    void Function(Object error)? onUploadError,
    void Function(double progress)? onProgress,
    Widget? customLoader,
    Widget? icon,
    bool showProgress = false,
    String? buttonText,
    ImageSource imageSource = ImageSource.gallery,
  });
}
```

**Parameters:**
- `currentAvatarUrl`: Current avatar URL (optional)
- `onUploadStart`: Called when upload starts
- `onUploadSuccess`: Called with new avatar URL
- `onUploadError`: Called on error
- `onProgress`: Called with progress (0.0-1.0)
- `customLoader`: Custom loading widget
- `icon`: Custom button icon
- `showProgress`: Show percentage during upload
- `buttonText`: Custom button text
- `imageSource`: Image picker source (gallery/camera)

**Example:**
```dart
AvatarUploadButton(
  onUploadSuccess: (url) => print('Uploaded: $url'),
  onProgress: (p) => print('${(p * 100).toInt()}%'),
  showProgress: true,
)
```

---

### AvatarDeleteButton

Button to delete avatar with optional confirmation.

```dart
class AvatarDeleteButton extends ConsumerStatefulWidget {
  const AvatarDeleteButton({
    Key? key,
    VoidCallback? onDeleteSuccess,
    void Function(Object error)? onDeleteError,
    bool confirmDelete = true,
    Widget? icon,
    String? buttonText,
    String? confirmTitle,
    String? confirmMessage,
  });
}
```

**Parameters:**
- `onDeleteSuccess`: Called after successful deletion
- `onDeleteError`: Called on error
- `confirmDelete`: Show confirmation dialog
- `icon`: Custom button icon
- `buttonText`: Custom button text
- `confirmTitle`: Custom dialog title
- `confirmMessage`: Custom dialog message

**Example:**
```dart
AvatarDeleteButton(
  confirmDelete: true,
  onDeleteSuccess: () => print('Deleted'),
)
```

---

### AvatarEditor

All-in-one avatar editor widget.

```dart
class AvatarEditor extends ConsumerWidget {
  const AvatarEditor({
    Key? key,
    double size = 120.0,
    bool showUploadButton = true,
    bool showDeleteButton = true,
    void Function(String url)? onUploadSuccess,
    void Function(Object error)? onUploadError,
    VoidCallback? onDeleteSuccess,
    void Function(double progress)? onProgress,
    Widget? customLoader,
    Color? backgroundColor,
    Color? foregroundColor,
    bool showProgress = true,
    AvatarEditorLayout layout = AvatarEditorLayout.vertical,
  });
}
```

**Parameters:**
- `size`: Avatar size
- `showUploadButton`: Show upload button
- `showDeleteButton`: Show delete button
- `onUploadSuccess`: Upload success callback
- `onUploadError`: Error callback
- `onDeleteSuccess`: Delete success callback
- `onProgress`: Upload progress callback
- `customLoader`: Custom loading widget
- `backgroundColor`: Avatar background color
- `foregroundColor`: Avatar foreground color
- `showProgress`: Show upload progress
- `layout`: Layout mode (vertical/horizontal/overlay)

**Layout Modes:**
- `AvatarEditorLayout.vertical`: Buttons below avatar
- `AvatarEditorLayout.horizontal`: Buttons beside avatar
- `AvatarEditorLayout.overlay`: Edit badge on avatar

**Example:**
```dart
AvatarEditor(
  size: 120,
  layout: AvatarEditorLayout.vertical,
  onUploadSuccess: (url) => showSuccessMessage(),
)
```

---

## Models

### AvatarState

Sealed class representing avatar state.

```dart
sealed class AvatarState {}

class AvatarLoading extends AvatarState {}

class AvatarData extends AvatarState {
  final String? url;
  bool get hasAvatar;
}

class AvatarError extends AvatarState {
  final Object error;
  final StackTrace? stackTrace;
}
```

### UploadState

Sealed class representing upload state.

```dart
sealed class UploadState {}

class UploadIdle extends UploadState {}

class UploadInProgress extends UploadState {
  final double progress; // 0.0 to 1.0
  int get progressPercent; // 0 to 100
}

class UploadSuccess extends UploadState {
  final String url;
}

class UploadError extends UploadState {
  final Object error;
  final StackTrace? stackTrace;
}
```

### CachedAvatar

Represents a cached avatar entry.

```dart
class CachedAvatar {
  final String url;
  final DateTime timestamp;

  bool isValid(Duration? ttl);
}
```

### UploadResult

Result of an upload operation.

```dart
class UploadResult {
  final String url;
  final File originalFile;
  final File convertedFile;
}
```

---

## Interfaces

All interfaces are in `lib/src/core/interfaces/`.

### StorageProvider

```dart
abstract class StorageProvider {
  Future<String> uploadFile(String path, File file, {String? contentType});
  Future<String?> getDownloadUrl(String path);
  Future<void> deleteFile(String path);
  Future<bool> fileExists(String path);
  Stream<double> getUploadProgress(String path);
}
```

### LocalCacheProvider

```dart
abstract class LocalCacheProvider {
  Future<void> init();
  Future<void> saveAvatarUrl(String userId, String url, DateTime timestamp);
  Future<CachedAvatar?> getAvatarUrl(String userId);
  Future<void> deleteAvatarUrl(String userId);
  Future<void> clear();
}
```

### IdentityProvider

```dart
abstract class IdentityProvider {
  String? getCurrentUserId();
  Stream<String?> get userIdStream;
}
```

### ImageConverter

```dart
abstract class ImageConverter {
  Future<File> convertToWebP(
    File sourceFile, {
    int quality = 80,
    int? maxSize,
  });
}
```

---

## Implementations

Default implementations are provided in `lib/src/implementations/`.

### FirebaseStorageProvider / FirebaseStorageProviderWithProgress

Firebase Storage implementation with optional progress tracking.

### FirebaseIdentityProvider

Firebase Auth implementation.

### HiveCacheProvider

Hive-based local cache implementation.

### WebPImageConverter / WebPImageConverterFromBytes

WebP image conversion implementations using `flutter_image_compress`.

---

## Utilities

### CacheBusting

```dart
class CacheBusting {
  static String addTimestamp(String url);
  static String removeTimestamp(String url);
}
```

### PathBuilder

```dart
class PathBuilder {
  static void validateUserId(String userId);
  static String normalizePath(String path);
}
```

---

## Error Handling

### Common Exceptions

- **UnimplementedError**: `avatarConfigProvider` not overridden
- **Exception**: No authenticated user during upload/delete
- **ArgumentError**: Invalid user ID in path builder
- **Upload failure**: Returns via `onError` callback

### Best Practices

1. Always provide error callbacks:
```dart
AvatarEditor(
  onUploadError: (error) => handleError(error),
)
```

2. Handle auth state changes:
```dart
ref.listen(currentUserAvatarProvider, (previous, next) {
  next.whenOrNull(
    error: (error, _) => showErrorDialog(error),
  );
});
```

3. Validate before operations:
```dart
final userId = identityProvider.getCurrentUserId();
if (userId == null) {
  showLoginPrompt();
  return;
}
```

---

## Migration Guide

### From PNG to WebP

```dart
// Before
pathBuilder: (userId) => 'avatars/$userId/avatar.png'

// After
pathBuilder: (userId) => 'avatars/$userId/avatar.webp'
```

### From Other Avatar Packages

1. Remove old package
2. Add `layou_user_avatar`
3. Configure with your storage provider
4. Replace old widgets with new ones
5. Test thoroughly

---

## Performance Tips

1. **Set appropriate maxImageSize**:
```dart
maxImageSize: 512, // Avatars don't need to be huge
```

2. **Use caching**:
```dart
localCacheProvider: HiveCacheProvider(),
cacheTtl: Duration(hours: 24),
```

3. **Show progress for large uploads**:
```dart
AvatarEditor(showProgress: true)
```

4. **Use overlay layout for compact UI**:
```dart
AvatarEditor(layout: AvatarEditorLayout.overlay)
```

---

For more examples, see the [example app](example/) and [Quick Start Guide](QUICK_START.md).
