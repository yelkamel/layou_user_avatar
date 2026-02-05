import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../core/interfaces/image_converter.dart';

/// WebP image converter using flutter_image_compress.
///
/// This implementation provides true WebP conversion using native platform APIs:
/// - Android: Native WebP support via Android SDK
/// - iOS: WebP support via native libraries
///
/// WebP typically provides 25-35% better compression than PNG/JPEG while
/// maintaining similar visual quality.
class WebPImageConverter implements ImageConverter {
  @override
  Future<File> convertToWebP(
    File sourceFile, {
    int quality = 80,
    int? maxSize,
  }) async {
    // Generate output path
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final targetPath = '${tempDir.path}/avatar_$timestamp.webp';

    // Compress and convert to WebP
    final result = await FlutterImageCompress.compressAndGetFile(
      sourceFile.absolute.path,
      targetPath,
      format: CompressFormat.webp,
      quality: quality,
      minWidth: maxSize ?? 2048,
      minHeight: maxSize ?? 2048,
      // keepExif: false, // Remove EXIF data for privacy
    );

    if (result == null) {
      throw Exception('Failed to convert image to WebP format');
    }

    return File(result.path);
  }
}

/// Alternative implementation using compressWithList for in-memory processing.
///
/// Use this if you need more control or want to avoid intermediate files.
class WebPImageConverterFromBytes implements ImageConverter {
  @override
  Future<File> convertToWebP(
    File sourceFile, {
    int quality = 80,
    int? maxSize,
  }) async {
    // Read source file
    final bytes = await sourceFile.readAsBytes();

    // Compress to WebP
    final compressed = await FlutterImageCompress.compressWithList(
      bytes,
      format: CompressFormat.webp,
      quality: quality,
      minWidth: maxSize ?? 2048,
      minHeight: maxSize ?? 2048,
    );

    // Save to temporary file
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempFile = File('${tempDir.path}/avatar_$timestamp.webp');
    await tempFile.writeAsBytes(compressed);

    return tempFile;
  }
}
