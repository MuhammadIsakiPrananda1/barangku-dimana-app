import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/theme_service.dart';
import '../services/pdf_service.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';
import '../controllers/item_controller.dart';
import '../theme/app_theme.dart';
import 'profile_screen.dart';
import 'pin_lock_screen.dart';
import 'faq_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _handlePdfExport(BuildContext context, ItemController controller) async {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Menyiapkan Laporan PDF...'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.emerald,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
    await PdfService.generateItemReport(controller.allItems);
  }

  void _showMockupSnackBar(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _handleDeleteAll(
      BuildContext context, ItemController controller) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Hapus Semua Data?',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: const Text(
              'Tindakan ini permanen dan tidak dapat dibatalkan. Semua daftar barang Anda akan direset menjadi kosong.'),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Batal',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Hapus',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (result == true) {
      final success = await controller.deleteAllItems();
      if (success && mounted) {
        _showMockupSnackBar(context, 'Semua data barang berhasil dihapus');
      }
    }
  }

  void _showAboutSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.slate900 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : AppTheme.slate900)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.emerald.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.inventory_2_rounded,
                    color: AppTheme.emerald, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                'Barangku Dimana?',
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppTheme.slate900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'v1.4.0',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.emerald,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Solusi cerdas untuk mencatat dan melacak lokasi penyimpanan barang berharga Anda dengan mudah dan rapi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: (isDark ? Colors.white : AppTheme.slate900)
                      .withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Tutup',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<ItemController>();

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.midnightScaffold : AppTheme.pearlScaffold,
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.quicksand(
          color: isDark ? Colors.white : AppTheme.slate900,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionHeader('Akun & Keamanan', isDark),
          _buildSettingsGroup(
            isDark: isDark,
            children: [
              _buildSettingsRow(
                icon: Icons.person_rounded,
                iconColor: Colors.blue,
                title: 'Profil Saya',
                subtitle: SettingsService.userName,
                onTap: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  setState(() {});
                },
                isDark: isDark,
              ),
              _buildSettingsRow(
                icon: Icons.lock_rounded,
                iconColor: Colors.teal,
                title: 'Kunci PIN Aplikasi',
                trailing: Switch(
                  value: SettingsService.pinEnabled,
                  onChanged: (v) async {
                    if (v) {
                      final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const PinLockScreen(isSetupMode: true)));
                      if (result == true) setState(() {});
                    } else {
                      await SettingsService.togglePinLock(false);
                      setState(() {});
                    }
                  },
                  activeColor: AppTheme.emerald,
                ),
                isDark: isDark,
              ),
              _buildSettingsRow(
                icon: Icons.fingerprint_rounded,
                iconColor: Colors.cyan,
                title: 'Kunci Sidik Jari',
                subtitle: 'Gunakan biometrik untuk membuka',
                trailing: Switch(
                  value: SettingsService.biometricEnabled,
                  onChanged: (v) async {
                    await SettingsService.toggleBiometricLock(v);
                    setState(() {});
                  },
                  activeColor: AppTheme.emerald,
                ),
                isDark: isDark,
                isLast: true,
              ),
            ],
          ),
          _buildSectionHeader('Preferensi', isDark),
          _buildSettingsGroup(
            isDark: isDark,
            children: [
              _buildSettingsRow(
                icon:
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                iconColor: AppTheme.emerald,
                title: 'Tema Gelap (Dark Mode)',
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    HapticFeedback.mediumImpact();
                    ThemeService.toggleTheme(value);
                  },
                  activeColor: AppTheme.emerald,
                ),
                isDark: isDark,
              ),
              _buildSettingsRow(
                icon: Icons.notifications_rounded,
                iconColor: Colors.orange,
                title: 'Notifikasi Garansi',
                subtitle: 'Ingatkan sebelum garansi habis',
                trailing: Switch(
                  value: SettingsService.warrantyNotifEnabled,
                  onChanged: (v) async {
                    if (v) {
                      final status = await Permission.notification.request();
                      if (status.isGranted) {
                        await SettingsService.toggleWarrantyNotif(true);
                        setState(() {});
                        _showMockupSnackBar(context, 'Notifikasi Diaktifkan');
                      } else {
                        _showMockupSnackBar(
                            context, 'Izin notifikasi ditolak!');
                        await SettingsService.toggleWarrantyNotif(false);
                        setState(() {});
                      }
                    } else {
                      await SettingsService.toggleWarrantyNotif(false);
                      setState(() {});
                      _showMockupSnackBar(context, 'Notifikasi Dinonaktifkan');
                    }
                  },
                  activeColor: AppTheme.emerald,
                ),
                isDark: isDark,
                isLast: true,
              ),
            ],
          ),
          _buildSectionHeader('Data & Laporan', isDark),
          _buildSettingsGroup(
            isDark: isDark,
            children: [
              _buildSettingsRow(
                icon: Icons.picture_as_pdf_rounded,
                iconColor: Colors.redAccent,
                title: 'Ekspor Data ke PDF',
                onTap: () => _handlePdfExport(context, controller),
                isDark: isDark,
              ),
              _buildSettingsRow(
                icon: Icons.delete_forever_rounded,
                iconColor: Colors.red,
                title: 'Hapus Semua Data',
                titleColor: Colors.red,
                onTap: () => _handleDeleteAll(context, controller),
                isDark: isDark,
                isLast: true,
              ),
            ],
          ),
          _buildSectionHeader('Bantuan & Informasi', isDark),
          _buildSettingsGroup(
            isDark: isDark,
            children: [
              _buildSettingsRow(
                icon: Icons.help_outline_rounded,
                iconColor: Colors.green,
                title: 'Pusat Bantuan & FAQ',
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const FaqScreen()));
                },
                isDark: isDark,
              ),
              _buildSettingsRow(
                icon: Icons.info_outline_rounded,
                iconColor: Colors.cyan,
                title: 'Tentang Aplikasi',
                onTap: () => _showAboutSheet(context, isDark),
                isDark: isDark,
              ),
              _buildSettingsRow(
                icon: Icons.chat_rounded,
                iconColor: Colors.green,
                title: 'Saluran WhatsApp',
                subtitle: 'Update info & fitur terbaru',
                onTap: () =>
                    _launchUrl('https://whatsapp.com/channel/0029Vb7hUrM23n3a6dSem72v'),
                isDark: isDark,
              ),
              _buildSettingsRow(
                icon: Icons.code_rounded,
                iconColor: Colors.brown,
                title: 'Hubungi Developer',
                onTap: () =>
                    _launchUrl('https://github.com/MuhammadIsakiPrananda1'),
                isDark: isDark,
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text(
                  'NEVERLAND STUDIO',
                  style: GoogleFonts.quicksand(
                    color: (isDark ? Colors.white : AppTheme.slate900)
                        .withValues(alpha: 0.35),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.4.0',
                  style: GoogleFonts.quicksand(
                    color: (isDark ? Colors.white : AppTheme.slate900)
                        .withValues(alpha: 0.2),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppTheme.emerald,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(
      {required List<Widget> children, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate800.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: (isDark ? Colors.white : AppTheme.slate900)
                .withValues(alpha: 0.05)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
    required bool isDark,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap ?? (trailing != null ? null : () {}),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: (isDark ? Colors.white : AppTheme.slate900)
                        .withValues(alpha: 0.05),
                  ),
                ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: titleColor ??
                          (isDark ? Colors.white : AppTheme.slate900),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.slate500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.slate400, size: 20),
          ],
        ),
      ),
    );
  }
}
