import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SecurityHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showLogo;

  const SecurityHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Column(
        children: [
          if (showLogo) ...[
            Hero(
              tag: 'logo-image',
              child: Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5A7BBE), Color(0xFF8CA4E0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(
                        alpha: 0.3,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(child: Image.asset('assets/images/3.png')),
              ),
            ),

            SizedBox(height: 2.h),
          ],
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            SizedBox(height: 1.h),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
