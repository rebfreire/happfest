import 'package:flutter/material.dart';
import 'package:happfest/design_system/theme/app_semantic_colors.dart';
import 'package:happfest/design_system/tokens/app_colors.dart';
import 'package:happfest/design_system/tokens/app_radius.dart';
import 'package:happfest/design_system/tokens/app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(brightness: Brightness.light);

  static ThemeData get dark => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    // `ColorScheme.fromSeed` gera uma paleta tonal M3 a partir da cor
    // semente e não preserva o hex exato — por isso fixamos primary/
    // secondary/tertiary com as cores reais da marca via `copyWith`.
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          error: AppColors.dangerStrong,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onPrimary,
          tertiary: AppColors.accent,
          onTertiary: AppColors.surface900,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: isDark
          ? AppColors.surface900
          : AppColors.surface50,
      extensions: [
        if (isDark) AppSemanticColors.dark else AppSemanticColors.light,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.surface900 : AppColors.surface0,
        foregroundColor: isDark ? AppColors.surface0 : AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surface800 : AppColors.surface0,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.surface800 : AppColors.surface0,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.surface800 : AppColors.surface0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.surface700 : AppColors.surface900,
        contentTextStyle: const TextStyle(color: AppColors.surface0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
