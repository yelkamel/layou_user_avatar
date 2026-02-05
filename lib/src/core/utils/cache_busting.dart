/// Utilities for cache busting avatar URLs.
class CacheBusting {
  /// Adds a timestamp query parameter to a URL for cache busting.
  ///
  /// Example:
  /// ```dart
  /// addTimestamp('https://example.com/avatar.webp')
  /// // Returns: 'https://example.com/avatar.webp?t=1234567890'
  /// ```
  static String addTimestamp(String url) {
    if (url.isEmpty) return url;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}t=$timestamp';
  }

  /// Removes any existing timestamp query parameter from a URL.
  ///
  /// This is useful for comparing URLs or storing clean URLs in cache.
  static String removeTimestamp(String url) {
    if (url.isEmpty) return url;

    final uri = Uri.parse(url);
    final queryParams = Map<String, String>.from(uri.queryParameters);
    queryParams.remove('t');

    if (queryParams.isEmpty) {
      // Return URL without query string
      return Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.hasPort ? uri.port : null,
        path: uri.path,
        fragment: uri.hasFragment ? uri.fragment : null,
      ).toString();
    }

    return uri.replace(queryParameters: queryParams).toString();
  }
}
