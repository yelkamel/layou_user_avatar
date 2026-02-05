/// Represents the state of an avatar upload operation.
sealed class UploadState {
  const UploadState();
}

/// No upload is currently in progress.
class UploadIdle extends UploadState {
  const UploadIdle();
}

/// An upload is currently in progress.
class UploadInProgress extends UploadState {
  /// Upload progress from 0.0 (start) to 1.0 (complete).
  final double progress;

  const UploadInProgress(this.progress);

  /// Returns the progress as a percentage (0-100).
  int get progressPercent => (progress * 100).round();
}

/// The upload completed successfully.
class UploadSuccess extends UploadState {
  /// The download URL of the uploaded avatar.
  final String url;

  const UploadSuccess(this.url);
}

/// The upload failed with an error.
class UploadError extends UploadState {
  /// The error that occurred during upload.
  final Object error;

  /// Optional stack trace for debugging.
  final StackTrace? stackTrace;

  const UploadError(this.error, [this.stackTrace]);
}
