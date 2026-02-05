import 'dart:io';

/// Abstract interface for image conversion.
/// Allows different image processing implementations.
abstract class ImageConverter {
  /// Converts an image file to WebP format.
  ///
  /// [sourceFile] is the original image file to convert.
  /// [quality] is the WebP compression quality (0-100, default: 80).
  /// [maxSize] is the maximum width/height in pixels. If specified, the image
  /// will be resized proportionally to fit within this size while maintaining
  /// aspect ratio.
  ///
  /// Returns a new File containing the converted WebP image.
  /// The file is typically stored in a temporary directory.
  Future<File> convertToWebP(
    File sourceFile, {
    int quality = 80,
    int? maxSize,
  });
}
