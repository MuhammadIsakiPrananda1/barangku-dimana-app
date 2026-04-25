import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  String _currentAvatar = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: SettingsService.userName);
    _currentAvatar = SettingsService.userAvatar;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Request permission first
    final status = await Permission.photos.request();
    
    if (status.isGranted || status.isLimited) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _currentAvatar = pickedFile.path;
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin akses galeri ditolak.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }


  Future<void> _saveProfile() async {
    final name = _nameController.text.trim().isEmpty ? SettingsService.userName : _nameController.text.trim();
    await SettingsService.updateUserName(name);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsService.keyUserAvatar, _currentAvatar);
    SettingsService.userAvatar = _currentAvatar;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil disimpan'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.emerald,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.midnightScaffold : AppTheme.pearlScaffold,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppTheme.slate900),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : AppTheme.slate900,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.emerald.withValues(alpha: 0.1),
                      border: Border.all(color: AppTheme.emerald.withValues(alpha: 0.3), width: 2),
                      image: _currentAvatar.isNotEmpty && File(_currentAvatar).existsSync()
                          ? DecorationImage(
                              image: FileImage(File(_currentAvatar)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _currentAvatar.isEmpty || !File(_currentAvatar).existsSync()
                        ? const Icon(Icons.person_rounded, size: 60, color: AppTheme.emerald)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.emerald,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _nameController,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.slate900,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'Nama Panggilan',
                labelStyle: const TextStyle(color: AppTheme.slate500),
                filled: true,
                fillColor: isDark ? AppTheme.slate800.withValues(alpha: 0.5) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.emerald, width: 2),
                ),
                prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.emerald),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emerald,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Simpan Profil',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
