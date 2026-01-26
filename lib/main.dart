import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/features/auth/presentation/auth_gate.dart';

import 'src/core/services/user_progress_service.dart';
import 'src/core/services/auth_service.dart';


import 'src/features/auth/application/auth_providers.dart';
import 'src/features/quiz/application/quiz_providers.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/profile/application/theme_mode_provider.dart';
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
  
  // Initialize AuthService
  final authService = AuthService.instance;
  try {
    await authService.initialize();
    debugPrint('AuthService initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize AuthService: $e');
    // Continue app initialization even if auth service fails
  }
  

  
  // Initialize UserProgressService
  final userProgressService = UserProgressService.instance;
  try {
    await userProgressService.initialize();
    debugPrint('UserProgressService initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize UserProgressService: $e');
    // Continue app initialization even if user progress service fails
  }
  

  


  runApp(
    ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(authService),

        userProgressServiceProvider.overrideWithValue(userProgressService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Ehliyet Rehberim',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AuthGate(), // Use the new AuthGate widget
      debugShowCheckedModeBanner: false,
    );
  }
}


