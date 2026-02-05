import 'dart:io';

/// Abstract interface for cloud storage providers.
/// Allows the package to be storage-agnostic (Firebase, AWS S3, Supabase, etc.)
abstract class StorageProvider {
  /// Uploads a file to the specified path in cloud storage.
  ///
  /// Returns the download URL of the uploaded file.
  /// Optionally specify [contentType] for the file (e.g., 'image/webp').
  Future<String> uploadFile(
    String path,
    File file, {
    String? contentType,
  });

  /// Retrieves the download URL for a file at the specified path.
  ///
  /// Returns null if the file doesn't exist or an error occurs.
  Future<String?> getDownloadUrl(String path);

  /// Deletes a file at the specified path from cloud storage.
  Future<void> deleteFile(String path);

  /// Checks if a file exists at the specified path.
  Future<bool> fileExists(String path);

  /// Returns a stream of upload progress for a file at the specified path.
  ///
  /// Emits values from 0.0 (start) to 1.0 (complete).
  /// This is used to provide real-time upload progress feedback.
  Stream<double> getUploadProgress(String path);
}
