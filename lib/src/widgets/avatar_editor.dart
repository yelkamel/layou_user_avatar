import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/avatar_state.dart';
import '../providers/avatar_providers.dart';
import 'avatar_display.dart';
import 'avatar_upload_button.dart';
import 'avatar_delete_button.dart';

/// A complete avatar editor widget for the current user.
///
/// Combines avatar display, upload, and delete functionality in one widget.
/// Features an edit badge overlay and manages all avatar operations.
class AvatarEditor extends ConsumerWidget {
  /// The size of the avatar (width and height).
  final double size;

  /// Whether to show the upload button.
  final bool showUploadButton;

  /// Whether to show the delete button (only visible when avatar exists).
  final bool showDeleteButton;

  /// Callback invoked when upload completes successfully.
  final void Function(String url)? onUploadSuccess;

  /// Callback invoked when an error occurs during upload.
  final void Function(Object error)? onUploadError;

  /// Callback invoked when deletion completes successfully.
  final VoidCallback? onDeleteSuccess;

  /// Callback invoked with upload progress (0.0 to 1.0).
  final void Function(double progress)? onProgress;

  /// Custom loading widget.
  final Widget? customLoader;

  /// Background color for the avatar placeholder.
  final Color? backgroundColor;

  /// Foreground color for the avatar placeholder.
  final Color? foregroundColor;

  /// Whether to show upload progress percentage.
  final bool showProgress;

  /// Layout style for the editor.
  final AvatarEditorLayout layout;

  const AvatarEditor({
    super.key,
    this.size = 120.0,
    this.showUploadButton = true,
    this.showDeleteButton = true,
    this.onUploadSuccess,
    this.onUploadError,
    this.onDeleteSuccess,
    this.onProgress,
    this.customLoader,
    this.backgroundColor,
    this.foregroundColor,
    this.showProgress = true,
    this.layout = AvatarEditorLayout.vertical,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarState = ref.watch(currentUserAvatarProvider);

    return avatarState.when(
      data: (state) => _buildEditor(context, ref, state),
      loading: () => _buildLoading(),
      // Don't show error for missing avatar - treat as no avatar
      error: (error, stack) {
        // If it's just a missing avatar, show editor with no avatar
        // Otherwise show error
        final errorMsg = error.toString().toLowerCase();
        if (errorMsg.contains('not found') ||
            errorMsg.contains('does not exist') ||
            errorMsg.contains('no avatar')) {
          return _buildEditor(context, ref, const AvatarData(null));
        }
        return _buildError(context, error);
      },
    );
  }

  Widget _buildEditor(BuildContext context, WidgetRef ref, AvatarState state) {
    String? avatarUrl;
    String? userId;

    if (state is AvatarData) {
      avatarUrl = state.url;
      userId = ref.read(avatarServiceProvider).config.identityProvider
          .getCurrentUserId();
    }

    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    switch (layout) {
      case AvatarEditorLayout.vertical:
        return _buildVerticalLayout(
          context,
          ref,
          avatarUrl,
          userId,
          hasAvatar,
        );
      case AvatarEditorLayout.horizontal:
        return _buildHorizontalLayout(
          context,
          ref,
          avatarUrl,
          userId,
          hasAvatar,
        );
      case AvatarEditorLayout.overlay:
        return _buildOverlayLayout(
          context,
          ref,
          avatarUrl,
          userId,
          hasAvatar,
        );
    }
  }

  Widget _buildVerticalLayout(
    BuildContext context,
    WidgetRef ref,
    String? avatarUrl,
    String? userId,
    bool hasAvatar,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AvatarDisplay(
          avatarUrl: avatarUrl,
          userId: userId,
          size: size,
          loader: customLoader,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
        const SizedBox(height: 16),
        if (showUploadButton)
          AvatarUploadButton(
            currentAvatarUrl: avatarUrl,
            onUploadSuccess: onUploadSuccess,
            onUploadError: onUploadError,
            onProgress: onProgress,
            customLoader: customLoader,
            showProgress: showProgress,
          ),
        if (showDeleteButton && hasAvatar) ...[
          const SizedBox(height: 8),
          AvatarDeleteButton(
            onDeleteSuccess: onDeleteSuccess,
            onDeleteError: onUploadError,
          ),
        ],
      ],
    );
  }

  Widget _buildHorizontalLayout(
    BuildContext context,
    WidgetRef ref,
    String? avatarUrl,
    String? userId,
    bool hasAvatar,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AvatarDisplay(
          avatarUrl: avatarUrl,
          userId: userId,
          size: size,
          loader: customLoader,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showUploadButton)
              AvatarUploadButton(
                currentAvatarUrl: avatarUrl,
                onUploadSuccess: onUploadSuccess,
                onUploadError: onUploadError,
                onProgress: onProgress,
                customLoader: customLoader,
                showProgress: showProgress,
              ),
            if (showDeleteButton && hasAvatar) ...[
              const SizedBox(height: 8),
              AvatarDeleteButton(
                onDeleteSuccess: onDeleteSuccess,
                onDeleteError: onUploadError,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildOverlayLayout(
    BuildContext context,
    WidgetRef ref,
    String? avatarUrl,
    String? userId,
    bool hasAvatar,
  ) {
    return Stack(
      children: [
        AvatarDisplay(
          avatarUrl: avatarUrl,
          userId: userId,
          size: size,
          loader: customLoader,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
        if (showUploadButton)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt),
                iconSize: size * 0.2,
                color: Theme.of(context).colorScheme.onPrimary,
                onPressed: () => _openUploadDialog(context, ref),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: customLoader ?? const CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          size: size * 0.5,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 8),
        Text(
          'Error loading avatar',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }

  void _openUploadDialog(BuildContext context, WidgetRef ref) {
    // For overlay layout, show a bottom sheet with upload/delete options
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showUploadButton)
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Upload Avatar'),
                onTap: () {
                  Navigator.pop(context);
                  // Upload logic handled by button
                },
              ),
            if (showDeleteButton)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Avatar'),
                onTap: () {
                  Navigator.pop(context);
                  // Delete logic handled by button
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Layout options for the avatar editor.
enum AvatarEditorLayout {
  /// Vertical layout: avatar on top, buttons below.
  vertical,

  /// Horizontal layout: avatar on left, buttons on right.
  horizontal,

  /// Overlay layout: edit badge overlaid on avatar.
  overlay,
}
