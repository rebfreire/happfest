import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest_core/core/error/failure.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_design_system/design_system/components/app_button.dart';
import 'package:happfest_design_system/design_system/feedback/app_dialog.dart';
import 'package:happfest_design_system/design_system/feedback/app_error_state.dart';
import 'package:happfest_design_system/design_system/feedback/app_loading.dart';
import 'package:happfest_design_system/design_system/feedback/app_snackbar.dart';
import 'package:happfest_design_system/design_system/tokens/app_spacing.dart';
import 'package:happfest_fornecedor/features/orders/data/orders_providers.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order_status.dart';
import 'package:happfest_fornecedor/features/orders/presentation/controllers/orders_providers.dart';
import 'package:happfest_fornecedor/features/orders/presentation/widgets/sub_order_status_label.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  const OrderDetailPage({required this.orderId, super.key});

  final String orderId;

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  bool _isProcessing = false;

  Future<void> _runAction(Future<Result<void>> Function() action) async {
    setState(() => _isProcessing = true);
    final result = await action();
    if (!mounted) return;
    setState(() => _isProcessing = false);

    switch (result) {
      case Ok():
        ref
          ..invalidate(orderDetailProvider(widget.orderId))
          ..invalidate(ordersListProvider);
        if (mounted) context.go('/orders');
      case Err(:final failure):
        if (mounted) AppSnackbar.error(context, failure.message);
    }
  }

  Future<void> _accept() {
    return _runAction(
      () => ref.read(acceptOrderUseCaseProvider)(widget.orderId),
    );
  }

  Future<void> _reject() async {
    final confirmed = await AppDialog.destructive(
      context,
      title: 'Recusar pedido',
      message: 'Tem certeza que deseja recusar este pedido?',
      confirmLabel: 'Recusar',
    );
    if (!confirmed) return;
    await _runAction(
      () => ref.read(rejectOrderUseCaseProvider)(widget.orderId),
    );
  }

  Future<void> _deliver() {
    return _runAction(
      () => ref.read(deliverOrderUseCaseProvider)(widget.orderId),
    );
  }

  Future<void> _cancel() async {
    final confirmed = await AppDialog.destructive(
      context,
      title: 'Cancelar pedido',
      message: 'Tem certeza que deseja cancelar este pedido?',
      confirmLabel: 'Cancelar pedido',
    );
    if (!confirmed) return;
    await _runAction(
      () => ref.read(cancelOrderUseCaseProvider)(widget.orderId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do pedido')),
      body: SafeArea(
        child: orderAsync.when(
          loading: () => const AppLoading(),
          error: (error, stackTrace) => AppErrorState(
            failure: const UnknownFailure(),
            onRetry: () => ref.invalidate(orderDetailProvider(widget.orderId)),
          ),
          data: (result) => switch (result) {
            Ok(:final value) => _OrderDetailBody(
              order: value,
              isProcessing: _isProcessing,
              onAccept: _accept,
              onReject: _reject,
              onDeliver: _deliver,
              onCancel: _cancel,
            ),
            Err(:final failure) => AppErrorState(
              failure: failure,
              onRetry: () =>
                  ref.invalidate(orderDetailProvider(widget.orderId)),
            ),
          },
        ),
      ),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  const _OrderDetailBody({
    required this.order,
    required this.isProcessing,
    required this.onAccept,
    required this.onReject,
    required this.onDeliver,
    required this.onCancel,
  });

  final SubOrder order;
  final bool isProcessing;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onDeliver;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          'Pedido #${order.id.substring(0, 8)}',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          subOrderStatusLabel(order.status),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (order.deliveryStreet != null) ...[
          Text('Entrega', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(_deliveryAddress(order)),
          if (order.deliveryDate != null) Text(_deliveryWhen(order)),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text('Itens', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        for (final item in order.items)
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
        const Divider(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Você recebe', style: theme.textTheme.titleMedium),
            Text(
              currency.format(order.supplierAmount),
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        if (order.cancellationReason != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text('Motivo do cancelamento', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(order.cancellationReason!),
        ],
        const SizedBox(height: AppSpacing.xl),
        ..._actionsFor(order.status),
      ],
    );
  }

  List<Widget> _actionsFor(SubOrderStatus status) {
    return switch (status) {
      SubOrderStatus.pending => [
        AppButton.confirm(
          label: 'Aceitar pedido',
          onPressed: isProcessing ? null : onAccept,
          isLoading: isProcessing,
          expanded: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: AppButton.delete(
            label: 'Recusar',
            onPressed: isProcessing ? null : onReject,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: AppButton.cancel(
            label: 'Cancelar pedido',
            onPressed: isProcessing ? null : onCancel,
          ),
        ),
      ],
      SubOrderStatus.accepted => [
        AppButton.confirm(
          label: 'Marcar como entregue',
          onPressed: isProcessing ? null : onDeliver,
          isLoading: isProcessing,
          expanded: true,
        ),
      ],
      _ => const [],
    };
  }
}

String _deliveryAddress(SubOrder order) {
  final parts = [
    '${order.deliveryStreet}, ${order.deliveryNumber ?? 's/n'}',
    if (order.deliveryNeighborhood != null) order.deliveryNeighborhood!,
    if (order.deliveryCityName != null) order.deliveryCityName!,
  ];
  return parts.join(' — ');
}

String _deliveryWhen(SubOrder order) {
  final date = DateFormat('dd/MM/yyyy').format(order.deliveryDate!);
  final time = order.deliveryTime;
  return 'Data: $date${time != null ? ' às $time' : ''}';
}
