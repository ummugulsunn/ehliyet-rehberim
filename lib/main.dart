import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/features/auth/presentation/auth_gate.dart';

import 'src/features/home/data/user_progress_repository.dart';
import 'src/features/auth/data/auth_repository.dart';


import 'src/features/auth/application/auth_providers.dart';
import 'src/features/quiz/application/quiz_providers.dart';
import 'src/core/theme/app_theme_provider.dart';
import 'src/core/theme/theme_model.dart';
// import 'src/core/theme/app_theme.dart'; // Deprecated
// import 'src/features/profile/application/theme_mode_provider.dart'; // Deprecated
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'dart:async';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with timeout for physical devices
  try {
    await Firebase.initializeApp().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('Firebase initialization timeout - continuing without Firebase');
        throw TimeoutException('Firebase initialization timeout', const Duration(seconds: 10));
      },
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize Firebase: $e');
    // Continue app initialization even if Firebase fails
  }
  
  // Initialize intl localization for date formatting
  try {
    await initializeDateFormatting('tr_TR', null);
    Intl.defaultLocale = 'tr_TR';
    debugPrint('Intl date formatting initialized for tr_TR');
  } catch (e) {
    debugPrint('Failed to initialize intl date formatting: $e');
  }
  
  // Initialize AuthRepository
  final authRepository = AuthRepository.instance;
  try {
    await authRepository.initialize();
    debugPrint('AuthRepository initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize AuthRepository: $e');
    // Continue app initialization even if auth service fails
  }
  

  
  // Initialize UserProgressRepository
  final userProgressRepository = UserProgressRepository.instance;
  try {
    await userProgressRepository.initialize();
    debugPrint('UserProgressRepository initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize UserProgressRepository: $e');
    // Continue app initialization even if user progress service fails
  }
  
  
  // Initialize NotificationService (disabled due to build issues)
  /*
  try {
    final notificationService = NotificationService.instance;
    await notificationService.initialize();
    await notificationService.requestPermissions();
    debugPrint('NotificationService initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize NotificationService: $e');
    // Continue app initialization even if notification service fails
  }
  */
  
  

  


  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),

        userProgressRepositoryProvider.overrideWithValue(userProgressRepository),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

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
      home: const AuthGate(), 
      debugShowCheckedModeBanner: false,
    );
  }
}
