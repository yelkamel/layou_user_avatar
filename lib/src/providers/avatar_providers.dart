import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/avatar_config.dart';
import '../core/models/avatar_state.dart';
import '../core/models/upload_state.dart';
import '../services/avatar_service.dart';

/// Provider for avatar configuration.
///
/// This MUST be overridden in the app's ProviderScope with the actual configuration.
///
/// Example:
/// ```dart
/// ProviderScope(
///   overrides: [
///     avatarConfigProvider.overrideWithValue(
///       AvatarConfig(
///         storageProvider: FirebaseStorageProvider(...),
///         // ... other config
///       ),
///     ),
///   ],
///   child: MyApp(),
/// )
/// ```
final avatarConfigProvider = Provider<AvatarConfig>((ref) {
  throw UnimplementedError(
    'avatarConfigProvider must be overridden in ProviderScope',
  );
});

/// Provider for the avatar service.
///
/// Automatically initializes the service when first accessed.
final avatarServiceProvider = Provider<AvatarService>((ref) {
  final config = ref.watch(avatarConfigProvider);
  final service = AvatarService(config);
  service.init();

  // Dispose when provider is disposed
  ref.onDispose(() => service.dispose());

  return service;
});

/// Stream provider for the current user's avatar state.
///
/// Automatically updates when the user changes or when the avatar is uploaded/deleted.
///
/// Example:
/// ```dart
/// final avatarState = ref.watch(currentUserAvatarProvider);
/// avatarState.when(
///   data: (state) {
///     if (state is AvatarData) {
///       return AvatarDisplay(avatarUrl: state.url);
///     }
///     return SomeOtherWidget();
///   },
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => Text('Error: $error'),
/// );
/// ```
final currentUserAvatarProvider = StreamProvider<AvatarState>((ref) {
  final service = ref.watch(avatarServiceProvider);
  return service.currentUserAvatarStream;
});

/// Family provider for external user avatars.
///
/// Fetches and caches avatar URLs for users other than the current user.
///
/// Example:
/// ```dart
/// final avatarAsync = ref.watch(externalUserAvatarProvider('user123'));
/// avatarAsync.when(
///   data: (url) => AvatarDisplay(avatarUrl: url),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => Icon(Icons.error),
/// );
/// ```
final externalUserAvatarProvider =
    FutureProvider.family<String?, String>((ref, userId) async {
  final service = ref.watch(avatarServiceProvider);
  return service.getAvatarUrl(userId);
});

/// State notifier for avatar upload operations.
class AvatarUploadNotifier extends Notifier<UploadState> {
  @override
  UploadState build() {
    return const UploadIdle();
  }

  /// Uploads an avatar for the current user.
  ///
  /// Automatically updates the state with progress, success, or error.
  Future<void> uploadAvatar(File imageFile) async {
    try {
      state = const UploadInProgress(0.0);

      final service = ref.read(avatarServiceProvider);
      await service.uploadCurrentUserAvatar(
        imageFile,
        onProgress: (progress) {
          state = UploadInProgress(progress);
        },
        onSuccess: (url) {
          state = UploadSuccess(url);
        },
        onError: (error) {
          state = UploadError(error);
        },
      );
    } catch (e, stack) {
      state = UploadError(e, stack);
    }
  }

  /// Resets the upload state to idle.
  void reset() {
    state = const UploadIdle();
  }
}

/// Provider for avatar upload state.
///
/// Used to manage upload operations with progress tracking.
///
/// Example:
/// ```dart
/// final uploadState = ref.watch(avatarUploadStateProvider);
/// if (uploadState is UploadInProgress) {
///   return CircularProgressIndicator(value: uploadState.progress);
/// }
/// ```
final avatarUploadStateProvider =
    NotifierProvider<AvatarUploadNotifier, UploadState>(
        AvatarUploadNotifier.new);
