import 'package:hive_flutter/hive_flutter.dart';

import '../core/interfaces/local_cache_provider.dart';

/// Hive implementation of [LocalCacheProvider].
class HiveCacheProvider implements LocalCacheProvider {
  static const String boxName = 'layou_avatar_cache';
  Box? _box;

  @override
  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox(boxName);
    } else {
      _box = Hive.box(boxName);
    }
  }

  Box get _ensureBox {
    if (_box == null) {
      throw StateError(
        'HiveCacheProvider not initialized. Call init() first.',
      );
    }
    return _box!;
  }

  @override
  Future<void> saveAvatarUrl(
    String userId,
    String url,
    DateTime timestamp,
  ) async {
    await _ensureBox.put('avatar_$userId', {
      'url': url,
      'timestamp': timestamp.millisecondsSinceEpoch,
    });
  }

  @override
  Future<CachedAvatar?> getAvatarUrl(String userId) async {
    final data = _ensureBox.get('avatar_$userId') as Map<dynamic, dynamic>?;

    if (data == null) return null;

    final url = data['url'] as String?;
    final timestampMs = data['timestamp'] as int?;

    if (url == null || timestampMs == null) return null;

    return CachedAvatar(
      url: url,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
    );
  }

  @override
  Future<void> deleteAvatarUrl(String userId) async {
    await _ensureBox.delete('avatar_$userId');
  }

  @override
  Future<void> clear() async {
    await _ensureBox.clear();
  }
}
