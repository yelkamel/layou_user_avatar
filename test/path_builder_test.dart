import 'package:flutter_test/flutter_test.dart';
import 'package:layou_user_avatar/layou_user_avatar.dart';

void main() {
  group('PathBuilder', () {
    test('validateUserId accepts valid user ID', () {
      expect(() => PathBuilder.validateUserId('user123'), returnsNormally);
      expect(
          () => PathBuilder.validateUserId('user-123-abc'), returnsNormally);
      expect(() => PathBuilder.validateUserId('user_123_abc'), returnsNormally);
    });

    test('validateUserId rejects empty user ID', () {
      expect(
        () => PathBuilder.validateUserId(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('validateUserId rejects invalid characters', () {
      expect(
        () => PathBuilder.validateUserId('user/123'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => PathBuilder.validateUserId('user\\123'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => PathBuilder.validateUserId('../user123'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => PathBuilder.validateUserId('user<123>'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('normalizePath removes leading slash', () {
      expect(PathBuilder.normalizePath('/avatars/user/photo.png'),
          'avatars/user/photo.png');
    });

    test('normalizePath removes trailing slash', () {
      expect(PathBuilder.normalizePath('avatars/user/'),
          'avatars/user');
    });

    test('normalizePath replaces multiple slashes', () {
      expect(PathBuilder.normalizePath('avatars//user///photo.png'),
          'avatars/user/photo.png');
    });

    test('normalizePath handles already normalized path', () {
      expect(PathBuilder.normalizePath('avatars/user/photo.png'),
          'avatars/user/photo.png');
    });

    test('normalizePath handles complex path', () {
      expect(PathBuilder.normalizePath('/avatars///user//photo.png/'),
          'avatars/user/photo.png');
    });
  });
}
