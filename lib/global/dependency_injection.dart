// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart'; 
// import 'package:email_otp/email_otp.dart';
// import 'package:my_secure_note_app/core/preferances/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// /// CORE SINGLETONS (never auto-dispose)

// final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
//   return SharedPreferences.getInstance();
// });



// final appSettingsProvider = Provider<AppSettings>((ref) {
//   final sharedPreferences = ref.watch(sharedPreferencesProvider).requireValue;
//   final preferences = SharedPreferencesWrapper(sharedPreferences);

//   final settings = AppSettings();
//   settings.init(preferences);

//   ref.keepAlive();
//   return settings;
// });


// final firebaseAuthProvider = Provider<FirebaseAuth>(
//   (ref) => FirebaseAuth.instance,
// );

// final firebaseMessagingProvider = Provider<FirebaseMessaging>(
//   (ref) => FirebaseMessaging.instance,
// );

// final firebaseAnalyticsProvider = Provider<FirebaseAnalytics>(
//   (ref) => FirebaseAnalytics.instance,
// );

// // final localNotificationPluginProvider =
// //     Provider<FlutterLocalNotificationsPlugin>((ref) {
// //       return FlutterLocalNotificationsPlugin();
// //     });

// final emailOtpProvider = Provider<EmailOTP>((ref) => EmailOTP());















// /// ---------------------------------------------------------------------------
// /// CORE SINGLETONS
// /// ---------------------------------------------------------------------------
// final preferencesProvider = FutureProvider<Preferences>((ref) async {
//   final sharedPreferences = await SharedPreferences.getInstance();
//   return SharedPreferencesWrapper(sharedPreferences);
// });

// final appSettingsProvider = FutureProvider<AppSettings>((ref) async {
//   final prefs = await ref.watch(preferencesProvider.future);
//   final appSettings = AppSettings();
//   await appSettings.init(prefs);
//   return appSettings;
// });

// final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
//   return FirebaseAuth.instance;
// });

// final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
//   return FirebaseMessaging.instance;
// });

// final firebaseAnalyticsProvider = Provider<FirebaseAnalytics>((ref) {
//   return FirebaseAnalytics.instance;
// });

// final localNotificationProvider = Provider<FlutterLocalNotificationsPlugin>((
//   ref,
// ) {
//   return FlutterLocalNotificationsPlugin();
// });

// final emailOtpProvider = Provider<EmailOTP>((ref) {
//   return EmailOTP();
// });

// /// ---------------------------------------------------------------------------
// /// AUTH FEATURE
// /// ---------------------------------------------------------------------------

// // ✅ Data Sources
// final authLocalDataSourceProvider = Provider<AuthLocalDataSources>((ref) {
//   final pref = ref.watch(preferencesProvider);
//   return AuthLocalDataSourcesImpl(pref);
// });

// final authRemoteDataSourceProvider = Provider<AuthRemoteDataSources>((ref) {
//   return AuthRemoteDataSourcesImpl();
// });

// // ✅ Repository
// final authRepositoryProvider = Provider<AuthRepository>((ref) {
//   final remote = ref.watch(authRemoteDataSourceProvider);
//   final local = ref.watch(authLocalDataSourceProvider);
//   return AuthRepositoryImpl(remote, local);
// });

// // ✅ Use Case
// final authUseCaseProvider = Provider<AuthUsecase>((ref) {
//   final repo = ref.watch(authRepositoryProvider);
//   return AuthUsecase(authRepository: repo);
// });

// // ✅ Controller (Notifier)
// final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
//   () => AuthController(),
// );

// /// ---------------------------------------------------------------------------
// /// OTHER FEATURES (EXAMPLE PATTERN — repeat per feature)
// /// ---------------------------------------------------------------------------

// /// ---------------------------------------------------------------------------
// /// ENVIRONMENT INITIALIZER
// /// ---------------------------------------------------------------------------

// Future<ProviderContainer> setupDependencies({bool isStaging = false}) async {
//   return ProviderContainer(
//     overrides: [
//       if (isStaging)
//         firebaseAnalyticsProvider.overrideWithValue(FirebaseAnalytics.instance),
//     ],
//   );
// }
