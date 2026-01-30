import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Main app theme configuration
/// Implements the new design system with modern, accessible styling
class AppTheme {
  // Prevent instantiation
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // ================================
      // COLOR SCHEME
      // ================================
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        shadow: Color(0xFF000000),
        inversePrimary: AppColors.primaryLight,
      ),

      // ================================
      // BACKGROUND COLORS
      // ================================
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.surface,

      // ================================
      // TYPOGRAPHY
      // ================================
      textTheme: AppTypography.textTheme,
      
      // ================================
      // APP BAR THEME
      // ================================
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: AppColors.shadow,
        surfaceTintColor: AppColors.background,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        toolbarTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.background.withValues(alpha: 0),
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // ================================
      // CARD THEME
      // ================================
      cardTheme: CardThemeData(
        color: AppColors.surface,
        shadowColor: AppColors.shadow,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),

      // ================================
      // ELEVATED BUTTON THEME
      // ================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.onSurfaceVariant.withValues(alpha: 31),
          disabledForegroundColor: AppColors.onSurfaceVariant.withValues(alpha: 97),
          elevation: 2,
          shadowColor: AppColors.primaryShadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTypography.button,
          minimumSize: const Size(0, 48),
        ),
      ),

      // ================================
      // OUTLINED BUTTON THEME
      // ================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.onSurfaceVariant.withValues(alpha: 97),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          textStyle: AppTypography.button.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          minimumSize: const Size(0, 56),
        ),
      ),

      // ================================
      // TEXT BUTTON THEME
      // ================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.onSurfaceVariant.withValues(alpha: 97),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTypography.labelLarge.copyWith(color: AppColors.primary),
          minimumSize: const Size(0, 40),
        ),
      ),

      // ================================
      // FLOATING ACTION BUTTON THEME
      // ================================
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 12,
        shape: CircleBorder(),
      ),

      // ================================
      // INPUT DECORATION THEME
      // ================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),

      // ================================
      // CHIP THEME
      // ================================
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerHighest,
        disabledColor: AppColors.onSurfaceVariant.withValues(alpha: 31),
        selectedColor: AppColors.primaryContainer,
        secondarySelectedColor: AppColors.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle: AppTypography.labelMedium,
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ================================
      // DIALOG THEME
      // ================================
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shadowColor: AppColors.shadow,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: AppTypography.h3,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      // ================================
      // BOTTOM SHEET THEME
      // ================================
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      // ================================
      // PROGRESS INDICATOR THEME
      // ================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceContainerHighest,
        circularTrackColor: AppColors.surfaceContainerHighest,
      ),

      // ================================
      // DIVIDER THEME
      // ================================
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),

      // ================================
      // LIST TILE THEME
      // ================================
      listTileTheme: ListTileThemeData(
        tileColor: AppColors.surface,
        selectedTileColor: AppColors.primaryContainer,
        iconColor: AppColors.onSurfaceVariant,
        textColor: AppColors.onSurface,
        titleTextStyle: AppTypography.titleMedium,
        subtitleTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ================================
      // SWITCH THEME
      // ================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.onPrimary;
          }
          return AppColors.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.surfaceContainerHighest;
        }),
      ),

      // ================================
      // ICON THEME
      // ================================
      iconTheme: const IconThemeData(
        color: AppColors.onSurfaceVariant,
        size: 24,
      ),
      primaryIconTheme: const IconThemeData(
        color: AppColors.onPrimary,
        size: 24,
      ),

      
      // ================================
      // PAGE TRANSITIONS
      // ================================
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // ================================
      // VISUAL DENSITY
      // ================================
      // ================================
      // PAGE TRANSITIONS
      // ================================
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ================================
      // COLOR SCHEME
      // ================================
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryDark,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
        error: AppColors.errorLight,
        onError: AppColors.onError,
        errorContainer: AppColors.errorDark,
        outline: AppColors.darkOutline,
        outlineVariant: AppColors.darkOutlineVariant,
        shadow: Color(0xFF000000),
        inversePrimary: AppColors.primary,
      ),

      // ================================
      // BACKGROUND COLORS
      // ================================
      scaffoldBackgroundColor: AppColors.darkBackground,
      canvasColor: AppColors.darkSurface,

      // ================================
      // TYPOGRAPHY
      // ================================
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.darkOnSurface,
        displayColor: AppColors.darkOnSurface,
      ),

      // ================================
      // APP BAR THEME
      // ================================
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: AppColors.shadow,
        surfaceTintColor: AppColors.darkBackground,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.darkOnSurface,
          fontWeight: FontWeight.w600,
        ),
        toolbarTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkOnSurface,
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.darkBackground.withValues(alpha: 0),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // ================================
      // CARD THEME
      // ================================
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        shadowColor: AppColors.shadow,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.darkOnSurfaceVariant.withValues(alpha: 31),
          disabledForegroundColor: AppColors.darkOnSurfaceVariant.withValues(alpha: 97),
          elevation: 2,
          shadowColor: AppColors.primaryShadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTypography.button,
          minimumSize: const Size(0, 48),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          disabledForegroundColor: AppColors.darkOnSurfaceVariant.withValues(alpha: 97),
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          textStyle: AppTypography.button.copyWith(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.bold,
          ),
          minimumSize: const Size(0, 56),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          disabledForegroundColor: AppColors.darkOnSurfaceVariant.withValues(alpha: 97),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTypography.labelLarge.copyWith(color: AppColors.primaryLight),
          minimumSize: const Size(0, 40),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.onPrimary,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 12,
        shape: CircleBorder(),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorLight),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkOnSurfaceVariant,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkOnSurfaceVariant,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        disabledColor: AppColors.darkOnSurfaceVariant.withValues(alpha: 31),
        selectedColor: AppColors.primaryDark,
        secondarySelectedColor: AppColors.secondaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: AppTypography.labelMedium.copyWith(color: AppColors.darkOnSurface),
        secondaryLabelStyle: AppTypography.labelMedium.copyWith(color: AppColors.darkOnSurface),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shadowColor: AppColors.shadow,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: AppTypography.h3.copyWith(color: AppColors.darkOnSurface),
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurface),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryLight,
        linearTrackColor: AppColors.darkSurfaceVariant,
        circularTrackColor: AppColors.darkSurfaceVariant,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.darkOutline,
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        tileColor: AppColors.darkSurface,
        selectedTileColor: AppColors.primaryDark.withValues(alpha: 0.2),
        iconColor: AppColors.darkOnSurfaceVariant,
        textColor: AppColors.darkOnSurface,
        titleTextStyle: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface),
        subtitleTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkOnSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.onPrimary;
          }
          return AppColors.darkOutline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.darkSurfaceVariant;
        }),
      ),

      iconTheme: const IconThemeData(
        color: AppColors.darkOnSurfaceVariant,
        size: 24,
      ),
      primaryIconTheme: const IconThemeData(
        color: AppColors.onPrimary,
        size: 24,
      ),

      
      // ================================
      // PAGE TRANSITIONS
      // ================================
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}