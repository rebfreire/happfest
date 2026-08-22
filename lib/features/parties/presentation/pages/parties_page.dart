import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/design_system/components/app_badge.dart';
import 'package:happfest/design_system/components/app_card.dart';
import 'package:happfest/design_system/components/app_scaffold.dart';
import 'package:happfest/design_system/feedback/app_empty_state.dart';
import 'package:happfest/design_system/feedback/app_error_state.dart';
import 'package:happfest/design_system/feedback/app_loading.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/parties/domain/entities/party.dart';
import 'package:happfest/features/parties/presentation/controllers/party_providers.dart';
import 'package:intl/intl.dart';

class PartiesPage extends ConsumerWidget {
  const PartiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partiesAsync = ref.watch(partiesProvider);

    return AppScaffold(
      title: 'Festas',
      onRefresh: () async => ref.invalidate(partiesProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/festas/novo'),
        child: const Icon(Icons.add),
      ),
      body: partiesAsync.when(
        loading: () => const AppLoading.skeleton(),
        error: (error, stackTrace) => AppErrorState(
          failure: const UnknownFailure(),
          onRetry: () => ref.invalidate(partiesProvider),
        ),
        data: (result) => switch (result) {
          Ok(:final value) when value.isEmpty => const AppEmptyState(
            message: 'Você ainda não cadastrou nenhuma festa.',
            icon: Icons.celebration_outlined,
          ),
          Ok(:final value) => ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: value.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) => _PartyCard(party: value[index]),
          ),
          Err(:final failure) => AppErrorState(
            failure: failure,
            onRetry: () => ref.invalidate(partiesProvider),
          ),
        },
      ),
    );
  }
}

class _PartyCard extends StatelessWidget {
  const _PartyCard({required this.party});

  final Party party;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final period = switch ((party.startDate, party.endDate)) {
      (final start?, final end?) =>
        '${dateFormat.format(start)} — ${dateFormat.format(end)}',
      (final start?, null) => dateFormat.format(start),
      _ => null,
    };
    final place = [
      party.cityName,
      party.stateUf,
    ].nonNulls.where((s) => s.isNotEmpty).join(' - ');

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  party.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (period != null) Text(period),
                if (place.isNotEmpty) Text(place),
                if (party.guestCount > 0)
                  Text('${party.guestCount} convidados'),
              ],
            ),
          ),
          if (party.status == PartyStatus.archived)
            const AppBadge(label: 'ARQUIVADA'),
        ],
      ),
    );
  }
}
