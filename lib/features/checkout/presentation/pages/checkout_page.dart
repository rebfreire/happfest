import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/design_system/components/app_button.dart';
import 'package:happfest/design_system/components/app_scaffold.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/checkout/presentation/controllers/checkout_flow_controller.dart';
import 'package:happfest/features/checkout/presentation/widgets/checkout_entrega_step.dart';
import 'package:happfest/features/checkout/presentation/widgets/checkout_festa_step.dart';
import 'package:happfest/features/checkout/presentation/widgets/checkout_itens_step.dart';
import 'package:happfest/features/checkout/presentation/widgets/checkout_resumo_step.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(checkoutFlowProvider);

    return AppScaffold(
      title: 'Finalizar compra',
      body: Column(
        children: [
          _StepHeader(step: flow.step),
          Expanded(
            child: switch (flow.step) {
              CheckoutStep.itens => const CheckoutItensStep(),
              CheckoutStep.festa => const CheckoutFestaStep(),
              CheckoutStep.entrega => const CheckoutEntregaStep(),
              CheckoutStep.resumo => const CheckoutResumoStep(),
            },
          ),
        ],
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step});

  final CheckoutStep step;

  static const _labels = ['Itens', 'Festa', 'Entrega', 'Resumo'];

  @override
  Widget build(BuildContext context) {
    final currentIndex = CheckoutStep.values.indexOf(step);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          for (var i = 0; i < _labels.length; i++) ...[
            if (i > 0) const Expanded(child: Divider()),
            Column(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: i <= currentIndex
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: i <= currentIndex
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(_labels[i], style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Barra fixa de "Voltar/Continuar" reutilizada pelos passos — mantém o
/// botão de avançar desabilitado até o passo estar completo.
class CheckoutStepActions extends ConsumerWidget {
  const CheckoutStepActions({
    required this.canContinue,
    this.continueLabel = 'Continuar',
    this.onContinue,
    super.key,
  });

  final bool canContinue;
  final String continueLabel;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(checkoutFlowProvider);
    final controller = ref.read(checkoutFlowProvider.notifier);
    final isFirstStep = flow.step == CheckoutStep.itens;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            if (!isFirstStep) ...[
              Expanded(
                child: AppButton(
                  label: 'Voltar',
                  variant: AppButtonVariant.tertiary,
                  onPressed: controller.back,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: AppButton.confirm(
                label: continueLabel,
                onPressed: canContinue ? onContinue ?? controller.next : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
