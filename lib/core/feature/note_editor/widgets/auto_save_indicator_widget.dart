import 'package:flutter/material.dart';
import 'package:my_secure_note_app/core/common/widgets/custom_icon_widget.dart';
import 'package:my_secure_note_app/core/theme/app_theme.dart';
import 'package:sizer/sizer.dart';

class AutoSaveIndicatorWidget extends StatelessWidget {
  final bool isSaving;
  final DateTime? lastSaved;

  const AutoSaveIndicatorWidget({
    super.key,
    required this.isSaving,
    this.lastSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSaving) ...[
            SizedBox(
              width: 3.w,
              height: 3.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              'Saving...',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else if (lastSaved != null) ...[
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.green,
              size: 14,
            ),
            SizedBox(width: 1.w),
            Text(
              'Saved ${_formatTime(lastSaved!)}',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
