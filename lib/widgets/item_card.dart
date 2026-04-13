import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../models/item_model.dart';
import '../models/category_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate800.withValues(alpha: 0.4) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isDark ? Colors.white : AppTheme.emerald).withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(categoryColor, isDark),
                _buildInfoSection(isDark, categoryColor),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack);
  }

  Widget _buildImageSection(Color categoryColor, bool isDark) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        children: [
          Hero(
            tag: 'item_${item.id}',
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.05),
              ),
              child: item.foto != null && item.foto!.isNotEmpty
                  ? Image.file(File(item.foto!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder(categoryColor))
                  : _buildPlaceholder(categoryColor),
            ),
          ),
          // Gradient Overlay for bottom text readability if needed
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Floating Favorite Button
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onFavoriteToggle?.call(!item.isFavorite);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                ),
                child: Icon(
                  item.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: item.isFavorite ? Colors.amber : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          // Category Tag (Floating)
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CategoryModel.getIconByName(item.kategori), color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    item.kategori.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(bool isDark, Color categoryColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.namaBarang,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppTheme.slate900,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.place_outlined,
                color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.4),
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.lokasi,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.4),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(Color categoryColor) {
    return Container(
      color: categoryColor.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          CategoryModel.getIconByName(item.kategori),
          color: categoryColor.withValues(alpha: 0.3),
          size: 48,
        ),
      ),
    );
  }
}
