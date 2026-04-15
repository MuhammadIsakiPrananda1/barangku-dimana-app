import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import '../widgets/permission_dialog.dart';
import '../theme/app_theme.dart';

class PermissionService {
  static Future<bool> handleCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        PermissionDialog.show(
          context,
          title: 'Akses Kamera Terkunci',
          description: 'Kamu telah menolak izin kamera secara permanen. Silakan buka pengaturan aplikasi untuk mengaktifkannya kembali.',
          icon: Icons.camera_alt_rounded,
          color: AppTheme.emerald,
          onAuthorize: () {},
          isPermanentlyDenied: true,
        );
      }
      return false;
    }

    final completer = Completer<bool>();
    if (context.mounted) {
      PermissionDialog.show(
        context,
        title: 'Butuh Akses Kamera',
        description: 'Kami butuh akses kamera untuk mengambil foto barang agar kakak lebih mudah mengenali barang tersebut nanti.',
        icon: Icons.camera_alt_rounded,
        color: AppTheme.emerald,
        onAuthorize: () async {
          final result = await Permission.camera.request();
          completer.complete(result.isGranted);
        },
      );
    } else {
      completer.complete(false);
    }

    return completer.future;
  }

  static Future<bool> handleGalleryPermission(BuildContext context) async {
    // Determine which permission to check/request based on platform
    // For Android 13+, we use Permission.photos. For older, Permission.storage.
    Permission permission = Permission.photos;
    
    // Check current status
    var status = await permission.status;
    
    // If photos is not supported or not in manifest, it might return denied/permanentlyDenied.
    // On older Android, Permission.storage is the way.
    if (Platform.isAndroid && !status.isGranted) {
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) return true;
      // If storage is granted, we're good for older versions.
    }

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        PermissionDialog.show(
          context,
          title: 'Akses Galeri Terkunci',
          description: 'Kamu telah menolak izin galeri secara permanen. Silakan buka pengaturan aplikasi untuk memilih foto barang.',
          icon: Icons.photo_library_rounded,
          color: AppTheme.cyberBlue,
          onAuthorize: () {},
          isPermanentlyDenied: true,
        );
      }
      return false;
    }

    final completer = Completer<bool>();
    if (context.mounted) {
      PermissionDialog.show(
        context,
        title: 'Butuh Akses Galeri',
        description: 'Beri izin akses galeri agar kakak bisa memilih foto yang sudah ada untuk disimpan sebagai data barang.',
        icon: Icons.photo_library_rounded,
        color: AppTheme.cyberBlue,
        onAuthorize: () async {
          PermissionStatus result;
          if (Platform.isAndroid) {
            // We request Permission.photos first (for Android 13+)
            // If it fails or isn't in manifest, we request storage as fallback
            result = await Permission.photos.request();
            if (result.isDenied || result.isRestricted) {
              result = await Permission.storage.request();
            }
          } else {
            result = await Permission.photos.request();
          }
          completer.complete(result.isGranted);
        },
      );
    } else {
      completer.complete(false);
    }

    return completer.future;
  }
}
