import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/item_controller.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';
import '../widgets/item_card.dart';
import 'edit_item_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _selectedCategory = CategoryModel.allCategories.first.name;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.midnightScaffold : AppTheme.pearlScaffold,
      appBar: AppBar(
        title: const Text('Kategori Barang'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : AppTheme.slate900,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      body: Column(
        children: [
          _buildCategorySelector(isDark),
          Expanded(child: _buildItemList(isDark)),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: CategoryModel.allCategories.length,
        itemBuilder: (context, index) {
          final category = CategoryModel.allCategories[index];
          final isSelected = _selectedCategory == category.name;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category.name;
                });
              },
              backgroundColor: isDark ? AppTheme.slate800 : Colors.white,
              selectedColor: AppTheme.emerald,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.white : AppTheme.slate900),
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              ),
              showCheckmark: false,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemList(bool isDark) {
    return Consumer<ItemController>(
      builder: (context, controller, child) {
        final filteredItems = controller.allItems.where((item) => item.kategori == _selectedCategory).toList();

        if (filteredItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.1),
                ),
                const SizedBox(height: 20),
                Text(
                  'Tidak Ada Barang',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.3),
                  ),
                ),
              ],
            ).animate().fadeIn(),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
    );
  }
}
