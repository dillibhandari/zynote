import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_secure_note_app/core/feature/onboarding/data/onboarding_data_model.dart'; 
import 'package:my_secure_note_app/core/preferances/shared_preferences.dart';
import '../providers/onboarding_provider.dart';
import '../widget/security_sertificate_widget.dart';

class OnBoardingPageView extends ConsumerStatefulWidget {
  const OnBoardingPageView({super.key});

  @override
  ConsumerState<OnBoardingPageView> createState() => _OnBoardingPageViewState();
}

class _OnBoardingPageViewState extends ConsumerState<OnBoardingPageView>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    ref.read(onboardingNotifierProvider(_pageController).notifier);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _showSkipDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Skip Security Introduction?'),
          content: const Text(
            'We recommend learning about our security features to better protect your sensitive notes.',
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Continue Tour'),
            ),
            TextButton(
              onPressed: () {
                AppSettings().viewedOnboardingScreen = true;
                context.pushReplacementNamed('pin-authentication');
              },
              child: const Text('Skip'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(
      onboardingNotifierProvider(_pageController).notifier,
    );

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double page = 0.0;
        if (_pageController.hasClients && _pageController.page != null) {
          page = _pageController.page!;
        }

        final colors = [
          [const Color(0xFFFFFFFF), const Color(0xFFF9F7F3)],
        ];

        final currentColorSet = colors[page.round() % colors.length];
        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: currentColorSet,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      padEnds: true,
                      pageSnapping: true,
                      controller: _pageController,
                      itemCount: notifier.onboardingList.length,
                      onPageChanged: (index) {
                        notifier.onPageChanged(index);
                        HapticFeedback.selectionClick();
                      },
                      itemBuilder: (context, index) {
                        final data = notifier.onboardingList[index];
                        final offset = page - index;
                        final transform = (1 - (offset.abs() * 0.2)).clamp(
                          0.8,
                          1.0,
                        );

                        return Transform.scale(
                          scale: transform,
                          child: Opacity(
                            opacity: (1 - offset.abs()).clamp(0.4, 1.0),
                            child: _AdvancedOnboardingPage(
                              data: data,
                              index: index,
                              total: notifier.onboardingList.length,
                              onSkip: _showSkipDialog,
                              pageController: _pageController,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _BottomProgressBar(
                    controller: _pageController,
                    totalPages: notifier.onboardingList.length,
                  ),
                  const SizedBox(height: 12),
                  _BottomSection(pageController: _pageController),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AdvancedOnboardingPage extends StatelessWidget {
  const _AdvancedOnboardingPage({
    required this.data,
    required this.index,
    required this.total,
    required this.onSkip,
    required this.pageController,
  });

  final OnboardingData data;
  final int index;
  final int total;
  final VoidCallback onSkip;
  final PageController pageController;

  bool get isLastPage => index == total - 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Spacer(flex: 2),
          _AnimatedIcon(iconName: data.iconName),
          const SizedBox(height: 40),
          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.black54, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!isLastPage)
                TextButton(onPressed: onSkip, child: const Text("Skip")),
              if (isLastPage)
                const SizedBox(width: 80)
              else
                const SizedBox(width: 60),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  if (isLastPage) {
                    AppSettings().viewedOnboardingScreen = true;
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         PinAuthentication(isFromOnboarding: true),
                    //   ),
                    // );
                    context.replaceNamed('pin-authentication');
                  } else {
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(isLastPage ? "Get Started" : "Next"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedIcon extends StatelessWidget {
  const _AnimatedIcon({required this.iconName});
  final String iconName;

  IconData _getIcon() {
    switch (iconName) {
      case 'security':
        return Icons.security_rounded;
      case 'fingerprint':
        return Icons.fingerprint;
      case 'lock':
        return Icons.lock_outline;
      case 'shield':
        return Icons.shield_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, _) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primaryContainer,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              _getIcon(),
              size: 86,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}

class _BottomProgressBar extends StatelessWidget {
  const _BottomProgressBar({
    required this.controller,
    required this.totalPages,
  });

  final PageController controller;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final progress = (controller.hasClients && controller.page != null)
            ? controller.page! / (totalPages - 1)
            : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progress.clamp(0, 1),
              backgroundColor: Colors.black12,
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomSection extends ConsumerWidget {
  const _BottomSection({required this.pageController});
  final PageController pageController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider(pageController));
    final notifier = ref.read(
      onboardingNotifierProvider(pageController).notifier,
    );
    final isLastPage = state.currentPage == notifier.onboardingList.length - 1;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: isLastPage
          ? SecurityCertificationWidgetCompact()
          : const SizedBox.shrink(),
    );
  }
}
