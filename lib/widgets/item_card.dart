import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../models/item_model.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final Function(bool)? onFavoriteToggle;
  final bool isSelected;

  const ItemCard({
    Key? key,
    required this.item,
    required this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onFavoriteToggle,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = CategoryModel.getColorByName(item.kategori);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected 
            ? (isDark ? AppTheme.emerald.withValues(alpha: 0.15) : AppTheme.emerald.withValues(alpha: 0.1))
            : (isDark ? AppTheme.slate800.withValues(alpha: 0.5) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected 
              ? AppTheme.emerald 
              : (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.05),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            onLongPress: () {
              if (onLongPress != null) {
                HapticFeedback.mediumImpact();
                onLongPress!();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildThumbnail(categoryColor),
                  const SizedBox(width: 14),
                  Expanded(child: _buildDetails(isDark, categoryColor)),
                  _buildActions(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(Color categoryColor) {
    return Hero(
      tag: 'item_${item.id}',
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: categoryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: item.foto != null && item.foto!.isNotEmpty
            ? Image.file(
                File(item.foto!), 
                fit: BoxFit.cover, 
                errorBuilder: (_, __, ___) => _buildPlaceholder(categoryColor)
              )
            : _buildPlaceholder(categoryColor),
      ),
    );
  }

  Widget _buildPlaceholder(Color categoryColor) {
    return Center(
      child: Icon(
        CategoryModel.getIconByName(item.kategori),
        color: categoryColor.withValues(alpha: 0.5),
        size: 28,
      ),
    );
  }

  Widget _buildDetails(bool isDark, Color categoryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.kategori.toUpperCase(),
                style: TextStyle(
                  color: categoryColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (item.peminjam != null && item.peminjam!.isNotEmpty) ...[
               const SizedBox(width: 6),
               Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'DIPINJAM',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
               ),
            ]
          ],
        ),
        const SizedBox(height: 6),
        Text(
          item.namaBarang,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppTheme.slate800,
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.place_outlined,
              color: AppTheme.slate500,
              size: 14,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                item.lokasi,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.slate500,
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

  Widget _buildActions(bool isDark) {
    if (isSelected) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: AppTheme.emerald,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onFavoriteToggle?.call(!item.isFavorite);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Icon(
          item.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
          color: item.isFavorite ? Colors.amber : AppTheme.slate300,
          size: 24,
        ),
      ),
    );
  }
}
