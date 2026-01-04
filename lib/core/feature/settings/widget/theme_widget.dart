import 'package:flutter/material.dart';
import 'package:my_secure_note_app/core/common/widgets/custom_app_bar.dart';
import 'package:my_secure_note_app/core/theme/app_theme.dart';
import 'package:sizer/sizer.dart';

class ThemePage extends StatefulWidget {
  final String title;
  const ThemePage({super.key, required this.title});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  String _selectedTheme = 'light';

  final List<Map<String, dynamic>> _themes = const [
    {
      'id': 'light',
      'name': 'Light',
      'desc': 'Bright and clean interface',
      'icon': Icons.wb_sunny,
    },
    {
      'id': 'dark',
      'name': 'Dark',
      'desc': 'Easy on the eyes',
      'icon': Icons.nightlight_round,
    },
    {
      'id': 'auto',
      'name': 'Auto',
      'desc': 'Follows system preference',
      'icon': Icons.devices,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Theme',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ..._themes.map((theme) {
                final isSelected = _selectedTheme == theme['id'];

                return Padding(
                  padding: EdgeInsets.only(bottom: 16.sp),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTheme = theme['id'] as String;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary.withAlpha(
                                27,
                              )
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : const Color(0xFFE5E7EB),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : const Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              theme['icon'] as IconData,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  theme['name'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppTheme
                                              .lightTheme
                                              .colorScheme
                                              .primary
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  theme['desc'] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
