import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../models/category_model.dart';
import '../controllers/item_controller.dart';
import '../services/image_service.dart';
import '../services/scanner_service.dart';
import '../theme/app_theme.dart';

class EditItemScreen extends StatefulWidget {
  final ItemModel item;
  const EditItemScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _lokasiController;
  late TextEditingController _catatanController;
  late TextEditingController _barcodeController;
  late TextEditingController _peminjamController;
  final ImageService _imageService = ImageService();

  DateTime? _garansiHabis;
  DateTime? _tglKadaluarsa;
  DateTime? _tglPinjam;
  DateTime? _tglKembali;

  String? _imagePath;
  late String _selectedCategory;
  late bool _isFavorite;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.item.namaBarang);
    _lokasiController = TextEditingController(text: widget.item.lokasi);
    _catatanController = TextEditingController(text: widget.item.catatan ?? '');
    _barcodeController = TextEditingController(text: widget.item.barcode ?? '');
    _peminjamController = TextEditingController(text: widget.item.peminjam ?? '');
    
    _garansiHabis = widget.item.garansiHabis;
    _tglKadaluarsa = widget.item.tglKadaluarsa;
    _tglPinjam = widget.item.tglPinjam;
    _tglKembali = widget.item.tglKembali;
    
    _imagePath = widget.item.foto;
    _selectedCategory = widget.item.kategori;
    _isFavorite = widget.item.isFavorite;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _catatanController.dispose();
    _barcodeController.dispose();
    _peminjamController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    HapticFeedback.lightImpact();
    final path = await (source == ImageSource.camera
        ? _imageService.pickImageFromCamera()
        : _imageService.pickImageFromGallery());
    if (path != null) setState(() => _imagePath = path);
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.slate800 : Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 40, offset: const Offset(0, -8)),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: AppTheme.slate400.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text('Sumber Foto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppTheme.slate900, letterSpacing: -0.5)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildPhotoOption(icon: Icons.camera_alt_rounded, label: 'Kamera', color: AppTheme.emerald, onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); })),
                  const SizedBox(width: 12),
                  Expanded(child: _buildPhotoOption(icon: Icons.photo_library_rounded, label: 'Galeri', color: AppTheme.cyberBlue, onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); })),
                ],
              ),
              if (_imagePath != null) ...[
                const SizedBox(height: 12),
                _buildPhotoOption(icon: Icons.delete_outline_rounded, label: 'Hapus Foto', color: Colors.redAccent, onTap: () { setState(() => _imagePath = null); Navigator.pop(context); }, fullWidth: true),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoOption({required IconData icon, required String label, required Color color, required VoidCallback onTap, bool fullWidth = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Future<void> _updateItem() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    try {
      final updatedItem = widget.item.copyWith(
        namaBarang: _namaController.text.trim(),
        lokasi: _lokasiController.text.trim(),
        foto: _imagePath,
        kategori: _selectedCategory,
        isFavorite: _isFavorite,
        catatan: _catatanController.text.trim().isNotEmpty ? _catatanController.text.trim() : null,
        barcode: _barcodeController.text.trim().isNotEmpty ? _barcodeController.text.trim() : null,
        peminjam: _peminjamController.text.trim().isNotEmpty ? _peminjamController.text.trim() : null,
        tglPinjam: _tglPinjam,
        tglKembali: _tglKembali,
        garansiHabis: _garansiHabis,
        tglKadaluarsa: _tglKadaluarsa,
      );
      await context.read<ItemController>().updateItem(updatedItem);
      if (mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text('Barang diperbarui!', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            backgroundColor: AppTheme.emerald,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.slate800 : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 40)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 36),
                ),
                const SizedBox(height: 20),
                Text('Hapus Barang?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppTheme.slate900)),
                const SizedBox(height: 10),
                Text(
                  '"${widget.item.namaBarang}" akan dihapus permanen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? AppTheme.slate400 : AppTheme.slate500, height: 1.5, fontSize: 14),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.slate700 : const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text('Batal', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : AppTheme.slate600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: const Text('Hapus', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true && mounted) {
      try {
        await context.read<ItemController>().deleteItem(widget.item);
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }

  Future<void> _scanBarcode() async {
    HapticFeedback.mediumImpact();
    final result = await ScannerService.scanBarcode(context);
    if (result != null) {
      setState(() {
        _barcodeController.text = result;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, String type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.emerald,
              onPrimary: Colors.white,
              onSurface: AppTheme.slate800,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (type == 'garansi') _garansiHabis = picked;
        if (type == 'kadaluarsa') _tglKadaluarsa = picked;
        if (type == 'pinjam') _tglPinjam = picked;
        if (type == 'kembali') _tglKembali = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.slate900 : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.slate800 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : AppTheme.slate900, size: 20),
          ),
        ),
        title: Text(
          'Edit Barang',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: isDark ? Colors.white : AppTheme.slate900, letterSpacing: -0.5),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: _deleteItem,
            child: Container(
              margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.15)),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            ),
          ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            _buildImageSection(isDark),
            const SizedBox(height: 20),
            _buildFormCard(isDark),
            const SizedBox(height: 16),
            _buildBarcodeCard(isDark),
            const SizedBox(height: 16),
            _buildLendingCard(isDark),
            const SizedBox(height: 16),
            _buildAlertsCard(isDark),
            const SizedBox(height: 16),
            _buildCategoryCard(isDark),
            const SizedBox(height: 32),
            _buildUpdateButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(bool isDark) {
    ImageProvider? imgProvider;
    if (_imagePath != null) {
      if (_imagePath!.startsWith('assets/')) {
        imgProvider = AssetImage(_imagePath!);
      } else {
        imgProvider = FileImage(File(_imagePath!));
      }
    }

    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: isDark ? AppTheme.slate800 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.emerald.withValues(alpha: imgProvider != null ? 0.15 : 0.06),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
          image: imgProvider != null ? DecorationImage(image: imgProvider, fit: BoxFit.cover) : null,
          border: Border.all(
            color: imgProvider != null ? AppTheme.emerald.withValues(alpha: 0.4) : AppTheme.emerald.withValues(alpha: 0.12),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imgProvider == null)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppTheme.emerald.withValues(alpha: 0.08), shape: BoxShape.circle),
                      child: Icon(Icons.add_a_photo_outlined, size: 36, color: AppTheme.emerald.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 12),
                    Text('Tap untuk tambah foto', style: TextStyle(color: isDark ? AppTheme.slate400 : AppTheme.slate500, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Kamera atau Galeri', style: TextStyle(color: (isDark ? AppTheme.slate400 : AppTheme.slate500).withValues(alpha: 0.6), fontSize: 12)),
                  ],
                ),
              // Favorite toggle
              Positioned(
                top: 14,
                left: 14,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _isFavorite = !_isFavorite);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isFavorite ? Colors.amber.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: imgProvider != null ? Colors.black.withValues(alpha: 0.5) : AppTheme.emerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: imgProvider != null ? Colors.white.withValues(alpha: 0.2) : AppTheme.emerald.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(imgProvider != null ? Icons.edit_rounded : Icons.camera_alt_rounded, size: 14,
                          color: imgProvider != null ? Colors.white : AppTheme.emerald),
                      const SizedBox(width: 6),
                      Text(imgProvider != null ? 'Ganti' : 'Pilih', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                          color: imgProvider != null ? Colors.white : AppTheme.emerald)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildFormCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text('DETAIL BARANG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppTheme.emerald)),
          ),
          _buildModernField(controller: _namaController, label: 'Nama Barang', hint: 'Contoh: Kunci Cadangan, Charger...', icon: Icons.inventory_2_outlined, isDark: isDark, isRequired: true, validator: (v) => v?.trim().isEmpty ?? true ? 'Nama barang wajib diisi' : null),
          _buildDivider(isDark),
          _buildModernField(controller: _lokasiController, label: 'Lokasi Penyimpanan', hint: 'Contoh: Laci Meja, Rak Buku...', icon: Icons.place_outlined, isDark: isDark, isRequired: true, validator: (v) => v?.trim().isEmpty ?? true ? 'Lokasi wajib diisi' : null),
          _buildDivider(isDark),
          _buildModernField(controller: _catatanController, label: 'Catatan', hint: 'Info tambahan tentang barang ini...', icon: Icons.sticky_note_2_outlined, isDark: isDark, maxLines: 3),
          const SizedBox(height: 4),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 50.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool isRequired = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppTheme.emerald),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? AppTheme.slate300 : AppTheme.slate600, letterSpacing: 0.3)),
              if (isRequired) ...[
                const SizedBox(width: 4),
                const Text('*', style: TextStyle(color: AppTheme.emerald, fontWeight: FontWeight.w900, fontSize: 14)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? Colors.white : AppTheme.slate900),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.3), fontWeight: FontWeight.w400, fontSize: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, thickness: 1, color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.06)),
    );
  }

  Widget _buildCategoryCard(bool isDark) {
    final selectedCat = CategoryModel.allCategories.firstWhere(
      (c) => c.name == _selectedCategory,
      orElse: () => CategoryModel.allCategories.last,
    );

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.category_outlined, size: 15, color: AppTheme.emerald),
              const SizedBox(width: 8),
              Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.slate300 : AppTheme.slate600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 4),
              const Text('*', style: TextStyle(color: AppTheme.emerald, fontWeight: FontWeight.w900, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonHideUnderline(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: selectedCat.color.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: selectedCat.color.withValues(alpha: 0.3), width: 1.5),
              ),
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? AppTheme.slate400 : AppTheme.slate500),
                dropdownColor: isDark ? AppTheme.slate800 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                elevation: 8,
                selectedItemBuilder: (context) => CategoryModel.allCategories.map((cat) {
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: cat.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(cat.icon, color: cat.color, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cat.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: isDark ? Colors.white : AppTheme.slate900,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                items: CategoryModel.allCategories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat.name,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: cat.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(cat.icon, color: cat.color, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            cat.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isDark ? Colors.white : AppTheme.slate900,
                            ),
                          ),
                        ),
                        if (cat.name == _selectedCategory)
                          Icon(Icons.check_rounded, color: AppTheme.emerald, size: 18),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.05, end: 0);
  }


  Widget _buildBarcodeCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.qr_code_scanner_rounded, size: 15, color: AppTheme.emerald),
              const SizedBox(width: 8),
              Text('BARCODE / QR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppTheme.emerald)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _barcodeController,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? Colors.white : AppTheme.slate900),
                  decoration: InputDecoration(
                    hintText: 'Scan atau ketik manual...',
                    hintStyle: TextStyle(color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.3), fontWeight: FontWeight.w400, fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.04),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _scanBarcode,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.emerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.emerald.withValues(alpha: 0.2)),
                  ),
                  child: Icon(Icons.center_focus_weak_rounded, color: AppTheme.emerald),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLendingCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Icon(Icons.handshake_outlined, size: 15, color: AppTheme.cyberBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'PELACAK PEMINJAMAN',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppTheme.cyberBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildModernField(
            controller: _peminjamController,
            label: 'Nama Peminjam',
            hint: 'Siapa yang meminjam?',
            icon: Icons.person_outline_rounded,
            isDark: isDark,
          ),
          _buildDivider(isDark),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildDatePickerField(
                    label: 'Tgl Pinjam',
                    date: _tglPinjam,
                    isDark: isDark,
                    onTap: () => _selectDate(context, 'pinjam'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDatePickerField(
                    label: 'Tgl Kembali',
                    date: _tglKembali,
                    isDark: isDark,
                    onTap: () => _selectDate(context, 'kembali'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active_outlined, size: 15, color: Colors.orangeAccent),
              const SizedBox(width: 8),
              Expanded(child: Text('PENGINGAT (REMINDERS)', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.orangeAccent))),
            ],
          ),
          const SizedBox(height: 16),
          _buildDatePickerField(label: 'Masa Garansi Habis', date: _garansiHabis, isDark: isDark, onTap: () => _selectDate(context, 'garansi')),
          const SizedBox(height: 12),
          _buildDatePickerField(label: 'Tanggal Kadaluarsa', date: _tglKadaluarsa, isDark: isDark, onTap: () => _selectDate(context, 'kadaluarsa')),
        ],
      ),
    );
  }

  Widget _buildDatePickerField({required String label, DateTime? date, required bool isDark, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? AppTheme.slate400 : AppTheme.slate500)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.04), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 14, color: isDark ? AppTheme.slate300 : AppTheme.slate600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null ? "${date.day}/${date.month}/${date.year}" : "Pilih Tanggal",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: date != null ? FontWeight.w700 : FontWeight.w400,
                      color: date != null ? (isDark ? Colors.white : AppTheme.slate900) : (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton(bool isDark) {
    return GestureDetector(
      onTap: _isSaving ? null : _updateItem,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isSaving
                ? [AppTheme.emerald.withValues(alpha: 0.5), AppTheme.emerald.withValues(alpha: 0.5)]
                : [AppTheme.emerald, const Color(0xFF059669)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isSaving ? [] : [BoxShadow(color: AppTheme.emerald.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Center(
          child: _isSaving
              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Text('Update Barang', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                  ],
                ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: 0.05, end: 0);
  }
}
