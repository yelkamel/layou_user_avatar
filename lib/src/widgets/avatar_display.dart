import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A widget that displays a user avatar.
///
/// Shows the avatar image if available, otherwise displays a placeholder
/// with user initials or a default icon.
class AvatarDisplay extends StatelessWidget {
  /// The URL of the avatar image to display.
  final String? avatarUrl;

  /// The user ID, used to generate initials for placeholder.
  final String? userId;

  /// The size of the avatar (width and height).
  final double size;

  /// Custom placeholder widget when no avatar is available.
  /// If null, displays initials or a default person icon.
  final Widget? placeholder;

  /// Custom loading widget while the image loads.
  /// If null, displays a CircularProgressIndicator.
  final Widget? loader;

  /// Whether to use cached network images.
  /// When true, uses CachedNetworkImage for better performance.
  /// When false, uses regular NetworkImage.
  final bool enableCaching;

  /// Callback invoked when an error occurs loading the avatar.
  final VoidCallback? onError;

  /// Background color for the placeholder.
  final Color? backgroundColor;

  /// Text color for initials in the placeholder.
  final Color? foregroundColor;

  const AvatarDisplay({
    super.key,
    this.avatarUrl,
    this.userId,
    this.size = 48.0,
    this.placeholder,
    this.loader,
    this.enableCaching = true,
    this.onError,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primary;
    final fgColor = foregroundColor ?? theme.colorScheme.onPrimary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      child: ClipOval(
        child: _buildContent(context, bgColor, fgColor),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color bgColor, Color fgColor) {
    // Show image if URL is available
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return _buildImage(context);
    }

    // Show custom placeholder if provided
    if (placeholder != null) {
      return placeholder!;
    }

    // Show initials or icon
    return _buildPlaceholder(fgColor);
  }

  Widget _buildImage(BuildContext context) {
    if (enableCaching) {
      return CachedNetworkImage(
        imageUrl: avatarUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            loader ?? _buildLoader(context),
        errorWidget: (context, url, error) {
          onError?.call();
          return _buildPlaceholder(
            foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
          );
        },
      );
    }

    return Image.network(
      avatarUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return loader ?? _buildLoader(context);
      },
      errorBuilder: (context, error, stackTrace) {
        onError?.call();
        return _buildPlaceholder(
          foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
        );
      },
    );
  }

  Widget _buildLoader(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size * 0.4,
        height: size * 0.4,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildPlaceholder(Color fgColor) {
    // Try to generate initials from userId
    final initials = _getInitials();

    if (initials != null) {
      return Center(
        child: Text(
          initials,
          style: TextStyle(
            color: fgColor,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    // Default to person icon
    return Center(
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: fgColor,
      ),
    );
  }

  String? _getInitials() {
    if (userId == null || userId!.isEmpty) return null;

    // Try to extract initials from userId
    // Remove common email domain patterns
    final cleanId = userId!.split('@').first;

    // Split by common separators
    final parts = cleanId.split(RegExp(r'[._-]'));

    if (parts.length >= 2) {
      // Take first letter of first two parts
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }

    // Take first two letters
    if (cleanId.length >= 2) {
      return cleanId.substring(0, 2).toUpperCase();
    }

    // Take first letter repeated
    return (cleanId[0] + cleanId[0]).toUpperCase();
  }
}
