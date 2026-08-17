import 'package:flutter/material.dart';
import 'package:happfest/design_system/theme/app_semantic_colors.dart';
import 'package:happfest/design_system/tokens/app_radius.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';

enum AppButtonVariant { primary, secondary, tertiary, danger, ghost }

enum AppButtonSize { small, medium, large }

/// Botão único do app — nenhuma tela cria `ElevatedButton`/`TextButton`
/// diretamente (ver AGENTS.md seção 3.3). `onPressed: null` = desabilitado.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
  });

  factory AppButton.save({
    required String label,
    required VoidCallback? onPressed,
    Key? key,
    bool isLoading = false,
    bool expanded = false,
  }) {
    return AppButton(
      key: key,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      expanded: expanded,
    );
  }

  factory AppButton.cancel({
    required String label,
    required VoidCallback? onPressed,
    Key? key,
  }) {
    return AppButton(
      key: key,
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.ghost,
    );
  }

  factory AppButton.delete({
    required String label,
    required VoidCallback? onPressed,
    Key? key,
    bool isLoading = false,
  }) {
    return AppButton(
      key: key,
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.danger,
      isLoading: isLoading,
    );
  }

  factory AppButton.confirm({
    required String label,
    required VoidCallback? onPressed,
    Key? key,
    bool isLoading = false,
    bool expanded = false,
  }) {
    return AppButton(
      key: key,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      expanded: expanded,
    );
  }

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  static const _minHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final height = switch (size) {
      AppButtonSize.small => _minHeight - 8,
      AppButtonSize.medium => _minHeight,
      AppButtonSize.large => _minHeight + 8,
    };

    final (background, foreground, border) = switch (variant) {
      AppButtonVariant.primary => (
        colorScheme.primary,
        colorScheme.onPrimary,
        null,
      ),
      AppButtonVariant.secondary => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        null,
      ),
      AppButtonVariant.tertiary => (
        Colors.transparent,
        colorScheme.primary,
        colorScheme.outline,
      ),
      AppButtonVariant.danger => (semantic.danger, colorScheme.onError, null),
      AppButtonVariant.ghost => (Colors.transparent, colorScheme.primary, null),
    };

    final effectiveOnPressed = isLoading ? null : onPressed;
    final child = isLoading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label),
            ],
          );

    final button = ElevatedButton(
      onPressed: effectiveOnPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: background.withValues(alpha: 0.4),
        disabledForegroundColor: foreground.withValues(alpha: 0.7),
        elevation: variant == AppButtonVariant.ghost ? 0 : null,
        minimumSize: Size(expanded ? double.infinity : 0, height),
        side: border != null ? BorderSide(color: border) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: child,
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
