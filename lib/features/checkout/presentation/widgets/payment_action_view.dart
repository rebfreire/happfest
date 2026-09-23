import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:happfest/design_system/components/app_button.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/checkout/domain/entities/payment.dart';
import 'package:happfest/features/checkout/presentation/pages/hosted_checkout_page.dart'
    show HostedCheckoutPage;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renderiza a instrução de pagamento de acordo com `payment.action.type` —
/// ver seção 3 do contrato de integração em `docs/progress/11-checkout.md`.
class PaymentActionView extends StatelessWidget {
  const PaymentActionView({
    required this.payment,
    this.onReturnFromHostedCheckout,
    super.key,
  });

  final Payment payment;

  /// Chamado quando a tela de checkout hospedado fecha (ver
  /// `HostedCheckoutPage`), para disparar uma consulta imediata a
  /// `GET /payments/order/{orderId}` em vez de esperar o próximo tick do
  /// polling.
  final VoidCallback? onReturnFromHostedCheckout;

  @override
  Widget build(BuildContext context) {
    final action = payment.action;
    final type = action?.type ?? PaymentActionType.none;

    return switch (type) {
      PaymentActionType.pix => _PixAction(action: action!),
      PaymentActionType.boleto => _BoletoAction(action: action!),
      PaymentActionType.hostedRedirect => _HostedRedirectAction(
        action: action!,
        orderId: payment.orderId,
        onReturn: onReturnFromHostedCheckout,
      ),
      PaymentActionType.none => const _PreparingAction(),
    };
  }
}

class _PreparingAction extends StatelessWidget {
  const _PreparingAction();

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

class _PixAction extends StatelessWidget {
  const _PixAction({required this.action});

  final PaymentAction action;

  @override
  Widget build(BuildContext context) {
    final code = action.pixCopyPaste;
    return Column(
      children: [
        if (code != null && code.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: QrImageView(data: code, size: 200),
          ),
        const SizedBox(height: AppSpacing.md),
        if (code != null && code.isNotEmpty) ...[
          Text(
            'Pix copia e cola',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(code, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Copiar código',
            variant: AppButtonVariant.tertiary,
            expanded: true,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código copiado.')),
                );
              }
            },
          ),
        ],
        if (action.expiresAt != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Expira em ${_formatExpiry(action.expiresAt!)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _BoletoAction extends StatelessWidget {
  const _BoletoAction({required this.action});

  final PaymentAction action;

  Future<void> _openBoleto(BuildContext context) async {
    final url = action.boletoPdfUrl;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final code = action.boletoIdentificationField;
    return Column(
      children: [
        if (code != null && code.isNotEmpty) ...[
          Text(
            'Linha digitável',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(code, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (action.boletoPdfUrl != null)
          AppButton.confirm(
            label: 'Abrir boleto',
            expanded: true,
            onPressed: () => _openBoleto(context),
          ),
        if (action.expiresAt != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Vencimento em ${_formatExpiry(action.expiresAt!)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _HostedRedirectAction extends StatelessWidget {
  const _HostedRedirectAction({
    required this.action,
    required this.orderId,
    this.onReturn,
  });

  final PaymentAction action;
  final String? orderId;
  final VoidCallback? onReturn;

  Future<void> _open(BuildContext context) async {
    final url = action.url;
    final order = orderId;
    if (url == null || order == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => HostedCheckoutPage(url: url, orderId: order),
      ),
    );
    onReturn?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Seus dados de pagamento são preenchidos direto no ambiente '
          'seguro da operadora — o app nunca coleta dados de cartão.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton.confirm(
          label: 'Ir para pagamento seguro',
          expanded: true,
          onPressed: () => _open(context),
        ),
      ],
    );
  }
}

String _formatExpiry(DateTime dateTime) {
  final local = dateTime.toLocal();
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')} às $hh:$mm';
}
