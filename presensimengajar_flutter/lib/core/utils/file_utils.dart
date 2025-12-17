import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class FileUtils {
  /// Compresses an image file to a maximum of 512x512 while maintaining aspect ratio.
  /// Returns the compressed file or the original if compression fails.
  static Future<File> compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        '${path.basenameWithoutExtension(file.path)}_compressed.jpg',
      );

      // Compress and resize
      // minWidth/minHeight work as constraints, keeping aspect ratio
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85,
        minWidth: 512,
        minHeight: 512,
      );

      if (result != null) {
        return File(result.path);
      } else {
        return file;
      }
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
