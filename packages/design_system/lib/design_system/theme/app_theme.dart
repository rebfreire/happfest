import 'package:flutter/material.dart';
import 'package:happfest_design_system/design_system/theme/app_semantic_colors.dart';
import 'package:happfest_design_system/design_system/tokens/app_colors.dart';
import 'package:happfest_design_system/design_system/tokens/app_radius.dart';
import 'package:happfest_design_system/design_system/tokens/app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(brightness: Brightness.light);

  static ThemeData get dark => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    // `ColorScheme.fromSeed` gera tons derivados algoritmicamente e não
    // preserva a cor exata da marca (ela vira um tom dessaturado/mais
    // escuro do rosa da marca) — os tokens em `AppColors` já são as cores
    // reais extraídas do site em produção, então sobrescrevemos os papéis
    // de marca no scheme gerado em vez de confiar no tom derivado.
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onPrimary,
          tertiary: AppColors.accent,
          onTertiary: AppColors.surface900,
          error: AppColors.dangerStrong,
          onError: AppColors.onPrimary,
          surface: isDark ? AppColors.surface900 : AppColors.surface0,
          onSurface: isDark ? AppColors.surface0 : AppColors.textPrimary,
          outline: AppColors.outline,
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
