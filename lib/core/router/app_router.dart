import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:my_secure_note_app/core/feature/note_editor/note_editor.dart';
import 'package:my_secure_note_app/core/feature/notes_dashboard/notes_dashboard.dart';
import 'package:my_secure_note_app/core/feature/onboarding/presentation/view/on_boarding_page_view.dart';
import 'package:my_secure_note_app/core/feature/pin_code/presentation/view/pin_code_page_view.dart';
import 'package:my_secure_note_app/core/feature/settings/settings_view.dart';
import 'package:my_secure_note_app/core/feature/settings/widget/change_pin_widget.dart';
import 'package:my_secure_note_app/core/feature/settings/widget/contact_page.dart';
import 'package:my_secure_note_app/core/feature/settings/widget/help_faq_widget.dart';
import 'package:my_secure_note_app/core/feature/settings/widget/theme_widget.dart';
import 'package:my_secure_note_app/core/feature/splash/presentation/view/splash_page_view.dart';
import 'package:my_secure_note_app/core/preferances/shared_preferences.dart';
import 'package:my_secure_note_app/core/router/root_navigator_keys.dart';

class AppSettingsNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }
}

final appSettingsNotifierProvider = ChangeNotifierProvider<AppSettingsNotifier>(
  (ref) {
    return AppSettingsNotifier();
  },
);

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: RootNavigatorKey.key,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPageView(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnBoardingPageView(),
      ),
      GoRoute(
        path: '/pin-authentication',
        name: 'pin-authentication',
        builder: (context, state) {
          final isFromOnboarding = state.extra as bool? ?? false;
          return PinAuthentication(isFromOnboarding: isFromOnboarding);
        },
      ),
      GoRoute(
        path: '/notes-dashboard',
        name: 'notes-dashboard',
        builder: (context, state) => const NotesDashboard(),
        routes: [
          GoRoute(
            path: 'note-editor',
            name: 'note-editor',
            builder: (context, state) {
              final note = state.extra as Map<String, dynamic>?;
              return NoteEditor(existingNote: note);
            },
          ),
          GoRoute(
            path: 'note-settings',
            name: 'note-settings',
            builder: (context, state) {
              return SettingsPage();
            },
            routes: [
              GoRoute(
                path: 'note-theme',
                name: 'note-theme',
                builder: (context, state) {
                  final String title = state.extra as String;
                  return ThemePage(title: title);
                },
              ),
              GoRoute(
                path: 'note-change-pin',
                name: 'note-change-pin',
                builder: (context, state) {
                  final String title = state.extra as String;
                  return ChangePINPage(title: title);
                },
              ),
              GoRoute(
                path: 'note-faq',
                name: 'note-faq',
                builder: (context, state) {
                  final String title = state.extra as String;
                  return FAQPage(title: title);
                },
              ),
              GoRoute(
                path: 'note-contact',
                name: 'note-contact',
                builder: (context, state) {
                  final String title = state.extra as String;
                  return ContactPage(title: title);
                },
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text("Page not found"))),
    redirect: (context, state) {
      final path = state.uri.path;
      final appSettings = ref.read(appSettingsNotifierProvider);
      final isAuthenticated = appSettings.isAuthenticated;
      final isOnboardingComplete = AppSettings().hasViewedOnboardingScreen;

      if (path == '/splash') {
        return null;
      }

      if (!isOnboardingComplete) {
        return path == '/onboarding' ? null : '/onboarding';
      }

      if (!isAuthenticated) {
        return path == '/pin-authentication' ? null : '/pin-authentication';
      }

      if (isAuthenticated &&
          (path == '/onboarding' ||
              path == '/pin-authentication' ||
              path == '/splash')) {
        return '/notes-dashboard';
      }

      return null;
    },
  );
});
