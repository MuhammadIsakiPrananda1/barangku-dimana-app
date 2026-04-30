import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/item_model.dart';
import '../theme/app_theme.dart';
import '../models/category_model.dart';

class ItemDetailSheet extends StatelessWidget {
  final ItemModel item;
  const ItemDetailSheet({Key? key, required this.item}) : super(key: key);

  static void show(BuildContext context, ItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ItemDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = CategoryModel.getColorByName(item.kategori);

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate900 : AppTheme.pearlScaffold,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Compact Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(CategoryModel.getIconByName(item.kategori), color: categoryColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namaBarang,
                      style: GoogleFonts.quicksand(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppTheme.slate900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.kategori.toUpperCase(),
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: categoryColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Scrollable Detail Content
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildCompactSection('DATA PEYIMPANAN', [
                    _buildCompactRow(Icons.location_on_rounded, 'Lokasi Simpan', item.lokasi, isDark),
                    _buildCompactRow(Icons.description_rounded, 'Catatan', item.catatan ?? 'Tidak ada catatan', isDark),
                  ], isDark),
                  
                  const SizedBox(height: 16),
                  
                  _buildCompactSection('WAKTU & LOG', [
                    _buildCompactRow(Icons.calendar_today_rounded, 'Hari & Tanggal', DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(item.createdAt), isDark),
                    _buildCompactRow(Icons.access_time_filled_rounded, 'Jam Pencatatan', 'Pukul ${DateFormat('HH:mm').format(item.createdAt)} WIB', isDark),
                  ], isDark),
                  
                  const SizedBox(height: 16),
                  
                  _buildCompactSection('KEAMANAN & STATUS', [
                    _buildCompactRow(Icons.qr_code_2_rounded, 'Kode Barang', item.barcode ?? 'Belum terdaftar', isDark),
                    if (item.garansiHabis != null)
                      _buildCompactRow(Icons.verified_user_rounded, 'Garansi Hingga', DateFormat('d MMMM yyyy', 'id_ID').format(item.garansiHabis!), isDark, color: Colors.blue),
                    if (item.peminjam != null && item.peminjam!.isNotEmpty)
                      _buildCompactRow(Icons.person_rounded, 'Dipinjam Oleh', item.peminjam!, isDark, color: Colors.orange),
                  ], isDark),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSection(String title, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: AppTheme.emerald,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.slate800.withValues(alpha: 0.3) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.05)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildCompactRow(IconData icon, String label, String value, bool isDark, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color ?? (isDark ? Colors.white38 : AppTheme.slate400)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.quicksand(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.slate500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
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
