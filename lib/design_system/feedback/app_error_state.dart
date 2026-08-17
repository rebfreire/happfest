import 'package:flutter/material.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/design_system/components/app_button.dart';
import 'package:happfest/design_system/theme/app_semantic_colors.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';

/// Estado de erro padrão — a UI nunca mostra `Exception: ...` cru, só a
/// mensagem tipada da [Failure] (ver AGENTS.md seção 5).
class AppErrorState extends StatelessWidget {
  const AppErrorState({required this.failure, super.key, this.onRetry});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: semantic.danger),
            const SizedBox(height: AppSpacing.md),
            Text(
              failure.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton(label: 'Tentar novamente', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
