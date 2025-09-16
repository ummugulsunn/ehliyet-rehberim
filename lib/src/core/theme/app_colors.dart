import 'package:flutter/material.dart';

/// App color palette following the new design system
/// Based on modern, accessible color principles for educational apps
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ================================
  // PRIMARY COLORS
  // ================================
  
  /// Primary brand color - Trustworthy blue for driving education
  static const Color primary = Color(0xFF2563EB);
  
  /// Primary light variant - For hover states and accent elements
  static const Color primaryLight = Color(0xFF3B82F6);
  
  /// Primary dark variant - For pressed states and emphasis
  static const Color primaryDark = Color(0xFF1D4ED8);
  
  /// Primary container - Light background for primary elements
  static const Color primaryContainer = Color(0xFFEFF6FF);

  // ================================
  // SECONDARY COLORS
  // ================================
  
  /// Secondary brand color - Warm amber for energy and motivation
  static const Color secondary = Color(0xFFF59E0B);
  
  /// Secondary light variant - For highlights and achievements
  static const Color secondaryLight = Color(0xFFFCD34D);
  
  /// Secondary dark variant - For pressed states
  static const Color secondaryDark = Color(0xFFD97706);
  
  /// Secondary container - Light background for secondary elements
  static const Color secondaryContainer = Color(0xFFFEF3C7);

  // ================================
  // PREMIUM/PRO COLORS
  // ================================
  
  /// Premium color - Vibrant purple for Pro features
  static const Color premium = Color(0xFF8B5CF6);
  
  /// Premium light variant - For hover states
  static const Color premiumLight = Color(0xFFA78BFA);
  
  /// Premium dark variant - For pressed states
  static const Color premiumDark = Color(0xFF7C3AED);
  
  /// Premium container - Light purple background
  static const Color premiumContainer = Color(0xFFF3F4F6);
  
  /// Text on premium color (usually white)
  static const Color onPremium = Color(0xFFFFFFFF);

  // ================================
  // SEMANTIC COLORS
  // ================================
  
  /// Success color - Clear positive feedback for correct answers
  static const Color success = Color(0xFF10B981);
  
  /// Success light - For success backgrounds and highlights
  static const Color successLight = Color(0xFF34D399);
  
  /// Success dark - For success emphasis
  static const Color successDark = Color(0xFF059669);
  
  /// Success container - Light green background
  static const Color successContainer = Color(0xFFECFDF5);
  
  /// Error color - Immediate error recognition for incorrect answers
  static const Color error = Color(0xFFEF4444);
  
  /// Error light - For error backgrounds
  static const Color errorLight = Color(0xFFF87171);
  
  /// Error dark - For error emphasis
  static const Color errorDark = Color(0xFFDC2626);
  
  /// Error container - Light red background
  static const Color errorContainer = Color(0xFFFEF2F2);
  
  /// Warning color - For caution and attention
  static const Color warning = Color(0xFFF97316);
  
  /// Warning light - For warning backgrounds
  static const Color warningLight = Color(0xFFFB923C);
  
  /// Warning dark - For warning emphasis
  static const Color warningDark = Color(0xFFEA580C);
  
  /// Warning container - Light orange background
  static const Color warningContainer = Color(0xFFFFF7ED);
  
  /// Info color - For helpful tips and information
  static const Color info = Color(0xFF06B6D4);
  
  /// Info light - For info backgrounds
  static const Color infoLight = Color(0xFF22D3EE);
  
  /// Info dark - For info emphasis
  static const Color infoDark = Color(0xFF0891B2);
  
  /// Info container - Light cyan background
  static const Color infoContainer = Color(0xFFECFEFF);

  // ================================
  // NEUTRAL COLORS
  // ================================
  
  /// Background color - Off-white to reduce eye strain
  static const Color background = Color(0xFFFAFBFC);
  
  /// Surface color - Pure white for cards and containers
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Surface variant - Light gray for secondary surfaces
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  
  /// Surface container highest - For elevated surfaces
  static const Color surfaceContainerHighest = Color(0xFFE2E8F0);
  
  /// Primary text color - Dark slate for maximum readability
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color onSurface = Color(0xFF1E293B);
  
  /// Secondary text color - Medium slate for supporting text
  static const Color textSecondary = Color(0xFF64748B);
  static const Color onSurfaceVariant = Color(0xFF64748B);
  
  /// Text on primary color (usually white)
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  /// Text on secondary color (usually white)
  static const Color onSecondary = Color(0xFFFFFFFF);
  
  /// Text on success color (usually white)
  static const Color onSuccess = Color(0xFFFFFFFF);
  
  /// Text on error color (usually white)
  static const Color onError = Color(0xFFFFFFFF);
  
  /// Border color - Light border for subtle separation
  static const Color outline = Color(0xFFE2E8F0);
  
  /// Outline variant - Even lighter for subtle borders
  static const Color outlineVariant = Color(0xFFF1F5F9);

  // ================================
  // GRADIENTS
  // ================================
  
  /// Primary gradient for buttons and special elements
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Secondary gradient for achievements and highlights
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Success gradient for positive feedback
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Premium gradient for Pro features and premium elements
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [premium, premiumLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ================================
  // SHADOW COLORS
  // ================================
  
  /// Primary shadow with opacity for elevated elements
  static Color get primaryShadow => primary.withValues(alpha: 77);
  
  /// Secondary shadow with opacity
  static Color get secondaryShadow => secondary.withValues(alpha: 77);
  
  /// Premium shadow with opacity for elevated premium elements
  static Color get premiumShadow => premium.withValues(alpha: 77);
  
  /// General shadow color for neutral elevation
  static Color get shadow => const Color(0xFF000000).withValues(alpha: 26);

  // ================================
  // DARK THEME NEUTRAL COLORS
  // ================================

  /// Dark background color - Near-black with subtle blue hue for OLED friendliness
  static const Color darkBackground = Color(0xFF0F172A); // slate-900

  /// Dark surface color - Slightly lighter than background for elevation
  static const Color darkSurface = Color(0xFF111827); // slate-800

  /// Dark surface variant - For inputs and containers
  static const Color darkSurfaceVariant = Color(0xFF1F2937); // slate-700

  /// Highest elevated dark container surface
  static const Color darkSurfaceContainerHighest = Color(0xFF273449); // custom

  /// Primary text color on dark backgrounds
  static const Color darkOnSurface = Color(0xFFE5E7EB); // slate-200

  /// Secondary text color on dark backgrounds
  static const Color darkOnSurfaceVariant = Color(0xFF9CA3AF); // slate-400

  /// Outline/border color in dark theme
  static const Color darkOutline = Color(0xFF334155); // slate-600

  /// Outline variant in dark theme
  static const Color darkOutlineVariant = Color(0xFF1F2937); // slate-700
}