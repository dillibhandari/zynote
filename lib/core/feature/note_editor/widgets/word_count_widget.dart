import 'package:flutter/material.dart';
import 'package:my_secure_note_app/core/common/widgets/custom_icon_widget.dart';
import 'package:my_secure_note_app/core/theme/app_theme.dart';
import 'package:sizer/sizer.dart';

class WordCountWidget extends StatelessWidget {
  final String content;
  final int characterLimit;

  const WordCountWidget({
    super.key,
    required this.content,
    this.characterLimit = 10000,
  });

  @override
  Widget build(BuildContext context) {
    final wordCount = _getWordCount(content);
    final characterCount = content.length;
    final isNearLimit = characterCount > (characterLimit * 0.8);
    final isOverLimit = characterCount > characterLimit;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$wordCount words',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          Row(
            children: [
              if (isNearLimit) ...[
                CustomIconWidget(
                  iconName: isOverLimit ? 'error' : 'warning',
                  color: isOverLimit ? Colors.red : Colors.orange,
                  size: 14,
                ),
                SizedBox(width: 1.w),
              ],
              Text(
                '$characterCount / $characterLimit',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: isOverLimit
                      ? Colors.red
                      : isNearLimit
                      ? Colors.orange
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: isNearLimit ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getWordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }
}
