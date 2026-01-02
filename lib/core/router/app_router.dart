 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:my_secure_note_app/core/feature/note_editor/note_editor.dart';
import 'package:my_secure_note_app/core/feature/notes_dashboard/notes_dashboard.dart';
import 'package:my_secure_note_app/core/feature/onboarding/presentation/view/on_boarding_page_view.dart';
import 'package:my_secure_note_app/core/feature/pin_code/presentation/view/pin_code_page_view.dart';
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
  final appSettings = ref.watch(appSettingsNotifierProvider);
  return GoRouter(
    navigatorKey: RootNavigatorKey.key,
    initialLocation: '/splash',
    refreshListenable: appSettings,
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
        builder: (context, state) => const PinAuthentication(),
      ),

      GoRoute(
        path: '/notes-dashboard',
        name: 'notes-dashboard',
        builder: (context, state) => const NotesDashboard(),
        routes: [
          GoRoute(
            path: 'note-editor',
            name: 'note-editor',
            builder: (context, state) => const NoteEditor(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text("Page not found"))),
    // redirect: (context, state) {
    //   final isAuthenticated = appSettings.isAuthenticated;
    //   final isOnboardingComplete = AppSettings().hasViewedOnboardingScreen;

    //   final authRoutes = ['/splash', '/onboarding', '/pin-authentication'];

    //   final isOnAuthRoute = authRoutes.contains(state.uri.path);

    //   if (!isOnboardingComplete) {
    //     return state.uri.path == '/onboarding' ? null : '/onboarding';
    //   }

    //   if (!isAuthenticated) {
    //     return state.uri.path == '/pin-authentication'
    //         ? null
    //         : '/pin-authentication';
    //   }

    //   if (isAuthenticated && isOnAuthRoute) {
    //     return '/notes-dashboard';
    //   }

    //   return null;
    // },
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthenticated = appSettings.isAuthenticated;
      final isOnboardingComplete = AppSettings().hasViewedOnboardingScreen;

   
      if (!isOnboardingComplete && path != '/onboarding') {
        return '/onboarding';
      }

      if (isOnboardingComplete &&
          !isAuthenticated &&
          path != '/pin-authentication') {
        return '/pin-authentication';
      }

      if (isAuthenticated &&
          (path == '/onboarding' || path == '/pin-authentication')) {
        return '/notes-dashboard';
      }

      return null;
    },
  );
});
