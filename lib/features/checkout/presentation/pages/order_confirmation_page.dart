import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/design_system/components/app_button.dart';
import 'package:happfest/design_system/components/app_scaffold.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/checkout/data/checkout_providers.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_result.dart';
import 'package:happfest/features/checkout/domain/entities/payment.dart';
import 'package:happfest/features/checkout/presentation/widgets/payment_action_view.dart';
import 'package:intl/intl.dart';

/// Acompanha o pagamento após `POST /orders/checkout` até um estado
/// terminal ou uma ação disponível — o checkout é assíncrono, então a
/// resposta inicial pode vir sem `payment` ou com `status: PENDING` e
/// nenhuma ação ainda. Faz polling em `GET /payments/order/{orderId}` a
/// cada ~10s, respeitando `expiresAt` — ver `docs/progress/11-checkout.md`.
class OrderConfirmationPage extends ConsumerStatefulWidget {
  const OrderConfirmationPage({required this.result, super.key});

  final CheckoutResult result;

  @override
  ConsumerState<OrderConfirmationPage> createState() =>
      _OrderConfirmationPageState();
}

class _OrderConfirmationPageState
    extends ConsumerState<OrderConfirmationPage> {
  Timer? _pollTimer;
  Payment? _payment;
  var _expired = false;

  @override
  void initState() {
    super.initState();
    _payment = widget.result.payment;
    _maybeStartPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  bool get _needsPolling {
    final payment = _payment;
    if (payment == null) return true;
    if (payment.isTerminal) return false;
    if (payment.hasAction) return false;
    return true;
  }

  void _maybeStartPolling() {
    if (!_needsPolling) return;
    final expiresAt = _payment?.expiresAt;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      setState(() => _expired = true);
      return;
    }
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _refreshStatus(),
    );
  }

  Future<void> _refreshStatus() async {
    final orderId = widget.result.orderId;
    if (orderId == null) return;

    final expiresAt = _payment?.expiresAt;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      _pollTimer?.cancel();
      if (mounted) setState(() => _expired = true);
      return;
    }

    final result = await ref.read(getPaymentStatusUseCaseProvider)(orderId);
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        setState(() => _payment = value);
        if (value.isTerminal || value.hasAction) {
          _pollTimer?.cancel();
        }
      case Err():
        // Falha transitória na consulta — mantém o polling tentando de novo
        // no próximo tick em vez de travar a tela num erro.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
    final payment = _payment;
    final failed =
        payment?.status != null &&
        payment!.isTerminal &&
        payment.status != PaymentStatus.approved;
    final approved = payment?.status == PaymentStatus.approved;

    return AppScaffold(
      title: 'Pedido realizado',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(
              failed
                  ? Icons.error_outline
                  : approved
                  ? Icons.check_circle_outline
                  : Icons.hourglass_top_outlined,
              size: 64,
              color: failed
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              failed
                  ? 'Não foi possível concluir o pagamento'
                  : approved
                  ? 'Pedido confirmado!'
                  : 'Pedido recebido!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              currency.format(widget.result.orderTotal),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (payment?.failureReason != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(payment!.failureReason!, textAlign: TextAlign.center),
            ],
            if (_expired) ...[
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'O prazo para pagamento expirou. Volte ao carrinho para '
                'tentar novamente.',
                textAlign: TextAlign.center,
              ),
            ] else if (!failed && payment != null) ...[
              const SizedBox(height: AppSpacing.lg),
              PaymentActionView(
                payment: payment,
                onReturnFromHostedCheckout: _refreshStatus,
              ),
            ] else if (!failed && payment == null) ...[
              const SizedBox(height: AppSpacing.lg),
              const _PreparingIndicator(),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Voltar para a Home',
              variant: AppButtonVariant.tertiary,
              expanded: true,
              onPressed: () => context.go('/'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreparingIndicator extends StatelessWidget {
  const _PreparingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(height: AppSpacing.sm),
        Text('Preparando instruções de pagamento...'),
      ],
    );
  }
}
