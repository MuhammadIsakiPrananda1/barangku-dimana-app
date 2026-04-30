import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/item_model.dart';
import '../theme/app_theme.dart';
import '../models/category_model.dart';

class ItemDetailScreen extends StatelessWidget {
  final ItemModel item;
  const ItemDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = CategoryModel.getColorByName(item.kategori);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.midnightScaffold : AppTheme.pearlScaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppTheme.slate900, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'DETAIL BARANG',
          style: GoogleFonts.quicksand(
            color: isDark ? Colors.white : AppTheme.slate900,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        physics: const BouncingScrollPhysics(),
        children: [
          // Basic Info Header
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CategoryModel.getIconByName(item.kategori),
                color: categoryColor,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              item.namaBarang,
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppTheme.slate900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                item.kategori.toUpperCase(),
                style: GoogleFonts.quicksand(
                  color: categoryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          _buildDetailSection('INFORMASI UTAMA', [
            _buildDetailRow(Icons.location_on_rounded, 'Lokasi Simpan', item.lokasi, isDark),
            _buildDetailRow(Icons.description_rounded, 'Catatan', item.catatan ?? 'Tidak ada catatan', isDark),
          ], isDark),

          const SizedBox(height: 24),

          _buildDetailSection('MASA BERLAKU & GARANSI', [
            _buildDetailRow(
              Icons.verified_user_rounded, 
              'Berlaku Garansi', 
              item.garansiHabis != null ? DateFormat('d MMMM yyyy', 'id_ID').format(item.garansiHabis!) : 'Tanpa Garansi', 
              isDark,
              color: item.garansiHabis != null ? Colors.blue : null,
            ),
            _buildDetailRow(
              Icons.timer_rounded, 
              'Kadaluarsa', 
              item.tglKadaluarsa != null ? DateFormat('d MMMM yyyy', 'id_ID').format(item.tglKadaluarsa!) : 'Tidak Ada', 
              isDark,
              color: item.tglKadaluarsa != null ? Colors.orange : null,
            ),
          ], isDark),

          const SizedBox(height: 24),

          _buildDetailSection('LOG & KEAMANAN', [
            _buildDetailRow(Icons.calendar_today_rounded, 'Tanggal Dicatat', DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(item.createdAt), isDark),
            _buildDetailRow(Icons.access_time_filled_rounded, 'Waktu Dicatat', 'Pukul ${DateFormat('HH:mm').format(item.createdAt)}', isDark),
            _buildDetailRow(Icons.qr_code_2_rounded, 'Kode / Barcode', item.barcode ?? 'Belum terdaftar', isDark),
          ], isDark),

          if (item.peminjam != null && item.peminjam!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildDetailSection('STATUS PINJAMAN', [
              _buildDetailRow(Icons.person_rounded, 'Nama Peminjam', item.peminjam!, isDark, color: Colors.amber),
            ], isDark),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppTheme.emerald,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.slate800.withValues(alpha: 0.5) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.05)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? (isDark ? Colors.white : AppTheme.slate900)).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color ?? (isDark ? Colors.white54 : AppTheme.slate400), size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.slate500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.slate900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
