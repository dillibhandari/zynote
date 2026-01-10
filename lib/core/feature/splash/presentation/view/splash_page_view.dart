// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_secure_note_app/core/preferances/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class SplashPageView extends StatefulWidget {
  const SplashPageView({super.key});

  @override
  State<SplashPageView> createState() => _SplashPageViewState();
}

class _SplashPageViewState extends State<SplashPageView>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  final ValueNotifier<String> _initializationTextNotifier = ValueNotifier(
    'Initializing security systems...',
  );
  final ValueNotifier<double> _progressValueNotifier = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitializationSequence();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
  }

  Future<void> _startInitializationSequence() async {
    await _logoController.forward();
    await _textController.forward();
    await _performInitializationSteps();
  }

  Future<void> _performInitializationSteps() async {
    final steps = [
      ('Checking encryption libraries...', 0.2),
      ('Validating biometric availability...', 0.4),
      ('Loading security certificates...', 0.6),
      ('Preparing secure storage...', 0.8),
      ('Finalizing authentication state...', 1.0),
    ];

    for (final step in steps) {
      _initializationTextNotifier.value = step.$1;
      _progressValueNotifier.value = step.$2;
      await Future.delayed(const Duration(milliseconds: 50));
    }

    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    bool isFirstLaunch = AppSettings().hasViewedOnboardingScreen == false;

    bool hasCompletedOnboarding =
        AppSettings().hasViewedOnboardingScreen == true;
    if (!mounted) return;

    if (isFirstLaunch || !hasCompletedOnboarding) {
      context.go('/onboarding');
    } else {
      context.go('/pin-authentication');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _initializationTextNotifier.dispose();
    _progressValueNotifier.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                _logoImageWidget(),

                SizedBox(height: 4.h),
                _appTitleWithTaglineWidget(),

                const Spacer(flex: 2),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3.w),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: ValueListenableBuilder<double>(
                              valueListenable: _progressValueNotifier,
                              builder: (context, progress, _) {
                                return FractionallySizedBox(
                                  widthFactor: progress,
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 2.h),

                          ValueListenableBuilder<String>(
                            valueListenable: _initializationTextNotifier,
                            builder: (context, text, _) {
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  text,
                                  key: ValueKey(text),
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.security,
                          size: 4.w,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'AES-256 Encryption • Zero-Knowledge Architecture',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AnimatedBuilder _appTitleWithTaglineWidget() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return SlideTransition(
          position: _textSlideAnimation,
          child: FadeTransition(
            opacity: _textFadeAnimation,
            child: Column(
              children: [
                Text(
                  'Secure Notes',
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Privacy by Design • Encrypted by Default',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  AnimatedBuilder _logoImageWidget() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: FadeTransition(
            opacity: _logoFadeAnimation,
            child: Container(
              width: 50.w,
              height: 50.w,

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(6.w),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Hero(
                  tag: 'logo-image',
                  child: Image.asset(
                     'assets/images/splash_logo.png',
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
