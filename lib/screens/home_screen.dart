import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../models/category_model.dart';
import '../services/preferences_service.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';
import '../widgets/item_card.dart';
import '../controllers/item_controller.dart';
import 'add_item_screen.dart';
import 'edit_item_screen.dart';
import '../models/item_model.dart';
import '../services/scanner_service.dart';
import '../services/voice_service.dart';
import '../services/report_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ItemController _controller = ItemController();
  final TextEditingController _searchController = TextEditingController();
  bool _isDarkMode = false;
  bool _isListening = false;
  final VoiceService _voiceService = VoiceService();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  bool _isFABExpanded = true;

  @override
  void initState() {
    super.initState();
    _controller.loadItems();
    _loadPreferences();
    _searchController.addListener(() {
      _controller.setSearchQuery(_searchController.text);
      if (mounted) setState(() {});
    });
    _controller.addListener(_onControllerChange);
    _voiceService.init();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });

    // Shrink FAB after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isFABExpanded = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  Future<void> _loadPreferences() async {
    final darkMode = await PreferencesService.isDarkMode();
    setState(() {
      _isDarkMode = darkMode;
    });
  }

  Future<void> _toggleDarkMode() async {
    HapticFeedback.lightImpact();
    final newValue = !_isDarkMode;
    await PreferencesService.setDarkMode(newValue);
    setState(() {
      _isDarkMode = newValue;
    });
    ThemeService.toggleTheme(newValue);
  }

  void _startVoiceSearch() {
    HapticFeedback.mediumImpact();
    _voiceService.startListening(
      onResult: (text) {
        setState(() {
          _searchController.text = text;
        });
      },
      onListening: (listening) {
        setState(() {
          _isListening = listening;
        });
      },
    );
  }

  Future<void> _startBarcodeScan() async {
    HapticFeedback.mediumImpact();
    final result = await ScannerService.scanBarcode(context);
    if (result != null) {
      final item = _controller.allItems.where((ItemModel i) => i.barcode == result).toList();
      if (item.isNotEmpty) {
        if (mounted) {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditItemScreen(item: item.first)),
          );
          if (refresh == true) _controller.loadItems();
        }
      } else {
        setState(() {
          _searchController.text = result;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkPageGradient : AppTheme.pageGradient,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.emerald.withValues(alpha: isDark ? 0.05 : 0.08),
                  shape: BoxShape.circle,
                ),
              ).animate().fadeIn(duration: 1.seconds).scale(begin: const Offset(0.5, 0.5)),
            ),
            
            SafeArea(
              child: Column(
                children: [
                  _buildModernHeader(isDark),
                  _buildInsightsDashboard(isDark),
                  _buildStatSection(isDark),
                  _buildSearchAndFilter(isDark),
                  Expanded(
                    child: _controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _controller.filteredItems.isEmpty
                            ? _buildEmptyState(isDark)
                            : RefreshIndicator(
                                onRefresh: _controller.loadItems,
                                color: AppTheme.emerald,
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _controller.filteredItems.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == _controller.filteredItems.length) {
                                      return _buildWatermark(isDark);
                                    }
                                    final item = _controller.filteredItems[index];
                                    return ItemCard(
                                      item: item,
                                      onTap: () async {
                                        await _controller.incrementView(item.id!);
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditItemScreen(item: item),
                                          ),
                                        );
                                        if (result == true) {
                                          _controller.loadItems();
                                        }
                                      },
                                      onDelete: () => _controller.deleteItem(item),
                                      onFavoriteToggle: (isFavorite) => 
                                          _controller.toggleFavorite(item, isFavorite),
                                    );
                                  },
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildPremiumShrinkingFAB(isDark),
    );
  }

  Widget _buildPremiumShrinkingFAB(bool isDark) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddItemScreen()),
        );
        if (result == true) _controller.loadItems();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart,
        height: 56, // Standard minimalist FAB height
        padding: EdgeInsets.symmetric(horizontal: _isFABExpanded ? 20 : 16),
        decoration: BoxDecoration(
          gradient: AppTheme.mintGradient,
          borderRadius: BorderRadius.circular(28), // Pill-shaped
          boxShadow: [
            BoxShadow(
              color: AppTheme.emerald.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: _isFABExpanded ? 65 : 0, // Compact width for "Tambah"
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isFABExpanded ? 1 : 0,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    'Tambah',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms); // Simpler animation
  }

  Widget _buildModernHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.emerald.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'MANAJEMEN BARANG',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.emerald,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Barangku Dimana?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppTheme.slate900,
                    letterSpacing: -1.2,
                  ),
                ),
              ],
            ),
          ),
          _buildThemeToggle(isDark),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(bool isDark) {
    return GestureDetector(
      onTap: _toggleDarkMode,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.slate800 : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: (isDark ? Colors.white : AppTheme.emerald).withValues(alpha: 0.08),
          ),
        ),
        child: Icon(
          _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: AppTheme.emerald,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildStatSection(bool isDark) {
    final recentCount = _controller.allItems.where((ItemModel item) {
      final diff = DateTime.now().difference(item.createdAt);
      return diff.inDays < 7;
    }).length;
    final favoriteCount = _controller.allItems.where((ItemModel item) => item.isFavorite).length;

    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildMiniStatChip(
            'Baru', 
            recentCount.toString(), 
            AppTheme.emerald,
            Icons.auto_awesome_rounded,
            isDark
          ),
          const SizedBox(width: 8),
          _buildMiniStatChip(
            'Favorit', 
            favoriteCount.toString(), 
            Colors.amber,
            Icons.star_rounded,
            isDark,
            onTap: () => _controller.toggleFavorites(!_controller.showFavoritesOnly),
            isSelected: _controller.showFavoritesOnly,
          ),
          const SizedBox(width: 8),
          _buildActionChip(
            'Ekspor Laporan',
            Icons.picture_as_pdf_rounded,
            AppTheme.cyberBlue,
            isDark,
            onTap: () => _exportReport(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms); // Simpler animation
  }

  Widget _buildActionChip(String title, IconData icon, Color color, bool isDark, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsDashboard(bool isDark) {
    if (_controller.allItems.isEmpty) return const SizedBox.shrink();

    final borrowedCount = _controller.allItems.where((i) => i.peminjam != null).length;
    final now = DateTime.now();
    final criticalCount = _controller.allItems.where((i) {
      if (i.garansiHabis != null) {
        final days = i.garansiHabis!.difference(now).inDays;
        if (days >= 0 && days <= 7) return true;
      }
      if (i.tglKadaluarsa != null) {
        final days = i.tglKadaluarsa!.difference(now).inDays;
        if (days >= 0 && days <= 7) return true;
      }
      return false;
    }).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate800.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (isDark ? Colors.white : AppTheme.emerald).withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RINGKASAN STATUS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.4),
                ),
              ),
              Icon(Icons.insights_rounded, size: 14, color: AppTheme.emerald.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInsightItem(
                  'Total Barang',
                  _controller.allItems.length.toString(),
                  Icons.inventory_2_outlined,
                  AppTheme.emerald,
                  isDark,
                ),
              ),
              Container(width: 1, height: 32, color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.05)),
              Expanded(
                child: _buildInsightItem(
                  'Dipinjam',
                  borrowedCount.toString(),
                  Icons.handshake_outlined,
                  AppTheme.cyberBlue,
                  isDark,
                ),
              ),
              Container(width: 1, height: 32, color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.05)),
              Expanded(
                child: _buildInsightItem(
                  'Sangat Penting',
                  criticalCount.toString(),
                  Icons.notification_important_outlined,
                  Colors.redAccent,
                  isDark,
                  isCritical: criticalCount > 0,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildInsightItem(String label, String value, IconData icon, Color color, bool isDark, {bool isCritical = false}) {
    return Column(
      children: [
        Icon(icon, size: 18, color: isCritical ? Colors.redAccent : color.withValues(alpha: 0.6)),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppTheme.slate900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Future<void> _exportReport() async {
    HapticFeedback.mediumImpact();
    await ReportService.generateInventoryPdf(_controller.allItems);
  }

  Widget _buildMiniStatChip(String title, String value, Color color, IconData icon, bool isDark, {VoidCallback? onTap, bool isSelected = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withValues(alpha: 0.15) 
              : (isDark ? AppTheme.slate800.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : (isDark ? Colors.white.withValues(alpha: 0.05) : AppTheme.emerald.withValues(alpha: 0.1)),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppTheme.slate900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: 250.ms,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      if (_isSearchFocused)
                        BoxShadow(
                          color: AppTheme.emerald.withValues(alpha: 0.1),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.slate800 : Colors.white).withValues(alpha: 0.95), // Solid opaque color
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: (_isSearchFocused ? AppTheme.emerald : (isDark ? Colors.white : AppTheme.emerald)).withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: _isListening ? 'Mendengarkan...' : 'Cari barang atau lokasi...',
                        hintStyle: TextStyle(
                          color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.35),
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded, 
                          color: (_isSearchFocused ? AppTheme.emerald : AppTheme.emerald.withValues(alpha: 0.4)), 
                          size: 22
                        ).animate(target: _isSearchFocused ? 1 : 0).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.05, 1.05)),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_searchController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  onPressed: () => _searchController.clear(),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ).animate().scale().fadeIn(),
                              const SizedBox(width: 8),
                              _buildSearchActionIconMini(
                                _isListening ? Icons.mic_rounded : Icons.mic_none_rounded, 
                                _isListening ? Colors.redAccent : AppTheme.emerald,
                                _startVoiceSearch,
                              ),
                              const SizedBox(width: 8),
                              _buildSearchActionIconMini(
                                Icons.qr_code_scanner_rounded, 
                                AppTheme.emerald, 
                                _startBarcodeScan,
                              ),
                            ],
                          ),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildFilterActionMinimalist(isDark),
            ],
          ),
          if (_controller.selectedCategory != 'Semua' || _controller.showFavoritesOnly)
            Row(
              children: [
                _buildFilterChipMinimalist(
                  _controller.showFavoritesOnly ? 'Favorit Saja' : 'Kategori: ${_controller.selectedCategory}',
                  () => _controller.setCategory('Semua'),
                  isDark,
                ),
              ],
            ).animate().fadeIn().slideX(begin: -0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildSearchActionIconMini(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildFilterActionMinimalist(bool isDark) {
    return GestureDetector(
      onTap: _showFilterBottomSheet,
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: (isDark ? AppTheme.slate800 : Colors.white).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: (isDark ? Colors.white : AppTheme.emerald).withValues(alpha: 0.1),
          ),
        ),
        child: Icon(Icons.tune_rounded, color: AppTheme.emerald.withValues(alpha: 0.8), size: 24),
      ),
    );
  }

  Widget _buildFilterChipMinimalist(String label, VoidCallback onDelete, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: AppTheme.emerald.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.emerald),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _controller.setCategory('Semua');
              _controller.toggleFavorites(false);
            },
            child: const Icon(Icons.close_rounded, size: 12, color: AppTheme.emerald),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 40),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.slate900 : Colors.white, // Solid opaque background
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Barang',
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppTheme.slate900,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() => localSelectedCategory = 'Semua');
                        },
                        child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pilih Kategori',
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.w800, 
                        color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.4),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.slate800 : Colors.white).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (isDark ? Colors.white : AppTheme.emerald).withValues(alpha: 0.08),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: localSelectedCategory,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.emerald),
                        dropdownColor: isDark ? AppTheme.slate900 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        items: [
                          const DropdownMenuItem(
                            value: 'Semua',
                            child: Row(
                              children: [
                                Icon(Icons.home_max_outlined, color: AppTheme.emerald, size: 20),
                                SizedBox(width: 10),
                                Text('Semua Kategori', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              ],
                            ),
                          ),
                          ...CategoryModel.allCategories.map((cat) {
                            return DropdownMenuItem(
                              value: cat.name,
                              child: Row(
                                children: [
                                  Icon(cat.icon, color: cat.color, size: 20),
                                  const SizedBox(width: 10),
                                  Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setSheetState(() => localSelectedCategory = value);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        _controller.setCategory(localSelectedCategory);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Terapkan Filter', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.emerald.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppTheme.emerald.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchController.text.isNotEmpty ? 'Barang tidak ditemukan' : 'Belum ada barang',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol + untuk menambah barang baru',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.5),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildWatermark(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 48),
      child: Column(
        children: [
          Text(
            'Neverland Studio',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.15),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'v1.2.0',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
