import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/item_controller.dart';
import '../models/item_model.dart';
import '../theme/app_theme.dart';
import '../widgets/item_card.dart';
import 'edit_item_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.midnightScaffold : AppTheme.pearlScaffold,
      appBar: AppBar(
        title: const Text('Statistik'),
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
          final items = controller.allItems;
          
          final totalItems = items.length;
          final borrowedItems = items.where((i) => i.peminjam != null && i.peminjam!.isNotEmpty).length;
          final withWarranty = items.where((i) => i.garansiHabis != null).length;
          
          // Get top 3 most viewed items
          final List<ItemModel> sortedByView = List.from(items)
            ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
          final topViewed = sortedByView.take(3).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompactStatCard(
                              'Total\nBarang',
                              totalItems.toString(),
                              Icons.all_inbox_rounded,
                              AppTheme.emerald,
                              isDark,
                            ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.1, end: 0),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCompactStatCard(
                              'Paling\nSering Dilihat',
                              topViewed.isNotEmpty && topViewed.first.viewCount > 0 ? topViewed.first.viewCount.toString() : '0',
                              Icons.visibility_rounded,
                              Colors.pinkAccent,
                              isDark,
                            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompactStatCard(
                              'Sedang\nDipinjam',
                              borrowedItems.toString(),
                              Icons.handshake_rounded,
                              Colors.orange,
                              isDark,
                            ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCompactStatCard(
                              'Dalam\nGaransi',
                              withWarranty.toString(),
                              Icons.verified_user_rounded,
                              Colors.blue,
                              isDark,
                            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (topViewed.isNotEmpty && topViewed.first.viewCount > 0) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Text(
                      'Riwayat Pantauan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppTheme.slate900,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = topViewed[index];
                        if (item.viewCount == 0) return const SizedBox.shrink();
                        return ItemCard(
                          item: item,
                          heroTag: 'stats_${item.id}',
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
                      childCount: topViewed.length,
                    ),
                  ),
                ),
              ] else ... [
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_graph_rounded,
                            size: 48,
                            color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.1),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum Ada Riwayat',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 300.ms),
                    ),
                  ),
                ),
              ]
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompactStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate800.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppTheme.slate900,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    color: AppTheme.slate500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
