import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/item_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/item_card.dart';
import '../widgets/item_detail_sheet.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.midnightScaffold : AppTheme.pearlScaffold,
      appBar: AppBar(
        title: const Text('Riwayat Catatan'),
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
          final sortedItems = List.from(controller.allItems)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (sortedItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Belum Ada Riwayat',
                    style: GoogleFonts.quicksand(
                      fontSize: 15,
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
            itemCount: sortedItems.length,
            itemBuilder: (context, index) {
              final item = sortedItems[index];
              final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(item.createdAt);
              
              bool showDateHeader = true;
              if (index > 0) {
                final prevItem = sortedItems[index - 1];
                if (DateFormat('yyyyMMdd').format(prevItem.createdAt) == 
                    DateFormat('yyyyMMdd').format(item.createdAt)) {
                  showDateHeader = false;
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showDateHeader) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 20, bottom: 12),
                      child: Text(
                        dateStr.toUpperCase(),
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.emerald,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                  ItemCard(
                    item: item,
                    showThumbnail: false,
                    heroTag: 'history_${item.id}_$index',
                    onTap: () {
                      ItemDetailSheet.show(context, item);
                    },
                    onFavoriteToggle: (isFav) => controller.toggleFavorite(item, isFav),
                  ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.05, end: 0),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
