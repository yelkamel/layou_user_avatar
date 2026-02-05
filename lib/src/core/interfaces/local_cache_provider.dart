/// Represents a cached avatar with its URL and timestamp.
class CachedAvatar {
  /// The download URL of the avatar.
  final String url;

  /// The timestamp when the avatar was cached.
  final DateTime timestamp;

  const CachedAvatar({
    required this.url,
    required this.timestamp,
  });

  /// Checks if the cache is still valid based on the provided TTL.
  ///
  /// Returns true if [ttl] is null (no expiration) or if the cache
  /// hasn't exceeded the TTL duration.
  bool isValid(Duration? ttl) {
    if (ttl == null) return true;
    final now = DateTime.now();
    return now.difference(timestamp) < ttl;
  }
}

/// Abstract interface for local cache providers.
/// Allows the package to support different caching mechanisms (Hive, SharedPreferences, etc.)
abstract class LocalCacheProvider {
  /// Initializes the cache provider.
  ///
  /// This should be called before any other cache operations.
  /// For example, Hive needs to open a box before use.
  Future<void> init();

  /// Saves an avatar URL to the cache with a timestamp.
  Future<void> saveAvatarUrl(
    String userId,
    String url,
    DateTime timestamp,
  );

  /// Retrieves a cached avatar URL and timestamp for the specified user.
  ///
  /// Returns null if no cached avatar exists for the user.
  Future<CachedAvatar?> getAvatarUrl(String userId);

  /// Deletes the cached avatar for the specified user.
  Future<void> deleteAvatarUrl(String userId);

  /// Clears all cached avatars.
  Future<void> clear();
}
