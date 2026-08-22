import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/design_system/components/app_card.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/checkout/presentation/controllers/checkout_flow_controller.dart';
import 'package:happfest/features/checkout/presentation/pages/checkout_page.dart';

/// Sem edição por loja nesta versão — cada loja usa automaticamente a
/// data/endereço da festa selecionada (comportamento padrão da API quando
/// nenhum `deliveries` é enviado no checkout). Ajuste por loja fica como
/// próximo passo (ver `docs/progress/11-checkout.md`).
class CheckoutEntregaStep extends ConsumerWidget {
  const CheckoutEntregaStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final party = ref.watch(checkoutFlowProvider).selectedParty;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Entrega',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Todas as lojas vão entregar no endereço e na data da '
                    'festa "${party?.name ?? ''}".',
                  ),
                  if (party?.cityName != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text('${party!.cityName} - ${party.stateUf ?? ''}'),
                  ],
                ],
              ),
            ),
          ),
        ),
        const CheckoutStepActions(canContinue: true),
      ],
    );
  }
}
