import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../controllers/item_controller.dart';
import '../services/image_service.dart';
import '../services/scanner_service.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';
import '../models/category_model.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _catatanController = TextEditingController();
  final _barcodeController = TextEditingController();
  final ImageService _imageService = ImageService();

  DateTime? _garansiHabis;
  DateTime? _tglKadaluarsa;
  String? _imagePath;
  String _selectedCategory = 'Lainnya';
  bool _isSaving = false;

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _catatanController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  void _applyAISuggestion() {
    final name = _namaController.text.trim();
    if (name.isEmpty) return;
    HapticFeedback.heavyImpact();
    final predictedCat = AIService.predictCategory(name);
    setState(() {
      _selectedCategory = predictedCat;
      if (_lokasiController.text.isEmpty) {
        _lokasiController.text = AIService.suggestLocation(predictedCat);
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    HapticFeedback.lightImpact();
    final path = await (source == ImageSource.camera
        ? _imageService.pickImageFromCamera(context)
        : _imageService.pickImageFromGallery(context));
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
          decoration: BoxDecoration(color: isDark ? AppTheme.slate800 : Colors.white, borderRadius: BorderRadius.circular(32)),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 44, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2))),
              Text('Sumber Foto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppTheme.slate900)),
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
                _buildPhotoOption(icon: Icons.delete_outline_rounded, label: 'Hapus Foto', color: Colors.redAccent, onTap: () { setState(() => _imagePath = null); Navigator.pop(context); }),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoOption({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, color: color, size: 22), const SizedBox(width: 10), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15))],
        ),
      ),
    );
  }

  Future<void> _saveItem() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.vibrate();
      return;
    }
    setState(() => _isSaving = true);
    try {
      final item = ItemModel(
        namaBarang: _namaController.text.trim(),
        lokasi: _lokasiController.text.trim(),
        foto: _imagePath,
        kategori: _selectedCategory,
        catatan: _catatanController.text.trim().isNotEmpty ? _catatanController.text.trim() : null,
        barcode: _barcodeController.text.trim().isNotEmpty ? _barcodeController.text.trim() : null,
        garansiHabis: _garansiHabis,
        tglKadaluarsa: _tglKadaluarsa,
      );
      await context.read<ItemController>().addItem(item);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.midnightScaffold : AppTheme.pearlScaffold,
      appBar: _buildAppBar(isDark),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildImageSection(isDark),
            const SizedBox(height: 32),
            _buildCardHeader('INFORMASI DETAIL', isDark),
            _buildMainSection(isDark),
            const SizedBox(height: 32),
            _buildCardHeader('SISTEM & MASA BERLAKU', isDark),
            _buildAdvancedSection(isDark),
            const SizedBox(height: 48),
            _buildSaveButton(isDark),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: isDark ? Colors.white : AppTheme.slate900),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'CATAT BARANG BARU',
        style: TextStyle(
          color: isDark ? Colors.white : AppTheme.slate900,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildImageSection(bool isDark) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: double.infinity,
        height: 220,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.1), width: 2),
          image: _imagePath != null ? DecorationImage(image: FileImage(File(_imagePath!)), fit: BoxFit.cover) : null,
        ),
        child: _imagePath == null 
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.2), size: 48),
                const SizedBox(height: 12),
                Text('TAMBAHKAN FOTO BARANG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.2), letterSpacing: 1.5)),
              ],
            ) 
          : null,
      ),
    );
  }

  Widget _buildCardHeader(String title, bool isDark) {
    return Padding(padding: const EdgeInsets.only(left: 4, bottom: 12), child: Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.4))));
  }

  Widget _buildMainSection(bool isDark) {
    return Column(
      children: [
        _buildOutlinedField(
          controller: _namaController, 
          label: 'Nama Barang', 
          hint: 'Masukkan nama barang', 
          icon: Icons.inventory_2_outlined, 
          isDark: isDark,
          validator: (v) => (v == null || v.isEmpty) ? 'Nama barang wajib diisi' : null,
          suffix: IconButton(icon: const Icon(Icons.auto_awesome_rounded, size: 18, color: AppTheme.emerald), onPressed: _applyAISuggestion),
        ),
        const SizedBox(height: 16),
        _buildOutlinedField(
          controller: _lokasiController, 
          label: 'Lokasi Simpan', 
          hint: 'Masukkan lokasi penyimpanan', 
          icon: Icons.location_on_outlined, 
          isDark: isDark,
          validator: (v) => (v == null || v.isEmpty) ? 'Lokasi wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        _buildCategorySelector(isDark),
        const SizedBox(height: 16),
        _buildOutlinedField(controller: _catatanController, label: 'Catatan Singkat', hint: 'Masukkan catatan tambahan...', icon: Icons.description_outlined, isDark: isDark, maxLines: 3),
      ],
    );
  }

  Widget _buildAdvancedSection(bool isDark) {
    return Column(
      children: [
        _buildOutlinedField(controller: _barcodeController, label: 'Barcode / QR', hint: 'Masukkan atau scan barcode', icon: Icons.qr_code_2_rounded, isDark: isDark, suffix: IconButton(icon: const Icon(Icons.qr_code_scanner_rounded, size: 20, color: AppTheme.emerald), onPressed: () async { final res = await ScannerService.scanBarcode(context); if (res != null) setState(() => _barcodeController.text = res); })),
        const SizedBox(height: 16),
        _buildDateSelector('Masa Garansi', _garansiHabis, isDark, Icons.verified_user_outlined, () async {
          final res = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
          if (res != null) setState(() => _garansiHabis = res);
        }),
        const SizedBox(height: 16),
        _buildDateSelector('Kadaluarsa', _tglKadaluarsa, isDark, Icons.timer_outlined, () async {
          final res = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
          if (res != null) setState(() => _tglKadaluarsa = res);
        }),
      ],
    );
  }

  Widget _buildOutlinedField({required TextEditingController controller, required String label, required String hint, required IconData icon, required bool isDark, Widget? suffix, int maxLines = 1, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 6), child: Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.emerald, letterSpacing: 1))),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppTheme.slate900),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14, color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.2)),
            prefixIcon: Icon(icon, size: 20, color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.3)),
            suffixIcon: suffix,
            filled: true,
            fillColor: (isDark ? AppTheme.slate800 : Colors.white).withValues(alpha: 0.8),
            contentPadding: const EdgeInsets.all(20),
            errorStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.redAccent),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.08))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.08))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.emerald, width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 6), child: Text('KATEGORI', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.emerald, letterSpacing: 1))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: (isDark ? AppTheme.slate800 : Colors.white).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              dropdownColor: isDark ? AppTheme.slate800 : Colors.white,
              borderRadius: BorderRadius.circular(20),
              items: CategoryModel.allCategories.map((c) => DropdownMenuItem(
                value: c.name,
                child: Row(children: [Icon(c.icon, size: 18, color: c.color), const SizedBox(width: 12), Text(c.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppTheme.slate900))]),
              )).toList(),
              onChanged: (v) { if (v != null) setState(() => _selectedCategory = v); },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, bool isDark, IconData icon, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 6), child: Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.emerald, letterSpacing: 1))),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.slate800 : Colors.white).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.3)),
                const SizedBox(width: 16),
                Text(date != null ? "${date.day}/${date.month}/${date.year}" : 'Ketuk untuk set tanggal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: date != null ? (isDark ? Colors.white : AppTheme.slate900) : (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.2))),
                const Spacer(),
                const Icon(Icons.calendar_month_rounded, size: 18, color: AppTheme.emerald),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.emerald,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSaving ? null : _saveItem,
          borderRadius: BorderRadius.circular(20),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          child: Center(
            child: _isSaving
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('SIMPAN BARANG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 1)),
          ),
        ),
      ),
    );
  }
}
