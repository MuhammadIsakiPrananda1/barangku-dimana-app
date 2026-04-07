import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../models/item_model.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final Function(bool)? onFavoriteToggle;

  const ItemCard({
    Key? key,
    required this.item,
    required this.onTap,
    this.onDelete,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = CategoryModel.getColorByName(item.kategori);
    
    return Dismissible(
      key: Key(item.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.redAccent.withValues(alpha: 0.1),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 28),
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Barang?', style: TextStyle(fontWeight: FontWeight.w900)),
            content: Text('Yakin ingin menghapus "${item.namaBarang}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                child: const Text('Hapus'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete?.call(),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              splashColor: AppTheme.emerald.withValues(alpha: 0.05),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildImageSection(categoryColor),
                    const SizedBox(width: 14),
                    Expanded(child: _buildInfoSection(isDark, categoryColor)),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.2),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 78, // Align with the start of the text (48 image + 16 padding + 14 gap)
            endIndent: 16,
            color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.05),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(Color categoryColor) {
    return Hero(
      tag: 'item_${item.id}',
      child: Container(
        width: 48, // Minimalist small image size
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: categoryColor.withValues(alpha: 0.1), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: item.foto != null && item.foto!.isNotEmpty
              ? Image.file(File(item.foto!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder(categoryColor))
              : _buildPlaceholder(categoryColor),
        ),
      ),
    );
  }

  Widget _buildInfoSection(bool isDark, Color categoryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.namaBarang,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.slate900,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onFavoriteToggle?.call(!item.isFavorite);
              },
              child: Icon(
                item.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                color: item.isFavorite ? Colors.amber : (isDark ? Colors.white : AppTheme.slate400).withValues(alpha: 0.3),
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(
              CategoryModel.getIconByName(item.kategori),
              color: categoryColor.withValues(alpha: 0.8),
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              item.kategori,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: categoryColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 4, height: 4, decoration: BoxDecoration(color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.2), shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.lokasi,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.4),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceholder(Color categoryColor) {
    return Container(
      color: categoryColor.withValues(alpha: 0.05),
      child: Center(
        child: Icon(
          CategoryModel.getIconByName(item.kategori),
          color: categoryColor.withValues(alpha: 0.2),
          size: 28,
        ),
      ),
    );
  }
}
