import 'package:flutter/material.dart';
import 'package:my_secure_note_app/core/common/widgets/custom_icon_widget.dart';
import 'package:sizer/sizer.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final bool isActive;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  width: isActive ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.6),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'search',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            controller.clear();
                            onChanged('');
                          },
                          child: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: CustomIconWidget(
                              iconName: 'clear',
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1,
                ),
              ),
              child: CustomIconWidget(
                iconName: 'filter_list',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
