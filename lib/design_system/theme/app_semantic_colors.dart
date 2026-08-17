import 'package:flutter/material.dart';
import 'package:happfest/design_system/tokens/app_colors.dart';

/// Cores que não existem no `ColorScheme` do Material (success/warning) —
/// ver AGENTS.md seção 3.2. Uso:
/// `Theme.of(context).extension<AppSemanticColors>()!.success`.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Color success;
  final Color warning;
  final Color danger;

  static const light = AppSemanticColors(
    success: AppColors.successStrong,
    warning: AppColors.warning,
    danger: AppColors.dangerStrong,
  );

  static const dark = AppSemanticColors(
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
  );

  @override
  AppSemanticColors copyWith({Color? success, Color? warning, Color? danger}) {
    return AppSemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
