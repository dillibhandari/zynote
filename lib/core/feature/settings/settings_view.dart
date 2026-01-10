// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_secure_note_app/core/common/widgets/custom_app_bar.dart';
import 'package:my_secure_note_app/core/feature/settings/widget/build_by_widget.dart';

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
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
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
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.6),
                  ),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(38),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
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
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.6),
                ),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(38),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            // ignore: deprecated_member_use
            activeColor: theme.colorScheme.primary,
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
