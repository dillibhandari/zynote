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
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const SplashPageView(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const OnBoardingPageView(),
        ),
      ),
      GoRoute(
        path: '/pin-authentication',
        name: 'pin-authentication',
        pageBuilder: (context, state) {
          final isFromOnboarding = state.extra as bool? ?? false;
          return _buildPageWithSlideTransition(
            context,
            state,
            PinAuthentication(isFromOnboarding: isFromOnboarding),
          );
        },
      ),
      GoRoute(
        path: '/notes-dashboard',
        name: 'notes-dashboard',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const NotesDashboard(),
        ),
        routes: [
          GoRoute(
            path: 'note-editor',
            name: 'note-editor',
            pageBuilder: (context, state) {
              final note = state.extra as Map<String, dynamic>?;
              return _buildPageWithSlideTransition(
                context,
                state,
                NoteEditor(existingNote: note),
              );
            },
          ),
          GoRoute(
            path: 'note-settings',
            name: 'note-settings',
            pageBuilder: (context, state) =>
                _buildPageWithSlideTransition(context, state, SettingsPage()),
            routes: [
              GoRoute(
                path: 'note-theme',
                name: 'note-theme',
                pageBuilder: (context, state) {
                  final String title = state.extra as String;
                  return _buildPageWithSlideTransition(
                    context,
                    state,
                    ThemePage(title: title),
                  );
                },
              ),
              GoRoute(
                path: 'note-change-pin',
                name: 'note-change-pin',
                pageBuilder: (context, state) {
                  final String title = state.extra as String;
                  return _buildPageWithSlideTransition(
                    context,
                    state,
                    ChangePINPage(title: title),
                  );
                },
              ),
              GoRoute(
                path: 'note-faq',
                name: 'note-faq',
                pageBuilder: (context, state) {
                  final String title = state.extra as String;
                  return _buildPageWithSlideTransition(
                    context,
                    state,
                    FAQPage(title: title),
                  );
                },
              ),
              GoRoute(
                path: 'note-contact',
                name: 'note-contact',
                pageBuilder: (context, state) {
                  final String title = state.extra as String;
                  return _buildPageWithSlideTransition(
                    context,
                    state,
                    ContactPage(title: title),
                  );
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

/// Helper function to build page with fade transition
Page<void> _buildPageWithFadeTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOutCubic).animate(animation),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

/// Helper function to build page with slide transition
Page<void> _buildPageWithSlideTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: Curves.easeInOutCubic));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
