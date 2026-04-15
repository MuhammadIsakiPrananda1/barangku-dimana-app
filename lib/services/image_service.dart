import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'permission_service.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Pick image from camera with permission check
  Future<String?> pickImageFromCamera(BuildContext context) async {
    try {
      final bool granted = await PermissionService.handleCameraPermission(context);
      if (!granted) return null;

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 75,
      );

      if (image != null) {
        return await _saveImage(image);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  // Pick image from gallery with permission check
  Future<String?> pickImageFromGallery(BuildContext context) async {
    try {
      final bool granted = await PermissionService.handleGalleryPermission(context);
      
      if (!granted) return null;

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 75,
      );

      if (image != null) {
        return await _saveImage(image);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }


  // Save image to app directory
  Future<String> _saveImage(XFile image) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final String savedPath = path.join(appDir.path, 'images', fileName);

      // Create directory if not exists
      final Directory imageDir = Directory(path.join(appDir.path, 'images'));
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      // Copy file to app directory
      final File savedImage = await File(image.path).copy(savedPath);
      return savedImage.path;
    } catch (e) {
      print('Error saving image: $e');
      return image.path;
    }
  }

  // Delete image file
  Future<bool> deleteImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return false;

    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Show bottom sheet for image source selection
  static Future<String?> showImageSourceDialog({
    required Function() onCameraPressed,
    required Function() onGalleryPressed,
  }) async {
    // This will be called from UI widgets
    return null;
  }
}
