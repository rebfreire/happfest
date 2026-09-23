import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_preview.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_result.dart';
import 'package:happfest/features/checkout/domain/entities/payment.dart';
import 'package:happfest/features/checkout/domain/entities/payment_method.dart';
import 'package:happfest/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:happfest/features/checkout/domain/usecases/get_payment_status_usecase.dart';
import 'package:happfest/features/checkout/domain/usecases/preview_checkout_usecase.dart';
import 'package:happfest/features/checkout/domain/usecases/submit_checkout_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockCheckoutRepository extends Mock implements CheckoutRepository {}

void main() {
  late _MockCheckoutRepository repository;

  setUpAll(() {
    registerFallbackValue(PaymentMethod.pix);
  });

  setUp(() {
    repository = _MockCheckoutRepository();
  });

  test(
    'PreviewCheckoutUseCase returns the preview from the repository',
    () async {
      const preview = CheckoutPreview(total: 100);
      when(
        () => repository.preview(
          partyId: 'p1',
          paymentMethod: PaymentMethod.pix,
        ),
      ).thenAnswer((_) async => const Ok(preview));

      final result = await PreviewCheckoutUseCase(repository)(
        partyId: 'p1',
        paymentMethod: PaymentMethod.pix,
      );

      expect(result, const Ok(preview));
      verify(
        () => repository.preview(
          partyId: 'p1',
          paymentMethod: PaymentMethod.pix,
        ),
      ).called(1);
    },
  );

  test(
    'SubmitCheckoutUseCase forwards the party/method/idempotency key and '
    'propagates failures',
    () async {
      when(
        () => repository.checkout(
          partyId: any(named: 'partyId'),
          paymentMethod: any(named: 'paymentMethod'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((_) async => const Err(ServerFailure()));

      final result = await SubmitCheckoutUseCase(repository)(
        partyId: 'p1',
        paymentMethod: PaymentMethod.pix,
        idempotencyKey: 'key-1',
      );

      expect(result, isA<Err<CheckoutResult>>());
      verify(
        () => repository.checkout(
          partyId: 'p1',
          paymentMethod: PaymentMethod.pix,
          idempotencyKey: 'key-1',
        ),
      ).called(1);
    },
  );

  test(
    'SubmitCheckoutUseCase reuses the same idempotency key across retries '
    'of the same attempt',
    () async {
      when(
        () => repository.checkout(
          partyId: any(named: 'partyId'),
          paymentMethod: any(named: 'paymentMethod'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((_) async => const Err(NetworkFailure()));

      final usecase = SubmitCheckoutUseCase(repository);
      await usecase(
        partyId: 'p1',
        paymentMethod: PaymentMethod.pix,
        idempotencyKey: 'stable-key',
      );
      await usecase(
        partyId: 'p1',
        paymentMethod: PaymentMethod.pix,
        idempotencyKey: 'stable-key',
      );

      final captured = verify(
        () => repository.checkout(
          partyId: any(named: 'partyId'),
          paymentMethod: any(named: 'paymentMethod'),
          idempotencyKey: captureAny(named: 'idempotencyKey'),
        ),
      ).captured;
      expect(captured, ['stable-key', 'stable-key']);
    },
  );

  test(
    'SubmitCheckoutUseCase surfaces a conflict when the scheduled slot is '
    'no longer available (409)',
    () async {
      when(
        () => repository.checkout(
          partyId: any(named: 'partyId'),
          paymentMethod: any(named: 'paymentMethod'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((_) async => const Err(ConflictFailure()));

      final result = await SubmitCheckoutUseCase(repository)(
        partyId: 'p1',
        paymentMethod: PaymentMethod.pix,
        idempotencyKey: 'key-1',
      );

      expect(result, isA<Err<CheckoutResult>>());
      expect((result as Err<CheckoutResult>).failure, isA<ConflictFailure>());
    },
  );

  test(
    'GetPaymentStatusUseCase returns the payment from the repository',
    () async {
      const payment = Payment(id: 'pay1', status: PaymentStatus.pending);
      when(
        () => repository.getPaymentStatus('order1'),
      ).thenAnswer((_) async => const Ok(payment));

      final result = await GetPaymentStatusUseCase(repository)('order1');

      expect(result, const Ok(payment));
    },
  );

  group('Payment terminal states', () {
    for (final status in [
      PaymentStatus.approved,
      PaymentStatus.failed,
      PaymentStatus.cancelled,
      PaymentStatus.partiallyRefunded,
      PaymentStatus.refunded,
      PaymentStatus.chargeback,
    ]) {
      test('$status is terminal', () {
        expect(Payment(id: 'p', status: status).isTerminal, isTrue);
      });
    }

    test('pending is not terminal', () {
      const payment = Payment(id: 'p', status: PaymentStatus.pending);
      expect(payment.isTerminal, isFalse);
    });
  });

  group('Payment action per method', () {
    test('PIX action exposes copy-paste payload', () {
      const payment = Payment(
        id: 'p',
        status: PaymentStatus.pending,
        action: PaymentAction(
          type: PaymentActionType.pix,
          pixCopyPaste: '00020126...',
        ),
      );
      expect(payment.hasAction, isTrue);
      expect(payment.action!.type, PaymentActionType.pix);
    });

    test('BOLETO action exposes identification field and PDF url', () {
      const payment = Payment(
        id: 'p',
        status: PaymentStatus.pending,
        action: PaymentAction(
          type: PaymentActionType.boleto,
          boletoIdentificationField: '34191...',
          boletoPdfUrl: 'https://example.com/boleto.pdf',
        ),
      );
      expect(payment.action!.boletoPdfUrl, isNotNull);
    });

    test('CREDIT_CARD (HOSTED_REDIRECT) action exposes the checkout url', () {
      const payment = Payment(
        id: 'p',
        status: PaymentStatus.pending,
        action: PaymentAction(
          type: PaymentActionType.hostedRedirect,
          url: 'https://checkout.example.com/session',
        ),
      );
      expect(payment.action!.url, isNotNull);
    });

    test('no action yet keeps hasAction false', () {
      const payment = Payment(id: 'p', status: PaymentStatus.pending);
      expect(payment.hasAction, isFalse);
    });
  });
}
