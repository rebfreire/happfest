import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest_core/core/error/failure.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_design_system/design_system/components/app_chip.dart';
import 'package:happfest_design_system/design_system/feedback/app_empty_state.dart';
import 'package:happfest_design_system/design_system/feedback/app_error_state.dart';
import 'package:happfest_design_system/design_system/feedback/app_loading.dart';
import 'package:happfest_design_system/design_system/tokens/app_spacing.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order_status.dart';
import 'package:happfest_fornecedor/features/orders/presentation/controllers/orders_providers.dart';
import 'package:happfest_fornecedor/features/orders/presentation/widgets/order_tile.dart';
import 'package:happfest_fornecedor/features/orders/presentation/widgets/sub_order_status_label.dart';

const List<SubOrderStatus?> _filterableStatuses = [
  null,
  SubOrderStatus.pending,
  SubOrderStatus.accepted,
  SubOrderStatus.delivered,
  SubOrderStatus.completed,
  SubOrderStatus.cancelled,
  SubOrderStatus.rejected,
];

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      body: const SafeArea(
        child: Column(
          children: [
            SizedBox(height: AppSpacing.sm),
            _StatusFilterChips(),
            SizedBox(height: AppSpacing.sm),
            Expanded(child: _OrdersList()),
          ],
        ),
      ),
    );
  }
}

class _StatusFilterChips extends ConsumerWidget {
  const _StatusFilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(orderStatusFilterProvider);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: _filterableStatuses.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final status = _filterableStatuses[index];
          return AppChip(
            label: status == null ? 'Todos' : subOrderStatusLabel(status),
            selected: selected == status,
            onSelected: (_) =>
                ref.read(orderStatusFilterProvider.notifier).setStatus(status),
          );
        },
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  const _OrdersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersListProvider);

    return ordersAsync.when(
      loading: () => const AppLoading.skeleton(),
      error: (error, stackTrace) => AppErrorState(
        failure: const UnknownFailure(),
        onRetry: () => ref.invalidate(ordersListProvider),
      ),
      data: (result) => switch (result) {
        Ok(:final value) when value.content.isEmpty => const AppEmptyState(
          message: 'Nenhum pedido encontrado.',
        ),
        Ok(:final value) => ListView.builder(
          itemCount: value.content.length,
          itemBuilder: (context, index) {
            final order = value.content[index];
            return OrderTile(
              order: order,
              onTap: () => context.push('/orders/${order.id}'),
            );
          },
        ),
        Err(:final failure) => AppErrorState(
          failure: failure,
          onRetry: () => ref.invalidate(ordersListProvider),
        ),
      },
    );
  }
}
