import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileUtils {
  /// Compresses an image file to a maximum of 1024x1024 while maintaining aspect ratio.
  /// Returns the compressed file or the original if compression fails.
  static Future<File> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(
      dir.path,
      '${path.basenameWithoutExtension(file.path)}_compressed.jpg',
    );

    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: 1024,
        minHeight: 1024,
        quality: 85,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        return File(result.path);
      }
      return file;
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
