import 'package:flutter_test/flutter_test.dart';
import 'package:layou_user_avatar/layou_user_avatar.dart';
import 'package:mockito/mockito.dart';

// Mock implementations for testing
class MockStorageProvider extends Mock implements StorageProvider {}

class MockIdentityProvider extends Mock implements IdentityProvider {}

class MockImageConverter extends Mock implements ImageConverter {}

class MockLocalCacheProvider extends Mock implements LocalCacheProvider {}

void main() {
  group('AvatarConfig', () {
    test('creates config with required parameters', () {
      final config = AvatarConfig(
        storageProvider: MockStorageProvider(),
        identityProvider: MockIdentityProvider(),
        imageConverter: MockImageConverter(),
      );

      expect(config.storageProvider, isA<StorageProvider>());
      expect(config.identityProvider, isA<IdentityProvider>());
      expect(config.imageConverter, isA<ImageConverter>());
      expect(config.enableCacheBusting, true);
      expect(config.webpQuality, 80);
    });

    test('creates config with optional parameters', () {
      final config = AvatarConfig(
        storageProvider: MockStorageProvider(),
        identityProvider: MockIdentityProvider(),
        imageConverter: MockImageConverter(),
        localCacheProvider: MockLocalCacheProvider(),
        cacheTtl: const Duration(hours: 24),
        webpQuality: 90,
        maxImageSize: 512,
        enableCacheBusting: false,
      );

      expect(config.localCacheProvider, isNotNull);
      expect(config.cacheTtl, const Duration(hours: 24));
      expect(config.webpQuality, 90);
      expect(config.maxImageSize, 512);
      expect(config.enableCacheBusting, false);
    });

    test('uses default path builder', () {
      final config = AvatarConfig(
        storageProvider: MockStorageProvider(),
        identityProvider: MockIdentityProvider(),
        imageConverter: MockImageConverter(),
      );

      final path = config.pathBuilder('user123');
      expect(path, 'avatars/user123/avatar.webp');
    });

    test('accepts custom path builder', () {
      final config = AvatarConfig(
        storageProvider: MockStorageProvider(),
        identityProvider: MockIdentityProvider(),
        imageConverter: MockImageConverter(),
        pathBuilder: (userId) => 'custom/$userId/photo.jpg',
      );

      final path = config.pathBuilder('user456');
      expect(path, 'custom/user456/photo.jpg');
    });

    test('validates webpQuality range', () {
      expect(
        () => AvatarConfig(
          storageProvider: MockStorageProvider(),
          identityProvider: MockIdentityProvider(),
          imageConverter: MockImageConverter(),
          webpQuality: -1,
        ),
        throwsAssertionError,
      );

      expect(
        () => AvatarConfig(
          storageProvider: MockStorageProvider(),
          identityProvider: MockIdentityProvider(),
          imageConverter: MockImageConverter(),
          webpQuality: 101,
        ),
        throwsAssertionError,
      );
    });
  });

  group('CachedAvatar', () {
    test('isValid returns true when no TTL', () {
      final cached = CachedAvatar(
        url: 'https://example.com/avatar.png',
        timestamp: DateTime.now().subtract(const Duration(days: 30)),
      );

      expect(cached.isValid(null), true);
    });

    test('isValid returns true when within TTL', () {
      final cached = CachedAvatar(
        url: 'https://example.com/avatar.png',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      );

      expect(cached.isValid(const Duration(hours: 24)), true);
    });

    test('isValid returns false when expired', () {
      final cached = CachedAvatar(
        url: 'https://example.com/avatar.png',
        timestamp: DateTime.now().subtract(const Duration(hours: 25)),
      );

      expect(cached.isValid(const Duration(hours: 24)), false);
    });
  });

  group('AvatarState', () {
    test('AvatarLoading is created', () {
      const state = AvatarLoading();
      expect(state, isA<AvatarState>());
    });

    test('AvatarData holds url', () {
      const state = AvatarData('https://example.com/avatar.png');
      expect(state.url, 'https://example.com/avatar.png');
      expect(state.hasAvatar, true);
    });

    test('AvatarData null url means no avatar', () {
      const state = AvatarData(null);
      expect(state.url, null);
      expect(state.hasAvatar, false);
    });

    test('AvatarError holds error', () {
      final error = Exception('Test error');
      final state = AvatarError(error);
      expect(state.error, error);
    });
  });

  group('UploadState', () {
    test('UploadIdle is created', () {
      const state = UploadIdle();
      expect(state, isA<UploadState>());
    });

    test('UploadInProgress holds progress', () {
      const state = UploadInProgress(0.5);
      expect(state.progress, 0.5);
      expect(state.progressPercent, 50);
    });

    test('UploadSuccess holds url', () {
      const state = UploadSuccess('https://example.com/avatar.png');
      expect(state.url, 'https://example.com/avatar.png');
    });

    test('UploadError holds error', () {
      final error = Exception('Upload failed');
      final state = UploadError(error);
      expect(state.error, error);
    });
  });
}
