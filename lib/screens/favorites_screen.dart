import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/item_controller.dart';
import '../widgets/item_card.dart';
import '../theme/app_theme.dart';
import 'edit_item_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.midnightScaffold : AppTheme.pearlScaffold,
      appBar: AppBar(
        title: const Text('Barang Favorit'),
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
      body: Consumer<ItemController>(
        builder: (context, controller, child) {
          final favoriteItems = controller.allItems.where((item) => item.isFavorite).toList();

          if (favoriteItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 64,
                    color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Belum Ada Favorit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ).animate().fadeIn(),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            physics: const BouncingScrollPhysics(),
            itemCount: favoriteItems.length,
            itemBuilder: (context, index) {
              final item = favoriteItems[index];
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
    );
  }
}
