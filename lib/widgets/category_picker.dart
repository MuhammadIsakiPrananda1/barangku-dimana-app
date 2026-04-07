import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/category_model.dart';

class CategoryPicker extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryPicker({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            'Kategori',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : const Color(0xFF2C4E63),
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          value: selectedCategory,
          decoration: InputDecoration(
            prefixIcon: Icon(
              CategoryModel.getIconByName(selectedCategory),
              color: CategoryModel.getColorByName(selectedCategory),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          dropdownColor: isDark ? const Color(0xFF1E2830) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          items: CategoryModel.allCategories.map((category) {
            return DropdownMenuItem<String>(
              value: category.name,
              child: Row(
                children: [
                  Icon(
                    category.icon,
                    color: category.color,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF2C4E63),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              HapticFeedback.selectionClick();
              onCategorySelected(value);
            }
          },
        ),
      ],
    );
  }
}
