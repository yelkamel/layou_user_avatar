/// Utilities for building storage paths.
class PathBuilder {
  /// Validates that a user ID is suitable for use in a file path.
  ///
  /// Throws an [ArgumentError] if the user ID is invalid.
  static void validateUserId(String userId) {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    // Check for invalid characters that might cause issues in storage paths
    final invalidChars = ['/', '\\', '..', '<', '>', ':', '"', '|', '?', '*'];
    for (final char in invalidChars) {
      if (userId.contains(char)) {
        throw ArgumentError(
          'User ID contains invalid character: $char',
        );
      }
    }
  }

  /// Normalizes a storage path by removing duplicate slashes and ensuring
  /// it doesn't start with a slash (which can cause issues with some storage providers).
  static String normalizePath(String path) {
    // Remove leading slash
    var normalized = path.startsWith('/') ? path.substring(1) : path;

    // Replace multiple slashes with single slash
    normalized = normalized.replaceAll(RegExp(r'/+'), '/');

    // Remove trailing slash
    normalized = normalized.endsWith('/') && normalized.length > 1
        ? normalized.substring(0, normalized.length - 1)
        : normalized;

    return normalized;
  }
}
