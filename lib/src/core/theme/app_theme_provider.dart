import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_model.dart';
import 'app_colors.dart';

class AppThemeState {
  final AppThemeMode mode;
  final ThemePalette palette;

  const AppThemeState({
    this.mode = AppThemeMode.system,
    this.palette = ThemePalette.defaultPalette,
  });

  AppThemeState copyWith({
    AppThemeMode? mode,
    ThemePalette? palette,
  }) {
    return AppThemeState(
      mode: mode ?? this.mode,
      palette: palette ?? this.palette,
    );
  }
}

class AppThemeNotifier extends AsyncNotifier<AppThemeState> {
  static const String _themeModeKey = 'theme_mode';
  static const String _themePaletteKey = 'theme_palette_id';

  @override
  Future<AppThemeState> build() async {
    return _loadTheme();
  }

  Future<AppThemeState> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Mode
    final modeIndex = prefs.getInt(_themeModeKey) ?? AppThemeMode.system.index;
    final mode = AppThemeMode.values[modeIndex];

    // Load Palette
    final paletteId = prefs.getString(_themePaletteKey) ?? ThemePalette.defaultPalette.id;
    final palette = ThemePalette.all.firstWhere(
      (p) => p.id == paletteId,
      orElse: () => ThemePalette.defaultPalette,
    );

    return AppThemeState(mode: mode, palette: palette);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final currentState = state.value ?? const AppThemeState();
    state = AsyncValue.data(currentState.copyWith(mode: mode));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  Future<void> setPalette(ThemePalette palette) async {
    final currentState = state.value ?? const AppThemeState();
    state = AsyncValue.data(currentState.copyWith(palette: palette));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePaletteKey, palette.id);
  }

  // --- Theme Data Generation ---

  ThemeData getLightTheme() {
    final palette = state.value?.palette ?? ThemePalette.defaultPalette;
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.outfit().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        primary: palette.primary,
        secondary: palette.secondary,
        tertiary: palette.tertiary,
        error: palette.error,
        brightness: Brightness.light,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
    );
  }

  ThemeData getDarkTheme() {
    final palette = state.value?.palette ?? ThemePalette.defaultPalette;
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.outfit().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        primary: palette.primary,
        secondary: palette.secondary,
        tertiary: palette.tertiary,
        error: palette.error,
        brightness: Brightness.dark,
        surface: AppColors.darkBackground,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: AppColors.darkSurface,
      ),
    );
  }
}

final appThemeProvider = AsyncNotifierProvider<AppThemeNotifier, AppThemeState>(() {
  return AppThemeNotifier();
});
