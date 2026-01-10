import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:my_secure_note_app/core/feature/notes_dashboard/provider/dashboard_provider.dart';

class CategoryFilterSection extends ConsumerWidget {
  final ValueChanged<String>? onCategoryChanged;

  final double? height;

  final double? horizontalPadding;

  final double? chipSpacing;

  final bool showIcons;

  final List<String>? customCategories;

  const CategoryFilterSection({
    super.key,
    this.onCategoryChanged,
    this.height,
    this.horizontalPadding,
    this.chipSpacing,
    this.showIcons = true,
    this.customCategories,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = customCategories ?? Constants.categories;

    return SizedBox(
      height: height ?? 5.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 4.w),
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) =>
            SizedBox(width: chipSpacing ?? 2.w),
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryChip(
            category: category,
            onPressed: () {
              onCategoryChanged?.call(category);
            },
          );
        },
      ),
    );
  }
}

class CategoryChip extends ConsumerWidget {
  final String category;
  final VoidCallback onPressed;

  const CategoryChip({
    super.key,
    required this.category,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final isSelected = category == selectedCategory;
    final icon = Constants.getCategoryIcon(category);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedBackground =
        isDark ? theme.colorScheme.onSurface : theme.colorScheme.primary;
    final selectedForeground =
        isDark ? theme.colorScheme.surface : theme.colorScheme.onSecondary;
    final unselectedBackground = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surface;
    final unselectedBorder = isDark
        ? theme.colorScheme.outlineVariant
        : theme.colorScheme.outline;
    final unselectedForeground = isDark
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedBackground : unselectedBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? selectedBackground : unselectedBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? selectedForeground
                  : unselectedForeground,
            ),
            const SizedBox(width: 8),
            Text(
              category,
              style: TextStyle(
                color: isSelected
                    ? selectedForeground
                    : unselectedForeground,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Constants {
  static const String defaultCategory = 'All Notes';

  static const List<String> categories = [
    'All Notes',
    'Personal',
    'Work',
    'Finance',
    'Health',
    'Ideas',
    'Passwords',
    'Important',
  ];

  static const Map<String, IconData> categoryIcons = {
    'All Notes': Icons.grid_view_rounded,
    'Personal': Icons.person_rounded,
    'Work': Icons.work_rounded,
    'Finance': Icons.account_balance_wallet_rounded,
    'Health': Icons.favorite_rounded,
    'Ideas': Icons.lightbulb_rounded,
    'Passwords': Icons.lock_rounded,
    'Important': Icons.star_rounded,
  };

  static const Map<String, Color> categoryColors = {
    'Personal': Color(0xFF6366F1),
    'Work': Color(0xFF8B5CF6),
    'Finance': Color(0xFF10B981),
    'Health': Color(0xFFEF4444),
    'Ideas': Color(0xFFF59E0B),
    'Passwords': Color(0xFF3B82F6),
    'Important': Color(0xFFEC4899),
  };

  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? Colors.grey;
  }

  static IconData getCategoryIcon(String category) {
    return categoryIcons[category] ?? Icons.folder_rounded;
  }
}
