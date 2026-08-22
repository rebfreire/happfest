import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/design_system/components/app_button.dart';
import 'package:happfest/design_system/components/app_card.dart';
import 'package:happfest/design_system/components/app_form_fields.dart';
import 'package:happfest/design_system/feedback/app_error_state.dart';
import 'package:happfest/design_system/feedback/app_loading.dart';
import 'package:happfest/design_system/feedback/app_snackbar.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/cart/presentation/controllers/cart_providers.dart';
import 'package:happfest/features/checkout/data/checkout_providers.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_preview.dart';
import 'package:happfest/features/checkout/domain/entities/payment_method.dart';
import 'package:happfest/features/checkout/presentation/controllers/checkout_flow_controller.dart';
import 'package:happfest/features/checkout/presentation/controllers/checkout_preview_provider.dart';
import 'package:intl/intl.dart';

class CheckoutResumoStep extends ConsumerStatefulWidget {
  const CheckoutResumoStep({super.key});

  @override
  ConsumerState<CheckoutResumoStep> createState() => _CheckoutResumoStepState();
}

class _CheckoutResumoStepState extends ConsumerState<CheckoutResumoStep> {
  PaymentMethod _paymentMethod = PaymentMethod.pix;
  var _isSubmitting = false;

  Future<void> _submit(String partyId) async {
    setState(() => _isSubmitting = true);
    final result = await ref.read(submitCheckoutUseCaseProvider)(
      partyId: partyId,
      paymentMethod: _paymentMethod,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Ok(:final value):
        ref
          ..invalidate(cartProvider)
          ..read(checkoutFlowProvider.notifier).reset();
        context.go('/pedido/confirmacao', extra: value);
      case Err(:final failure):
        AppSnackbar.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final party = ref.watch(checkoutFlowProvider).selectedParty;
    if (party == null) {
      return const AppErrorState(
        failure: UnknownFailure('Selecione uma festa antes de continuar.'),
      );
    }

    final previewAsync = ref.watch(checkoutPreviewProvider(party.id));
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

    return previewAsync.when(
      loading: () => const AppLoading.skeleton(),
      error: (error, stackTrace) => AppErrorState(
        failure: const UnknownFailure(),
        onRetry: () => ref.invalidate(checkoutPreviewProvider(party.id)),
      ),
      data: (result) => switch (result) {
        Ok(:final value) => _ResumoContent(
          preview: value,
          currency: currency,
          paymentMethod: _paymentMethod,
          isSubmitting: _isSubmitting,
          onPaymentMethodChanged: (method) =>
              setState(() => _paymentMethod = method ?? _paymentMethod),
          onSubmit: () => _submit(party.id),
        ),
        Err(:final failure) => AppErrorState(
          failure: failure,
          onRetry: () => ref.invalidate(checkoutPreviewProvider(party.id)),
        ),
      },
    );
  }
}

class _ResumoContent extends StatelessWidget {
  const _ResumoContent({
    required this.preview,
    required this.currency,
    required this.paymentMethod,
    required this.isSubmitting,
    required this.onPaymentMethodChanged,
    required this.onSubmit,
  });

  final CheckoutPreview preview;
  final NumberFormat currency;
  final PaymentMethod paymentMethod;
  final bool isSubmitting;
  final ValueChanged<PaymentMethod?> onPaymentMethodChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              for (final store in preview.stores)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.storeName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text('${store.itemCount} item(ns)'),
                        const SizedBox(height: AppSpacing.xs),
                        Text(currency.format(store.subtotal)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Forma de pagamento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              AppRadioGroup<PaymentMethod>(
                value: paymentMethod,
                options: {
                  for (final method in PaymentMethod.values)
                    method: method.label,
                },
                onChanged: onPaymentMethodChanged,
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      currency.format(preview.total),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton.confirm(
                  label: 'Confirmar pedido',
                  expanded: true,
                  isLoading: isSubmitting,
                  onPressed: isSubmitting ? null : onSubmit,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
