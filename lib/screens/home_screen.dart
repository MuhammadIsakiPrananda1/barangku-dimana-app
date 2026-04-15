import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../controllers/item_controller.dart';
import '../widgets/item_card.dart';
import '../screens/add_item_screen.dart';
import '../screens/edit_item_screen.dart';
import '../theme/app_theme.dart';
import '../services/theme_service.dart';
import '../services/scanner_service.dart';
import '../services/pdf_service.dart';
import '../models/category_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  late ItemController _controller;
  late Stream<DateTime> _clockStream;

  @override
  void initState() {
    super.initState();
    _controller = context.read<ItemController>();

    // Defer loading to after the first frame to avoid building error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadItems();
    });

    _searchController.addListener(() {
      _controller.setSearchQuery(_searchController.text);
    });
    _clockStream =
        Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  void _toggleDarkMode() {
    HapticFeedback.mediumImpact();
    ThemeService.isDarkModeNotifier.value =
        !ThemeService.isDarkModeNotifier.value;
  }

  void _startBarcodeScan() async {
    final res = await ScannerService.scanBarcode(context);
    if (res != null) {
      _searchController.text = res;
      _controller.setSearchQuery(res);
    }
  }

  void _handlePdfExport() async {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Menyiapkan Laporan PDF...'),
          duration: Duration(seconds: 1)),
    );
    await PdfService.generateItemReport(_controller.allItems);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.midnightScaffold : AppTheme.pearlScaffold,
      body: Consumer<ItemController>(
        builder: (context, controller, child) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(isDark),
              SliverToBoxAdapter(child: _buildClockSection(isDark)),
              SliverToBoxAdapter(child: _buildQuickSummary(isDark)),
              SliverToBoxAdapter(child: _buildUnifiedToolbar(isDark)),
              if (controller.isLoading)
                const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()))
              else if (controller.filteredItems.isEmpty)
                SliverFillRemaining(child: _buildEmptyState(isDark))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = controller.filteredItems[index];
                        return Dismissible(
                          key: Key('dismiss_${item.id}'),
                          direction: DismissDirection.endToStart,
                          background: _buildDeleteBackground(),
                          confirmDismiss: (direction) =>
                              _showDeleteConfirmation(context, item),
                          onDismissed: (direction) {
                            controller.deleteItem(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.namaBarang} dihapus'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppTheme.slate800,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          child: ItemCard(
                            item: item,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => EditItemScreen(item: item)),
                              );
                              if (result == true) controller.loadItems();
                            },
                            onFavoriteToggle: (isFav) =>
                                controller.toggleFavorite(item, isFav),
                          ),
                        );
                      },
                      childCount: controller.filteredItems.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: _buildWatermark(isDark)),
            ],
          );
        },
      ),
      floatingActionButton: _buildMinimalistFAB(isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader(bool isDark) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BARANGKU',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppTheme.slate900,
                  letterSpacing: -1)),
          Text('DIMANA?',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.emerald,
                  letterSpacing: 4)),
        ],
      ),
      actions: [
        _buildExportButton(isDark),
        const SizedBox(width: 8),
        _buildThemeToggle(isDark),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildClockSection(bool isDark) {
    return StreamBuilder<DateTime>(
      stream: _clockStream,
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final time = snapshot.data ?? DateTime.now();
        final timeStr = DateFormat('HH:mm:ss').format(time);
        final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(time);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.emerald.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.emerald.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateStr.toUpperCase(),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.emerald,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    Text(timeStr,
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppTheme.slate900,
                            letterSpacing: -0.5)),
                  ],
                ),
              ),
              Icon(Icons.access_time_filled_rounded,
                  size: 48, color: AppTheme.emerald.withValues(alpha: 0.2)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportButton(bool isDark) {
    return IconButton(
      onPressed: _handlePdfExport,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: AppTheme.emerald.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.picture_as_pdf_rounded,
            size: 20, color: AppTheme.emerald),
      ),
    );
  }

  Widget _buildThemeToggle(bool isDark) {
    return GestureDetector(
      onTap: _toggleDarkMode,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: (isDark ? Colors.white : AppTheme.slate900)
                .withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 16, color: isDark ? Colors.amber : AppTheme.slate700),
          const SizedBox(width: 8),
          Text(isDark ? 'Light' : 'Dark',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppTheme.slate900)),
        ]),
      ),
    );
  }

  Widget _buildQuickSummary(bool isDark) {
    if (_controller.allItems.isEmpty) return const SizedBox.shrink();
    final total = _controller.allItems.length;
    final favorites = _controller.allItems.where((i) => i.isFavorite).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            (isDark ? AppTheme.slate800 : Colors.white).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: (isDark ? Colors.white : AppTheme.emerald)
                .withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total', total.toString(), AppTheme.emerald),
          _buildSummaryDivider(isDark),
          _buildSummaryItem('Favorit', favorites.toString(), Colors.amber),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(children: [
      Text(value,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w900, color: color)),
      Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.slate500)),
    ]);
  }

  Widget _buildSummaryDivider(bool isDark) {
    return Container(
        width: 1,
        height: 24,
        color:
            (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.1));
  }

  Widget _buildUnifiedToolbar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 54,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.slate800 : Colors.white)
                    .withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.slate900,
                    fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Cari barang...',
                  hintStyle: TextStyle(color: AppTheme.slate400, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppTheme.slate400, size: 20),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () => _searchController.clear()),
                    IconButton(
                        icon: const Icon(Icons.qr_code_scanner_rounded,
                            size: 18, color: AppTheme.emerald),
                        onPressed: _startBarcodeScan),
                    const SizedBox(width: 4),
                  ]),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: (isDark ? AppTheme.slate800 : Colors.white)
                .withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            child: InkWell(
              onTap: _showFilterBottomSheet,
              child: Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                child: Icon(Icons.tune_rounded,
                    color: isDark ? Colors.white : AppTheme.slate700, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    HapticFeedback.mediumImpact();
    String localSelectedCategory = _controller.selectedCategory;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 40),
            decoration: BoxDecoration(
                color: isDark ? AppTheme.slate900 : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: (isDark ? Colors.white : AppTheme.slate900)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2))),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Filter',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppTheme.slate900)),
                TextButton(
                    onPressed: () =>
                        setSheetState(() => localSelectedCategory = 'Semua'),
                    child: const Text('Reset')),
              ]),
              const SizedBox(height: 12),
              DropdownButtonHideUnderline(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: (isDark ? AppTheme.slate800 : AppTheme.slate100)
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16)),
                  child: DropdownButton<String>(
                    value: localSelectedCategory,
                    isExpanded: true,
                    dropdownColor: isDark ? AppTheme.slate900 : Colors.white,
                    items: [
                      'Semua',
                      ...CategoryModel.allCategories.map((c) => c.name)
                    ]
                        .map((cat) =>
                            DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null)
                        setSheetState(() => localSelectedCategory = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                      onPressed: () {
                        _controller.setCategory(localSelectedCategory);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.white : AppTheme.slate900,
                          foregroundColor:
                              isDark ? AppTheme.slate900 : Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: const Text('Terapkan',
                          style: TextStyle(fontWeight: FontWeight.w900)))),
            ]),
          );
        });
      },
    );
  }

  Widget _buildMinimalistFAB(bool isDark) {
    return FloatingActionButton(
      onPressed: () async {
        HapticFeedback.lightImpact();
        final result = await Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddItemScreen()));
        if (result == true) _controller.loadItems();
      },
      backgroundColor: isDark ? Colors.white : AppTheme.slate900,
      elevation: 8,
      shape: const CircleBorder(),
      child: Icon(Icons.add_rounded,
          color: isDark ? AppTheme.slate900 : Colors.white, size: 36),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inventory_2_outlined,
          size: 64,
          color: (isDark ? Colors.white : AppTheme.slate900)
              .withValues(alpha: 0.1)),
      const SizedBox(height: 20),
      Text('Belum Ada Barang',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: (isDark ? Colors.white : AppTheme.slate900)
                  .withValues(alpha: 0.4))),
    ]).animate().fadeIn());
  }

  Widget _buildWatermark(bool isDark) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
            child: Text('Neverland Studio',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: (isDark ? Colors.white : AppTheme.slate900)
                        .withValues(alpha: 0.1),
                    letterSpacing: 3))));
  }

  Widget _buildDeleteBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
      ),
      child:
          const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 30),
    );
  }

  Future<bool?> _showDeleteConfirmation(
      BuildContext context, dynamic item) async {
    HapticFeedback.mediumImpact();
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.slate900
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus Barang?',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text(
            'Yakin ingin menghapus "${item.namaBarang}"? Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('BATAL',
                style: TextStyle(
                    color: AppTheme.slate500, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('HAPUS',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
