import 'package:flutter/material.dart';

class CategoryModel {
  final String name;
  final IconData icon;
  final Color color;
  final String emoji;

  const CategoryModel({
    required this.name,
    required this.icon,
    required this.color,
    required this.emoji,
  });

  static const List<CategoryModel> allCategories = [
    CategoryModel(
      name: 'Elektronik',
      icon: Icons.devices_rounded,
      color: Color(0xFF2196F3),
      emoji: '📱',
    ),
    CategoryModel(
      name: 'Kunci',
      icon: Icons.key_rounded,
      color: Color(0xFFFFC107),
      emoji: '🔑',
    ),
    CategoryModel(
      name: 'Dokumen',
      icon: Icons.description_rounded,
      color: Color(0xFF4CAF50),
      emoji: '📄',
    ),
    CategoryModel(
      name: 'Pakaian',
      icon: Icons.checkroom_rounded,
      color: Color(0xFFE91E63),
      emoji: '👕',
    ),
    CategoryModel(
      name: 'Alat',
      icon: Icons.build_rounded,
      color: Color(0xFFFF5722),
      emoji: '🔧',
    ),
    CategoryModel(
      name: 'Obat',
      icon: Icons.medical_services_rounded,
      color: Color(0xFFF44336),
      emoji: '💊',
    ),
    CategoryModel(
      name: 'Mainan',
      icon: Icons.toys_rounded,
      color: Color(0xFF9C27B0),
      emoji: '🎮',
    ),
    CategoryModel(
      name: 'Buku',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF795548),
      emoji: '📚',
    ),
    CategoryModel(
      name: 'Lainnya',
      icon: Icons.category_rounded,
      color: Color(0xFF607D8B),
      emoji: '📦',
    ),
  ];

  static CategoryModel? getByName(String name) {
    try {
      return allCategories.firstWhere((cat) => cat.name == name);
    } catch (e) {
      return allCategories.last; // Return 'Lainnya' as default
    }
  }

  static Color getColorByName(String name) {
    return getByName(name)?.color ?? const Color(0xFF607D8B);
  }

  static IconData getIconByName(String name) {
    return getByName(name)?.icon ?? Icons.category_rounded;
  }

  static String getEmojiByName(String name) {
    return getByName(name)?.emoji ?? '📦';
  }
}
