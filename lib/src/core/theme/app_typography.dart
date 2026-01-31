import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; // Temporarily disabled due to font loading issues
import 'app_colors.dart';

/// App typography system following the new design system
/// Uses Inter-like system font for optimal readability and modern appearance
class AppTypography {
  // Prevent instantiation
  AppTypography._();

  /// Base font family for the entire app - uses system font as fallback for Inter
  static const TextStyle _baseStyle = TextStyle(
    fontFamily: 'System', // Will use the platform's default modern font
    fontFeatures: [FontFeature.proportionalFigures()],
  );

  // ================================
  // HEADLINE STYLES
  // ================================

  /// H1 - 32px, Bold - Screen titles and main headers
  static TextStyle get h1 => _baseStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700, // Bold
    height: 1.25, // Line height: 40px
    letterSpacing: -0.02, // Slight negative spacing for large text
    color: AppColors.onSurface,
  );

  /// H2 - 24px, SemiBold - Section headers and important titles
  static TextStyle get h2 => _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.33, // Line height: 32px
    letterSpacing: -0.01,
    color: AppColors.onSurface,
  );

  /// H3 - 20px, SemiBold - Card titles and subsection headers
  static TextStyle get h3 => _baseStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.4, // Line height: 28px
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  /// H4 - 18px, SemiBold - Small headers and emphasized text
  static TextStyle get h4 => _baseStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.44, // Line height: 26px
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  // ================================
  // BODY STYLES
  // ================================

  /// Body Large - 16px, Regular - Primary text content
  static TextStyle get bodyLarge => _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5, // Line height: 24px
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  /// Body Medium - 14px, Regular - Secondary text content
  static TextStyle get bodyMedium => _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    height: 1.43, // Line height: 20px
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  /// Body Small - 12px, Regular - Small text and captions
  static TextStyle get bodySmall => _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    height: 1.33, // Line height: 16px
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  // ================================
  // LABEL STYLES
  // ================================

  /// Label Large - 14px, Medium - Button text and labels
  static TextStyle get labelLarge => _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    height: 1.43, // Line height: 20px
    letterSpacing: 0.01,
    color: AppColors.onSurface,
  );

  /// Label Medium - 12px, Medium - Small labels and tags
  static TextStyle get labelMedium => _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500, // Medium
    height: 1.33, // Line height: 16px
    letterSpacing: 0.01,
    color: AppColors.onSurface,
  );

  /// Label Small - 10px, Medium - Tiny labels and metadata
  static TextStyle get labelSmall => _baseStyle.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500, // Medium
    height: 1.2, // Line height: 12px
    letterSpacing: 0.02,
    color: AppColors.onSurface,
  );

  // ================================
  // SPECIALIZED STYLES
  // ================================

  /// Title Large - 22px, SemiBold - For app bars and dialog titles
  static TextStyle get titleLarge => _baseStyle.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.27, // Line height: 28px
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  /// Title Medium - 16px, Medium - For card titles and list items
  static TextStyle get titleMedium => _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    height: 1.5, // Line height: 24px
    letterSpacing: 0.01,
    color: AppColors.onSurface,
  );

  /// Title Small - 14px, Medium - For small titles and emphasized content
  static TextStyle get titleSmall => _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    height: 1.43, // Line height: 20px
    letterSpacing: 0.01,
    color: AppColors.onSurface,
  );

  // ================================
  // DISPLAY STYLES (For large numbers and statistics)
  // ================================

  /// Display Large - 48px, Bold - For large numbers and statistics
  static TextStyle get displayLarge => _baseStyle.copyWith(
    fontSize: 48,
    fontWeight: FontWeight.w700, // Bold
    height: 1.17, // Line height: 56px
    letterSpacing: -0.02,
    color: AppColors.onSurface,
  );

  /// Display Medium - 36px, Bold - For medium display text
  static TextStyle get displayMedium => _baseStyle.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w700, // Bold
    height: 1.22, // Line height: 44px
    letterSpacing: -0.02,
    color: AppColors.onSurface,
  );

  /// Display Small - 28px, Bold - For small display text
  static TextStyle get displaySmall => _baseStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700, // Bold
    height: 1.29, // Line height: 36px
    letterSpacing: -0.01,
    color: AppColors.onSurface,
  );

  // ================================
  // CONTEXT-SPECIFIC STYLES
  // ================================

  /// Button text style - Optimized for buttons
  static TextStyle get button => _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.25, // Line height: 20px
    letterSpacing: 0.01,
    color: AppColors.onPrimary,
  );

  /// Quiz question text - Optimized for readability
  static TextStyle get quizQuestion => _baseStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500, // Medium
    height: 1.56, // Line height: 28px - Better for reading comprehension
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  /// Quiz option text - For answer choices
  static TextStyle get quizOption => _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5, // Line height: 24px
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  /// Score display - For large score numbers
  static TextStyle get scoreDisplay => _baseStyle.copyWith(
    fontSize: 42,
    fontWeight: FontWeight.w700, // Bold
    height: 1.19, // Line height: 50px
    letterSpacing: -0.02,
    color: AppColors.primary,
  );

  /// Percentage display - For percentage scores
  static TextStyle get percentageDisplay => _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.33, // Line height: 32px
    letterSpacing: 0,
    color: AppColors.onSurfaceVariant,
  );

  // ================================
  // HELPER METHODS
  // ================================

  /// Get text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Get text style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Get text style with custom size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Get the complete TextTheme for Material Design
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: h1,
    headlineMedium: h2,
    headlineSmall: h3,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
