import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/item_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/item_card.dart';
import 'edit_item_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationsScreen extends StatelessWidget {
  const LocationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.midnightScaffold : AppTheme.pearlScaffold,
      appBar: AppBar(
        title: const Text('Lokasi Penyimpanan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.comicNeue(
          color: isDark ? Colors.white : AppTheme.slate900,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      body: Consumer<ItemController>(
        builder: (context, controller, child) {
          final items = controller.allItems;
          
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.explore_outlined,
                    size: 64,
                    color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Belum Ada Rekaman Lokasi',
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

          // Get unique locations
          final locationsMap = <String, int>{};
          for (var item in items) {
            final loc = item.lokasi.trim().isEmpty ? 'Tanpa Lokasi' : item.lokasi.trim();
            locationsMap[loc] = (locationsMap[loc] ?? 0) + 1;
          }
          
          final uniqueLocations = locationsMap.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            physics: const BouncingScrollPhysics(),
            itemCount: uniqueLocations.length,
            itemBuilder: (context, index) {
              final locName = uniqueLocations[index];
              final count = locationsMap[locName]!;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.slate800.withValues(alpha: 0.5) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.emerald.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.place_rounded, color: AppTheme.emerald),
                  ),
                  title: Text(
                    locName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.slate900,
                    ),
                  ),
                  subtitle: Text(
                    '$count Barang',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.slate500,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.slate400),
                  onTap: () => _showItemsInLocation(context, locName, isDark),
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: 30 * index)).slideX(begin: 0.1, end: 0);
            },
          );
        },
      ),
    );
  }

  void _showItemsInLocation(BuildContext context, String location, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocationDetailSheet(location: location, isDark: isDark),
    );
  }
}

class _LocationDetailSheet extends StatelessWidget {
  final String location;
  final bool isDark;

  const _LocationDetailSheet({Key? key, required this.location, required this.isDark})
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
                    color: AppTheme.emerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.place_rounded, color: AppTheme.emerald, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(location,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppTheme.slate900)),
                      const Text('Daftar Barang Disini',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
                final filteredItems = controller.allItems.where((item) {
                  final loc = item.lokasi.trim().isEmpty ? 'Tanpa Lokasi' : item.lokasi.trim();
                  return loc == location;
                }).toList();

                if (filteredItems.isEmpty) {
                  return const Center(child: Text('Kosong'));
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
