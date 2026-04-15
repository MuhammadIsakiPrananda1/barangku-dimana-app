import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'glass_card.dart';
import '../theme/app_theme.dart';

class PermissionDialog extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onAuthorize;
  final bool isPermanentlyDenied;

  const PermissionDialog({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onAuthorize,
    this.isPermanentlyDenied = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: GlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(28),
          borderRadius: 32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppTheme.slate900,
                  letterSpacing: -0.5,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.6),
                  height: 1.5,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'NANTI SAJA',
                        style: TextStyle(
                          color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.4),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (isPermanentlyDenied) {
                          openAppSettings();
                        } else {
                          onAuthorize();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isPermanentlyDenied ? 'BUKA SETTING' : 'BERI IZIN',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onAuthorize,
    bool isPermanentlyDenied = false,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => PermissionDialog(
        title: title,
        description: description,
        icon: icon,
        color: color,
        onAuthorize: onAuthorize,
        isPermanentlyDenied: isPermanentlyDenied,
      ),
    );
  }
}
