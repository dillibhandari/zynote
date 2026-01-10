// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:my_secure_note_app/core/common/widgets/custom_icon_widget.dart';
import 'package:sizer/sizer.dart';

class SecurityCertificationWidgetCompact extends StatelessWidget {
  const SecurityCertificationWidgetCompact({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      margin: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
         color:  theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security Certifications',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),

          // Wrap badges into multiple lines
          Wrap(
            spacing: 3.w, // horizontal spacing between badges
            runSpacing: 2.h, // vertical spacing between lines
            children: [
              _buildCompactBadge('AES-256 Encryption', theme),
              _buildCompactBadge('FIPS 140-2 Compliant', theme),
              _buildCompactBadge('Zero-Log Policy', theme),
              _buildCompactBadge('End-to-End Encryption', theme),
              // _buildCompactBadge('Secure Cloud Backup', theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBadge(String title, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'verified',
            size: 14,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: 2.w),
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
