import 'dart:io';
import 'package:image/image.dart' as img; // Use image package
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileUtils {
  /// Compresses an image file to a maximum of 1024x1024 while maintaining aspect ratio.
  /// Returns the compressed file or the original if compression fails.
  static Future<File> compressImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return file;
      }

      // Check if resizing is needed
      if (image.width <= 1024 && image.height <= 1024) {
        // Just re-encode to ensure reasonable quality if desired, or return original
        // Returning original is faster if size is small enough
        return file;
      }

      // Resize logic
      // copyResize maintains aspect ratio if one dimension is passed as null,
      // but here we want to fit within 1024x1024.

      int width = image.width;
      int height = image.height;

      if (width > 1024 || height > 1024) {
        if (width > height) {
          height = (height * 1024 / width).round();
          width = 1024;
        } else {
          width = (width * 1024 / height).round();
          height = 1024;
        }
      }

      final resized = img.copyResize(image, width: width, height: height);
      final compressedBytes = img.encodeJpg(resized, quality: 85);

      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        '${path.basenameWithoutExtension(file.path)}_compressed.jpg',
      );

      final compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      // If compression fails, return original file
      return file;
    }
  }

  /// Checks if a file is an image based on extension
  static bool isImage(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.webp', '.heic'].contains(ext);
  }

  /// Checks if a file is a PDF based on extension
  static bool isPdf(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    return ext == '.pdf';
  }
}
