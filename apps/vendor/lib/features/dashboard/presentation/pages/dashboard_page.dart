import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest_core/core/error/failure.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_design_system/design_system/components/app_button.dart';
import 'package:happfest_design_system/design_system/components/app_card.dart';
import 'package:happfest_design_system/design_system/components/app_scaffold.dart';
import 'package:happfest_design_system/design_system/feedback/app_empty_state.dart';
import 'package:happfest_design_system/design_system/feedback/app_error_state.dart';
import 'package:happfest_design_system/design_system/feedback/app_loading.dart';
import 'package:happfest_design_system/design_system/tokens/app_spacing.dart';
import 'package:happfest_fornecedor/features/dashboard/presentation/controllers/dashboard_providers.dart';
import 'package:happfest_fornecedor/features/dashboard/presentation/widgets/metrics_summary_row.dart';
import 'package:happfest_fornecedor/features/dashboard/presentation/widgets/pending_order_tile.dart';
import 'package:happfest_fornecedor/l10n/generated/app_localizations.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.appName,
      onRefresh: () async {
        ref
          ..invalidate(supplierProfileProvider)
          ..invalidate(supplierMetricsProvider)
          ..invalidate(pendingOrdersProvider);
      },
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [
          _ProfileHeader(),
          SizedBox(height: AppSpacing.md),
          _MetricsSection(),
          SizedBox(height: AppSpacing.lg),
          _ProductsLink(),
          SizedBox(height: AppSpacing.lg),
          _PendingOrdersSection(),
        ],
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(supplierProfileProvider);

    return profileAsync.when(
      loading: () => const AppLoading(),
      error: (error, stackTrace) => AppErrorState(
        failure: const UnknownFailure(),
        onRetry: () => ref.invalidate(supplierProfileProvider),
      ),
      data: (result) => switch (result) {
        Ok(:final value) => Text(
          value.tradeName ?? value.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Err(:final failure) => AppErrorState(
          failure: failure,
          onRetry: () => ref.invalidate(supplierProfileProvider),
        ),
      },
    );
  }
}

class _MetricsSection extends ConsumerWidget {
  const _MetricsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(supplierMetricsProvider);

    return metricsAsync.when(
      loading: () => const AppLoading(),
      error: (error, stackTrace) => AppErrorState(
        failure: const UnknownFailure(),
        onRetry: () => ref.invalidate(supplierMetricsProvider),
      ),
      data: (result) => switch (result) {
        Ok(:final value) => MetricsSummaryRow(metrics: value),
        Err(:final failure) => AppErrorState(
          failure: failure,
          onRetry: () => ref.invalidate(supplierMetricsProvider),
        ),
      },
    );
  }
}

class _ProductsLink extends StatelessWidget {
  const _ProductsLink();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/products'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Meus produtos', style: Theme.of(context).textTheme.titleMedium),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _PendingOrdersSection extends ConsumerWidget {
  const _PendingOrdersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(pendingOrdersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Pedidos pendentes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            AppButton(
              label: 'Ver todos',
              onPressed: () => context.push('/orders'),
              variant: AppButtonVariant.ghost,
              size: AppButtonSize.small,
            ),
          ],
        ),
        ordersAsync.when(
          loading: () => const AppLoading(),
          error: (error, stackTrace) => AppErrorState(
            failure: const UnknownFailure(),
            onRetry: () => ref.invalidate(pendingOrdersProvider),
          ),
          data: (result) => switch (result) {
            Ok(:final value) when value.content.isEmpty => const AppEmptyState(
              message: 'Nenhum pedido pendente no momento.',
            ),
            Ok(:final value) => Column(
              children: [
                for (final order in value.content)
                  PendingOrderTile(
                    order: order,
                    onTap: () => context.push('/orders/${order.id}'),
                  ),
              ],
            ),
            Err(:final failure) => AppErrorState(
              failure: failure,
              onRetry: () => ref.invalidate(pendingOrdersProvider),
            ),
          },
        ),
      ],
    );
  }
}
