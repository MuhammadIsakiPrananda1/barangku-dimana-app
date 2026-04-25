import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/item_controller.dart';
import '../widgets/item_card.dart';
import '../theme/app_theme.dart';
import 'edit_item_screen.dart';

class BorrowedScreen extends StatelessWidget {
  const BorrowedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.midnightScaffold : AppTheme.pearlScaffold,
      appBar: AppBar(
        title: const Text('Barang Dipinjam'),
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
          final borrowedItems = controller.allItems.where((item) => item.peminjam != null && item.peminjam!.isNotEmpty).toList();

          if (borrowedItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.handshake_outlined,
                    size: 64,
                    color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tidak Ada Barang Dipinjam',
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
            itemCount: borrowedItems.length,
            itemBuilder: (context, index) {
              final item = borrowedItems[index];
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
