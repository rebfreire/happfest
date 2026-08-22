import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/design_system/components/app_badge.dart';
import 'package:happfest/design_system/components/app_card.dart';
import 'package:happfest/design_system/components/app_scaffold.dart';
import 'package:happfest/design_system/feedback/app_error_state.dart';
import 'package:happfest/design_system/feedback/app_loading.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/account/domain/entities/order_detail.dart';
import 'package:happfest/features/account/presentation/controllers/order_detail_provider.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

    return AppScaffold(
      title: 'Pedido',
      body: orderAsync.when(
        loading: () => const AppLoading.skeleton(),
        error: (error, stackTrace) => AppErrorState(
          failure: const UnknownFailure(),
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
        data: (result) => switch (result) {
          Ok(:final value) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total do pedido',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    currency.format(value.totalAmount),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              if (value.createdAt != null)
                Text(
                  'Realizado em '
                  '${DateFormat('dd/MM/yyyy').format(value.createdAt!)}',
                ),
              const SizedBox(height: AppSpacing.lg),
              for (final subOrder in value.subOrders)
                _SubOrderCard(subOrder: subOrder, currency: currency),
            ],
          ),
          Err(:final failure) => AppErrorState(
            failure: failure,
            onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
          ),
        },
      ),
    );
  }
}

class _SubOrderCard extends StatelessWidget {
  const _SubOrderCard({required this.subOrder, required this.currency});

  final SubOrderDetail subOrder;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subOrder.storeName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (subOrder.status != null)
                  AppBadge(label: subOrder.status!.label.toUpperCase()),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final item in subOrder.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('${item.quantity}x ${item.productName}'),
                    ),
                    Text(currency.format(item.lineTotal)),
                  ],
                ),
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal da loja'),
                Text(currency.format(subOrder.subtotal)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
