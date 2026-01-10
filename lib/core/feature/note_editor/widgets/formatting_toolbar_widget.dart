import 'package:flutter/material.dart';
import 'package:my_secure_note_app/core/common/widgets/custom_icon_widget.dart';
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
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline,
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
            context: context,
          ),
          SizedBox(width: 2.w),
          _buildFormatButton(
            iconName: 'format_italic',
            isActive: isItalic,
            onPressed: onItalicPressed,
            context:context,
          ),
          SizedBox(width: 2.w),
          _buildFormatButton(
            iconName: 'format_list_bulleted',
            isActive: isBulletList,
            onPressed: onBulletPressed,
            context: context,
          ),
          SizedBox(width: 4.w),
          Container(
            width: 1,
            height: 4.h,
            color: Theme.of(context).colorScheme.outline,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Row(
              children: [
                Text(
                  'Size',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    activeColor: Theme.of(context).colorScheme.primary,
                    inactiveColor: Theme.of(context).colorScheme.outline,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  '${fontSize.toInt()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
   required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 10.w,
        height: 5.h,
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1,
                )
              : null,
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: iconName,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
    );
  }
}
