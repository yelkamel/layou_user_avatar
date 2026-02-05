import 'dart:async';
import 'dart:io';

import '../core/models/avatar_config.dart';
import '../core/models/avatar_state.dart';
import '../core/utils/cache_busting.dart';
import '../core/utils/path_builder.dart';
import 'avatar_cache_manager.dart';

/// Result of an upload operation.
class UploadResult {
  /// The download URL of the uploaded avatar.
  final String url;

  /// The original file that was uploaded.
  final File originalFile;

  /// The converted WebP file that was uploaded.
  final File convertedFile;

  const UploadResult({
    required this.url,
    required this.originalFile,
    required this.convertedFile,
  });
}

/// Main service for avatar management.
///
/// Orchestrates avatar upload, deletion, and retrieval with caching.
class AvatarService {
  final AvatarConfig config;
  final AvatarCacheManager cacheManager;

  late final StreamController<AvatarState> _currentUserAvatarController;
  StreamSubscription<String?>? _userIdSubscription;

  AvatarService(this.config)
      : cacheManager = AvatarCacheManager(config) {
    _currentUserAvatarController = StreamController<AvatarState>.broadcast();
  }

  /// Stream of the current user's avatar state.
  ///
  /// Automatically updates when the user changes or when the avatar is uploaded/deleted.
  Stream<AvatarState> get currentUserAvatarStream =>
      _currentUserAvatarController.stream;

  /// Initializes the service.
  ///
  /// Must be called before using the service.
  Future<void> init() async {
    await cacheManager.init();
    _listenToUserChanges();
  }

  /// Disposes of resources used by the service.
  Future<void> dispose() async {
    await _userIdSubscription?.cancel();
    await _currentUserAvatarController.close();
  }

  /// Listens to user authentication changes and updates avatar state.
  void _listenToUserChanges() {
    _userIdSubscription = config.identityProvider.userIdStream.listen(
      (userId) async {
        if (userId == null) {
          _currentUserAvatarController.add(const AvatarData(null));
          return;
        }

        try {
          _currentUserAvatarController.add(const AvatarLoading());
          final url = await getAvatarUrl(userId);
          _currentUserAvatarController.add(AvatarData(url));
        } catch (e, stack) {
          _currentUserAvatarController.add(AvatarError(e, stack));
        }
      },
      onError: (error, stack) {
        _currentUserAvatarController.add(AvatarError(error, stack));
      },
    );
  }

  /// Uploads an avatar for the current user.
  ///
  /// [imageFile] is the image to upload (will be converted to WebP).
  /// [onProgress] is called with progress updates (0.0 to 1.0).
  /// [onSuccess] is called when upload completes successfully.
  /// [onError] is called if an error occurs.
  ///
  /// Returns an [UploadResult] containing the URL and file information.
  Future<UploadResult> uploadCurrentUserAvatar(
    File imageFile, {
    void Function(double progress)? onProgress,
    void Function(String url)? onSuccess,
    void Function(Object error)? onError,
  }) async {
    final userId = config.identityProvider.getCurrentUserId();
    if (userId == null) {
      final error = Exception('No user is currently authenticated');
      onError?.call(error);
      throw error;
    }

    try {
      PathBuilder.validateUserId(userId);

      // Convert to WebP
      final convertedFile = await config.imageConverter.convertToWebP(
        imageFile,
        quality: config.webpQuality,
        maxSize: config.maxImageSize,
      );

      // Build storage path
      final path = PathBuilder.normalizePath(config.pathBuilder(userId));

      // Upload to storage
      // Determine content type based on file extension
      final contentType = path.endsWith('.webp')
          ? 'image/webp'
          : path.endsWith('.png')
              ? 'image/png'
              : 'image/jpeg';

      final uploadFuture = config.storageProvider.uploadFile(
        path,
        convertedFile,
        contentType: contentType,
      );

      // Listen to progress
      final progressStream = config.storageProvider.getUploadProgress(path);
      final progressSubscription = progressStream.listen(onProgress);

      // Wait for upload to complete
      var url = await uploadFuture;

      // Cancel progress subscription
      await progressSubscription.cancel();

      // Add cache busting if enabled
      if (config.enableCacheBusting) {
        url = CacheBusting.addTimestamp(url);
      }

      // Update cache
      await cacheManager.set(userId, url);

      // Update current user avatar stream
      _currentUserAvatarController.add(AvatarData(url));

      // Call success callback
      onSuccess?.call(url);

      return UploadResult(
        url: url,
        originalFile: imageFile,
        convertedFile: convertedFile,
      );
    } catch (e, stack) {
      onError?.call(e);
      _currentUserAvatarController.add(AvatarError(e, stack));
      rethrow;
    }
  }

  /// Deletes the avatar for the current user.
  ///
  /// Removes the avatar from storage and cache.
  Future<void> deleteCurrentUserAvatar() async {
    final userId = config.identityProvider.getCurrentUserId();
    if (userId == null) {
      throw Exception('No user is currently authenticated');
    }

    try {
      PathBuilder.validateUserId(userId);

      // Build storage path
      final path = PathBuilder.normalizePath(config.pathBuilder(userId));

      // Delete from storage
      await config.storageProvider.deleteFile(path);

      // Delete from cache
      await cacheManager.delete(userId);

      // Update current user avatar stream
      _currentUserAvatarController.add(const AvatarData(null));
    } catch (e, stack) {
      _currentUserAvatarController.add(AvatarError(e, stack));
      rethrow;
    }
  }

  /// Gets the avatar URL for a specific user.
  ///
  /// First checks cache, then fetches from storage if not cached or expired.
  /// Returns null if the user has no avatar.
  Future<String?> getAvatarUrl(String userId) async {
    PathBuilder.validateUserId(userId);

    // Check cache first
    final cached = await cacheManager.get(userId);
    if (cached != null) {
      return cached;
    }

    // Fetch from storage
    final path = PathBuilder.normalizePath(config.pathBuilder(userId));
    final exists = await config.storageProvider.fileExists(path);

    if (!exists) {
      return null;
    }

    var url = await config.storageProvider.getDownloadUrl(path);
    if (url == null) {
      return null;
    }

    // Add cache busting if enabled
    if (config.enableCacheBusting) {
      url = CacheBusting.addTimestamp(url);
    }

    // Cache the URL
    await cacheManager.set(userId, url);

    return url;
  }

  /// Invalidates the cache for a specific user.
  ///
  /// Useful when you know the avatar has changed externally.
  Future<void> invalidateCache(String userId) async {
    await cacheManager.delete(userId);
  }

  /// Clears all cached avatars.
  ///
  /// Useful when logging out.
  Future<void> clearAllCache() async {
    await cacheManager.clear();
  }
}
