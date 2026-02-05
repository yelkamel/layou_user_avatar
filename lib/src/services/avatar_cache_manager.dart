import '../core/interfaces/local_cache_provider.dart';
import '../core/models/avatar_config.dart';

/// Manages caching of avatar URLs in memory and local storage.
class AvatarCacheManager {
  final AvatarConfig config;

  /// In-memory cache for fast access.
  final Map<String, CachedAvatar> _memoryCache = {};

  AvatarCacheManager(this.config);

  /// Initializes the cache manager.
  Future<void> init() async {
    await config.localCacheProvider?.init();
  }

  /// Gets an avatar URL from cache.
  ///
  /// First checks memory cache, then local cache if available.
  /// Returns null if not cached or if cache has expired based on [config.cacheTtl].
  Future<String?> get(String userId) async {
    // Check memory cache first (fastest)
    final memoryCached = _memoryCache[userId];
    if (memoryCached != null && memoryCached.isValid(config.cacheTtl)) {
      return memoryCached.url;
    }

    // Check local cache if available
    final localCache = config.localCacheProvider;
    if (localCache != null) {
      final localCached = await localCache.getAvatarUrl(userId);
      if (localCached != null && localCached.isValid(config.cacheTtl)) {
        // Update memory cache
        _memoryCache[userId] = localCached;
        return localCached.url;
      }
    }

    return null;
  }

  /// Saves an avatar URL to cache.
  ///
  /// Stores in both memory cache and local cache (if available).
  Future<void> set(String userId, String url) async {
    final now = DateTime.now();
    final cached = CachedAvatar(url: url, timestamp: now);

    // Save to memory cache
    _memoryCache[userId] = cached;

    // Save to local cache if available
    await config.localCacheProvider?.saveAvatarUrl(userId, url, now);
  }

  /// Deletes an avatar from cache.
  ///
  /// Removes from both memory cache and local cache.
  Future<void> delete(String userId) async {
    _memoryCache.remove(userId);
    await config.localCacheProvider?.deleteAvatarUrl(userId);
  }

  /// Clears all cached avatars.
  ///
  /// Useful when logging out or resetting the app.
  Future<void> clear() async {
    _memoryCache.clear();
    await config.localCacheProvider?.clear();
  }

  /// Invalidates expired cache entries based on [config.cacheTtl].
  ///
  /// This is called automatically, but can be called manually if needed.
  Future<void> cleanExpired() async {
    final ttl = config.cacheTtl;
    if (ttl == null) return; // No expiration

    // Clean memory cache
    _memoryCache.removeWhere((_, cached) => !cached.isValid(ttl));

    // Note: Local cache cleanup is not implemented here as it would require
    // iterating through all entries, which is not efficient with Hive.
    // Expired entries are checked on read instead.
  }
}
