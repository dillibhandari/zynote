import 'package:flutter/material.dart';
import 'package:my_secure_note_app/core/common/widgets/custom_icon_widget.dart';
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
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$wordCount words',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isOverLimit
                      ? Colors.red
                      : isNearLimit
                      ? Colors.orange
                      : Theme.of(context).colorScheme.onSurfaceVariant,
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
