import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:my_secure_note_app/core/feature/onboarding/data/onboarding_data_model.dart';

class OnboardingState {
  final int currentPage;
  final bool userInteracted;

  const OnboardingState({this.currentPage = 0, this.userInteracted = false});

  OnboardingState copyWith({int? currentPage, bool? userInteracted}) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      userInteracted: userInteracted ?? this.userInteracted,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier(this.pageController) : super(const OnboardingState()) {
    _startAutoAdvanceTimer();
  }

  Timer? _autoAdvanceTimer;
  final PageController pageController;

  final List<OnboardingData> onboardingList = const [
    OnboardingData(
      title: 'Military-Grade Encryption',
      description:
          'Your notes are protected with AES-256 encryption, the same standard used by governments and financial institutions worldwide.',
      iconName: 'security',
    ),
    OnboardingData(
      title: 'Biometric Protection',
      description:
          'Access your secure notes with fingerprint or face recognition. Your biometric data never leaves your device.',
      iconName: 'fingerprint',
    ),
    OnboardingData(
      title: 'Offline Security',
      description:
          'All encryption happens locally on your device. Your notes remain private even without internet connection.',
      iconName: 'lock',
    ),
    OnboardingData(
      title: 'Complete Privacy',
      description:
          'Zero-knowledge architecture means we cannot access your notes. Only you hold the keys to your encrypted data.',
      iconName: 'shield',
    ),
  ];

  void _startAutoAdvanceTimer() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(const Duration(seconds: 8), () {
      if (!state.userInteracted) nextPage();
    });
  }

  void nextPage() {
    HapticFeedback.lightImpact();
    _autoAdvanceTimer?.cancel();

    final nextIndex = state.currentPage + 1;
    if (nextIndex < onboardingList.length) {
      pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _startAutoAdvanceTimer();
    }
  }

  void previousPage() {
    HapticFeedback.lightImpact();
    _autoAdvanceTimer?.cancel();

    final prevIndex = state.currentPage - 1;
    if (prevIndex >= 0) {
      pageController.animateToPage(
        prevIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      // State update happens in onPageChanged callback
    } else {
      _startAutoAdvanceTimer();
    }
  }

  void onPageChanged(int page) {
    state = state.copyWith(currentPage: page, userInteracted: true);
    _autoAdvanceTimer?.cancel();
    _startAutoAdvanceTimer();
  }

  void userInteracted() {
    state = state.copyWith(userInteracted: true);
    _autoAdvanceTimer?.cancel();
    _startAutoAdvanceTimer();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }
}

final onboardingNotifierProvider =
    StateNotifierProvider.family<
      OnboardingNotifier,
      OnboardingState,
      PageController
    >((ref, pageController) {
      return OnboardingNotifier(pageController);
    });
