/// Represents the state of an avatar.
///
/// This is used to track the current state of avatar data, including
/// loading, success, and error states.
sealed class AvatarState {
  const AvatarState();
}

/// Indicates the avatar is currently being loaded.
class AvatarLoading extends AvatarState {
  const AvatarLoading();
}

/// Contains the loaded avatar data.
///
/// [url] may be null if the user has no avatar.
class AvatarData extends AvatarState {
  /// The download URL of the avatar, or null if no avatar exists.
  final String? url;

  const AvatarData(this.url);

  /// Whether the user has an avatar.
  bool get hasAvatar => url != null && url!.isNotEmpty;
}

/// Indicates an error occurred while loading or managing the avatar.
class AvatarError extends AvatarState {
  /// The error that occurred.
  final Object error;

  /// Optional stack trace for debugging.
  final StackTrace? stackTrace;

  const AvatarError(this.error, [this.stackTrace]);
}
