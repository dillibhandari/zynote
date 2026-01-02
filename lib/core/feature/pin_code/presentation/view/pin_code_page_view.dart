// lib/core/feature/pin_code/presentation/screens/pin_authentication.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_secure_note_app/core/common/widgets/custom_icon_widget.dart';
import 'package:my_secure_note_app/core/feature/pin_code/presentation/providers/pin_code_provider.dart';
import 'package:my_secure_note_app/core/feature/pin_code/presentation/widget/lockout_timer.dart';
import 'package:my_secure_note_app/core/feature/pin_code/presentation/widget/numeric_keypad.dart';
import 'package:my_secure_note_app/core/feature/pin_code/presentation/widget/pin_input_display.dart';
import 'package:my_secure_note_app/core/feature/pin_code/presentation/widget/security_header.dart';
import 'package:my_secure_note_app/core/theme/app_theme.dart';
import 'package:my_secure_note_app/core/router/app_router.dart';
import 'package:sizer/sizer.dart';

class PinAuthentication extends ConsumerStatefulWidget {
  final bool isFromOnboarding;
  const PinAuthentication({super.key, this.isFromOnboarding = false});

  @override
  ConsumerState<PinAuthentication> createState() => _PinAuthenticationState();
}

class _PinAuthenticationState extends ConsumerState<PinAuthentication>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _preventScreenshots();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      ref
          .read(pinCodeProvider(widget.isFromOnboarding).notifier)
          .resetForSecurity();
    }
  }

  void _preventScreenshots() {
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final pinNotifier = ref.read(
      pinCodeProvider(widget.isFromOnboarding).notifier,
    );
    final pinState = ref.watch(pinCodeProvider(widget.isFromOnboarding));
    ref.listen<PinAuthState>(pinCodeProvider(widget.isFromOnboarding), (
      previous,
      current,
    ) {
      if (current.currentPinState == PinState.authSuccess &&
          previous?.currentPinState != PinState.authSuccess) {
        ref.read(appSettingsNotifierProvider.notifier).setAuthenticated(true);

        Future.microtask(() {
          if (mounted) {
            context.pushReplacementNamed('notes-dashboard');
          }
        });
      }

      if (pinNotifier.shouldRequireMasterPassword()) {
        context.pushReplacementNamed('master-password-setup');
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: double.infinity,
              height: constraints.maxHeight,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.lightTheme.scaffoldBackgroundColor,
                      AppTheme.lightTheme.scaffoldBackgroundColor.withValues(
                        alpha: 0.8,
                      ),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 6.h),
                    SecurityHeader(
                      title: pinNotifier.getHeaderTitle(),
                      subtitle: pinNotifier.getHeaderSubtitle(),
                    ),

                    SizedBox(height: 2.h),
                    Expanded(
                      child: pinState.isLocked
                          ? LockoutTimer(
                              lockoutDuration: pinState.lockoutDuration,
                              onTimerComplete: pinNotifier.onLockoutComplete,
                            )
                          : PinInputDisplay(
                              pinLength: PinCodeNotifier.PIN_LENGTH,
                              currentLength: pinState.currentPin.length,
                              isError: pinState.isError,
                            ),
                    ),

                    pinState.isLocked
                        ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 6.h),
                                backgroundColor:
                                    AppTheme.lightTheme.colorScheme.surface,
                              ),
                              child: const Text('Locked'),
                            ),
                          )
                        : NumericKeypad(
                            onNumberPressed: pinNotifier.onNumberPressed,
                            onDeletePressed: pinNotifier.onDeletePressed,
                            onDeleteLongPressed:
                                pinNotifier.onDeleteLongPressed,
                            isEnabled:
                                !pinState.isProcessing &&
                                pinState.currentPinState !=
                                    PinState.authSuccess,
                          ),

                    SizedBox(height: 3.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'shield',
                              color: AppTheme.lightTheme.primaryColor,
                              size: 5.w,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                'Your notes are protected with military-grade encryption',
                                style: AppTheme.lightTheme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
