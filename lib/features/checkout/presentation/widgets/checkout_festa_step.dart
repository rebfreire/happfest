import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/design_system/components/app_button.dart';
import 'package:happfest/design_system/components/app_card.dart';
import 'package:happfest/design_system/feedback/app_empty_state.dart';
import 'package:happfest/design_system/feedback/app_error_state.dart';
import 'package:happfest/design_system/feedback/app_loading.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/checkout/presentation/controllers/checkout_flow_controller.dart';
import 'package:happfest/features/checkout/presentation/pages/checkout_page.dart';
import 'package:happfest/features/parties/domain/entities/party.dart';
import 'package:happfest/features/parties/presentation/controllers/party_providers.dart';

class CheckoutFestaStep extends ConsumerWidget {
  const CheckoutFestaStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partiesAsync = ref.watch(partiesProvider);
    final selectedParty = ref.watch(checkoutFlowProvider).selectedParty;

    return Column(
      children: [
        Expanded(
          child: partiesAsync.when(
            loading: () => const AppLoading.skeleton(),
            error: (error, stackTrace) => AppErrorState(
              failure: const UnknownFailure(),
              onRetry: () => ref.invalidate(partiesProvider),
            ),
            data: (result) => switch (result) {
              Ok(:final value) when value.isEmpty => AppEmptyState(
                message: 'Você ainda não cadastrou nenhuma festa.',
                icon: Icons.celebration_outlined,
                actionLabel: 'Cadastrar festa',
                onAction: () => unawaited(_createParty(context, ref)),
              ),
              Ok(:final value) => ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  for (final party in value)
                    _PartyOption(
                      party: party,
                      selected: party.id == selectedParty?.id,
                      onTap: () => ref
                          .read(checkoutFlowProvider.notifier)
                          .selectParty(party),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'Nova festa',
                    variant: AppButtonVariant.tertiary,
                    icon: Icons.add,
                    onPressed: () => unawaited(_createParty(context, ref)),
                  ),
                ],
              ),
              Err(:final failure) => AppErrorState(
                failure: failure,
                onRetry: () => ref.invalidate(partiesProvider),
              ),
            },
          ),
        ),
        CheckoutStepActions(canContinue: selectedParty != null),
      ],
    );
  }

  Future<void> _createParty(BuildContext context, WidgetRef ref) async {
    await context.push<void>('/festas/novo');
    ref.invalidate(partiesProvider);
  }
}

class _PartyOption extends StatelessWidget {
  const _PartyOption({
    required this.party,
    required this.selected,
    required this.onTap,
  });

  final Party party;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    party.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (party.cityName != null)
                    Text('${party.cityName} - ${party.stateUf ?? ''}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
