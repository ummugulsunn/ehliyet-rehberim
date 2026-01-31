import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';

import 'src/features/auth/presentation/auth_gate.dart';
import 'src/features/home/data/user_progress_repository.dart';
import 'src/features/auth/data/auth_repository.dart';
import 'src/features/auth/application/auth_providers.dart';
import 'src/core/theme/app_theme_provider.dart';
import 'src/core/theme/theme_model.dart';
import 'src/features/home/application/home_providers.dart';
import 'src/features/onboarding/data/onboarding_repository.dart';
import 'src/features/onboarding/presentation/onboarding_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with timeout
  try {
    await Firebase.initializeApp().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint(
          'Firebase initialization timeout - continuing without Firebase',
        );
        throw TimeoutException(
          'Firebase initialization timeout',
          const Duration(seconds: 10),
        );
      },
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize Firebase: $e');
  }

  // Initialize intl localization
  try {
    await initializeDateFormatting('tr_TR', null);
    Intl.defaultLocale = 'tr_TR';
  } catch (e) {
    debugPrint('Failed to initialize intl: $e');
  }

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final onboardingRepository = OnboardingRepository(prefs);

  // Initialize AuthRepository
  final authRepository = AuthRepository.instance;
  try {
    await authRepository.initialize();
  } catch (e) {
    debugPrint('Failed to initialize AuthRepository: $e');
  }

  // Initialize UserProgressRepository
  final userProgressRepository = UserProgressRepository.instance;
  try {
    await userProgressRepository.initialize();
  } catch (e) {
    debugPrint('Failed to initialize UserProgressRepository: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        userProgressRepositoryProvider.overrideWithValue(
          userProgressRepository,
        ),
        onboardingRepositoryProvider.overrideWithValue(onboardingRepository),
      ],
      child: MyApp(
        isOnboardingComplete: onboardingRepository.isOnboardingComplete,
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final bool isOnboardingComplete;

  const MyApp({super.key, required this.isOnboardingComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the new theme provider
    final themeStateAsync = ref.watch(appThemeProvider);

    // Default fallback values if loading
    ThemeData lightTheme = ThemeData.light();
    ThemeData darkTheme = ThemeData.dark();
    ThemeMode themeMode = ThemeMode.system;

    // Access the notifier to generate theme data
    final notifier = ref.read(appThemeProvider.notifier);

    if (themeStateAsync.hasValue) {
      final state = themeStateAsync.value!;
      lightTheme = notifier.getLightTheme();
      darkTheme = notifier.getDarkTheme();

      switch (state.mode) {
        case AppThemeMode.light:
          themeMode = ThemeMode.light;
          break;
        case AppThemeMode.dark:
          themeMode = ThemeMode.dark;
          break;
        case AppThemeMode.system:
          themeMode = ThemeMode.system;
          break;
      }
    }

    return MaterialApp(
      title: 'Ehliyet Rehberim',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: isOnboardingComplete ? const AuthGate() : const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
    );
  }
}
