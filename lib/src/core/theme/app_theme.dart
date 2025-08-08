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
      // VISUAL DENSITY
      // ================================
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// Dark theme configuration (for future implementation)
  static ThemeData get darkTheme {
    // For now, return the light theme
    // TODO: Implement dark theme with appropriate dark colors
    return lightTheme;
  }
}