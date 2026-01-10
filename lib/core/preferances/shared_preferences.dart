import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AuthPreferenceKeys {
  static const viewedOnboardingScreen = 'viewed_onboarding_screen';
  static const userPinCode = 'user_pin_code';
  static const userPinCodeInitial = 'user_pin_code_initial';
  static const themeMode = 'theme_mode';
  static String privateKey = "private_key";
  static String publicKey = "public_key";
  static String globalKey = "global_key";
  static String recentlyAddedNoteId = 'recently_added_note';
}

class AppSettings {
  static final AppSettings _instance = AppSettings._internal();
  late final Preferences _preferences;

  factory AppSettings() {
    return _instance;
  }

  AppSettings._internal();

  Future<void> init(Preferences preferences) async {
    _preferences = preferences;
  }

  // Onboarding Screen
  bool get hasViewedOnboardingScreen =>
      _preferences.getBool(_AuthPreferenceKeys.viewedOnboardingScreen) ?? false;

  set viewedOnboardingScreen(bool viewed) =>
      _preferences.setBool(_AuthPreferenceKeys.viewedOnboardingScreen, viewed);

  // PIN Code
  String get getUserPinCode =>
      _preferences.getString(_AuthPreferenceKeys.userPinCode) ?? '';
  set userPinCode(String pin) =>
      _preferences.setString(_AuthPreferenceKeys.userPinCode, pin);

  // Initial PIN Code for verification during setup
  String get getUserPinCodeInitial =>
      _preferences.getString(_AuthPreferenceKeys.userPinCodeInitial) ?? '';
  set userPinCodeInitial(String pin) =>
      _preferences.setString(_AuthPreferenceKeys.userPinCodeInitial, pin);

  // Private Key
  String get privateKey =>
      _preferences.getString(_AuthPreferenceKeys.privateKey) ?? '';

  set privateKey(String key) =>
      _preferences.setString(_AuthPreferenceKeys.privateKey, key);

  // Public Key
  String get publicKey =>
      _preferences.getString(_AuthPreferenceKeys.publicKey) ?? '';

  set publicKey(String key) =>
      _preferences.setString(_AuthPreferenceKeys.publicKey, key);

  // Global Key (e.g., AES / shared key)
  String get globalKey =>
      _preferences.getString(_AuthPreferenceKeys.globalKey) ?? '';

  set globalKey(String key) =>
      _preferences.setString(_AuthPreferenceKeys.globalKey, key);

  // recently added note
  String get recentlyAddedNoteId =>
      _preferences.getString(_AuthPreferenceKeys.recentlyAddedNoteId) ?? '';

  set recentlyAddedNoteId(String key) =>
      _preferences.setString(_AuthPreferenceKeys.recentlyAddedNoteId, key);

  // Theme mode
  ThemeMode get themeMode {
    final value = _preferences.getString(_AuthPreferenceKeys.themeMode);
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  set themeMode(ThemeMode mode) {
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    };
    _preferences.setString(_AuthPreferenceKeys.themeMode, value);
  }

}

abstract class Preferences {
  Future<bool> setString(String key, String value);

  Future<bool> setStringList(String key, List<String> permissions);
  List<String> getStringList(String key);

  String? getString(String key);

  Future<bool> setBool(String key, bool value);

  bool? getBool(String key);

  Future<bool> remove(String key);

  bool containsKey(String key);
}

class SharedPreferencesWrapper implements Preferences {
  final SharedPreferences _sharedPreferences;

  SharedPreferencesWrapper(this._sharedPreferences);

  @override
  Future<bool> setString(String key, String value) {
    return _sharedPreferences.setString(key, value);
  }

  @override
  List<String> getStringList(String key) {
    return _sharedPreferences.getStringList(key) ?? [];
  }

  @override
  Future<bool> setStringList(String key, List<String> permissions) {
    return _sharedPreferences.setStringList(key, permissions);
  }

  @override
  String? getString(String key) {
    return _sharedPreferences.getString(key);
  }

  @override
  Future<bool> setBool(String key, bool value) {
    return _sharedPreferences.setBool(key, value);
  }

  @override
  bool? getBool(String key) {
    return _sharedPreferences.getBool(key);
  }

  @override
  Future<bool> remove(String key) {
    return _sharedPreferences.remove(key);
  }

  @override
  bool containsKey(String key) {
    return _sharedPreferences.containsKey(key);
  }
}
