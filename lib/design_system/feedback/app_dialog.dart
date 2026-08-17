import 'package:flutter/material.dart';
import 'package:happfest/design_system/components/app_button.dart';

/// Diálogos padronizados — `.confirm`/`.destructive`/`.info` já vêm com os
/// botões no lugar certo (ver AGENTS.md seção 3.3).
abstract final class AppDialog {
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          AppButton.cancel(
            label: cancelLabel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppButton.confirm(
            label: confirmLabel,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<bool> destructive(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Excluir',
    String cancelLabel = 'Cancelar',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          AppButton.cancel(
            label: cancelLabel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppButton.delete(
            label: confirmLabel,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<void> info(
    BuildContext context, {
    required String title,
    required String message,
    String closeLabel = 'Ok',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          AppButton.confirm(
            label: closeLabel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
