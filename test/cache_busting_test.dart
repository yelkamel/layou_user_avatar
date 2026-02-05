import 'package:flutter_test/flutter_test.dart';
import 'package:layou_user_avatar/layou_user_avatar.dart';

void main() {
  group('CacheBusting', () {
    test('addTimestamp adds timestamp parameter', () {
      const url = 'https://example.com/avatar.png';
      final result = CacheBusting.addTimestamp(url);

      expect(result, startsWith('https://example.com/avatar.png?t='));
      expect(result.contains('t='), true);
    });

    test('addTimestamp works with existing query params', () {
      const url = 'https://example.com/avatar.png?size=large';
      final result = CacheBusting.addTimestamp(url);

      expect(result, contains('size=large'));
      expect(result, contains('&t='));
    });

    test('addTimestamp handles empty url', () {
      const url = '';
      final result = CacheBusting.addTimestamp(url);

      expect(result, '');
    });

    test('removeTimestamp removes timestamp parameter', () {
      const url = 'https://example.com/avatar.png?t=1234567890';
      final result = CacheBusting.removeTimestamp(url);

      expect(result, 'https://example.com/avatar.png');
    });

    test('removeTimestamp preserves other parameters', () {
      const url = 'https://example.com/avatar.png?size=large&t=1234567890';
      final result = CacheBusting.removeTimestamp(url);

      expect(result, 'https://example.com/avatar.png?size=large');
      expect(result, isNot(contains('t=')));
    });

    test('removeTimestamp handles url without timestamp', () {
      const url = 'https://example.com/avatar.png?size=large';
      final result = CacheBusting.removeTimestamp(url);

      expect(result, 'https://example.com/avatar.png?size=large');
    });
  });
}
