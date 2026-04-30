import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/item_controller.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';
import '../widgets/item_card.dart';
import 'edit_item_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.midnightScaffold : AppTheme.pearlScaffold,
      appBar: AppBar(
        title: const Text('Kategori'),
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
      body: Consumer<ItemController>(
        builder: (context, controller, child) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: CategoryModel.allCategories.length,
            itemBuilder: (context, index) {
              final category = CategoryModel.allCategories[index];
              final itemsCount = controller.allItems
                  .where((item) => item.kategori == category.name)
                  .length;

              return _buildCategoryCard(context, category, itemsCount, isDark)
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 30 * index))
                  .slideY(begin: 0.1, end: 0);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, CategoryModel category, int count, bool isDark) {
    return Material(
      color: isDark ? AppTheme.slate800.withValues(alpha: 0.5) : Colors.white,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showCategoryItems(context, category, isDark),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.05),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(category.icon, color: category.color, size: 28),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.slate900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count Barang',
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.slate500,
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

  void _showCategoryItems(BuildContext context, CategoryModel category, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategoryDetailSheet(category: category, isDark: isDark),
    );
  }
}

class _CategoryDetailSheet extends StatelessWidget {
  final CategoryModel category;
  final bool isDark;

  const _CategoryDetailSheet({Key? key, required this.category, required this.isDark})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate900 : AppTheme.pearlScaffold,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(category.icon, color: category.color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name,
                          style: GoogleFonts.quicksand(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppTheme.slate900)),
                      Text('Daftar Barang',
                          style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.slate500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<ItemController>(
              builder: (context, controller, child) {
                final filteredItems = controller.allItems
                    .where((item) => item.kategori == category.name)
                    .toList();

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64,
                            color: (isDark ? Colors.white : AppTheme.slate900)
                                .withValues(alpha: 0.1)),
                        const SizedBox(height: 20),
                        Text('Belum Ada Barang',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: (isDark ? Colors.white : AppTheme.slate900)
                                    .withValues(alpha: 0.3))),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return ItemCard(
                      item: item,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditItemScreen(item: item)),
                        );
                        controller.loadItems();
                      },
                      onFavoriteToggle: (isFav) => controller.toggleFavorite(item, isFav),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
