import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/avatar_providers.dart';

/// A button that allows deleting the current user's avatar.
///
/// Optionally shows a confirmation dialog before deletion.
class AvatarDeleteButton extends ConsumerStatefulWidget {
  /// Callback invoked when deletion completes successfully.
  final VoidCallback? onDeleteSuccess;

  /// Callback invoked when an error occurs during deletion.
  final void Function(Object error)? onDeleteError;

  /// Whether to show a confirmation dialog before deleting.
  final bool confirmDelete;

  /// Custom icon for the button.
  /// If null, displays a delete icon.
  final Widget? icon;

  /// Custom button text.
  final String? buttonText;

  /// Confirmation dialog title.
  final String? confirmTitle;

  /// Confirmation dialog message.
  final String? confirmMessage;

  const AvatarDeleteButton({
    super.key,
    this.onDeleteSuccess,
    this.onDeleteError,
    this.confirmDelete = true,
    this.icon,
    this.buttonText,
    this.confirmTitle,
    this.confirmMessage,
  });

  @override
  ConsumerState<AvatarDeleteButton> createState() =>
      _AvatarDeleteButtonState();
}

class _AvatarDeleteButtonState extends ConsumerState<AvatarDeleteButton> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    if (_isDeleting) {
      return const CircularProgressIndicator();
    }

    return ElevatedButton.icon(
      onPressed: () => _handleDelete(context),
      icon: widget.icon ?? const Icon(Icons.delete),
      label: Text(widget.buttonText ?? 'Delete Avatar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    // Show confirmation dialog if enabled
    if (widget.confirmDelete) {
      final confirmed = await _showConfirmDialog(context);
      if (confirmed != true) return;
    }

    // Perform deletion
    setState(() => _isDeleting = true);

    try {
      final service = ref.read(avatarServiceProvider);
      await service.deleteCurrentUserAvatar();

      if (mounted) {
        setState(() => _isDeleting = false);
        widget.onDeleteSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        widget.onDeleteError?.call(e);
      }
    }
  }

  Future<bool?> _showConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.confirmTitle ?? 'Delete Avatar'),
        content: Text(
          widget.confirmMessage ??
              'Are you sure you want to delete your avatar? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
