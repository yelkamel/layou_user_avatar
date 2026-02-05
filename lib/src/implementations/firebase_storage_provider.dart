import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import '../core/interfaces/storage_provider.dart';

/// Firebase Storage implementation of [StorageProvider].
class FirebaseStorageProvider implements StorageProvider {
  final FirebaseStorage storage;

  const FirebaseStorageProvider(this.storage);

  @override
  Future<String> uploadFile(
    String path,
    File file, {
    String? contentType,
  }) async {
    final ref = storage.ref(path);
    await ref.putFile(
      file,
      SettableMetadata(contentType: contentType),
    );
    return getDownloadUrl(path) as Future<String>;
  }

  @override
  Future<String?> getDownloadUrl(String path) async {
    try {
      final ref = storage.ref(path);
      return await ref.getDownloadURL();
    } catch (e) {
      // File doesn't exist or error occurred
      return null;
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    final ref = storage.ref(path);
    await ref.delete();
  }

  @override
  Future<bool> fileExists(String path) async {
    try {
      final ref = storage.ref(path);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<double> getUploadProgress(String path) {
    // Note: This is a simplified implementation.
    // In a real app, you might want to store the UploadTask and listen to its snapshots.
    // For now, we emit 0.0 immediately and 1.0 when complete.
    return Stream.value(0.0);
  }
}

/// Extended Firebase Storage provider with progress tracking support.
///
/// This version stores upload tasks to provide real-time progress updates.
class FirebaseStorageProviderWithProgress implements StorageProvider {
  final FirebaseStorage storage;
  final Map<String, UploadTask> _uploadTasks = {};
  final Map<String, StreamController<double>> _progressControllers = {};

  FirebaseStorageProviderWithProgress(this.storage);

  @override
  Future<String> uploadFile(
    String path,
    File file, {
    String? contentType,
  }) async {
    final storageRef = storage.ref(path);
    final task = storageRef.putFile(
      file,
      SettableMetadata(contentType: contentType),
    );

    _uploadTasks[path] = task;

    // Create progress controller before listening
    if (!_progressControllers.containsKey(path)) {
      _progressControllers[path] = StreamController<double>.broadcast();
    }
    final progressController = _progressControllers[path]!;

    // Listen to task state changes and update progress
    task.snapshotEvents.listen(
      (snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        progressController.add(progress);
      },
      onError: (error) {
        progressController.addError(error);
      },
      onDone: () {
        _uploadTasks.remove(path);
        progressController.close();
        _progressControllers.remove(path);
      },
    );

    await task;
    return getDownloadUrl(path) as Future<String>;
  }

  /// Disposes resources used by this provider.
  Future<void> dispose() async {
    for (final controller in _progressControllers.values) {
      await controller.close();
    }
    _progressControllers.clear();
    _uploadTasks.clear();
  }

  @override
  Future<String?> getDownloadUrl(String path) async {
    try {
      final ref = storage.ref(path);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    final ref = storage.ref(path);
    await ref.delete();
  }

  @override
  Future<bool> fileExists(String path) async {
    try {
      final ref = storage.ref(path);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<double> getUploadProgress(String path) {
    if (!_progressControllers.containsKey(path)) {
      _progressControllers[path] = StreamController<double>.broadcast();
    }
    return _progressControllers[path]!.stream;
  }
}
