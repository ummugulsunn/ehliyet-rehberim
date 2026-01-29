import 'package:flutter/material.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemePalette {
  final String id;
  final String name;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color error;
  
  const ThemePalette({
    required this.id,
    required this.name,
    required this.primary,
    required this.secondary,
    this.tertiary = const Color(0xFF8B5CF6), // Default Premium Purple
    this.error = const Color(0xFFEF4444),
  });

  static const defaultPalette = ThemePalette(
    id: 'default',
    name: 'Turkuaz (Varsayılan)',
    primary: Color(0xFF2563EB), // Blue-600
    secondary: Color(0xFFF59E0B), // Amber-500
  );

  static const oceanPalette = ThemePalette(
    id: 'ocean',
    name: 'Okyanus Mavisi',
    primary: Color(0xFF0EA5E9), // Sky-500
    secondary: Color(0xFF6366F1), // Indigo-500
  );

  static const naturePalette = ThemePalette(
    id: 'nature',
    name: 'Doğa Yeşili',
    primary: Color(0xFF10B981), // Emerald-500
    secondary: Color(0xFF84CC16), // Lime-500
  );

  static const sunsetPalette = ThemePalette(
    id: 'sunset',
    name: 'Gün Batımı',
    primary: Color(0xFFF97316), // Orange-500
    secondary: Color(0xFFEC4899), // Pink-500
  );

  static const midnightPalette = ThemePalette(
    id: 'midnight',
    name: 'Gece Moru',
    primary: Color(0xFF8B5CF6), // Violet-500
    secondary: Color(0xFF06B6D4), // Cyan-500
  );

  static const List<ThemePalette> all = [
    defaultPalette,
    oceanPalette,
    naturePalette,
    sunsetPalette,
    midnightPalette,
  ];
}
