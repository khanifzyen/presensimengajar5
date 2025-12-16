import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Show dialog to choose between camera or gallery
  static Future<File?> pickAndResizeImage(BuildContext context) async {
    final source = await _showImageSourceDialog(context);
    if (source == null) return null;

    // Request permission based on source
    final hasPermission = await _requestPermission(source);
    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? 'Izin kamera diperlukan untuk mengambil foto'
                  : 'Izin storage diperlukan untuk memilih foto',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Pengaturan',
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
      return null;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 100, // Get original quality, we'll resize manually
      );

      if (pickedFile == null) return null;

      // Resize image
      final resizedFile = await _resizeImage(File(pickedFile.path));
      return resizedFile;
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// Request permission based on image source
  static Future<bool> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else {
      // For gallery, check Android version
      if (Platform.isAndroid) {
        final androidInfo = await Permission.storage.status;
        if (androidInfo.isDenied) {
          final status = await Permission.storage.request();
          return status.isGranted;
        }
        return true;
      } else {
        final status = await Permission.photos.request();
        return status.isGranted;
      }
    }
  }

  /// Show dialog to choose image source
  static Future<ImageSource?> _showImageSourceDialog(
    BuildContext context,
  ) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Pilih Sumber Foto',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                title: const Text('Kamera'),
                subtitle: const Text('Ambil foto baru'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.green),
                ),
                title: const Text('Galeri'),
                subtitle: const Text('Pilih dari galeri'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  /// Resize image to max 1024x1024 while maintaining aspect ratio
  static Future<File> _resizeImage(File imageFile) async {
    try {
      // Read image from file
      final bytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Calculate new dimensions maintaining aspect ratio
      final int maxDimension = 1024;
      int newWidth = originalImage.width;
      int newHeight = originalImage.height;

      if (originalImage.width > maxDimension ||
          originalImage.height > maxDimension) {
        if (originalImage.width > originalImage.height) {
          // Landscape
          newWidth = maxDimension;
          newHeight =
              (originalImage.height * maxDimension / originalImage.width)
                  .round();
        } else {
          // Portrait or square
          newHeight = maxDimension;
          newWidth = (originalImage.width * maxDimension / originalImage.height)
              .round();
        }
      }

      // Resize image
      final resizedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Encode to JPEG with good quality
      final resizedBytes = img.encodeJpg(resizedImage, quality: 85);

      // Save to temporary file
      final tempDir = imageFile.parent;
      final tempFile = File(
        '${tempDir.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(resizedBytes);

      // Delete original file to save space
      try {
        await imageFile.delete();
      } catch (e) {
        debugPrint('Could not delete original file: $e');
      }

      debugPrint(
        'Image resized: ${originalImage.width}x${originalImage.height} -> ${newWidth}x${newHeight}',
      );

      return tempFile;
    } catch (e) {
      debugPrint('Error resizing image: $e');
      // Return original file if resize fails
      return imageFile;
    }
  }

  /// Get file size in MB
  static Future<double> getFileSizeInMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }
}
