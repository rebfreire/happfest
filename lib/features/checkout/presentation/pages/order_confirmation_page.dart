import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/design_system/components/app_button.dart';
import 'package:happfest/design_system/components/app_scaffold.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_result.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({required this.result, super.key});

  final CheckoutResult result;

  Future<void> _openPaymentLink(BuildContext context) async {
    final link = result.paymentLink;
    if (link == null) return;
    final uri = Uri.tryParse(link);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o link de pagamento.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
    final failed = result.paymentStatus == PaymentStatus.failed;

    return AppScaffold(
      title: 'Pedido realizado',
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              failed ? Icons.error_outline : Icons.check_circle_outline,
              size: 64,
              color: failed
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              failed
                  ? 'Não foi possível concluir o pagamento'
                  : 'Pedido confirmado!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              currency.format(result.orderTotal),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (result.failureReason != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(result.failureReason!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: AppSpacing.lg),
            if (result.paymentLink != null)
              AppButton.confirm(
                label: 'Abrir pagamento',
                expanded: true,
                onPressed: () => _openPaymentLink(context),
              ),
            const SizedBox(height: AppSpacing.sm),
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
