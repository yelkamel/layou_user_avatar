# Core Interfaces

This directory contains the abstract interfaces that make the package extensible and storage-agnostic.

## Available Interfaces

### StorageProvider
Abstract interface for cloud storage operations.

**Default Implementation**: `FirebaseStorageProvider`

**Custom Implementation Example**:
```dart
class SupabaseStorageProvider implements StorageProvider {
  final SupabaseClient client;

  SupabaseStorageProvider(this.client);

  @override
  Future<String> uploadFile(String path, File file, {String? contentType}) async {
    await client.storage.from('avatars').upload(path, file);
    return getDownloadUrl(path);
  }

  @override
  Future<String?> getDownloadUrl(String path) async {
    return client.storage.from('avatars').getPublicUrl(path);
  }

  // ... implement other methods
}
```

### LocalCacheProvider
Abstract interface for local caching.

**Default Implementation**: `HiveCacheProvider`

**Custom Implementation Example**:
```dart
class SharedPreferencesCacheProvider implements LocalCacheProvider {
  late SharedPreferences _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveAvatarUrl(String userId, String url, DateTime timestamp) async {
    await _prefs.setString('avatar_$userId', url);
    await _prefs.setInt('avatar_${userId}_time', timestamp.millisecondsSinceEpoch);
  }

  // ... implement other methods
}
```

### IdentityProvider
Abstract interface for user authentication.

**Default Implementation**: `FirebaseIdentityProvider`

**Custom Implementation Example**:
```dart
class CustomAuthProvider implements IdentityProvider {
  final YourAuthService authService;

  CustomAuthProvider(this.authService);

  @override
  String? getCurrentUserId() {
    return authService.currentUser?.id;
  }

  @override
  Stream<String?> get userIdStream {
    return authService.authStateChanges.map((user) => user?.id);
  }
}
```

### ImageConverter
Abstract interface for image processing.

**Default Implementations**:
- `WebPImageConverter` (recommended)
- `WebPImageConverterFromBytes` (advanced)

**Custom Implementation Example**:
```dart
class CustomImageConverter implements ImageConverter {
  @override
  Future<File> convertToWebP(File sourceFile, {int quality = 80, int? maxSize}) async {
    // Your custom conversion logic
    // Could use platform channels, native code, etc.
    return convertedFile;
  }
}
```

## Design Philosophy

These interfaces follow the **Dependency Inversion Principle**:
- High-level modules (widgets, services) depend on abstractions
- Low-level modules (implementations) also depend on abstractions
- Abstractions don't depend on details

This allows you to:
- ✅ Switch between different backends (Firebase, Supabase, AWS)
- ✅ Test components in isolation with mocks
- ✅ Extend functionality without modifying core code
- ✅ Use the package with any auth/storage provider

## Creating Custom Implementations

1. **Implement the interface**:
```dart
class MyCustomProvider implements StorageProvider {
  // Implement all required methods
}
```

2. **Use in configuration**:
```dart
AvatarConfig(
  storageProvider: MyCustomProvider(),
  // ... other config
)
```

3. **Test thoroughly**:
```dart
test('custom provider works', () async {
  final provider = MyCustomProvider();
  // Test all interface methods
});
```

## Best Practices

### 1. Maintain Interface Contracts
Ensure your implementation respects the interface contract:
- Return types match
- Exceptions are documented
- Edge cases are handled

### 2. Handle Errors Gracefully
```dart
@override
Future<String?> getDownloadUrl(String path) async {
  try {
    return await yourStorageApi.getUrl(path);
  } catch (e) {
    // Log error but return null instead of throwing
    print('Error getting URL: $e');
    return null;
  }
}
```

### 3. Provide Progress Feedback
```dart
@override
Stream<double> getUploadProgress(String path) {
  // Return meaningful progress updates
  return yourApi.uploadStream(path).map((event) {
    return event.bytesUploaded / event.totalBytes;
  });
}
```

### 4. Clean Up Resources
```dart
class MyProvider implements StorageProvider {
  StreamController? _controller;

  Future<void> dispose() async {
    await _controller?.close();
  }
}
```

## Examples

See the `implementations/` directory for complete, production-ready examples of each interface.
