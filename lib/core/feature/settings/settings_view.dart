import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_secure_note_app/core/common/widgets/custom_app_bar.dart';
import 'package:my_secure_note_app/core/feature/settings/widget/build_by_widget.dart';
import 'package:my_secure_note_app/core/theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedTheme = 'light';
  bool isBiometricEnabled = false;

  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
  }

  Future<void> _loadBiometricPreference() async {
    setState(() {
      isBiometricEnabled = false;
    });
  }

  Future<void> _toggleBiometricLogin(bool enabled) async {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isDeviceSupported = await auth.isDeviceSupported();

    if (!canCheckBiometrics || !isDeviceSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication not available')),
      );
      return;
    }

    if (enabled) {
      try {
        bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to enable biometric login',
          // options: const AuthenticationOptions(
          //   biometricOnly: true,
          //   stickyAuth: true,
          // ),
        );

        if (didAuthenticate) {
          setState(() {
            isBiometricEnabled = true;
          });
          // TODO: Save to secure storage that biometric is enabled
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error enabling biometric: $e')));
      }
    } else {
      setState(() {
        isBiometricEnabled = false;
      });
      // TODO: Save to secure storage that biometric is disabled
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildSettingsCard(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: BuildByWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
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
        children: [
          _buildSettingItem(
            icon: Icons.palette_outlined,
            label: 'Theme',
            sublabel:
                selectedTheme[0].toUpperCase() + selectedTheme.substring(1),
            onTap: () => _navigateToTheme('Theme'),
            isFirst: true,
          ),
          _buildSettingItem(
            icon: Icons.lock_outline,
            label: 'Change PIN',
            sublabel: 'Update your security PIN',
            onTap: () => _navigateToChangePIN('Change PIN'),
          ),
          _buildSettingItemWithSwitch(
            icon: Icons.fingerprint,
            label: 'Enable Biometric',
            value: isBiometricEnabled,
            onChanged: _toggleBiometricLogin,
          ),
          _buildSettingItem(
            icon: Icons.help_outline,
            label: 'Help & FAQ',
            sublabel: 'Get answers to common questions',
            onTap: () => _navigateToFAQ('Help & FAQ'),
          ),
          _buildSettingItem(
            icon: Icons.mail_outline,
            label: 'Contact Us',
            sublabel: 'Send feedback or report issues',
            onTap: () => _navigateToContact('Contact Us'),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required String sublabel,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary.withAlpha(38),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItemWithSwitch({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withAlpha(38),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.lightTheme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  void _navigateToTheme(String title) {
    context.pushNamed('note-theme', extra: title);
  }

  void _navigateToChangePIN(String title) {
    context.pushNamed('note-change-pin', extra: title);
  }

  void _navigateToFAQ(String title) {
    context.pushNamed('note-faq', extra: title);
  }

  void _navigateToContact(String title) {
    context.pushNamed('note-contact', extra: title);
  }
}
