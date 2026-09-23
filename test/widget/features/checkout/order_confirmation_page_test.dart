import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/design_system/theme/app_theme.dart';
import 'package:happfest/features/checkout/data/checkout_providers.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_preview.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_result.dart';
import 'package:happfest/features/checkout/domain/entities/payment.dart';
import 'package:happfest/features/checkout/domain/entities/payment_method.dart';
import 'package:happfest/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:happfest/features/checkout/domain/usecases/get_payment_status_usecase.dart';
import 'package:happfest/features/checkout/presentation/pages/order_confirmation_page.dart';
import 'package:happfest/l10n/generated/app_localizations.dart';

class _StubCheckoutRepository implements CheckoutRepository {
  _StubCheckoutRepository(this.responses);

  final List<Payment> responses;
  var _calls = 0;

  @override
  Future<Result<Payment>> getPaymentStatus(String orderId) async {
    final payment = responses[_calls.clamp(0, responses.length - 1)];
    _calls++;
    return Ok(payment);
  }

  @override
  Future<Result<CheckoutResult>> checkout({
    required String partyId,
    required PaymentMethod paymentMethod,
    required String idempotencyKey,
    double? useBalanceAmount,
  }) => throw UnimplementedError();

  @override
  Future<Result<CheckoutPreview>> preview({
    required String partyId,
    PaymentMethod? paymentMethod,
  }) => throw UnimplementedError();
}

Widget _wrap(CheckoutResult result, _StubCheckoutRepository repository) {
  return ProviderScope(
    overrides: [
      getPaymentStatusUseCaseProvider.overrideWithValue(
        GetPaymentStatusUseCase(repository),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: OrderConfirmationPage(result: result),
    ),
  );
}

void main() {
  testWidgets(
    'polls GET /payments/order/{orderId} every ~10s until a payment '
    'action becomes available, then stops',
    (tester) async {
      const result = CheckoutResult(
        orderId: 'order-1',
        orderTotal: 250,
        paymentProcessingAsync: true,
      );
      final repository = _StubCheckoutRepository([
        const Payment(id: 'pay-1', status: PaymentStatus.pending),
        const Payment(
          id: 'pay-1',
          status: PaymentStatus.pending,
          action: PaymentAction(
            type: PaymentActionType.pix,
            pixCopyPaste: '00020126...',
          ),
        ),
      ]);

      await tester.pumpWidget(_wrap(result, repository));
      await tester.pump();
      expect(
        find.text('Preparando instruções de pagamento...'),
        findsOneWidget,
      );

      // First tick: still PENDING with no action yet — keeps polling.
      await tester.pump(const Duration(seconds: 10));
      await tester.pump();
      expect(
        find.text('Preparando instruções de pagamento...'),
        findsOneWidget,
      );

      // Second tick: an action becomes available — polling stops here.
      await tester.pump(const Duration(seconds: 10));
      await tester.pump();
      expect(find.text('Pix copia e cola'), findsOneWidget);

      // No further calls should happen once an action is shown — the
      // widget cancels its own timer.
      await tester.pump(const Duration(seconds: 10));
      expect(repository._calls, 2);
    },
  );

  testWidgets('stops polling once a terminal state (APPROVED) is reached', (
    tester,
  ) async {
    const result = CheckoutResult(orderId: 'order-2', orderTotal: 100);
    final repository = _StubCheckoutRepository([
      const Payment(id: 'pay-2', status: PaymentStatus.approved),
    ]);

    await tester.pumpWidget(_wrap(result, repository));
    await tester.pump();
    await tester.pump(const Duration(seconds: 10));
    await tester.pump();

    expect(find.text('Pedido confirmado!'), findsOneWidget);
  });
}
