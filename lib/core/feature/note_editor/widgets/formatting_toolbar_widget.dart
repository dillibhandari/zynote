import 'package:flutter/material.dart';
import 'package:my_secure_note_app/core/common/widgets/custom_icon_widget.dart';
import 'package:my_secure_note_app/core/theme/app_theme.dart';
import 'package:sizer/sizer.dart';
 

class FormattingToolbarWidget extends StatelessWidget {
  final bool isBold;
  final bool isItalic;
  final bool isBulletList;
  final double fontSize;
  final VoidCallback onBoldPressed;
  final VoidCallback onItalicPressed;
  final VoidCallback onBulletPressed;
  final ValueChanged<double> onFontSizeChanged;

  const FormattingToolbarWidget({
    super.key,
    required this.isBold,
    required this.isItalic,
    required this.isBulletList,
    required this.fontSize,
    required this.onBoldPressed,
    required this.onItalicPressed,
    required this.onBulletPressed,
    required this.onFontSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 4.w),
          _buildFormatButton(
            iconName: 'format_bold',
            isActive: isBold,
            onPressed: onBoldPressed,
          ),
          SizedBox(width: 2.w),
          _buildFormatButton(
            iconName: 'format_italic',
            isActive: isItalic,
            onPressed: onItalicPressed,
          ),
          SizedBox(width: 2.w),
          _buildFormatButton(
            iconName: 'format_list_bulleted',
            isActive: isBulletList,
            onPressed: onBulletPressed,
          ),
          SizedBox(width: 4.w),
          Container(
            width: 1,
            height: 4.h,
            color: AppTheme.lightTheme.colorScheme.outline,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Row(
              children: [
                Text(
                  'Size',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Slider(
                    value: fontSize,
                    min: 12.0,
                    max: 24.0,
                    divisions: 6,
                    onChanged: onFontSizeChanged,
                    activeColor: AppTheme.lightTheme.colorScheme.primary,
                    inactiveColor: AppTheme.lightTheme.colorScheme.outline,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  '${fontSize.toInt()}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
        ],
      ),
    );
  }

  Widget _buildFormatButton({
    required String iconName,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 10.w,
        height: 5.h,
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 1,
                )
              : null,
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: iconName,
            color: isActive
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
    );
  }
}
