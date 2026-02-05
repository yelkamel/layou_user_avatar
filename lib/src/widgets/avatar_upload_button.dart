import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../core/models/upload_state.dart';
import '../providers/avatar_providers.dart';

/// A button that allows uploading a new avatar.
///
/// Opens the image picker and handles the upload process.
class AvatarUploadButton extends ConsumerWidget {
  /// The current avatar URL (optional, used for display purposes).
  final String? currentAvatarUrl;

  /// Callback invoked when upload starts.
  final VoidCallback? onUploadStart;

  /// Callback invoked when upload completes successfully.
  final void Function(String url)? onUploadSuccess;

  /// Callback invoked when an error occurs during upload.
  final void Function(Object error)? onUploadError;

  /// Callback invoked with upload progress (0.0 to 1.0).
  final void Function(double progress)? onProgress;

  /// Custom loading widget during upload.
  /// If null, displays a CircularProgressIndicator.
  final Widget? customLoader;

  /// Custom icon for the button.
  /// If null, displays a camera icon.
  final Widget? icon;

  /// Whether to show upload progress percentage.
  final bool showProgress;

  /// Custom button text.
  final String? buttonText;

  /// Image source for picking images.
  /// Defaults to gallery.
  final ImageSource imageSource;

  const AvatarUploadButton({
    super.key,
    this.currentAvatarUrl,
    this.onUploadStart,
    this.onUploadSuccess,
    this.onUploadError,
    this.onProgress,
    this.customLoader,
    this.icon,
    this.showProgress = false,
    this.buttonText,
    this.imageSource = ImageSource.gallery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(avatarUploadStateProvider);

    // Show loader during upload
    if (uploadState is UploadInProgress) {
      return _buildUploadingState(uploadState);
    }

    // Show button
    return _buildButton(context, ref);
  }

  Widget _buildButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () => _pickAndUploadImage(context, ref),
      icon: icon ?? const Icon(Icons.camera_alt),
      label: Text(buttonText ?? 'Upload Avatar'),
    );
  }

  Widget _buildUploadingState(UploadInProgress state) {
    if (customLoader != null) {
      return customLoader!;
    }

    if (showProgress) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(value: state.progress),
          const SizedBox(height: 8),
          Text('${state.progressPercent}%'),
        ],
      );
    }

    return const CircularProgressIndicator();
  }

  Future<void> _pickAndUploadImage(BuildContext context, WidgetRef ref) async {
    try {
      // Pick image
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: imageSource);

      if (pickedFile == null) {
        return; // User cancelled
      }

      onUploadStart?.call();

      // Upload via provider
      final notifier = ref.read(avatarUploadStateProvider.notifier);
      await notifier.uploadAvatar(File(pickedFile.path));

      // Check final state
      final finalState = ref.read(avatarUploadStateProvider);
      if (finalState is UploadSuccess) {
        onUploadSuccess?.call(finalState.url);
      } else if (finalState is UploadError) {
        onUploadError?.call(finalState.error);
      }

      // Reset state
      notifier.reset();
    } catch (e) {
      onUploadError?.call(e);
    }
  }
}
