import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:my_secure_note_app/core/helper/rsa_services.dart';
import 'package:my_secure_note_app/core/preferances/shared_preferences.dart';

enum PinState { create, confirm, verify, authSuccess }

class PinAuthState {
  final String currentPin;
  final String newPin;
  final int failedAttempts;
  final bool isLocked;
  final int lockoutDuration;
  final bool isError;
  final bool isProcessing;
  final PinState currentPinState;

  const PinAuthState({
    this.currentPin = '',
    this.newPin = '',
    this.failedAttempts = 0,
    this.isLocked = false,
    this.lockoutDuration = 0,
    this.isError = false,
    this.isProcessing = false,
    this.currentPinState = PinState.verify,
  });

  PinAuthState copyWith({
    String? currentPin,
    String? newPin,
    int? failedAttempts,
    bool? isLocked,
    int? lockoutDuration,
    bool? isError,
    bool? isProcessing,
    PinState? currentPinState,
  }) {
    return PinAuthState(
      currentPin: currentPin ?? this.currentPin,
      newPin: newPin ?? this.newPin,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      isLocked: isLocked ?? this.isLocked,
      lockoutDuration: lockoutDuration ?? this.lockoutDuration,
      isError: isError ?? this.isError,
      isProcessing: isProcessing ?? this.isProcessing,
      currentPinState: currentPinState ?? this.currentPinState,
    );
  }
}

class PinCodeNotifier extends StateNotifier<PinAuthState> {
  static const int PIN_LENGTH = 6;
  static const Map<int, int> LOCKOUT_DURATIONS = {3: 30, 5: 300, 10: 0};

  final bool isFromOnboarding;
  final AppSettings appSettings;
  final RSAService rsaService;

  PinCodeNotifier({
    required this.isFromOnboarding,
    required this.appSettings,
    required this.rsaService,
  }) : super(const PinAuthState()) {
    _determineInitialState();
  }

  void _determineInitialState() {
    final storedPin = appSettings.getUserPinCode;

    if (isFromOnboarding) {
      state = state.copyWith(currentPinState: PinState.create);
    } else if (storedPin.isEmpty) {
      state = state.copyWith(currentPinState: PinState.create);
    } else {
      state = state.copyWith(currentPinState: PinState.verify);
    }
  }

  void onNumberPressed(String number) {
    if (state.isLocked ||
        state.isProcessing ||
        state.currentPin.length >= PIN_LENGTH ||
        state.currentPinState == PinState.authSuccess) {
      return;
    }

    final newPin = state.currentPin + number;

    state = state.copyWith(currentPin: newPin, isError: false);

    if (newPin.length == PIN_LENGTH) {
      _processPin();
    }
  }

  void onDeletePressed() {
    if (state.isLocked ||
        state.isProcessing ||
        state.currentPin.isEmpty ||
        state.currentPinState == PinState.authSuccess) {
      return;
    }

    state = state.copyWith(
      currentPin: state.currentPin.substring(0, state.currentPin.length - 1),
      isError: false,
    );
  }

  void onDeleteLongPressed() {
    if (state.isLocked ||
        state.isProcessing ||
        state.currentPinState == PinState.authSuccess) {
      return;
    }

    state = state.copyWith(currentPin: '', isError: false);
  }

  Future<void> _processPin() async {
    state = state.copyWith(isProcessing: true);

    await Future.delayed(const Duration(milliseconds: 500));
    HapticFeedback.heavyImpact();

    switch (state.currentPinState) {
      case PinState.create:
        _handleCreatePin();
        break;
      case PinState.confirm:
        _handleConfirmPin();
        break;
      case PinState.verify:
        _handleVerifyPin();
        break;
      case PinState.authSuccess:
        break;
    }
  }

  void _handleCreatePin() {
    state = state.copyWith(
      newPin: state.currentPin,
      currentPinState: PinState.confirm,
      currentPin: '',
      isProcessing: false,
      isError: false,
    );
  }

  void _handleConfirmPin() {
    if (state.currentPin == state.newPin) {
      _savePinToStorage(state.currentPin);

      state = state.copyWith(
        currentPinState: PinState.authSuccess,
        isProcessing: false,
        isError: false,
      );
    } else {
      state = state.copyWith(
        isError: true,
        isProcessing: false,
        currentPin: '',
        newPin: '',
        currentPinState: PinState.create,
        failedAttempts: state.failedAttempts + 1,
      );

      _checkForLockout();
    }
  }

  void _handleVerifyPin() {
    final storedPin = appSettings.getUserPinCode;

    if (storedPin.isEmpty) {
      state = state.copyWith(
        currentPinState: PinState.create,
        isProcessing: false,
        currentPin: '',
      );
      return;
    }

    if (state.currentPin == storedPin) {
      state = state.copyWith(
        currentPinState: PinState.authSuccess,
        isProcessing: false,
        isError: false,
        failedAttempts: 0,
      );
    } else {
      state = state.copyWith(
        isError: true,
        isProcessing: false,
        currentPin: '',
        failedAttempts: state.failedAttempts + 1,
      );

      _checkForLockout();
    }
  }

  void _checkForLockout() {
    if (LOCKOUT_DURATIONS.containsKey(state.failedAttempts)) {
      if (state.failedAttempts == 10) {
      } else {
        _startLockout(LOCKOUT_DURATIONS[state.failedAttempts]!);
      }
    }
  }

  void _savePinToStorage(String pin) {
    appSettings.userPinCode = pin;
    rsaService.generatePublicPrivateKeys();
  }

  void _startLockout(int duration) {
    state = state.copyWith(isLocked: true, lockoutDuration: duration);
  }

  void onLockoutComplete() {
    state = state.copyWith(isLocked: false, lockoutDuration: 0, isError: false);
  }

  void resetForSecurity() {
    state = state.copyWith(currentPin: '', isError: false);
  }

  String getHeaderTitle() {
    switch (state.currentPinState) {
      case PinState.create:
        return 'Create PIN';
      case PinState.confirm:
        return 'Confirm PIN';
      case PinState.verify:
        return 'Enter PIN';
      case PinState.authSuccess:
        return 'Success!';
    }
  }

  String? getHeaderSubtitle() {
    if (state.isLocked) return null;

    switch (state.currentPinState) {
      case PinState.create:
        return 'Create a 6-digit PIN to secure your notes';
      case PinState.confirm:
        return 'Re-enter your PIN to confirm';
      case PinState.verify:
        if (state.failedAttempts > 0) {
          final attemptsLeft = (3 - state.failedAttempts).clamp(0, 3);
          return 'Incorrect PIN. $attemptsLeft attempts remaining.';
        }
        return 'Enter your 6-digit PIN to continue';
      case PinState.authSuccess:
        return 'Authentication successful!';
    }
  }

  bool shouldRequireMasterPassword() {
    return state.failedAttempts == 10;
  }

  bool isAuthSuccess() {
    return state.currentPinState == PinState.authSuccess;
  }
}

final pinCodeProvider = StateNotifierProvider.family
    .autoDispose<PinCodeNotifier, PinAuthState, bool>((ref, isFromOnboarding) {
      final appSettings = ref.watch(appSettingsProvider);
      final RSAService rsaService = RSAService();
      return PinCodeNotifier(
        isFromOnboarding: isFromOnboarding,
        appSettings: appSettings,
        rsaService: rsaService,
      );
    });

final appSettingsProvider = Provider<AppSettings>((ref) {
  return AppSettings();
});
