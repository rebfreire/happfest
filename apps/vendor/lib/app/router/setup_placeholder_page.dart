import 'package:flutter/material.dart';
import 'package:happfest_design_system/design_system/components/app_scaffold.dart';
import 'package:happfest_design_system/design_system/tokens/app_spacing.dart';
import 'package:happfest_fornecedor/l10n/generated/app_localizations.dart';

/// Placeholder da Fase 0 (ver AGENTS.md seção 15) — as features reais
/// (login, dashboard, pedidos, produtos, agenda) entram uma a uma.
class SetupPlaceholderPage extends StatelessWidget {
  const SetupPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.appName,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            l10n.setupPlaceholderMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
