import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';

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

  void _scheduleAlerts(ItemModel item) {
    if (item.id == null) return;
    
    final notif = NotificationService();
    
    // Cancel existing first
    _cancelAlerts(item.id!);

    // Schedule Warranty
    if (item.garansiHabis != null) {
      if (item.garansiHabis!.isAfter(DateTime.now())) {
        notif.scheduleNotification(
          id: item.id! * 10 + 0,
          title: 'Garansi Habis!',
          body: 'Masa garansi ${item.namaBarang} habis hari ini.',
          scheduledDate: item.garansiHabis!,
        );
      }
    }

    // Schedule Expiry
    if (item.tglKadaluarsa != null) {
      if (item.tglKadaluarsa!.isAfter(DateTime.now())) {
        notif.scheduleNotification(
          id: item.id! * 10 + 1,
          title: 'Barang Kadaluarsa!',
          body: 'Masa berlaku ${item.namaBarang} habis hari ini.',
          scheduledDate: item.tglKadaluarsa!,
        );
      }
    }

    // Schedule Return (Lending)
    if (item.tglKembali != null && item.peminjam != null) {
      if (item.tglKembali!.isAfter(DateTime.now())) {
        notif.scheduleNotification(
          id: item.id! * 10 + 2,
          title: 'Waktunya Pengembalian!',
          body: '${item.peminjam} harus mengembalikan ${item.namaBarang} hari ini.',
          scheduledDate: item.tglKembali!,
        );
      }
    }
  }

  void _cancelAlerts(int itemId) {
    final notif = NotificationService();
    notif.cancelNotification(itemId * 10 + 0);
    notif.cancelNotification(itemId * 10 + 1);
    notif.cancelNotification(itemId * 10 + 2);
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
