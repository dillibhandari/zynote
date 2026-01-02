import 'package:flutter/material.dart';
import 'package:my_secure_note_app/core/common/widgets/custom_icon_widget.dart';
import 'package:my_secure_note_app/core/theme/app_theme.dart';
import 'package:sizer/sizer.dart';

class CategorySelectorWidget extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const CategorySelectorWidget({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'Personal',
        'icon': 'person',
        'color': AppTheme.lightTheme.colorScheme.primary
      },
      {
        'name': 'Work',
        'icon': 'work',
        'color': AppTheme.lightTheme.colorScheme.secondary
      },
      {
        'name': 'Finance',
        'icon': 'account_balance_wallet',
        'color': Colors.green
      },
      {'name': 'Health', 'icon': 'local_hospital', 'color': Colors.red},
      {'name': 'Ideas', 'icon': 'lightbulb', 'color': Colors.orange},
      {'name': 'Travel', 'icon': 'flight', 'color': Colors.blue},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            height: 6.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (context, index) => SizedBox(width: 2.w),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category['name'];

                return GestureDetector(
                  onTap: () => onCategoryChanged(category['name'] as String),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (category['color'] as Color).withValues(alpha: 0.1)
                          : AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? (category['color'] as Color)
                            : AppTheme.lightTheme.colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: category['icon'] as String,
                          color: isSelected
                              ? (category['color'] as Color)
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          category['name'] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? (category['color'] as Color)
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
