import 'package:flutter/widgets.dart';
import '../interfaces/storage_provider.dart';
import '../interfaces/local_cache_provider.dart';
import '../interfaces/identity_provider.dart';
import '../interfaces/image_converter.dart';

/// Configuration for the avatar module.
///
/// This class contains all configuration options for avatar management,
/// including provider implementations, caching settings, and UI customization.
class AvatarConfig {
  /// The cloud storage provider implementation (required).
  final StorageProvider storageProvider;

  /// The local cache provider implementation (optional).
  /// If null, local caching will be disabled.
  final LocalCacheProvider? localCacheProvider;

  /// The identity provider for getting current user information (required).
  final IdentityProvider identityProvider;

  /// The image converter for WebP conversion (required).
  final ImageConverter imageConverter;

  /// Function to build the storage path for a user's avatar.
  ///
  /// Defaults to: 'avatars/{userId}/avatar.webp'
  ///
  /// Example custom path builder:
  /// ```dart
  /// pathBuilder: (userId) => 'users/$userId/profile/avatar.webp'
  /// ```
  final String Function(String userId) pathBuilder;

  /// How long cached avatars remain valid.
  ///
  /// If null, cached avatars never expire.
  /// If specified, cached avatars older than this duration will be refetched.
  final Duration? cacheTtl;

  /// Whether to add cache-busting timestamps to avatar URLs.
  ///
  /// When true, a timestamp query parameter is added to avatar URLs
  /// (e.g., '?t=1234567890') to ensure browsers don't use stale cached images.
  final bool enableCacheBusting;

  /// WebP compression quality (0-100).
  ///
  /// Higher values produce better quality but larger files.
  /// Default: 80
  final int webpQuality;

  /// Maximum image size in pixels (width or height).
  ///
  /// If specified, images will be resized to fit within this size
  /// while maintaining aspect ratio. If null, images keep their original size.
  final int? maxImageSize;

  /// Path to a custom placeholder asset image.
  ///
  /// This image is shown when a user has no avatar.
  /// If null, initials or a default icon will be used.
  final String? placeholderAssetPath;

  /// Custom loading widget to show during operations.
  ///
  /// If null, a default CircularProgressIndicator is used.
  final Widget? customLoader;

  const AvatarConfig({
    required this.storageProvider,
    required this.identityProvider,
    required this.imageConverter,
    this.localCacheProvider,
    this.pathBuilder = defaultPathBuilder,
    this.cacheTtl,
    this.enableCacheBusting = true,
    this.webpQuality = 80,
    this.maxImageSize,
    this.placeholderAssetPath,
    this.customLoader,
  }) : assert(webpQuality >= 0 && webpQuality <= 100,
            'webpQuality must be between 0 and 100');

  /// Default path builder: 'avatars/{userId}/avatar.webp'
  /// Note: Extension should match your ImageConverter output format
  static String defaultPathBuilder(String userId) =>
      'avatars/$userId/avatar.webp';
}
