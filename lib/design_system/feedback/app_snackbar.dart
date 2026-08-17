import 'package:flutter/material.dart';
import 'package:happfest/design_system/theme/app_semantic_colors.dart';

abstract final class AppSnackbar {
  static void success(BuildContext context, String message) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    _show(context, message, color: semantic.success, icon: Icons.check_circle);
  }

  static void error(BuildContext context, String message) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    _show(context, message, color: semantic.danger, icon: Icons.error);
  }

  static void warning(BuildContext context, String message) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    _show(context, message, color: semantic.warning, icon: Icons.warning);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, icon: Icons.info);
  }

  static void _show(
    BuildContext context,
    String message, {
    required IconData icon,
    Color? color,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}
