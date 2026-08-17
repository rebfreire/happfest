import 'package:flutter/material.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/design_system/components/app_avatar.dart';
import 'package:happfest/design_system/components/app_badge.dart';
import 'package:happfest/design_system/components/app_button.dart';
import 'package:happfest/design_system/components/app_card.dart';
import 'package:happfest/design_system/components/app_chip.dart';
import 'package:happfest/design_system/components/app_form_fields.dart';
import 'package:happfest/design_system/components/app_form_layout.dart';
import 'package:happfest/design_system/components/app_list_tile.dart';
import 'package:happfest/design_system/components/app_text_field.dart';
import 'package:happfest/design_system/feedback/app_dialog.dart';
import 'package:happfest/design_system/feedback/app_empty_state.dart';
import 'package:happfest/design_system/feedback/app_error_state.dart';
import 'package:happfest/design_system/feedback/app_loading.dart';
import 'package:happfest/design_system/feedback/app_snackbar.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';

/// Vitrine de todos os componentes do design system, só em debug — ver
/// AGENTS.md seção 3.5. Rota: `/dev/design-system`.
class DesignSystemStorybookPage extends StatelessWidget {
  const DesignSystemStorybookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design System')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const _Section(
            title: 'AppButton',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppButton(label: 'Primary', onPressed: _noop),
                AppButton(
                  label: 'Secondary',
                  onPressed: _noop,
                  variant: AppButtonVariant.secondary,
                ),
                AppButton(
                  label: 'Tertiary',
                  onPressed: _noop,
                  variant: AppButtonVariant.tertiary,
                ),
                AppButton(
                  label: 'Danger',
                  onPressed: _noop,
                  variant: AppButtonVariant.danger,
                ),
                AppButton(
                  label: 'Ghost',
                  onPressed: _noop,
                  variant: AppButtonVariant.ghost,
                ),
                AppButton(label: 'Loading', onPressed: _noop, isLoading: true),
                AppButton(label: 'Disabled', onPressed: null),
              ],
            ),
          ),
          const _Section(
            title: 'AppTextField / AppFormLayout',
            child: AppFormLayout(
              children: [
                AppTextField(label: 'E-mail', hint: 'voce@exemplo.com'),
                AppTextField(label: 'Senha', obscureText: true),
                AppTextField(label: 'Com erro', errorText: 'Campo obrigatório'),
              ],
            ),
          ),
          _Section(
            title: 'Campos diversos',
            child: Column(
              children: [
                const AppSearchField(
                  hint: 'Buscar bolos, decoração, buffet...',
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCheckbox(
                  label: 'Aceito os termos',
                  value: true,
                  onChanged: (_) {},
                ),
                AppSwitch(
                  label: 'Notificações',
                  value: false,
                  onChanged: (_) {},
                ),
                AppDropdown<String>(
                  label: 'Categoria',
                  value: 'bolos',
                  items: const [
                    DropdownMenuItem(value: 'bolos', child: Text('Bolos')),
                    DropdownMenuItem(value: 'buffet', child: Text('Buffet')),
                  ],
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          const _Section(
            title: 'AppCard / AppListTile / AppChip / AppBadge / AppAvatar',
            child: Column(
              children: [
                AppCard(
                  child: Row(
                    children: [
                      AppAvatar(initials: 'HF'),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text('AppCard com AppAvatar')),
                      AppBadge(label: 'PRODUTO'),
                    ],
                  ),
                ),
                AppListTile(title: 'AppListTile', subtitle: 'Subtítulo'),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    AppChip(label: 'Bolos'),
                    AppChip(label: 'Decoração', selected: true),
                  ],
                ),
              ],
            ),
          ),
          _Section(
            title: 'Feedback',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppButton(
                  label: 'Snackbar success',
                  onPressed: () => AppSnackbar.success(context, 'Deu certo!'),
                ),
                AppButton(
                  label: 'Snackbar error',
                  onPressed: () => AppSnackbar.error(context, 'Deu errado.'),
                ),
                AppButton(
                  label: 'Dialog confirm',
                  onPressed: () => AppDialog.confirm(
                    context,
                    title: 'Confirmar',
                    message: 'Tem certeza?',
                  ),
                ),
                AppButton(
                  label: 'Dialog destructive',
                  onPressed: () => AppDialog.destructive(
                    context,
                    title: 'Excluir',
                    message: 'Essa ação não pode ser desfeita.',
                  ),
                ),
              ],
            ),
          ),
          const _Section(
            title: 'Estados de tela',
            child: Column(
              children: [
                SizedBox(height: 120, child: AppLoading.skeleton(lines: 2)),
                SizedBox(height: 12),
                AppEmptyState(message: 'Nenhum item por aqui.'),
                SizedBox(height: 12),
                AppErrorState(failure: ServerFailure()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _noop() {}
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}
