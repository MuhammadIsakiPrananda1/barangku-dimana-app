import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';

class ItemController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  List<ItemModel> allItems = [];
  List<ItemModel> filteredItems = [];
  bool isLoading = false;
  String selectedCategory = 'Semua';
  bool showFavoritesOnly = false;
  String searchQuery = '';

  Future<void> loadItems() async {
    isLoading = true;
    notifyListeners();

    try {
      List<ItemModel> items;
      if (showFavoritesOnly) {
        items = await _dbHelper.getFavoriteItems();
      } else if (selectedCategory != 'Semua') {
        items = await _dbHelper.getItemsByCategory(selectedCategory);
      } else {
        items = await _dbHelper.getAllItems();
      }

      allItems = items;
      applyFilter();
    } catch (e) {
      debugPrint('Error loading items: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    applyFilter();
  }

  void setCategory(String category) {
    selectedCategory = category;
    loadItems();
  }

  void toggleFavorites(bool value) {
    showFavoritesOnly = value;
    loadItems();
  }

  void applyFilter() {
    if (searchQuery.isEmpty) {
      filteredItems = allItems;
    } else {
      final query = searchQuery.toLowerCase();
      filteredItems = allItems
          .where((item) =>
              item.namaBarang.toLowerCase().contains(query) ||
              item.lokasi.toLowerCase().contains(query))
          .toList();
    }
    notifyListeners();
  }

  Future<void> addItem(ItemModel item) async {
    final id = await _dbHelper.insertItem(item);
    final newItem = item.copyWith(id: id);
    _scheduleAlerts(newItem);
    await loadItems();
  }

  Future<void> updateItem(ItemModel item) async {
    await _dbHelper.updateItem(item);
    _scheduleAlerts(item);
    await loadItems();
  }

  Future<bool> deleteItem(ItemModel item) async {
    try {
      if (item.id != null) {
        _cancelAlerts(item.id!);
        await _dbHelper.deleteItem(item.id!);
      }
      await loadItems();
      return true;
    } catch (e) {
      debugPrint('Error deleting item: $e');
      return false;
    }
  }

  Future<bool> deleteAllItems() async {
    try {
      final itemsToClear = List<ItemModel>.from(allItems);
      for (var item in itemsToClear) {
        if (item.id != null) {
          _cancelAlerts(item.id!);
        }
      }
      await _dbHelper.deleteAllItems();
      await loadItems();
      return true;
    } catch (e) {
      debugPrint('Error deleting all items: $e');
      return false;
    }
  }

  void _scheduleAlerts(ItemModel item) {
    if (item.id == null) return;
    
    final notif = NotificationService();
    
    // Cancel existing first
    _cancelAlerts(item.id!);
    
    if (!SettingsService.warrantyNotifEnabled) return;

    // Schedule Warranty
    if (item.garansiHabis != null) {
      final daysToDue = item.garansiHabis!.difference(DateTime.now()).inDays;
      if (daysToDue >= 0) {
        // Exact day
        notif.scheduleNotification(
          id: item.id! * 20 + 0,
          title: 'Garansi ${_getShortName(item.namaBarang)} Habis Hari Ini!',
          body: 'Segera cek kondisi barang sebelum terlambat.',
          scheduledDate: item.garansiHabis!,
        );
        // 7 days before warning
        if (daysToDue > 7) {
          notif.scheduleNotification(
            id: item.id! * 20 + 1,
            title: 'Garansi ${_getShortName(item.namaBarang)} Sisa 7 Hari!',
            body: 'Masa garansi akan berakhir seminggu lagi.',
            scheduledDate: item.garansiHabis!.subtract(const Duration(days: 7)),
          );
        }
      }
    }

    // Schedule Expiry
    if (item.tglKadaluarsa != null) {
      final daysToDue = item.tglKadaluarsa!.difference(DateTime.now()).inDays;
      if (daysToDue >= 0) {
        // Exact day
        notif.scheduleNotification(
          id: item.id! * 20 + 10,
          title: 'Barang Kadaluarsa!',
          body: '${item.namaBarang} sudah tidak layak digunakan.',
          scheduledDate: item.tglKadaluarsa!,
        );
        // 7 days before warning
        if (daysToDue > 7) {
          notif.scheduleNotification(
            id: item.id! * 20 + 11,
            title: 'Kadaluarsa Sisa 7 Hari!',
            body: '${item.namaBarang} akan kadaluarsa minggu depan.',
            scheduledDate: item.tglKadaluarsa!.subtract(const Duration(days: 7)),
          );
        }
      }
    }

    // Schedule Return (Lending)
    if (item.tglKembali != null && item.peminjam != null) {
      final daysToDue = item.tglKembali!.difference(DateTime.now()).inDays;
      if (daysToDue >= 0) {
        // Exact day
        notif.scheduleNotification(
          id: item.id! * 20 + 20,
          title: 'Hari Ini Pengembalian!',
          body: '${item.peminjam} harus mengembalikan ${item.namaBarang}.',
          scheduledDate: item.tglKembali!,
        );
      }
    }
  }

  String _getShortName(String name) {
    return name.length > 15 ? '${name.substring(0, 12)}...' : name;
  }

  void _cancelAlerts(int itemId) {
    final notif = NotificationService();
    for (int i = 0; i < 30; i++) {
      notif.cancelNotification(itemId * 20 + i);
    }
  }

  Future<bool> toggleFavorite(ItemModel item, bool isFavorite) async {
    try {
      await _dbHelper.toggleFavorite(item.id!, isFavorite);
      await loadItems();
      return true;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }

  Future<void> incrementView(int itemId) async {
    await _dbHelper.incrementViewCount(itemId);
  }
}
